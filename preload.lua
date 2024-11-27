if avatar:getMaxInitCount() < 10000000 then
  figuraMetatables.HostAPI.__index.isHost = function() return false end
end
--figuraMetatables.HostAPI.__index.isHost = function() return false end

require("require")

require("load")

