local state_manager = require 'state_manager'
local end_scene = state_manager:register('end')
local graphics = love.graphics

local big_font = graphics.newFont(80)

local function enter(self, prev, scores)
  self.prev = prev
  self.scores = scores

  local phrase
  if scores[1] > scores[2] then
    phrase = 'Yellow Wins!'
  elseif scores[1] < scores[2] then
    phrase = 'Blue Wins!'
  else
    phrase = 'Tie!'
  end

  self.text = phrase .. ' Press ENTER to play again'
end

local function draw(self)
  self.prev:draw()
  local radius = 2.5*GRID_SIZE
  love.graphics.setColor(0, 0, 0)
  graphics.circle('fill',
    4 * GRID_SIZE, SCREEN_HEIGHT / 2,
    radius, 50
  )

  graphics.circle('fill',
    12 * GRID_SIZE, SCREEN_HEIGHT / 2,
    radius, 50
  )

  graphics.setColor(255, 255, 0)
  graphics.circle('fill',
    4 * GRID_SIZE, SCREEN_HEIGHT / 2,
    radius - 20, 50
  )

  graphics.setColor(0, 0, 255)
  graphics.circle('fill',
    12 * GRID_SIZE, SCREEN_HEIGHT / 2,
    radius - 20, 50
  )

  graphics.setColor(0, 0, 0)
  graphics.printf(self.text, 0, SCREEN_HEIGHT - 40, SCREEN_WIDTH, 'center')

  local old_font = graphics.getFont()
  graphics.setFont(big_font)
  graphics.printf(
    self.scores[1],
    4 * GRID_SIZE - radius,
    SCREEN_HEIGHT / 2 - 45,
    2*radius,
    'center'
  )

  graphics.setColor(255, 255, 255)
  graphics.printf(
    self.scores[2],
    12 * GRID_SIZE - radius,
    SCREEN_HEIGHT / 2 - 45,
    2*radius,
    'center'
  )
  graphics.setFont(old_font)

end

local function keypressed(self, key)
  if key == 'kpenter' or key == 'return' then
    state_manager:switch('play')
  end
end

-- interface
end_scene.enter = enter
end_scene.draw = draw
end_scene.keypressed = keypressed

return end_scene