-- for local testing
local love = love or {}
local clone = clone or function() end

local game_grid = {}
local graphics = love.graphics
local queue = require 'simple_queue'
local to_add = clone(queue)

local function make_board()
  local board = {}
  for gx=1, 17 do
    row = {}
    for gy=1, 10 do
      table.insert(row, false)
    end
    table.insert(board, row)
  end
  return board
end


local function init(self)
  local board = make_board()
  local stones = {}
  local stone

  for gx=6, 12 do
    for gy=4, 7 do
      stone = {x=gx, y=gy}
      board[gx][gy] = stone
      table.insert(stones, stone)
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
      (stone.x - 1) * GRID_SIZE, (stone.y - 1) * GRID_SIZE,
      STONE_RADIUS, 24
    )
    if stone.clicked then
      graphics.setColor(255, 0, 0)
    elseif stone.rotating then
      graphics.setColor(0, 255, 0)
    else
      graphics.setColor(255, 255, 255)
    end

    graphics.circle('fill',
      (stone.x - 1) * GRID_SIZE, (stone.y - 1) * GRID_SIZE,
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
    if square_contains(x, y, (stone.x - 1) * GRID_SIZE, (stone.y - 1) * GRID_SIZE, STONE_RADIUS) then
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


local function unrotate_all(stones)
  for i=1, #stones do
    stones[i].rotating = nil
  end
end


local function unlink_all(stones)
  for i=1, #stones do
    stones[i].links = nil
  end
end


local function unclick_all(self)
  if not any_clicked then
    return
  end

  local stones = self.stones

  for i=1, #stones do
    stones[i].clicked = false
  end
end


local function clicked_stone(self)
  if not any_clicked then
    return nil
  end

  local stones = self.stones

  for i=1, #stones do
    if stones[i].clicked then
      return stones[i]
    end
  end
end


local function link_stones(stone_a, stone_b)
  local links = stone_a.links or {}
  table.insert(links, stone_b)
  stone_a.links = links

  links = stone_b.links or {}
  table.insert(links, stone_a)
  stone_b.links = links
end


local function build_links(self, stones)
  local board = self.board
  local neighbor, links

  for i=1, #stones do
    stone = stones[i]
    neighbor = board[stone.x + 1] and board[stone.x + 1][stone.y]

    if neighbor and neighbor.rotating then
      link_stones(stone, neighbor)
    end

    neighbor = board[stone.x] and board[stone.x][stone.y + 1]

    if neighbor and neighbor.rotating then
      link_stones(stone, neighbor)
    end
  end
end


local function rotate_stone(self, direction)
  if not any_clicked then
    return
  end

  local stone = self:clicked_stone()

  chunk = self:chunk_from_pivot(stone)

  self:build_links(chunk)
  print(inspect(chunk))

  local other, dx, dy, nx, ny
  for i=1, #chunk do
    other = chunk[i]
    dx = other.x - stone.x
    dy = other.y - stone.y

    if direction == COUNTERCLOCKWISE then
      nx = stone.x + dy
      ny = stone.y - dx
    elseif direction == CLOCKWISE then
      nx = stone.x - dy
      ny = stone.y + dx
    end

    if self.board[nx] and self.board[nx][ny] == false then
      self.board[other.x][other.y] = false
      other.x = nx
      other.y = ny
      self.board[other.x][other.y] = other
    end
  end

  unlink_all(self.stones)
  unrotate_all(self.stones)
  self:unclick_all()
end


local function counter(_, acc)
  acc = acc or 0
  return acc + 1
end


local function append(stone, acc)
  acc = acc or {}
  table.insert(acc, stone)
  return acc
end


local function each_neighbor(grid, stone, callback)
  local board = grid.board
  local dx = 0
  local dy = 1
  local arg, found

  for i=1, 4 do
    found = board[stone.x + dx] and board[stone.x + dx][stone.y + dy]
    if found then
      arg = callback(found, arg)
    end

    dx, dy = -dy, dx
  end

  return arg
end


local function is_neighbor(stone_a, stone_b)
  local dx = math.abs(stone_a.x - stone_b.x)
  if dx > 1 then return false end
  local dy = math.abs(stone_a.y - stone_b.y)
  if dy > 1 then return false end
  return dx + dy == 1
end


local function count_neighbors(self, stone)
  return each_neighbor(self, stone, counter)
end


local function neighbors(self, stone)
  return each_neighbor(self, stone, append)
end


local function chunk_from_pivot(self, pivot)
  local checked = make_board()
  local connected = {}
  local q = to_add
  q:init()
  local stone, can_rotate, num_neighbors

  q:add(pivot)

  while not q:is_empty() do
    stone = q:pop()
    can_rotate = false

    if stone == pivot then
      can_rotate = true
    else
      num_neighbors = self:count_neighbors(stone)
      can_rotate = (num_neighbors < 3 or
                    (num_neighbors == 3 and
                     is_neighbor(stone, pivot)))
    end
    checked[stone.x][stone.y] = true

    if can_rotate then
      table.insert(connected, stone)
      stone.rotating = true

      each_neighbor(self, stone, function (other, _)
        if not checked[other.x][other.y] then
          q:add(other)
        end
      end)
    end
  end

  return connected
end

-- interface
game_grid.init = init
game_grid.draw = draw
game_grid.search = search
game_grid.unclick_all = unclick_all
game_grid.chunk_from_pivot = chunk_from_pivot
game_grid.count_neighbors = count_neighbors
game_grid.rotate_stone = rotate_stone
game_grid.clicked_stone = clicked_stone
game_grid.build_links = build_links

-- testing


return game_grid