local scripts = avatar:getNBT().scripts
originalScripts = {}
compiledScripts = {}
local macros = require("libs.TheKillerBunny.BunnyMacros")

macros.add {
  ["log%((.-)%)"] = "print(%1)",
  ["printf%((.-)%)"] = "print(string.format(%1))"
}

local cache = {}

local function split(str, on)
    on = on or " "
    local result = {}
    local delimiter = on:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    for match in (str .. on):gmatch("(.-)" .. delimiter) do
        result[#result+1] = match
    end
    return result
end

local function getNonRelativePath(path)
  if not path:match("^%.%./") then
    return path
  end

  local trace = ({pcall(function() error("", 4) end)})[2]:match("stack traceback:(.+)$")
  trace = split(trace:gsub("[ \t]", ""), "\n")
  local script = trace[3]:gsub(":.+$", "")

  return script:gsub("%.", "/"):gsub("/[^/]-$", "/") .. path
end

function require(module, globals)
  module = getNonRelativePath(module)
  local path = module:gsub("([^/]+)/%.%./", "")
  path = path:gsub("%.", "/")

  if not cache[path] then
    cache[path] = {}
  end

  if cache[path][globals or _G] then
    return table.unpack(cache[path][globals or _G] or {})
  end

  local script = scripts[path:gsub("/", ".")]
  if not script then
    error("Invalid module " .. path)
  end

  if math.max(table.unpack(script)) > 255 or math.min(table.unpack(script)) < 0 then
    if collection then
      collection:map(script, function(v) return v%256 end)
    else
      for k in pairs(script) do
        script[k] = script[k] % 256
      end
    end
  end

  local untouchedScript = string.char(table.unpack(script))

  script = macros.format(untouchedScript)

  originalScripts[path:gsub("/", ".")] = untouchedScript
  compiledScripts[path:gsub("/", ".")] = script

  local pathWithoutFile = ""
  path:gsub(".-/", function(s)
    pathWithoutFile = pathWithoutFile .. s
  end)
  pathWithoutFile = pathWithoutFile:gsub("/$", "")

  local func, err = load(script, path, globals or _G)
  assert(func, path .. (err or ": "):match(": .*$"))

  cache[path][globals or _G] = table.pack(func(pathWithoutFile, path:gsub(pathWithoutFile, "")) or "")

  return table.unpack(cache[path][globals or _G] or {})
end

