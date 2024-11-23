disconnected = false

local disconnectedTick = -100000
local tick = 0
function events.WORLD_TICK()
  disconnected = (disconnectedTick + (20 * 20)) < tick
  tick = tick + 1
end

local pingNewIndex = figuraMetatables.PingAPI.__newindex
local pingIndex = figuraMetatables.PingAPI.__index

local function compress(...)
  local compressed = table.pack(...)

  return table.unpack(compressed)
end
local function uncompress(...)
  local uncompressed = table.pack(...)

  return table.unpack(uncompressed)
end

function figuraMetatables.PingAPI.__newindex(self, key, func)
  pingNewIndex(self, key, function(...)
    disconnectedTick = tick
    func(uncompress(...))
  end)
end

function figuraMetatables.PingAPI.__index(self, key)
  return function(...)
    if not host:isHost() then return end
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

if not host:isHost() then return end

local tick = 0
function events.WORLD_TICK()
  tick = tick + 1
  if tick % (10*20) == 0 then
    syncToggles()
  end
end
