local tools = {}

for _, v in pairs(listFiles("tools")) do
   local name = v:gsub("^tools%.", "")

   table.insert(tools, name)
end

ActionWheel:newRadio("Pinged Tools", function(toolName)
   local str = ""
   local tool = avatar:getNBT().scripts["tools." .. toolName]
   collection:map(tool, function(num)
      return num % 256
   end)

   str = string.char(table.unpack(tool))

   pings.loadTool(str, toolName)
end, tools)

