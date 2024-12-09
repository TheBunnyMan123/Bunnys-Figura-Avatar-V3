#[macros_v1]

function pings.loadTool(tool, name)
   printf("Received tool %s", name)
   load(tool, "pinged-" .. name, _G)()
end

