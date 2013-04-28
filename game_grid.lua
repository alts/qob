-- for local testing
local love = love or {}
local clone = clone or function() end

local game_grid = {}
local graphics = love.graphics
local queue = require 'simple_queue'
local to_add = clone(queue)
local stone_obj = require 'stone'
local anim_sequence = require 'anim_sequence'
local anim_collection = require 'animation_collection'
local old_board = nil

local animations = clone(anim_collection)
animations:init()
local ROTATE_TIME = 0.25
local W = math.pi * 2
local theta = 0
local pivot = nil
local turn_count = 0

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
      stone = clone(stone_obj):init(gx, gy)
      board[gx][gy] = stone
      table.insert(stones, stone)
    end
  end

  self.board = board
  self.stones = stones
  self.any_clicked = false
  return self
end

local function yellow_territory(stone)
  return ((stone.x <= 5 and stone.y <= 3) or
          (stone.x >= 13 and stone.y >= 8))
end

local function blue_territory(stone)
  return ((stone.x <= 5 and stone.y >= 8) or
          (stone.x >= 13 and stone.y <= 3))
end

local function draw(self)
  local stones = self.stones
  local stone, cx, cy
  local sin = math.sin(theta)
  local cos = math.cos(theta)

  for i=1,#stones do
    stone = stones[i]
    cx, cy = (stone.x - 1) * GRID_SIZE, (stone.y - 1) * GRID_SIZE
    if stone.to_x then
      cx = GRID_SIZE * ((pivot.x - 1) - sin * (stone.y - pivot.y) + (stone.x - pivot.x) * cos)
      cy = GRID_SIZE * ((pivot.y - 1) + sin * (stone.x - pivot.x) + (stone.y - pivot.y) * cos)
    end

    graphics.setColor(0, 0, 0)
    graphics.circle('fill',
      cx, cy,
      STONE_RADIUS, 40
    )
    if stone.clicked then
      graphics.setColor(255, 0, 0)
    elseif blue_territory(stone) then
      graphics.setColor(0, 0, 255)
    elseif yellow_territory(stone) then
      graphics.setColor(255, 255, 0)
    else
      graphics.setColor(255, 255, 255)
    end

    graphics.circle('fill',
      cx, cy,
      STONE_INNER, 40
    )
  end

  graphics.setColor(255, 0, 255)
  graphics.print(turn_count, 30, 30)
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


local function clean_stones(stones)
  local stone
  for i=1, #stones do
    stone = stones[i]
    stone.links = nil
    stone.rotating = nil
    stone.free = nil
    stone.failed = nil
    stone.failures = nil
    stone.revert = nil
    stone.success = nil
    stone.dependents = nil
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

local function shallow_copy(t)
  return __.map(t, fn.id)
end

local function rotate_stone(self, direction)
  if not any_clicked then
    return
  end

  local stone = self:clicked_stone()

  chunk = self:chunk_from_pivot(stone)

  self:build_links(chunk)

  local other, dx, dy, nx, ny, space

  -- build dependents
  old_board = __.map(self.board, shallow_copy)

  -- wipe moving blocks
  for i=1, #chunk do
    other = chunk[i]
    self.board[other.x][other.y] = false
  end

  print(#chunk .. ' stones in chunk')

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

    if other == stone then
      stone:succeed()
      self.board[other.x][other.y] = other
    else
      print('try: ' .. other.x .. ', ' .. other.y .. ' -> ' .. nx .. ', ' .. ny)
      space = self.board[nx] and self.board[nx][ny]
      if space == false and not other.failed then
        if old_board[nx][ny] then
          if not old_board[nx][ny].dependents then
            old_board[nx][ny].dependents = {}
          end
          table.insert(old_board[nx][ny].dependents, other)
          print '--   made dep'
          local oldx, oldy = other.x, other.y
          other.revert = (function (other, nx, ny)
            return function ()
              self.board[nx][ny] = false
              self.board[oldx][oldy] = other
              other.to_x = nil
              other.to_y = nil
              print(other.x .. ', ' .. other.y .. ' <- ' .. nx .. ', ' .. ny)
            end
          end)(other, nx, ny)
          other.to_x = nx
          other.to_y = ny
          self.board[nx][ny] = other
          print('did: ' .. other.x .. ', ' .. other.y .. ' -> ' .. nx .. ', ' .. ny)
        elseif other.free then
          other:succeed()
          other.to_x = nx
          other.to_y = ny
          self.board[nx][ny] = other
          print('did: ' .. other.x .. ', ' .. other.y .. ' -> ' .. nx .. ', ' .. ny)
        else
          local oldx, oldy = other.x, other.y
          other.revert = (function (other, nx, ny)
            return function ()
              self.board[nx][ny] = false
              self.board[oldx][oldy] = other
              other.to_x = nil
              other.to_y = nil
              print(other.x .. ', ' .. other.y .. ' <- ' .. nx .. ', ' .. ny)
            end
          end)(other, nx, ny)
          other.to_x = nx
          other.to_y = ny
          self.board[nx][ny] = other
          print('did: ' .. other.x .. ', ' .. other.y .. ' -> ' .. nx .. ', ' .. ny)
        end
      else
        other:fail()
        self.board[other.x][other.y] = other
      end
    end
  end

  print 'some still waiting?'
  local again = true
  local count = 0
  local limit = #chunk + 1
  while again and count < limit do
    print 'bleh'
    count =  count + 1
    again = false
    for i=1, #chunk do
      other = chunk[i]
      print(inspect(other))
      if other.to_x and other.failed then
        other.to_x = nil
        other.to_y = nil
        print('releasing: ('..other.x..', '..other.y..')')
      elseif not other.success and not other.failed and other.failures and other.failures > 0 then
        other.to_x = nil
        other.to_y = nil
        other:fail()
        print('releasing: ('..other.x..', '..other.y..')')
      end
    end
  end

  print 'cleaning\n\n'

  clean_stones(self.stones)
  self:unclick_all()

  local factor = (direction == CLOCKWISE) and 1 or -1
  pivot = stone
  animations:add(anim_sequence(
    {ROTATE_TIME, function (dt)
                    theta = theta + W*dt*factor
                  end},
    function ()
      print('done!')
      theta = 0
    end,
    function ()
      local stone
      for i=1,#self.stones do
        stone = self.stones[i]
        if stone.to_x then
          stone.x = stone.to_x
          stone.y = stone.to_y
          stone.to_x = nil
          stone.to_y = nil
        end
      end
    end
  ))

  turn_count = turn_count + 1
end


local function update(self, dt)
  if not animations:is_empty() then
    animations:run(dt)
  end
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


local function each_neighbor(grid, stone, callback, arg)
  local board = grid.board
  local dx = 0
  local dy = 1
  local found

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
  return each_neighbor(self, stone, counter, 0)
end


local function neighbors(self, stone)
  return each_neighbor(self, stone, append, {})
end


local function undo(self)
  local stone
  if old_board then
    self.board = old_board
    for gx=1,#old_board do
      for gy=1, #old_board[gx] do
        stone = old_board[gx][gy]
        if stone then
          stone.x = gx
          stone.y = gy
        end
      end
    end
  end
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

    if not checked[stone.x][stone.y] then
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
game_grid.undo = undo
game_grid.update = update

-- testing


return game_grid