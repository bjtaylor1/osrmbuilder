require("lualib/whitelist")
require("lualib/blacklist")
require("luaspecifics/touristb")

restriction_exception_tags = { "motorcar", "motor_vehicle", "vehicle" }
access_tags_hierachy = { "motorcar", "motor_vehicle", "vehicle", "access" }
barrier_whitelist = { ["cattle_grid"] = true, ["border_control"] = true, ["checkpoint"] = true, ["toll_booth"] = true, ["sally_port"] = true, ["gate"] = true, ["no"] = true, ["entrance"] = true, ["lift_gate"] = true }
access_tag_blacklist = { ["no"] = true, ["private"] = true, ["agricultural"] = true, ["forestry"] = true, ["emergency"] = true }

-- Open PostGIS connection
lua_sql = require "luasql.postgres"           -- we will connect to a postgresql database
sql_env = assert( lua_sql.postgres() )
sql_con = assert( sql_env:connect("osm", "osm", "osm") ) -- you can add db user/password here if needed
print("PostGIS connection opened")


maxspeed_table_default = {
  ["urban"] = 50,
  ["rural"] = 90,
  ["trunk"] = 110,
  ["motorway"] = 130
}

-- List only exceptions
maxspeed_table = {
  ["ch:rural"] = 80,
  ["ch:trunk"] = 100,
  ["ch:motorway"] = 120,
  ["de:living_street"] = 7,
  ["ru:living_street"] = 20,
  ["ru:urban"] = 60,
  ["ua:urban"] = 60,
  ["at:rural"] = 100,
  ["de:rural"] = 100,
  ["at:trunk"] = 100,
  ["cz:trunk"] = 0,
  ["ro:trunk"] = 100,
  ["cz:motorway"] = 0,
  ["de:motorway"] = 0,
  ["ru:motorway"] = 110,
  ["gb:nsl_single"] = (60*1609)/1000,
  ["gb:nsl_dual"] = (70*1609)/1000,
  ["gb:motorway"] = (70*1609)/1000,
  ["uk:nsl_single"] = (60*1609)/1000,
  ["uk:nsl_dual"] = (70*1609)/1000,
  ["uk:motorway"] = (70*1609)/1000
}
local obey_oneway = true


function way_function(way, result)
  result.forward_mode = mode.driving
  result.backward_mode = mode.driving

	  -- check if oneway tag is unsupported
  local oneway = way:get_value_by_key("oneway")
	local highway = way:get_value_by_key("highway")

  if oneway and "reversible" == oneway then
    return
  end
  -- Set direction according to tags on way
  if obey_oneway then
    if oneway == "-1" then
      result.forward_mode = 0
    elseif oneway == "yes" or
    oneway == "1" or
    oneway == "true" or
    junction == "roundabout" or
    (highway == "motorway_link" and oneway ~="no") or
    (highway == "motorway" and oneway ~= "no") then
      result.backward_mode = 0
    end
  end
	local thespeed = get_speed(way)

	if thespeed ~= nil and thespeed > 0 then
		local wayid = way:id()
		local sql_query = "select score  from urbannessscores where osm_id = "..wayid

--		print("running sql:"..sql_query)

		local cursor = assert(sql_con:execute(sql_query))
		local row = cursor:fetch( {}, "a")
		if row then
			local score = tonumber(row.score)

			if score ~= nil then
				local thenewspeed = thespeed * score
				thespeed = thenewspeed
			end
	
		end
		cursor:close()
	end


	result.forward_speed = thespeed
	result.backward_speed = thespeed

end

function get_speed (way)
local wayid = way:id()

	local highway = way:get_value_by_key("highway")
  local junction = way:get_value_by_key("junction")
  local thespeed = -1

	local specificspeed=touristb.get_specific_speed(way)
	if(0 ~= specificspeed) then
		return specificspeed
	end

--special ways override everything else and we can go max (unclassified) speed on them
--print("whitelist = "..Whitelist.whitelist_way_by_id[wayid])

  if(Whitelist.whitelist_ways_by_id[wayid]) then
	print("whitelisted "..wayid.." - returning "..touristb.whitelist_speed)
	return touristb.whitelist_speed
  end

  if(Blacklist.blacklist_ways_by_id[wayid]) then
    return -1
  end

  if "motorway" == highway then
  	return -1
  end
  
  if "motorway_junction" == highway then
  	return -1
  end


	local max_speed = parse_maxspeed( way:get_value_by_key("maxspeed") )

  if max_speed ~= nil and max_speed >= 112 and "roundabout" ~= junction then --112 = 70 mph
    return -1
  end

  -- Set the avg speed on the way if it is accessible by road class
  if (touristb.speed_profile[highway] ~= nil ) then
      return touristb.speed_profile[highway]
	else
		return -1
  end

end

-- These are wrappers to parse vectors of nodes and ways and thus to speed up any tracing JIT
function node_vector_function(vector)
  for v in vector.nodes do
    node_function(v)
  end
end

local function find_access_tag(source)
  for i,v in ipairs(access_tags_hierachy) do
    local access_tag = source:get_value_by_key(v)
    if access_tag and "" ~= access_tag then
      return access_tag
    end
  end
  return ""
end

function node_function (node, result)
  -- parse access and barrier tags
  local access = find_access_tag(node)
  if access ~= "" then
    if access_tag_blacklist[access] then
      result.barrier = true
    end
  else
    local barrier = node:get_value_by_key("barrier")
    if barrier and "" ~= barrier then
      if barrier_whitelist[barrier] then
        return
      else
        result.barrier = true
      end
    end
  end

  -- check if node is a traffic light
  local tag = node:get_value_by_key("highway")
  if tag and "traffic_signals" == tag then
    result.traffic_lights = true;
  end
end


function get_exceptions(vector)
  for i,v in ipairs(restriction_exception_tags) do
    vector:Add(v)
  end
end



function parse_maxspeed(source)
  if not source then
    return 0
  end
  local n = tonumber(source:match("%d*"))
  if n then
    if string.match(source, "mph") or string.match(source, "mp/h") then
      n = (n*1609)/1000;
    end
  else
    -- parse maxspeed like FR:urban
    source = string.lower(source)
    n = maxspeed_table[source]
    if not n then
      local highway_type = string.match(source, "%a%a:(%a+)")
      n = maxspeed_table_default[highway_type]
      if not n then
        n = 0
      end
    end
  end
  return n
end



turn_penalty = 60
turn_bias      = 1.4

function turn_function (angle)
--		if angle > 75 or angle < -75 then
--			return 350
--		elseif angle > 45 or angle < -45 then
--			return 200
--		else
			return 0 
--		end
end

function turn_function_alt(angle)
    -- compute turn penalty as angle^2, with a left/right bias
    k = turn_penalty/(90.0*90.0)
		local result=0
    if angle>=0 then
        result = angle*angle*k/turn_bias
    else
        result = angle*angle*k*turn_bias
    end
--	print ("turn_function, angle="..angle..", result="..result)
	return result * 10
end


