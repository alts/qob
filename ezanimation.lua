local function ezanimation(tuple)
  local max_time = tuple[1]
  local cb = tuple[2]
  local elapsed = 0
  local remainder = 0

  return function(dt)
    elapsed = elapsed + dt
    if elapsed > max_time then
      remainder = elapsed - max_time
      dt = dt - remainder
      cb(dt, elapsed, true)
      return remainder
    else
      cb(dt, elapsed, false)
      return nil
    end
  end
end

return ezanimation