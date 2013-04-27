local ezanimation = require 'ezanimation'

local function anim_sequence(...)
  local sequence = {}
  local args = {...}
  local index = 1
  local arg

  for i=1,#args do
    arg = args[i]
    if type(arg) == 'function' then
      arg = {0, arg}
    end

    table.insert(sequence, ezanimation(arg))
  end

  local size = #sequence

  return function (dt)
    local remainder

    while true do
      remainder = sequence[index](dt)

      if not remainder then
        return nil
      end

      index = index + 1

      if index > size then
        return remainder
      end

      dt = remainder
    end
  end
end

return anim_sequence