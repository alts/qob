local fn = {}

fn.const = function (a)
  return function (_)
    return a
  end
end

return fn