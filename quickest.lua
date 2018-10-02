-- Bicycle profile

api_version = 4

Set = require('lib/set')
Sequence = require('lib/sequence')
Handlers = require("lib/way_handlers")
find_access_tag = require("lib/access").find_access_tag
limit = require("lib/maxspeed").limit
require("lualib/surfacewhitelist")

function setup()

  local raster_path = os.getenv("OSRM_RASTER_SOURCE") 

  local default_speed = 15
  local walking_speed = 4

  return {
    properties = {
      u_turn_penalty                = 20,
      traffic_light_penalty         = 150,
      weight_name                   = 'cyclability',
--      weight_name                   = 'duration',
      process_call_tagless_node     = false,
      max_speed_for_map_matching    = 110/3.6, -- kmph -> m/s
      use_turn_restrictions         = false,
      continue_straight_at_waypoint = false,
      mode_change_penalty           = 30,
      highway_change_penalty        = 100, --it is not worth turning off a highway onto a residential to avoid one traffic light.
                                                -- ...but it might be worth it to avoid two or more!
      onto_primary_penalty          = 100, -- test 'off and on again' phenonenon on A9 (Golspie/Brora/Helmsdale/Dunbeath)
      static_turn_cost              = 0,  -- extra penalty for every turn. abstract way of favouring rural routes.
      force_split_edges = true,
      process_call_tagless_node = false
    },

    raster_sources = {
        raster_35_03 = raster:load(raster_path..'srtm_35_03.asc', -10, -5, 45, 50, 6001, 6001),
        raster_36_03 = raster:load(raster_path..'srtm_36_03.asc',  -5,  0, 45, 50, 6001, 6001),
	raster_34_02 = raster:load(raster_path..'srtm_34_02.asc', -15,-10, 50, 55, 6001, 6001 ),
        raster_35_02 = raster:load(raster_path..'srtm_35_02.asc', -10, -5, 50, 55, 6001, 6001),
        raster_36_02 = raster:load(raster_path..'srtm_36_02.asc',  -5,  0, 50, 55, 6001, 6001),
        raster_37_02 = raster:load(raster_path..'srtm_37_02.asc',   0,  5, 50, 55, 6001, 6001),
        raster_34_01 = raster:load(raster_path..'srtm_34_01.asc', -15, -10,55, 60, 6001, 6001),
        raster_35_01 = raster:load(raster_path..'srtm_35_01.asc', -10, -5, 55, 60, 6001, 6001),
        raster_36_01 = raster:load(raster_path..'srtm_36_01.asc', -5,  0,  55, 60, 6001, 6001),
        raster_37_01 = raster:load(raster_path..'srtm_37_01.asc',  0,  5,  55, 60, 6001, 6001)   
    },

    default_mode              = mode.cycling,
    default_speed             = default_speed,
    walking_speed             = walking_speed,
    oneway_handling           = true,
    turn_penalty              = 6,
    turn_bias                 = 1.4,
    use_public_transport      = true,

    allowed_start_modes = Set {
      mode.cycling,
      mode.pushing_bike
    },

    barrier_blacklist = Set {
      'yes',
      'wall',
      'fence'
    },

    access_tag_whitelist = Set {
      'yes',
      'permissive',
      'designated'
    },

    access_tag_blacklist = Set {
      'no',
      'private',
      'agricultural',
      'forestry',
      'delivery'
    },

    restricted_access_tag_list = Set { },

    restricted_highway_whitelist = Set { },

    -- tags disallow access to in combination with highway=service
    service_access_tag_blacklist = Set { },

    construction_whitelist = Set {
      'no',
      'widening',
      'minor',
    },

    access_tags_hierarchy = Sequence {
      'bicycle',
      'vehicle',
      'access'
    },

    restrictions = Set {
      'bicycle'
    },

    cycleway_tags = Set {
      'track',
      'lane',
      'share_busway',
      'sharrow',
      'shared',
      'shared_lane'
    },

    opposite_cycleway_tags = Set {
      'opposite',
      'opposite_lane',
      'opposite_track',
    },

    -- reduce the driving speed by 30% for unsafe roads
    -- only used for cyclability metric
    unsafe_highway_list = {
--      trunk = 0.80,
--      primary = 0.80,
--      secondary = 0.65,
--      tertiary = 0.8,
--      primary_link = 0.8
--      secondary_link = 0.65,
--      tertiary_link = 0.8,
    },

    service_penalties = {
      alley             = 0.5,
    },

    bicycle_speeds = {
      cycleway = default_speed,
      trunk = default_speed, -- but there shouldn't be any trunks
      primary = default_speed ,
      primary_link = default_speed,
      secondary = default_speed * (5.0/4.0),
      secondary_link = default_speed,
      tertiary = default_speed,
      tertiary_link = default_speed,
      residential = default_speed * (2.0/3.0),
      unclassified = default_speed * (4.0/5.0),
      living_street = default_speed * (2.0/3.0),
      road = default_speed,
      track = default_speed,
      path = default_speed
--      service = default_speed
    },


    is_road = Sequence {
        motorway        = true,
        motorway_link   = true,
        trunk           = true,
        trunk_link      = true,
        primary         = true,
        primary_link    = true,
        secondary       = true,
        secondary_link  = true,
        tertiary        = true,
        tertiary_link   = true,
        unclassified    = true,
        residential     = true,
        living_street   = true
--        service = true
    },

    pedestrian_speeds = {
      footway = walking_speed,
      pedestrian = walking_speed,
      steps = 2
    },

    railway_speeds = {
      train = 10,
      railway = 10,
      subway = 10,
      light_rail = 10,
      monorail = 10,
      tram = 10
    },

    platform_speeds = {
      platform = walking_speed
    },

    amenity_speeds = {
      parking = 10,
      parking_entrance = 10
    },

    man_made_speeds = {
      pier = walking_speed
    },

    route_speeds = {
      --ferry = 5
    },

    --bridge_speeds = {
    --  movable = default_speed
    --},

    surface_speeds = {
      asphalt = default_speed,
      ["cobblestone:flattened"] = default_speed,
      paving_stones = default_speed,
      compacted = 0,
      cobblestone = 0,
      unpaved = 0,
      fine_gravel = 0,
      gravel = 0,
      pebblestone = 0,
      ground = 0,
      dirt = 0,
      earth = 0,
      grass = 0,
      mud = 0,
      sand = 0,
      sett = 0
    },

    classes = Sequence {
        'ferry', 'tunnel'
    },

    -- Which classes should be excludable
    -- This increases memory usage so its disabled by default.
    excludable = Sequence {
--        Set {'ferry'}
    },

    tracktype_speeds = {
    },

    smoothness_speeds = {
    },

    avoid = Set {
      'impassable',
      'construction'
    }, 

    highway_turn_classification = {
      ['trunk'] = 1,
      ['primary'] = 1,
      ['trunk_link'] = 2,
      ['primary_link'] = 2,
      ['secondary'] = 3,
      ['secondary_link'] = 3,
      ['tertiary'] = 4,
      ['tertiary_link'] = 4,
      ['unclassified'] = 5,
      ['cycleway'] = 6, 
      ['track'] = 7,
      ['residential'] = 8, -- turning off <= 7 to >= 8 incurs penalty
      ['living_street'] = 10,
      ['footway'] = 11,
      ['path'] = 12,
      ['pedestrian'] = 13,
    },

    access_turn_classification = {}
  }
end

local function parse_maxspeed(source)
    if not source then
        return 0
    end
    local n = tonumber(source:match("%d*"))
    if not n then
        n = 0
    end
    if string.match(source, "mph") or string.match(source, "mp/h") then
        n = (n*1609)/1000
    end
    return n
end

function process_node(profile, node, result)
  -- parse access and barrier tags
  local highway = node:get_value_by_key("highway")
  local is_crossing = highway and highway == "crossing"

  local access = find_access_tag(node, profile.access_tags_hierarchy)
  if access and access ~= "" then
    -- access restrictions on crossing nodes are not relevant for
    -- the traffic on the road
    if profile.access_tag_blacklist[access] and not is_crossing then
      result.barrier = true
    end
  else
    local barrier = node:get_value_by_key("barrier")
    if barrier and "" ~= barrier then
      if profile.barrier_blacklist[barrier] then
        result.barrier = true
      end
    end
  end

  -- check if node is a traffic light
  local tag = node:get_value_by_key("highway")
  if tag and "traffic_signals" == tag then
    result.traffic_lights = true
  end

--  if result.barrier then
--    io.write(tostring(node:id())..": is a barrier!\n")
--  end
end

function handle_bicycle_tags(profile,way,result,data)

    -- initial routability check, filters out buildings, boundaries, etc
  data.route = way:get_value_by_key("route")
  data.man_made = way:get_value_by_key("man_made")
  data.railway = way:get_value_by_key("railway")
  data.amenity = way:get_value_by_key("amenity")
  data.public_transport = way:get_value_by_key("public_transport")
--  data.bridge = way:get_value_by_key("bridge")

  if (not data.highway or data.highway == '') and
  (not data.route or data.route == '') and
  (not profile.use_public_transport or not data.railway or data.railway=='') and
  (not data.amenity or data.amenity=='') and
  (not data.man_made or data.man_made=='') and
  (not data.public_transport or data.public_transport=='') 
--  (not data.bridge or data.bridge=='')
  then
    return false
  end

  -- access
  data.access = find_access_tag(way, profile.access_tags_hierarchy)
  if data.access and profile.access_tag_blacklist[data.access] then
    return false
  end

  -- other tags
  data.junction = way:get_value_by_key("junction")
  data.maxspeed = parse_maxspeed(way:get_value_by_key ( "maxspeed") )
  data.maxspeed_forward = parse_maxspeed(way:get_value_by_key( "maxspeed:forward"))
  data.maxspeed_backward = parse_maxspeed(way:get_value_by_key( "maxspeed:backward"))
  data.barrier = way:get_value_by_key("barrier")
  data.oneway = way:get_value_by_key("oneway")
  data.oneway_bicycle = way:get_value_by_key("oneway:bicycle")
  data.cycleway = way:get_value_by_key("cycleway")
  data.cycleway_left = way:get_value_by_key("cycleway:left")
  data.cycleway_right = way:get_value_by_key("cycleway:right")
  data.duration = way:get_value_by_key("duration")
  data.service = way:get_value_by_key("service")
  data.foot = way:get_value_by_key("foot")
  data.foot_forward = way:get_value_by_key("foot:forward")
  data.foot_backward = way:get_value_by_key("foot:backward")
  data.bicycle = way:get_value_by_key("bicycle")

 --debug-way(way,result,data,"A") 

  speed_handler(profile,way,result,data)

  --debug-way(way,result,data,"B")

  oneway_handler(profile,way,result,data)

  --debug-way(way,result,data,"C")

  cycleway_handler(profile,way,result,data)

  --debug-way(way,result,data,"D")

  safety_handler(profile,way,result,data)

  --debug-way(way,result,data,"E")

  -- maxspeed
  limit( result, data.maxspeed, data.maxspeed_forward, data.maxspeed_backward )

  --debug-way(way,result,data,"F")

  -- not routable if no speed assigned
  -- this avoid assertions in debug builds
  if result.forward_speed <= 0 and result.duration <= 0 then
    result.forward_mode = mode.inaccessible
  end
  if result.backward_speed <= 0 and result.duration <= 0 then
    result.backward_mode = mode.inaccessible
  end

  --debug-way(way,result,data,"G")
end

function debug_way(way, result, data, msg)
  local id = way:id()
  if id == 316886591 or id == 89349043 then
--    local access = data.access or '(nil)'
    io.write(tostring(id)..": "..msg..", forward_rate = "..tostring(result.forward_rate)..", forward_speed = "..tostring(result.forward_speed).."\n")
  end 
end

function speed_handler(profile,way,result,data)

  data.way_type_allows_pushing = false

  if profile.route_speeds[data.route] then
    -- ferries (doesn't cover routes tagged using relations)
    result.forward_mode = mode.ferry
    result.backward_mode = mode.ferry
    if data.duration and durationIsValid(data.duration) then
      result.duration = math.max( 1, parseDuration(data.duration) )
    else
       result.forward_speed = profile.route_speeds[data.route]
       result.backward_speed = profile.route_speeds[data.route]
    end
    --debug_way(way,result,data, "2")
  -- railway platforms (old tagging scheme)
  elseif data.railway and profile.platform_speeds[data.railway] then
    result.forward_speed = profile.platform_speeds[data.railway]
    result.backward_speed = profile.platform_speeds[data.railway]
    data.way_type_allows_pushing = true
    --debug_way(way,result,data, "3")
  -- public_transport platforms (new tagging platform)
  elseif data.public_transport and profile.platform_speeds[data.public_transport] then
    result.forward_speed = profile.platform_speeds[data.public_transport]
    result.backward_speed = profile.platform_speeds[data.public_transport]
    data.way_type_allows_pushing = true
    --debug_way(way,result,data, "4")
  -- railways
  elseif profile.use_public_transport and data.railway and profile.railway_speeds[data.railway] and profile.access_tag_whitelist[data.access] then
    result.forward_mode = mode.train
    result.backward_mode = mode.train
    result.forward_speed = profile.railway_speeds[data.railway]
    result.backward_speed = profile.railway_speeds[data.railway]
    --debug_way(way,result,data, "5")
  elseif data.amenity and profile.amenity_speeds[data.amenity] then
    -- parking areas
    result.forward_speed = profile.amenity_speeds[data.amenity]
    result.backward_speed = profile.amenity_speeds[data.amenity]
    data.way_type_allows_pushing = true
    --debug_way(way,result,data, "6")
  elseif profile.bicycle_speeds[data.highway] then
    -- regular ways
    result.forward_speed = profile.bicycle_speeds[data.highway]
    result.backward_speed = profile.bicycle_speeds[data.highway]
    data.way_type_allows_pushing = true
    --debug_way(way,result,data, "7")
  elseif data.access and profile.access_tag_whitelist[data.access]  then
    -- unknown way, but valid access tag
    result.forward_speed = profile.default_speed
    result.backward_speed = profile.default_speed
    data.way_type_allows_pushing = true
    --debug_way(way,result,data, "8")
  end
end

function oneway_handler(profile,way,result,data)
  -- oneway
  data.implied_oneway = data.junction == "roundabout" or data.junction == "circular" or data.highway == "motorway"
  data.reverse = false

  if data.oneway_bicycle == "yes" or data.oneway_bicycle == "1" or data.oneway_bicycle == "true" then
    result.backward_mode = mode.inaccessible
  elseif data.oneway_bicycle == "no" or data.oneway_bicycle == "0" or data.oneway_bicycle == "false" then
   -- prevent other cases
  elseif data.oneway_bicycle == "-1" then
    result.forward_mode = mode.inaccessible
    data.reverse = true
  elseif data.oneway == "yes" or data.oneway == "1" or data.oneway == "true" then
    result.backward_mode = mode.inaccessible
  elseif data.oneway == "no" or data.oneway == "0" or data.oneway == "false" then
    -- prevent other cases
  elseif data.oneway == "-1" then
    result.forward_mode = mode.inaccessible
    data.reverse = true
  elseif data.implied_oneway then
    result.backward_mode = mode.inaccessible
  end
end

function cycleway_handler(profile,way,result,data)
  -- cycleway
  data.has_cycleway_forward = false
  data.has_cycleway_backward = false
  data.is_twoway = result.forward_mode ~= mode.inaccessible and result.backward_mode ~= mode.inaccessible and not data.implied_oneway

  -- cycleways on normal roads
  if data.is_twoway then
    if data.cycleway and profile.cycleway_tags[data.cycleway] then
      data.has_cycleway_backward = true
      data.has_cycleway_forward = true
    end
    if (data.cycleway_right and profile.cycleway_tags[data.cycleway_right]) or (data.cycleway_left and profile.opposite_cycleway_tags[data.cycleway_left]) then
      data.has_cycleway_forward = true
    end
    if (data.cycleway_left and profile.cycleway_tags[data.cycleway_left]) or (data.cycleway_right and profile.opposite_cycleway_tags[data.cycleway_right]) then
      data.has_cycleway_backward = true
    end
  else
    local has_twoway_cycleway = (data.cycleway and profile.opposite_cycleway_tags[data.cycleway]) or (data.cycleway_right and profile.opposite_cycleway_tags[data.cycleway_right]) or (data.cycleway_left and profile.opposite_cycleway_tags[data.cycleway_left])
    local has_opposite_cycleway = (data.cycleway_left and profile.opposite_cycleway_tags[data.cycleway_left]) or (data.cycleway_right and profile.opposite_cycleway_tags[data.cycleway_right])
    local has_oneway_cycleway = (data.cycleway and profile.cycleway_tags[data.cycleway]) or (data.cycleway_right and profile.cycleway_tags[data.cycleway_right]) or (data.cycleway_left and profile.cycleway_tags[data.cycleway_left])

    -- set cycleway even though it is an one-way if opposite is tagged
    if has_twoway_cycleway then
      data.has_cycleway_backward = true
      data.has_cycleway_forward = true
    elseif has_opposite_cycleway then
      if not data.reverse then
        data.has_cycleway_backward = true
      else
        data.has_cycleway_forward = true
      end
    elseif has_oneway_cycleway then
      if not data.reverse then
        data.has_cycleway_forward = true
      else
        data.has_cycleway_backward = true
      end

    end
  end

  if data.has_cycleway_backward then
    result.backward_mode = mode.cycling
    result.backward_speed = profile.bicycle_speeds["cycleway"]
  end

  if data.has_cycleway_forward then
    result.forward_mode = mode.cycling
    result.forward_speed = profile.bicycle_speeds["cycleway"]
  end
end


function safety_handler(profile,way,result,data)
  if data.maxspeed > 110  or data.bicycle == 'unsuitable' then
    data.forward_rate = 0
    data.backward_rate = 0
    return false
  end

  -- convert duration into cyclability
  if profile.properties.weight_name == 'cyclability' then
    local safety_penalty = profile.unsafe_highway_list[data.highway] or 1.
    local is_unsafe = safety_penalty < 1

    -- primaries that are one ways are probably huge primaries where the lanes need to be separated
    if is_unsafe and data.highway == 'primary' and not data.is_twoway then
      safety_penalty = safety_penalty * 0.5
    end
    if is_unsafe and data.highway == 'secondary' and not data.is_twoway then
      safety_penalty = safety_penalty * 0.6
    end

    local forward_is_unsafe = is_unsafe and not data.has_cycleway_forward
    local backward_is_unsafe = is_unsafe and not data.has_cycleway_backward
    local is_undesireable = data.highway == "service" and profile.service_penalties[data.service]
    local forward_penalty = 1.
    local backward_penalty = 1.
    if forward_is_unsafe then
--      forward_penalty = math.min(forward_penalty, safety_penalty)
    end
    if backward_is_unsafe then
--       backward_penalty = math.min(backward_penalty, safety_penalty)
    end

    if is_undesireable then
       forward_penalty = math.min(forward_penalty, profile.service_penalties[data.service])
       backward_penalty = math.min(backward_penalty, profile.service_penalties[data.service])
    end

    if result.forward_speed > 0 then
      -- convert from km/h to m/s
      result.forward_rate = result.forward_speed / 3.6 * forward_penalty
    end
    if result.backward_speed > 0 then
      -- convert from km/h to m/s
      result.backward_rate = result.backward_speed / 3.6 * backward_penalty
    end
    if result.duration > 0 then
      result.weight = result.duration / forward_penalty
    end

    if data.highway == "bicycle" then
      safety_bonus = safety_bonus + 0.2
      if result.forward_speed > 0 then
        -- convert from km/h to m/s
        result.forward_rate = result.forward_speed / 3.6 * safety_bonus
      end
      if result.backward_speed > 0 then
        -- convert from km/h to m/s
        result.backward_rate = result.backward_speed / 3.6 * safety_bonus
      end
      if result.duration > 0 then
        result.weight = result.duration / safety_bonus
      end
    end
  end
end



function process_way(profile, way, result)
  -- the initial filtering of ways based on presence of tags
  -- affects processing times significantly, because all ways
  -- have to be checked.
  -- to increase performance, prefetching and initial tag check
  -- is done directly instead of via a handler.

  -- in general we should try to abort as soon as
  -- possible if the way is not routable, to avoid doing
  -- unnecessary work. this implies we should check things that
  -- commonly forbids access early, and handle edge cases later.

  -- data table for storing intermediate values during processing

  local data = {
    -- prefetch tags
    highway = way:get_value_by_key('highway'),

    route = nil,
    man_made = nil,
    railway = nil,
    amenity = nil,
    public_transport = nil,
    --bridge = nil,

    access = nil,

    junction = nil,
    maxspeed = nil,
    maxspeed_forward = nil,
    maxspeed_backward = nil,
    barrier = nil,
    oneway = nil,
    oneway_bicycle = nil,
    cycleway = nil,
    cycleway_left = nil,
    cycleway_right = nil,
    duration = nil,
    service = nil,
    foot = nil,
    foot_forward = nil,
    foot_backward = nil,
    bicycle = nil,

    way_type_allows_pushing = false,
    has_cycleway_forward = false,
    has_cycleway_backward = false,
    is_twoway = true,
    reverse = false,
    implied_oneway = false
  }

  local handlers = Sequence {
    -- set the default mode for this profile. if can be changed later
    -- in case it turns we're e.g. on a ferry
    WayHandlers.default_mode,

    -- check various tags that could indicate that the way is not
    -- routable. this includes things like status=impassable,
    -- toll=yes and oneway=reversible
    WayHandlers.blocked_ways,

    -- our main handler
    handle_bicycle_tags,

    -- compute speed taking into account way type, maxspeed tags, etc.
    WayHandlers.surface,


    -- new handler to reject anything that isn't a surface we like, including unknown surfaces.
    unknown_surface_handler,

    -- new handler to query postgis for built up area
    --builtup_area_handler,

    -- handle turn lanes and road classification, used for guidance
    WayHandlers.classification,

    custom_way_classification,

    -- handle allowed start/end modes
    WayHandlers.startpoint,

    -- handle roundabouts
    WayHandlers.roundabouts,

    -- set name, ref and pronunciation
    WayHandlers.names,

    -- set classes
    WayHandlers.classes,

    -- set weight properties of the way
    WayHandlers.weights,

    -- set classification of ways relevant for turns
    WayHandlers.way_classification_for_turn
  }

  WayHandlers.run(profile, way, result, data, handlers)

	--debug_way(way,result,data,"END")
--if result.forward_mode == mode.inaccessible or result.backward_mode == mode.inaccessible then
--  io.write(tostring(way:id()).." is inaccessible!\n!")
--end

end

function custom_way_classification(profile, way, result, data)
  if data.oneway then
    result.road_classification.num_lanes = result.road_classification.num_lanes * 2

    -- this is to all prevention of turning off a 4 lane road without traffic lights (e.g. A90, see example elsewhere)
    -- to also apply to a road that is drawn as each carriageway being its own way - each with 2 laens and oneway.
  end

end

function unknown_surface_handler(profile,way,result,data)
	--debug-way(way,result,data,"ush_begin")
  local id = way:id()
  local surface = way:get_value_by_key("surface")
  local ncn_ref = way:get_value_by_key("ncn_ref")
  if ncn_ref == "647" and surface ~= "dirt" then
    result.forward_speed = profile.default_speed
    result.backward_speed = profile.default_speed
    --debug-way(way,result,data,"ncn647")

  elseif (SurfaceWhitelist.whitelist_ways_by_id[id] == true) then
    result.forward_speed = profile.default_speed
    result.backward_speed = profile.default_speed
    --debug-way(way,result,data,"whitelist")
  else
    if not profile.is_road[data.highway] then
      if surface == nil or (profile.surface_speeds[surface] == nil or profile.surface_speeds[surface] == 0) then
        result.forward_rate = 0
        result.backward_rate = 0
        return false
      end
    end
    --debug-way(way,result,data,"ush_else")
  end
	--debug-way(way,result,data,"ush_end")
end

function builtup_area_handler(profile, way, result, data)
  local sql_query = " " ..
    "SELECT SUM(SQRT(area.area)) AS val " ..
    "FROM osm_roads_t way " ..
    "LEFT JOIN osm_landusages area ON ST_DWithin(way.geometry, area.geometry, 100) " ..
    "WHERE area.type IN ('industrial') AND way.osm_id=" .. way:id() .. " " ..
    "GROUP BY way.id"

  local cursor = assert( sql_con:execute(sql_query) )
  local builtup_sensitivity = 10 -- minimum 1
  local row = cursor:fetch( {}, "a" )
  if row then
    local val = tonumber(row.val)
    if val > 10 then
      local factor = ((builtup_sensitivity*math.log10( val )) -(builtup_sensitivity-1) )

      result.forward_rate = result.forward_speed / factor
      result.backward_rate = result.backward_speed / factor 
--      io.write("way "..tostring(way:id()).." forward speed = "..tostring(result.forward_speed)..", forward_rate = "..tostring(result.forward_rate).."\n")
    end
  end
  cursor:close()
end 

function process_turn(profile, turn)


  -- compute turn penalty as angle^2, with a left/right bias
  local normalized_angle = turn.angle / 90.0
  if normalized_angle >= 0.0 then
    turn.duration = normalized_angle * normalized_angle * profile.turn_penalty / profile.turn_bias
  else
    turn.duration = normalized_angle * normalized_angle * profile.turn_penalty * profile.turn_bias
  end

  if turn.is_u_turn then
    turn.duration = turn.duration + profile.properties.u_turn_penalty
  end

  if turn.has_traffic_light then
     turn.duration = turn.duration + profile.properties.traffic_light_penalty
  end
  if profile.properties.weight_name == 'cyclability' then
    turn.weight = turn.duration
  end
  if turn.source_mode == mode.cycling and turn.target_mode ~= mode.cycling then
    turn.weight = turn.weight + profile.properties.mode_change_penalty
  end
  

  if turn.source_highway_turn_classification > 0  and turn.target_highway_turn_classification > 0 then
    if turn.source_highway_turn_classification <= 7 and turn.target_highway_turn_classification >= 8 then --turning onto a worse road, e.g. residential
      turn.weight = turn.weight + profile.properties.highway_change_penalty
    end

    if turn.source_highway_turn_classification > 1 and turn.target_highway_turn_classification == 1 then
      turn.weight = turn.weight + profile.properties.onto_primary_penalty --if we're turning onto a primary/trunk from a non-primary/trunk,incur a penalty.
                -- this is to avoid the coming off a main road temporarily and then back onto it again phenomenon.
    end
  end


  if turn.source_number_of_lanes > 2 and turn.angle > 30 and not turn.has_traffic_light then
    -- e.g. 55.966113,-3.318558 (A90 in Edinburgh)
    turn.weight = turn.weight + 2000

  end

  turn.weight = turn.weight + profile.properties.static_turn_cost

end

function get_raster_source(profile,pos)
  if pos.lon >= -10 and pos.lon <= -5 and pos.lat >= 45 and pos.lat <= 50 then
    return profile.raster_sources.raster_35_03

  elseif pos.lon >= -5 and pos.lon <= 0 and pos.lat >= 45 and pos.lat <= 50 then
    return profile.raster_sources.raster_36_03

  elseif pos.lon >= -15 and pos.lon <= -10 and pos.lat >= 50 and pos.lat <= 55 then
    return profile.raster_sources.raster_34_02

  elseif pos.lon >= -10 and pos.lon <= -5 and pos.lat >= 50 and pos.lat <= 55 then
    return profile.raster_sources.raster_35_02

  elseif pos.lon >= -5 and pos.lon <= 0 and pos.lat >= 50 and pos.lat <= 55 then
    return profile.raster_sources.raster_36_02
  
  elseif pos.lon >= 0 and pos.lon <= 5 and pos.lat >= 50 and pos.lat <= 55 then
    return profile.raster_sources.raster_37_02
  
  elseif pos.lon >= -15 and pos.lon <= -10 and pos.lat >= 55 then
    return profile.raster_sources.raster_34_01
  
  elseif pos.lon >= -10 and pos.lon <= -5 and pos.lat >= 55 then
    return profile.raster_sources.raster_35_01
  
  elseif pos.lon >= -5 and pos.lon <= 0 and pos.lat >= 55  then
    return profile.raster_sources.raster_36_01
  
  elseif pos.lon >= 0 and pos.lon <= 5 and pos.lat >= 55 and pos.lat <= 60 then
    return profile.raster_sources.raster_37_01

  else
    io.write("no raster source for "..pos.lat..","..pos.lon.."\n")    
    return nil
  end

end

maxaversion = nil
minaversion = nil

function get_hill_aversion(slope, elevationgain)
  local min_grad_for_aversion = 0.0
--  local max_grad = 0.35

--  if slope > max_grad then
--    slope = max_grad
--  end

  if slope < min_grad_for_aversion then
    slope = min_grad_for_aversion
  end

  local aversion = math.abs(1.0 / (1.0 - (slope * 5.0)))

  if slope < 0.1 and elevationgain < 0 then
    aversion = 0.8 --slight benefit for gentle downhills
  end

  return aversion
  --return aversion
end

function process_segment(profile, segment)
  local sourceraster = get_raster_source(profile,segment.source)
  local targetraster = get_raster_source(profile,segment.target)
  if sourceraster ~= nil and targetraster ~= nil then
    local sourceData = raster:interpolate(sourceraster, segment.source.lon, segment.source.lat)
    local targetData = raster:interpolate(targetraster, segment.target.lon, segment.target.lat)
    local invalid = sourceData.invalid_data()
    local scaled_weight = segment.weight
    local scaled_duration = segment.duration

    if sourceData.datum ~= invalid and targetData.datum ~= invalid then
      local elevationgain = targetData.datum - sourceData.datum
      --local slope = math.abs(elevationgain) / segment.distance -- avoid steepness whether up or down
      local slope = (targetData.datum - sourceData.datum) / segment.distance

      local hillaversion = get_hill_aversion(slope, elevationgain)
      if maxaversion == nil or hillaversion > maxaversion then
        maxaversion = hillaversion
        io.write("maxaversion = "..tostring(maxaversion).."\n")
      end

      if minaversion == nil or hillaversion < minaversion then
        minaversion = hillaversion
        io.write("minaversion = "..tostring(minaversion).."\n")
      end

      if hillaversion == 0 or hillaversion == nil then
        io.write("aversion is 0 or nil!\n")
      end

      --if segment.target.lat > 57.124556 then
      --  hillaversion = hillaversion + 1000
      --end
      --io.write("hillaversion = "..tostring(hillaversion).."\n")
      scaled_weight = scaled_weight * hillaversion
      scaled_duration = scaled_duration * hillaversion

      --scaled_weight = scaled_weight / (1.0 - (slope * 5.0))
      --scaled_duration = scaled_duration / (1.0 - (slope * 5.0)) 
    end
    segment.weight = scaled_weight
    segment.duration = scaled_duration

  end
end

return {
  setup = setup,
  process_way = process_way,
  process_node = process_node,
  process_turn = process_turn,
  process_segment = process_segment
}
