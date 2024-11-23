--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / The TextField Class.
/ /_/ / /|  / an editable text box.
\____/_/ |_/ Source: link]]
---@diagnostic disable: assign-type-mismatch
local Box = require(....."/../primitives/box") ---@type GNUI.Box
local cfg = require(....."/../config") ---@type GNUI.Config
local eventLib = cfg.event ---@type EventLibAPI
local Theme = require(....."/../theme")

local Button = require(.....".button")


---@class GNUI.TextField : GNUI.Button
---@field isVertical boolean
---@field textField string
---@field editingTextField string
---@field isEditing boolean
---@field pipePos integer
---@field FIELD_CONFIRMED EventLib
---@field FIELD_CHANGED EventLib
local TextField = {}
TextField.__index = function (t,i) return rawget(t,i) or TextField[i] or Button[i] or Box[i] end
TextField.__type = "GNUI.TextField"


---@param parent GNUI.Box?
---@param variant string|"none"|"default"?
---@return GNUI.TextField
function TextField.new(parent,variant)
  ---@type GNUI.TextField
  local new = setmetatable(Button.new(parent,"none"),TextField)
  new.textField = ""
  new.editingTextField = ""
  new.isEditing = false
  new.pipePos = 0
  new.FIELD_CONFIRMED = eventLib.new()
  new.FIELD_CHANGED = eventLib.new()
  
  local id = "GNUI.TextField"..new.id
  
  local pressCanvas
  local chatInput = ""
  local cancel = false
  new.PRESSED:register(function ()
    if new.isEditing then
      new:setEditing(false,cancel)
      pressCanvas.INPUT:remove(id)
      events.CHAR_TYPED:remove(id)
      events.KEY_PRESS:remove(id)
      events.WORLD_RENDER:remove(id)
      if chatInput then
        host:setChatText(chatInput)
      end
    else
      chatInput = host:getChatText()
      new:setEditing(true)
      pressCanvas = new.Canvas
      ---@param event GNUI.InputEvent
      pressCanvas.INPUT:register(function (event)
        if event.key == "key.mouse.left" and event.state == 1 then
          new:click()
        end
        return true
      end,id)
      events.CHAR_TYPED:register(function (char, modifiers, codepoint)
        new:appendTextField(char)
      end,id)
      events.KEY_PRESS:register(function (key, state, modifiers)
        if state ~= 0 then
          local ctrl = math.floor(modifiers / 2) % 2 == 1
          if key == 259 then -- backspace
          if ctrl then
            local finalRemoved = (new.editingTextField:sub(0,math.max(new.pipePos-1,0)):gsub("%s*%S+$", "") or "")
            local pp = new.pipePos
            new.pipePos = #finalRemoved
            new:setTextField(finalRemoved .. new.editingTextField:sub(pp+1,-1))
          else
            new:setTextField(new.editingTextField:sub(0,math.max(new.pipePos-1,0))..new.editingTextField:sub(new.pipePos+1,-1))
            new.pipePos = math.max(0, new.pipePos - 1)
          end
          elseif key == 257 then -- enter
            new:click()
          elseif key == 263 then -- left
            if ctrl then
              new.pipePos = #(new.editingTextField:sub(0,new.pipePos):gsub("%s%S+$", "") or "") 
            else
              new.pipePos = math.max(0, new.pipePos - 1)
            end
            new:updateField()
          elseif key == 262 then -- right
            if ctrl then
              new.pipePos = new.pipePos + #(new.editingTextField:sub(new.pipePos+1,-1):gsub("^%S%s+", "") or "")
            else
              new.pipePos = math.min(#new.editingTextField, new.pipePos + 1)
            end
            new:updateField()
          elseif key == 256 then -- escape
            cancel = true
            new:click()
          end
        end
        return true
      end,id)
      events.WORLD_RENDER:register(function () host:setChatText("") end,id)
    end
  end)
  Theme.style(new,variant)
  return new
end

---Updates the text being displayed in the text field. call this when modifying the fields without using the official APIs.
---@generic self
---@param self self
---@return self
function TextField:updateField()
  ---@cast self GNUI.TextField
  if self.isEditing then
    self:setText(self.editingTextField:sub(0,self.pipePos) .. "|" .. self.editingTextField:sub(self.pipePos+1,-1))
    self.FIELD_CHANGED:invoke(self.editingTextField)
  else
    self:setText(self.textField)
    self.FIELD_CHANGED:invoke(self.textField)
  end
  return self
end

---Sets the exact value of the text field.
---@param text string
---@generic self
---@param self self
---@return self
function TextField:setTextField(text)
  ---@cast self GNUI.TextField
  self.editingTextField = text
  self:updateField()
  return self
end

---Appends a string onto the existing editing text field.
---@generic self
---@param self self
---@return self
function TextField:appendTextField(text)
  ---@cast self GNUI.TextField
  self.editingTextField = self.editingTextField:sub(0,self.pipePos) .. text .. self.editingTextField:sub(self.pipePos+1,-1)
  self.pipePos = self.pipePos + #text
  self:updateField()
  return self
end

---Sets the sate if the text field is being edited or not. setting this to false from true will confirm the text field
---@generic self
---@param self self
---@return self
function TextField:setEditing(isEditing,dontSave)
  ---@cast self GNUI.TextField
  if self.isEditing ~= isEditing then
    self.isEditing = isEditing
    if isEditing then
      self.editingTextField = self.textField
    else
      if not dontSave then
        self.textField = self.editingTextField
        self.FIELD_CONFIRMED:invoke(self.textField)
      end
      self.editingTextField = ""
    end
  end
  self:updateField()
  return self
end

---@private
function TextField:setToggle() end

return TextField
