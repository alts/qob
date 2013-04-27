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
  return self
end

local function draw(self)
  local row, stone

  for gx=1,#self.board do
    row = self.board[gx]
    for gy=1, #row do
      stone = row[gy]
      if stone == 1 then
        graphics.setColor(0, 0, 0)
        graphics.circle('fill',
          (gx - 1) * 50, (gy - 1) * 50,
          12, 24
        )
        graphics.setColor(255, 255, 255)
        graphics.circle('fill',
          (gx - 1) * 50, (gy - 1) * 50,
          6, 24
        )
      end
    end
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
      stone.clicked = not stone.clicked
      return stone
    end
  end
end

-- interface
game_grid.init = init
game_grid.draw = draw
game_grid.search = search

return game_grid