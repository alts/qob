local state_manager = require 'state_manager'
local image_bank = require 'image_bank'
local title = state_manager:register('title')
local graphics = love.graphics


local function enter(self)
  self.img = image_bank:get('assets/qob_title.png')
end


local function draw(self)
  graphics.draw(self.img, 0, 0)
end

local function mousepressed(self)
  state_manager:switch('play')
end


-- interface
title.enter = enter
title.draw = draw
title.mousepressed = mousepressed

return title