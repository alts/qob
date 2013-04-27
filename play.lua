local state_manager = require 'state_manager'
local play = state_manager:register('play')
local graphics = love.graphics
local game_grid = require 'game_grid'


local function enter()
  game_grid:init()
end


local function mousepressed(self, x, y, button)
  game_grid:search(x, y)
end


local function keypressed(self, key)
  if key == 'left' then
    game_grid:rotate_stone(-1)
  elseif key == 'right' then
    game_grid:rotate_stone(1)
  end
end


local function draw()
  -- blocks
  graphics.setColor(255, 255, 0)
  graphics.rectangle('fill',
    0, 0,
    HOME_WIDTH, HOME_HEIGHT
  )
  graphics.rectangle('fill',
    SCREEN_WIDTH - HOME_WIDTH, SCREEN_HEIGHT - HOME_HEIGHT,
    HOME_WIDTH, HOME_HEIGHT
  )

  graphics.setColor(0, 0, 255)
  graphics.rectangle('fill',
    0, SCREEN_HEIGHT - HOME_HEIGHT,
    HOME_WIDTH, HOME_HEIGHT
  )
  graphics.rectangle('fill',
    SCREEN_WIDTH - HOME_WIDTH, 0,
    HOME_WIDTH, HOME_HEIGHT
  )

  -- grid
  love.graphics.setColor(0, 0, 0, 15)
  for gx=0, 16 do
    local x = gx * 50
    graphics.line(x, 0, x, SCREEN_HEIGHT)
  end

  for gy=0, 10 do
    local y = gy * 50
    graphics.line(0, y, SCREEN_WIDTH, y)
  end

  -- lines
  love.graphics.setLineWidth(4)
  graphics.setColor(0, 0, 0)
  graphics.line(
    HOME_WIDTH, 0,
    HOME_WIDTH, SCREEN_HEIGHT
  )
  graphics.line(
    SCREEN_WIDTH - HOME_WIDTH, 0,
    SCREEN_WIDTH - HOME_WIDTH, SCREEN_HEIGHT
  )
  graphics.line(
    0, HOME_HEIGHT,
    SCREEN_WIDTH, HOME_HEIGHT
  )
  graphics.line(
    0, SCREEN_HEIGHT - HOME_HEIGHT,
    SCREEN_WIDTH, SCREEN_HEIGHT - HOME_HEIGHT
  )
  love.graphics.setLineWidth(1)

  game_grid:draw()
end

-- interface
play.enter = enter
play.draw = draw
play.mousepressed = mousepressed
play.keypressed = keypressed

return play