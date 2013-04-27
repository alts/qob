local SimpleQueue = require 'simple_queue'
local animation_collection = create(SimpleQueue)

local function run(self, dt)
  local ret = nil
  local animations = self.items
  local animation = nil

  for i = self.head, self.tail do
    animation = animations[i]
    if animation then
      ret = animation(dt)
      if ret ~= nil then
        animations[i] = nil
      end
    end
  end
end

animation_collection:init()
animation_collection.run = run

return animation_collection