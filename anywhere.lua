-- anywhere profile

api_version = 4


local default_speed = 15

function process_way(profile, way, result)
    result.forward_speed = profile.default_speed
    result.backward_speed = profile.default_speed
    result.forward_rate = profile.default_speed / 3.6
    result.backward_rate = profile.default_speed / 3.6
    result.forward_mode = mode.cycling
    result.backward_mode = mode.cycling

end


return {
  process_way = process_way
}
