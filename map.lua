local map = {}

-- utility


local function init(self, size)
  local world = {}

  local zol, col

  for z=1, size do
    zol = {}

    for y=1, size do
      col = {}

      for x=1, size do
        table.insert(col, 0)
      end

      table.insert(zol, col)
    end

    table.insert(world, zol)
  end

  self.world = world
  self.size = size

  return self
end

local function place_block(self, x, y, z)
  self.world[z+1][y+1][x+1] = 1
end

local function next_face(self, tri, x, y, z)
  -- floor is selectable
  if z == 0 then
    return {x, y, z, tri}
  end

  -- out of bounds
  if x < 1 or y < 1 then
    return nil
  end

  -- hit a valid block
  if self.world[z][y][x] == 1 then
    return {x, y, z, tri}
  end

  if tri == 0 then
    return self:next_face(2, x-1, y, z)
  elseif tri == 1 then
    return self:next_face(5, x, y-1, z)
  elseif tri == 2 then
    return self:next_face(4, x, y-1, z)
  elseif tri == 3 then
    return self:next_face(1, x, y, z-1)
  elseif tri == 4 then
    return self:next_face(0, x, y, z-1)
  else -- tri == 5
    return self:next_face(3, x-1, y, z)
  end
end

local function generate_collision_tree(self)
  local x, y, tx, ty
  local size = self.size

  local collidables = {}
  local col, hit

  -- left half
  y = self.size
  for sx=1, size do
    col = {}

    for sz=1, size do
      hit = self:next_face(4, sx, y, sz)
      if hit then table.insert(col, hit) end

      hit = self:next_face(5, sx, y, sz)
      if hit then table.insert(col, hit) end
    end

    tx = sx
    ty = y

    while ty > 0 do
      hit = self:next_face(0, tx, ty, size)
      if hit then table.insert(col, hit) end

      tx = tx - 1

      if tx < 1 then
        break
      end

      hit = self:next_face(1, tx, ty, size)
      if hit then table.insert(col, hit) end

      ty = ty - 1
    end

    table.insert(collidables, col)
  end

  -- right half
  x = self.size
  for sy=size, 1, -1 do
    col = {}

    for sz=1, size do
      hit = self:next_face(3, x, sy, sz)
      if hit then table.insert(col, hit) end

      hit = self:next_face(2, x, sy, sz)
      if hit then table.insert(col, hit) end
    end

    tx = x
    ty = sy

    while tx > 0 do
      hit = self:next_face(1, tx, ty, size)
      if hit then table.insert(col, hit) end

      ty = ty - 1

      if ty < 1 then
        break
      end

      hit = self:next_face(0, tx, ty, size)
      if hit then table.insert(col, hit) end

      tx = tx - 1
    end

    table.insert(collidables, col)
  end

  self.collidables = collidables
end


function rotate(self, counterclockwise)
  --[[
  clockwise zol rotation
  x, y = size - y0 + 1, x0

  x0, y0 = y, size - x + 1

  counterclockwise zol rotation
  x, y = y0, size - x + 1

  x0, y0 = size - x + 1, x
  ]]

  local world = self.world
  local zol, old_zol, col
  local size = self.size

  for z=1, size do
    zol = {}
    old_zol = world[z]

    for y=1, size do
      col = {}

      for x=1, size do
        -- clockwise
        if counterclockwise then
          table.insert(col, old_zol[x][size - y + 1])
        else
          table.insert(col, old_zol[size - x + 1][y])
        end
      end

      table.insert(zol, col)
    end

    world[z] = zol
  end

  self:generate_collision_tree()
end

-- interface
map.init = init
map.place_block = place_block
map.generate_collision_tree = generate_collision_tree
map.next_face = next_face
map.rotate = rotate

return map