require("errors")

for _, v in pairs(models.models:getChildren()) do
  v:remove()
  models:addChild(v)
end

avars = avars or {}
local _store = figuraMetatables.AvatarAPI.__index.store
figuraMetatables.AvatarAPI.__index.store = function(self, key, val)
  avars[key] = val
end

function events.WORLD_TICK()
  for k, v in pairs(avars) do
    _store(avatar, k, v)
  end
end

if client.compareVersions(client:getVersion(), "1.20.5") > -1 then
  models:newItem("alt")
    :setItem('player_head[profile={name:"APeacefulRabbit"}]')
    :setScale(0)
else
  models:newItem("alt")
    :setItem('player_head{SkullOwner:"APeacefulRabbit"}')
    :setScale(0)
end

function pings.setScale(scale)
  modelScale = scale
end

afk = false

local _store = avatar.store
function events.WORLD_TICK()
  for key, value in pairs(avars) do
    _store(avatar, key, value)
  end
end

for _, v in pairs(listFiles("extensions")) do
  require(v)
end

if host:isHost() then
  ActionWheel = require("libs.TheKillerBunny.ActionWheelPlusPlus")
end

anims = {}
for _, v in pairs(animations:getAnimations()) do
  anims[v:getName()] = v
end

local currentDance = nil
local dances = {
  kazotsky = anims.kazotsky,
  dance = anims.dance,
  Caramelldansen = anims.Caramelldansen,
  CaramelldansenGood = anims.CaramelldansenGood,
  penguin = anims.penguin,
  car = anims.car,
  sit = anims.afk
}
function pings.dance(dance)
  dance = string.lower(tostring(dance))
  if dance and dance ~= "Stop" then
    for k, v in pairs(dances) do
      if string.lower(tostring(k)) == dance then
        v:play()
      else
        v:stop()
      end
    end
  else
    for _, v in pairs(dances) do
      v:stop()
    end
  end
  currentDance = dance
end

do
  local tick = 0
  function events.TICK()
    tick = tick + 1
    if tick % (20 * 30) == 0 then
      pings.dance(currentDance)
    end
  end
end

do
  local awaits = {}
  ---Runs a function when a promise completes
  ---@param promise Future
  function await(promise, func)
    table.insert(awaits, {
      promise = promise,
      func = func
    })
  end

  function events.WORLD_TICK()
    for k, v in pairs(awaits) do
      if v.promise:isDone() then
        v.func(v.promise)
        table.remove(awaits, k)
      end
    end
  end
end

if ActionWheel then
  require("libs.GNamimates.GNUI.main")
  actionPages = {
    ui = ActionWheel:newPage({text = "UI Stuff", color = "#ff3636"}),
    avatar = ActionWheel:newPage({text = "Avatar Menu", color = "#ff7736"})
  }

  actionPages.ui:newToggle("Hide Chat", function(state)
    goofy:setDisableGUIElement("CHAT", state)
  end)

  actionPages.avatar:newButton("Upload Avatar", function()
    goofy:uploadAvatar()
  end)
  actionPages.avatar:newButton("Load Local", function()
    goofy:loadLocalAvatar("Bunnys-Figura-Avatar-V2-2")
  end)
  local btn = actionPages.avatar:newButton("Reload Avatar", function()
    goofy:reloadAvatar(avatar:getUUID())
  end)

  local dnces = {"Stop"}
  for k in pairs(dances) do
    local opt = k:gsub("^.", string.upper)
    table.insert(dnces, opt)
  end

  ActionWheel:newRadio("Dance", function(option)
    pings.dance(option)
  end, dnces)

  ActionWheel:newNumber("Model Scale", function(num)
    pings.setScale(num)
  end, 0, 15, 0.05, 0.8)
end

vanilla_model.PLAYER:setVisible(false)
vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)
modelScale = 0.8

local trustedServers = {
  ["plaza.figuramc.org"] = true,
  ["4p5.nz"] = true
}
local eyeHeight = 1.62
function events.RENDER()
  models.rabbit.root:scale(modelScale)
  avatar:store("patpat.boundingBox", player:getBoundingBox() * modelScale)
  avatar:store("scale", modelScale)

  local trustedServer = (not client.getServerData().ip) or (trustedServers[client.getServerData().ip]) or (player:getPermissionLevel() > 1)

  renderer:setOffsetCameraPivot(0, (trustedServer and (eyeHeight * modelScale) - eyeHeight) or 0, 0)
  renderer:setEyeOffset(0, (trustedServer and (eyeHeight * modelScale) - eyeHeight) or 0, 0)
end

models.rabbit.root.LegLeft:setParentType("LEFT_LEG")
models.rabbit.root.LegRight:setParentType("RIGHT_LEG")
models.rabbit.root.UpperBody.ArmLeft:setParentType("LEFT_ARM")
models.rabbit.root.UpperBody.ArmRight:setParentType("RIGHT_ARM")
models.rabbit.root.UpperBody.TheBody:setParentType("BODY")
models.rabbit.root.UpperBody.TheHead:setParentType("HEAD")

models.rabbit.root.LegLeft.LeftBootPivot:setScale(0.85)
models.rabbit.root.LegRight.RightBootPivot:setScale(0.85)
models.rabbit.root.LegLeft.LeftLeggingPivot:setScale(0.95)
models.rabbit.root.LegRight.RightLeggingPivot:setScale(0.95)
models.rabbit.root.UpperBody.TheHead.HelmetPivot:setScale(0.95)
models.rabbit.root.UpperBody.TheBody.ChestplatePivot:setScale(0.9)
models.rabbit.root.UpperBody.ArmRight.RightShoulderPivot:setScale(0.87)
models.rabbit.root.UpperBody.ArmLeft.LeftShoulderPivot:setScale(0.87)

events.WORLD_TICK:register(function()
  local viewer = client:getViewer()

  if not viewer:isLoaded() then
    return
  end

  local disabled = viewer:getVariable("TKBunny$Disabled") or {}

  require("libs.TheKillerBunny.BunnyPat")
  require("libs.TheKillerBunny.BunnyAsync").forpairs(listFiles("scripts", true), function(_, v)
    if disabled[v] then
      if v == "scripts.common.skull" then
        models.halo.Skull:setVisible(false)
      end

      log("Not loading script " .. v)
      return
    else
      require(v)
    end
  end)

  events.WORLD_TICK:remove("TOBEREMOVED.LOADAVATAR")
end, "TOBEREMOVED.LOADAVATAR")

avatar:store("net_prompter", function()
    local vrs = world.avatarVars()["584fb77d-5c02-468b-a5ba-4d62ce8eabe2"]
    if vrs and vrs.net_acceptor then
        vrs.net_acceptor(net)
    end
end)

