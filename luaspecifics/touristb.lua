module "touristb"

whitelist_speed = 20

speed_profile = {
  ["trunk"] = 5,
  ["trunk_link"] = 5,
  ["primary"] = 15,
  ["primary_link"] = 15,
  ["secondary"] = 20,
  ["secondary_link"] = 20,
  ["tertiary"] = 20,
  ["tertiary_link"] = 20,
  ["unclassified"] = 20,
  ["residential"] = 15,
  ["living_street"] = 15,
  ["service"] = 5,
  ["ferry"] = 5,
  ["shuttle_train"] = 10,
  ["default"] = 15
}

function get_specific_speed(way)

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

