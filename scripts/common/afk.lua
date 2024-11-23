#[]
local tick = 0

function pings.setafk(tick)
  tick = tick or 0
end

local oldPos = vectors.vec3(math.huge)

local taskGroup = models:newPart("TKBunny-AFK-TextTasks", "WORLD")

local tasks = {
  {
    age = math.huge,
    task = taskGroup:newText("0"),
    firstTick = 0,
    origin = vec(0, 0, 0)
  }
}

if host:isHost() then
  ActionWheel:newToggle("AFK", function(state)
    afk = state
    syncToggles()
    pings.setafk((state and tick) or 0)
  end)
end

function events.TICK()
  if not BunnyPlate then return end
  for k, v in pairs(tasks) do
    if not afk or v.age > 180 then
      v.task:remove()
      tasks[k] = nil
    end
  end

  if tick % (20 * 30) == 0 then
    pings.setafk((afk and tick) or 0)
    if not afk then
      tick = 0
    end
  end

  if afk then
    if tick % 60 == 0 then
      local task = taskGroup:newText(client.getSystemTime())
        :setText("z")
        :setOutline(true)
      table.insert(tasks, {
        age = 0,
        task = task,
        firstTick = tick,
        origin = models.rabbit.root.UpperBody.TheHead.Hat:partToWorldMatrix():apply():mul(16, 16, 16) 
      })
    end

    BunnyPlate.setCustomBadge("AFK", "", "figura:emoji_symbol", {
      text = "AFK for " .. string.format("%.3f", tick / 20 / 60 / 22) .. " Ash Twin Cycles",
      font = "default"
    })

    BunnyPlate.setExtra(toJson{
      {
        text = "AFK for " .. string.format("%.3f", tick / 20 / 60 / 22) .. " Ash Twin Cycles",
        font = "default",
        color = "#888888"
      },
      (showHealth and {
        text = "HP: " .. math.round(player:getHealth() + player:getAbsorptionAmount()) .. "/" .. player:getMaxHealth(),
        font = "default",
        color = (player:getAbsorptionAmount() > 0 and "gold") or "red"
      } or {text=""})
    })
  else
    BunnyPlate.setExtra(toJson{
      (showHealth and {
        text = "HP: " .. math.round(player:getHealth() + player:getAbsorptionAmount()) .. "/" .. player:getMaxHealth(),
        font = "default",
        color = (player:getAbsorptionAmount() > 0 and "gold") or "red"
      } or {text=""})
    })

    BunnyPlate.setCustomBadge("AFK", "", "figura:emoji_symbol", "")
  end
  tick = tick + 1
end

function events.render(delta)
  for _, v in pairs(tasks) do
    local otick = tick - v.firstTick
    v.age = otick
    v.task:scale(math.abs((otick / 180) - 1) / 1.5):setRot(client.getCameraRot():mul(0, -1, 1))
    local currPos = v.origin + vectors.vec3(otick / 3, otick / 3, otick / 3)
    local prevPos = v.origin + vectors.vec3((otick - 1) / 3, (otick - 1) / 3, (otick - 1) / 3)
    v.task:setPos(math.lerp(prevPos, currPos, delta))
  end
end

