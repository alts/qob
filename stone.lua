local stone = {}

local function init(self, x, y)
  self.x = x
  self.y = y
  return self
end


local function fail(self)
  print '-- fail called'
  print ('\t ' .. self.x .. ', ' .. self.y)
  if self.failed then return end

  self.failed = true

  local deps = self.dependents or {}
  for i=1, #deps do
    deps[i]:fail()
  end

  local links = self.links or {}
  for i=1, #links do
    links[i]:notify_failure()
  end

  if self.revert then self.revert() end
end


local function succeed(self)
  print '-- succeed called'
  self.success = true
  local links = self.links or {}
  for i=1, #links do
    links[i]:notify_success()
  end
end


local function notify_success(self)
  print '-- notify_success called'
  self.free = true
end


local function notify_failure(self)
  print '-- notify_failure called'
  if self.failed then return end

  local failures = self.failures or 0
  failures = failures + 1
  if failures == #self.links then
    self:fail()
  end
end

-- interface
stone.init = init
stone.succeed = succeed
stone.fail = fail
stone.notify_success = notify_success
stone.notify_failure = notify_failure

return stone