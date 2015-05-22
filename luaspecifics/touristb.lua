module "touristb"

whitelist_speed = 19 

speed_profile = {
  ["trunk"] = 5,
  ["trunk_link"] = 5,
  ["primary"] = 15,
  ["primary_link"] = 15,
  ["secondary"] = 17,
  ["secondary_link"] = 17,
  ["tertiary"] = 17,
  ["tertiary_link"] = 17,
  ["unclassified"] = 19,
  ["residential"] = 15,
  ["living_street"] = 15,
  ["service"] = 5,
  ["ferry"] = 5,
  ["shuttle_train"] = 10,
  ["default"] = 15
}

function get_specific_speed(way)

	local ncnref = way:get_value_by_key("ncn_ref")
	if (ncnref ~= nil and ncnref == "647") then
		local wayid = way:id()
		print "ncn 647 - "..wayid
		return whitelist_speed
	end

  local surface = way:get_value_by_key("surface")
  local bicycle = way:get_value_by_key("bicycle")
  local bikesallowed = ("yes" == bicycle or "permissive" == bicycle or "designated" == bicycle or "destination" == bicycle)
  local name = way:get_value_by_key("name")
  local highway = way:get_value_by_key("highway")
  local descriptor = highway.." "..surface.." "..bicycle.." "..name
  if ("asphalt" == surface or "paved" == surface) and 
	("cycleway" == highway or
		("track" == highway and bikesallowed) or
		("bridleway" == highway and bikesallowed) or 
		("footway" == highway and bikesallowed) or
        ("path" == highway and bikesallowed)
		) then
	
			return whitelist_speed
	else
		return 0
  end

end

