local BunnyPat = require("libs.TheKillerBunny.BunnyPat")

local pats = 0

function pings.setPats(pat)
  pats = pat
end

BunnyPat.oncePat:register(function()
  pats = pats + 1
  if not player:isLoaded() then return end

  if pats % 120 == 0 then
    local playerPos = player:getPos()

    for _ = 1, math.round(100 * modelScale) do
      particles:newParticle("minecraft:happy_villager", playerPos + (vec(math.random() - 0.5, math.random() * 2, math.random() - 0.5) * modelScale))
    end

    pings.setScale(modelScale + 0.1)
    pings.setPats(pats % 20)
  end
end)

