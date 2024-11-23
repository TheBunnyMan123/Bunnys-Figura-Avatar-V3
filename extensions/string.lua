---@param str string
---@param on? string
---@return string[]
function string.split(str, on)
  on = on or " "
  local result = {}
  local delimiter = on:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
  for match in (str .. on):gmatch("(.-)" .. delimiter) do
    result[#result+1] = match
  end
  return result
end

