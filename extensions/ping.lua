disconnected = false

local disconnectedTick = -100000
local tick = 0
function events.WORLD_TICK()
end

local pingNewIndex = figuraMetatables.PingAPI.__newindex
local pingIndex = figuraMetatables.PingAPI.__index

local function compress(...)
  return ...
end
local function uncompress(...)
  return ...
end

function figuraMetatables.PingAPI.__newindex(self, key, func)
  pingNewIndex(self, key, function(...)
    disconnectedTick = tick
    func(uncompress(...))
  end)
end

function figuraMetatables.PingAPI.__index(self, key)
  return function(...)
    pingIndex(self, key)(compress(...))
  end
end

afk = false
local afkNum = 2^0

function pings.syncToggles(bools)
  afk = (bit32.band(bools, afkNum) ~= 0)
end

local function getNum(num, bool)
  return (bool and num) or 0
end

function syncToggles()
  pings.syncToggles(bit32.bor(
    getNum(afkNum, afk)
  ))
end

function events.WORLD_TICK()
  tick = tick + 1
  if tick % (10*20) == 0 then
    syncToggles()
  end
  disconnected = (disconnectedTick + (20 * 20)) < tick
end

