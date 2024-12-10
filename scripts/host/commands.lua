local commandLib = require("libs.Bitslayn.FoxCommandLib")
local height = models.rabbit.root.UpperBody.TheHead.HeightPivot:getPivot().y / 16

local scaleUnitMultipliers = {
  m = (1/height);
  km = ((1/height) * 1000);
  cm = (100/height);
  mm = (1000/height);
  ["in"] = (0.0254/height);
  ft = ((0.0254*12)/height);
  ["\""] = (0.0254/height);
  ["'"] = ((0.0254*12)/height);
  px = ((0.0254/height)/96);
  pt = ((0.0254/height)/72);
  pc = (((0.0254/height)/96)*12);
  mcpx = ((1/height)/16);
}
print(height, scaleUnitMultipliers)

commandLib:createCommand("scale"):setFunction(function(modifier)
  local unit = modifier:match("[a-z]+$")
  print(tonumber(modifier:match("%d+")))
  modifier = tonumber(modifier:match("[%d.]+")) or 0.8

  print(modifier, modifier * (scaleUnitMultipliers[unit] or 1))
  
  pings.setScale(modifier * (scaleUnitMultipliers[unit] or 1) * math.worldScale)
end)

