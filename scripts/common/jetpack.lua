local pack = models.rabbit.root.UpperBody.TheBody.Jetpack
local smokePivotLeft = pack.SmokePivotLeft
local smokePivotRight = pack.SmokePivotRight

local flight = false

function events.TICK()
  local jetpackOn = (player:getGamemode() == "CREATIVE") or (player:getItem(5).id == "minecraft:elytra") or creativeFlying
  if player:getVelocity():length() > 0.22 and player:getVehicle() and player:getVehicle():getType() == "minecraft:minecart" then
    jetpackOn = true
  elseif player:getVehicle() and player:getVehicle():getType() == "minecraft:minecart" then
    jetpackOn = false
  end

  for _, v in pairs(player:getNbt().active_effects or {}) do
    if v.id == "minecraft:levitation" or v.id == "minecraft:slow_falling" then
      jetpackOn = true
    end
  end

  pack:setVisible(jetpackOn)
  local smokeOn = player:isGliding() or creativeFlying
  smokeOn = smokeOn and jetpackOn
  if player:getVelocity():length() > 0.22 and player:getVehicle() and player:getVehicle():getType() == "minecraft:minecart" then
    smokeOn = true
  elseif player:getVehicle() and player:getVehicle():getType() == "minecraft:minecart" then
    smokeOn = false
  end
  
  if smokeOn then
    local velocity = pack:partToWorldMatrix().c2.xyz * -4
    local colorBase = vec(1, 1, 1)
    particles:newParticle("minecraft:dust 1 1 1 2", smokePivotLeft:partToWorldMatrix():apply(0,0,0))
      :setVelocity(velocity)
      :setScale(0.75)
      :setLifetime(40)
      :setColor(colorBase - (math.random() / 5))
    particles:newParticle("minecraft:dust 1 1 1 2", smokePivotRight:partToWorldMatrix():apply(0,0,0))
      :setVelocity(velocity)
      :setScale(0.75)
      :setLifetime(40)
      :setColor(colorBase - (math.random() / 5))
  end
end

