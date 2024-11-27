local macros = {}
local lib = {}

function lib.add(macrosToAdd)
  for k, v in pairs(macrosToAdd) do
    macros[k] = v
  end
end

function lib.scriptUsesMacros(script)
  local metadata = script:match("^%#%[(.-)%]\n")
  if not metadata then
    return false
  end

  local mdata = {}

  (metadata .. ";"):gsub("(.-)[;,]", function(v)
    mdata[v] = true
  end)

  return mdata.macros_v1
end

function lib.format(script)
  if not lib.scriptUsesMacros(script) then
    return script
  end

  for k, v in pairs(macros) do
    script = script:gsub(k, v)
  end

  return script
end

return lib

