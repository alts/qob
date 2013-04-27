inspect = require 'lib.inspect.inspect'
__ = require 'lib.underscore'

require 'profiler'
require 'constants'
require 'create'
Timer = require 'lib.hump.timer'
inspect = require 'lib.inspect.inspect'
require 'lib.slam'
fn = require 'fn'


--love.audio.setVolume(0)
love.graphics.setBackgroundColor(255, 255, 255)

local Gamestate = require 'lib.hump.gamestate'

-- game states
local start = require 'play'

-- load other states
local states = {
}

for i = 1, #states do
  require(states[i])
end

--profiler.start()
Gamestate.registerEvents()
Gamestate.switch(start)