local state_manager = require 'state_manager'
local image_bank = require 'image_bank'
local title = state_manager:register('title')
local graphics = love.graphics


local function enter(self)
  self.img = image_bank:get('assets/qob_title.png')
end


local function draw(self)
  graphics.setColor(255, 255, 255)
  graphics.draw(self.img, 0, -40)
  graphics.setColor(0, 0, 0)
  graphics.printf('made in 48 hours for Ludum Dare #26 by Stephen Altamirano',
    0, 380, SCREEN_WIDTH, 'center')
  graphics.printf('click to play', 0, 400, SCREEN_WIDTH, 'center')
end

local function mousepressed(self)
  state_manager:switch('play')
end


-- interface
title.enter = enter
title.draw = draw
title.mousepressed = mousepressed

return title