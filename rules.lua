local state_manager = require 'state_manager'
local rules = state_manager:register('rules')
local game_grid = require 'game_grid'
local graphics = love.graphics

local lines = {
  'qob is a competitive 2 player game',
  'the goal of the game is to collect the most stones in your colored zone',
  'players take turns moving stones',
  'move stones by selecting a pivot point, and rotating',
  'select a pivot stone by clicking it',
  'rotate counter-clockwise with LEFT or A',
  'rotate clockwise with RIGHT or D',
  'a stone will rotate only if it is connected to the pivot stone',
  'a stone will rotate only if is has 2 or fewer non-pivot neighbors',
  'a stone will rotate only if its destination is not blocked',
  'you cannot pivot from your opponent\'s zone',
  'you cannot undo your opponent\'s move',
  'a game lasts 100 turns',
  '',
  'to practice, play with the stones on the right',
  'when you want to start, press ENTER',
}

local function enter(self)
  game_grid:demo_init()
end


local function mousepressed(self, x, y, button)
  game_grid:search(x, y)
end


local function keypressed(self, key)
  if key == 'left' or key == 'a' then
    game_grid:rotate_stone(-1)
  elseif key == 'right' or key == 'd' then
    game_grid:rotate_stone(1)
  elseif key == 'kpenter' or key == 'return' then
    state_manager:switch('play')
  end
end


local function draw()
  game_grid:draw()

  graphics.setColor(0, 0, 0)
  graphics.print('RULES:', 10, 30)
  graphics.setColor(40, 40, 40)
  local y = 30
  for i=1, #lines do
    y = y + 20
    graphics.print(lines[i], 10, y)
  end
end


local function update(self, dt)
  game_grid:update(dt)
end

-- interface
rules.enter = enter
rules.draw = draw
rules.update = update
rules.mousepressed = mousepressed
rules.keypressed = keypressed

return rules