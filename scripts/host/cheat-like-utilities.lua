local function roundVector(vec3)
  vec3:applyFunc(function(x)
    return math.round(x)
  end)

  return vec3
end

local cheats = ActionWheel:newPage("Cheats")
local superJump = cheats:newToggle("Super Jump", function() end)
local windBurst = cheats:newToggle("Wind Burst", function() end)
local fly = cheats:newToggle("Fly", function() end)
local flySpeed = cheats:newNumber("Fly Speed", function() end, 0, 5, 0.1, 1)

cheats:newButton("Lock rotation", function()
  local targetRot = roundVector(player:getRot():div(45, 45)):mul(45, 45)
  goofy:setRot(targetRot.xy)
  goofy:setBodyRot(targetRot.y)
end)

keybinds:fromVanilla("key.attack"):setOnPress(function()
  if windBurst.isPressed and player:getTargetedEntity(host:getReachDistance() * 1.5) then
    goofy:setVelocity(player:getVelocity():mul(1, 0, 1):add(0, 1, 0))
  end
end)
keybinds:fromVanilla("key.jump"):setOnPress(function()
  if superJump.isPressed then
    goofy:setVelocity(player:getVelocity():mul(1, 0, 1):add(0, 1, 0))
    return true
  end
end)
local fward = keybinds:fromVanilla("key.forward"):setOnPress(function()
  if fly.isPressed then
    return true
  end
end)
local bward = keybinds:fromVanilla("key.back"):setOnPress(function()
  if fly.isPressed then
    return true
  end
end)

function events.WORLD_TICK()
  if fly.isPressed then
    if fward:isPressed() then
      goofy:setVelocity(player:getLookDir() * flySpeed.value)
    elseif bward:isPressed() then
      goofy:setVelocity(player:getLookDir() * -flySpeed.value)
    else
      goofy:setVelocity(0, 0, 0)
    end
  end
end

