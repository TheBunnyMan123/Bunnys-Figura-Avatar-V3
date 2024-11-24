goofy:setDisableGUIElement("TAB_LIST", true)
local tab = keybinds:fromVanilla("key.playerlist")

local uuidCache = {}
local mojangApiUsernameToUUID = "https://api.mojang.com/users/profiles/minecraft/%s"
local utils = require("libs.TheKillerBunny.BunnyUtils")

if not file:exists("uuidCache.json") then
  file:writeString("uuidCache.json", toJson(uuidCache))
end

uuidCache = parseJson(file:readString("uuidCache.json"))

local tasks = {}
local UI = models:newPart("TKBunny$Tablist", "GUI")

local oldPlayers = ""
local maxWidth = 0
function events.WORLD_RENDER()
  local players = client.getTabList().players
  for _, v in pairs(tasks) do
    v:remove()
  end

  if tab:isPressed() then
    local numCols = math.ceil(#players / 20)
    local leftMost = (client.getScaledWindowSize().x / 2) - (numCols * maxWidth) + (maxWidth * (0.5+(numCols / 2)))
    for k, v in pairs(players) do
      local succ, plate = pcall(function()
        local chat, entity, list = goofy:getAvatarNameplate(uuidCache[v] or v)
        chat = chat:gsub("\n", " "):gsub("\\n", " "):gsub("${name}", v):gsub("�", "")
        entity = entity:gsub("\n", ""):gsub("\\n", ""):gsub("${name}", v):gsub("�", "")
        list = list:gsub("\n", ""):gsub("\\n", ""):gsub("${name}", v):gsub("�", "")

        return list or entity or chat
      end)
      if not succ or plate == uuidCache[v] then
        plate = v
      end

      if client.getTextWidth(plate) > maxWidth then
        maxWidth = client.getTextWidth(plate)
      end

      table.insert(tasks, UI:newText(v)
      :setText(plate)
      :setPos(-(leftMost + (math.floor(k / 20)*maxWidth)), -(10*(((k%20))+1)))
      :setOutline(true)
      :setWidth(maxWidth)
      :setAlignment("CENTER")
      :setBackground(true)
      )
    end
  end

  if toJson(players) ~= oldPlayers then
    oldPlayers = toJson(players)

    for _, v in pairs(players) do
      if uuidCache[v] then goto continue end
      await(net.http:request(mojangApiUsernameToUUID:format(utils.urlFormat(v))):send(), function(response)
        local val = response:getValue()

        if not val then return end
        local code = val:getResponseCode()
        
        if tostring(code) ~= "200" then
          if tostring(code) == "400" then
            uuidCache[v] = v
          end
          return
        end

        local dat = val:getData()
        local buf = data:createBuffer(dat:available())
        buf:readFromStream(dat)
        buf:setPosition(0)

        dat = buf:readString(buf:available())
        local jsonData = parseJson(dat)

        uuidCache[v] = utils.untrimUUID(jsonData.id)

        file:writeString("uuidCache.json", toJson(uuidCache))
      end)
      ::continue::
    end
  end
end

