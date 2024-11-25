local figcolors = {
  AWESOME_BLUE = "#5EA5FF",
  PURPLE = "#A672EF",
  BLUE = "#00F0FF",
  SOFT_BLUE = "#99BBEE",
  RED = "#FF2400",
  ORANGE = "#FFC400",

  CHEESE = "#F8C53A",

  LUA_LOG = "#5555FF",
  LUA_ERROR = "#FF5555",
  LUA_PING = "#A155DA",

  DEFAULT = "#5AAAFF",
  DISCORD = "#5865F2",
  KOFI = "#27AAE0",
  GITHUB = "#FFFFFF",
  MODRINTH = "#1BD96A",
  CURSEFORGE = "#F16436",
}

local errored = false
function tracebackError(msg)
  local split = string.split(msg:gsub("\t", ""), "\n")
  local compose = {}

  local longestLineNumCount = 1
  msg:gsub(":[0-9]-:", function(str)
    local num = str:gsub(":", "")
    if longestLineNumCount < #num then
      longestLineNumCount = #num
    end
  end)

  table.remove(split, 2)
  local message = split[1]
  table.remove(split, 1)

  table.insert(compose, {
    text = "[Traceback]",
    color = "#ff7b72"
  })

  local oldSplit = {}
  for k, v in pairs(split) do
    oldSplit[k] = v
  end

  local iter = 0
  for i = #split, 1, -1 do
    iter = iter + 1
    split[iter] = oldSplit[i]
  end

  for _, v in pairs(split) do
    table.insert(compose, {
      text = "\n"
    })
    local java = v:match("%S-.[Jj]ava.")

    local splitTrace = string.split(v, " ")
    local path = string.split(splitTrace[1], "/")
    local linenum

    path[#path] = path[#path]:gsub(":[0-9]+:", function(str)
      linenum = tostring(str:match("[0-9]+"))
      return ""
    end)

    local oldPath = {}
    for l, w in pairs(path) do
      oldPath[l] = w
    end
    iter = 0
    for i = #oldPath, 1, -1 do
      iter = iter + 1
      path[i] = oldPath[iter]
    end

    linenum = linenum or "0"

    table.insert(compose, {
      text = " ↓ ",
      color = "#797979"
    })
    if java then
      table.insert(compose, {
        text = ("?"):rep(longestLineNumCount),
        color = figcolors.SOFT_BLUE
      })
      table.insert(compose, {
        text = " :",
        color = "gray",
      })
      table.insert(compose, {
        text = v:gsub(".[jJ]ava.: in", ""),
        color = "#f89820"
      })
      table.insert(compose, {
        text = "<Java",
        color = "#797979"
      })
    else
      table.insert(compose, {
        text = ("0"):rep(math.clamp(longestLineNumCount - #linenum, 0, 5)) .. linenum,
        color = figcolors.BLUE
      })
      table.insert(compose, {
        text = " :",
        color = "gray",
      })
    end

    if not java then
      table.insert(compose, {
        text = " " .. path[1],
        color = figcolors.LUA_ERROR
      })
      table.remove(path, 1)
      for _, w in pairs(path) do
        table.insert(compose, {
          text = "<" .. w,
          color = "#797979"
        })
      end
    end

    table.remove(splitTrace, 1)

    if not java then
      table.insert(compose, {
        text = " : ",
        color = "gray"
      })
      table.insert(compose, {
        text = table.concat(splitTrace, " "),
        color = "#896767"
      })
    end
  end

  table.insert(compose, {
    text = "\n[Error]\n",
    color = "#ff7b72"
  })
  table.insert(compose, {
    text = " → ",
    color = "#797979"
  })
  table.insert(compose, {
    text = message:gsub(".*:[0-9]+ ?", ""):gsub("^.", string.upper),
    color = figcolors.LUA_ERROR
  })

  local lex = require("libs.BlueMoonJune.lex")
  table.insert(compose, {
    text = "\n[Code]\n",
    color = "#ff7b72"
  })

  local script = oldSplit[1]:gsub("/", "."):gsub(":.*$", "")
  local line = tonumber(oldSplit[1]:match(":([0-9]+)%S"))
  local code = ""
  for _, v in pairs((avatar:getNBT().scripts or {})[script]) do
    code = code .. string.char(v % 255)
  end
  local oldcode = string.split(code, "\n")
  code = {}
  local readlines = {}
  for i = -5, 5 do
    if not readlines[math.clamp(line + i, 1, #oldcode)] then
      table.insert(code, oldcode[math.clamp(line + i, 1, #oldcode)])
      readlines[math.clamp(line + i, 1, #oldcode)] = true
    end
  end
  code = table.concat(code, "\n")

  for _, v in pairs(lex(code)) do
    if v[1] == "comment" or v[1] == "ws" or v[1] == "mlcom" then
      table.insert(compose, {
        text = v[2],
        color = "#888888"
      })
    elseif v[1] == "word" or v[1] == "number" then
      table.insert(compose, {
        text = v[2],
        color = (v[2] == "true" or v[2] == "false") and "#ff8836" or "#36ffff"
      })
    elseif v[1] == "keyword" then
      table.insert(compose, {
        text = v[2],
        color = "#3636ff"
      })
    elseif v[1] == "string" or v[1] == "mlstring" then
      table.insert(compose, {
        text = v[2],
        color = "#36ff36"
      })
    elseif v[1] == "op" then
      table.insert(compose, {
        text = v[2],
        color = "#ffffff"
      })
    end
  end

  return compose
end

local function newError(msg)
    if errored then return "" end
    errored = true
    local err = tracebackError(msg)

    logJson(toJson({
      table.unpack(err)
    }))

    for _, v in pairs(events:getEvents()) do
      v:clear()
    end

    err = err

    ---@type TextJsonComponent
    local newNameplate = {
      {
        text = "TheKillerBunny ",
        color = "white"
      },
      {
        text = "❌",
        color = "#FF0000",
        bold = true,
        hoverEvent = {
          action = "show_text",
          value =err
        }
      },
      {
        text = "${badges}",
        color = "white"
      }
    }

    nameplate.ALL:setText(toJson(newNameplate))
    nameplate.ENTITY:setOutline(true)

    vanilla_model.ALL:setVisible(true)

    local function remove(model)
      for _, v in pairs(model:getChildren()) do
        remove(v)
      end
      model:remove()
    end
    for _, v in pairs(models:getChildren()) do
      remove(v)
    end

    sounds:stopSound()
    particles:removeParticles()
end

if goofy then 
  function events.ERROR(msg)
    local err = toJson(tracebackError(msg))
    logJson(err)
    goofy:stopAvatar(err)
    return true
  end
else
  local _require = require
  
  function require(module)
    local successAndArgs = table.pack(pcall(_require, module))
    successAndArgs.n = nil
    if not successAndArgs[1] then
      newError(successAndArgs[2])
    else
      table.remove(successAndArgs, 1)
      return table.unpack(successAndArgs)
    end 
  end

  local _newindex = figuraMetatables.EventsAPI.__newindex
  local _register = figuraMetatables.Event.__index.register
  function figuraMetatables.EventsAPI.__newindex(self, event, func)
    _newindex(self, event, function(...)
      local success, error = pcall(func, ...)
      if not success then
        newError(error)
      else
        return error
      end
    end)
  end
  function figuraMetatables.Event.__index.register(self, func, name)
    _register(self, function(...)
      local success, error = pcall(func, ...)
      if not success then
        newError(error)
      else
        return error
      end
    end, name)
  end
end

