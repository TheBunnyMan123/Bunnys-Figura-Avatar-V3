function pings.setRabbitPrimaryRenderType(type)
   if type == "OFF" then
      models.rabbit:setPrimaryRenderType()
   else
      models.rabbit:setPrimaryRenderType(type)
   end
end
   
local renderTypes = {
   "OFF",
   "END_PORTAL",
   "END_GATEWAY",
   "TEXTURED_PORTAL",
   "LINES_STRIP",
   "SOLID",
   "BLURRY"
}

if host:isHost() then
   ActionWheel:newRadio("Render Type", function(opt) pings.setRabbitPrimaryRenderType(opt) end, renderTypes, "NONE")
end

