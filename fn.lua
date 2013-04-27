local fn = {}

fn.id = function (v)
  return v
end

fn.const = function (a)
  return function (_)
    return a
  end
end

return fn