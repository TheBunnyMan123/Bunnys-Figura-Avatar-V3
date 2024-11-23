keybinds:of("Unlock Cursor", "key.keyboard.backslash"):setOnPress(function()
  host:setUnlockCursor(not host:isCursorUnlocked())
end)

