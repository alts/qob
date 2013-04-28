local anim_sequence = require 'anim_sequence'
local anim_collection = require 'animation_collection'
local graphics = love.graphics

local animations = clone(anim_collection)
animations:init()

local big_font = graphics.newFont(30)
local turn_swipe = {
  ready = false
}


local function grow_bars(dt)
  local outer_radius = turn_swipe.outer_radius
  local inner_radius = turn_swipe.inner_radius

  outer_radius = outer_radius + SWIPE_SPEED*dt
  if outer_radius > SWIPE_WIDTH then
    inner_radius = outer_radius - SWIPE_WIDTH
  end

  turn_swipe.outer_radius = outer_radius
  turn_swipe.inner_radius = inner_radius
end


local function turn_to_color(turn)
  if turn == YELLOW_TURN then
    return {255, 255, 0}
  else
    return {0, 0, 255}
  end
end


local function show(self)
end


local function swipe(self, turn, text)
  self.ready = true
  self.text = text -- {'TURN', turn_num..' / 100'}
  self.turn = turn
  self.color = turn_to_color(turn)

  animations:add(anim_sequence(
    {1, fn.id},
    function ()
      self.ready = false
    end
  ))
end


local function update(self, dt)
  if not animations:is_empty() then
    animations:run(dt)
  end
end


local function draw(self)
  if not self.ready then
    return
  end

  graphics.setColor(0, 0, 0)
  graphics.circle('fill',
    SCREEN_WIDTH/2, SCREEN_HEIGHT/2,
    100, 50
  )
  graphics.setColor(self.color)
  graphics.circle('fill',
    SCREEN_WIDTH/2, SCREEN_HEIGHT/2,
    80, 50
  )

  if self.turn == YELLOW_TURN then
    graphics.setColor(0, 0, 0)
  else
    graphics.setColor(255,255,255)
  end
  local old_font = graphics.getFont()
  graphics.setFont(big_font)
  graphics.printf(self.text[1], 0, SCREEN_HEIGHT / 2 - 30, SCREEN_WIDTH, 'center')
  graphics.printf(self.text[2], 0, SCREEN_HEIGHT / 2, SCREEN_WIDTH, 'center')
  graphics.setFont(old_font)
end


-- interface
turn_swipe.swipe = swipe
turn_swipe.update = update
turn_swipe.draw = draw


return turn_swipe