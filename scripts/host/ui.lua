local GNUI = require("libs.GNamimates.GNUI.main")
local button = require("libs.GNamimates.GNUI.element.button")
local box = require("libs.GNamimates.GNUI.primitives.box")

require("libs.TheKillerBunny.BunnyChatUtils")

local screen = GNUI.getScreenCanvas()

local toggleChatContainer = box.new(screen)
toggleChatContainer:setAnchor(0, 1)

local toggleChatButton = button.new(toggleChatContainer, "none"):setAnchor(1, 1, 1, 1)

