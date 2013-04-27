local game_grid = {}
local graphics = love.graphics

local function init(self)
  local board = {}
  local stones = {}
  local row

  for gx=1, 17 do
    row = {}
    for gy=1, 10 do
      table.insert(row, 0)
    end
    table.insert(board, row)
  end

  for gx=6, 12 do
    for gy=4, 7 do
      board[gx][gy] = 1
      table.insert(stones, {x=gx-1, y=gy-1})
    end
  end

  self.board = board
  self.stones = stones
  self.any_clicked = false
  return self
end

local function draw(self)
  local stones = self.stones
  local stone

  for i=1,#stones do
    stone = stones[i]

    graphics.setColor(0, 0, 0)
    graphics.circle('fill',
      stone.x * GRID_SIZE, stone.y * GRID_SIZE,
      STONE_RADIUS, 24
    )
    if stone.clicked then
      graphics.setColor(255, 0, 0)
    else
      graphics.setColor(255, 255, 255)
    end

    graphics.circle('fill',
      stone.x * GRID_SIZE, stone.y * GRID_SIZE,
      STONE_INNER, 24
    )
  end
end


local function square_contains(x, y, cx, cy, cr)
  return x > cx - cr and x < cx + cr and y > cy - cr and y < cy + cr
end


local function search(self, x, y)
  local stones = self.stones
  local stone

  for i=1, #stones do
    stone = stones[i]
    -- clumsy square collision
    if square_contains(x, y, stone.x * GRID_SIZE, stone.y * GRID_SIZE, STONE_RADIUS) then
      if stone.clicked then
        stone.clicked = false
        any_clicked = false
      else
        self:unclick_all()
        stone.clicked = true
        any_clicked = true
      end
      return stone
    end
  end

  if any_clicked then
    self:unclick_all()
    any_clicked = false
  end
end


local function unclick_all(self)
  local stones = self.stones

  for i=1, #stones do
    stones[i].clicked = false
  end
end

-- interface
game_grid.init = init
game_grid.draw = draw
game_grid.search = search
game_grid.unclick_all = unclick_all

return game_grid