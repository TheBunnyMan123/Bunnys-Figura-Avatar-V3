local lib = {}

function lib.run(code)
  local out = ""
  local tape = {}
  local tapePointer = 1
  local codePointer = 1
  local loopPointers = {}

  while codePointer <= #code do
    local pointerChanged = false
    tapePointer = tapePointer % 30000
    tape[tapePointer] = (tape[tapePointer] or 0) % 256

  end

  return out
end

function lib.runLimited(code, max, input, codePointer, tokens, tape, tapePointer, out, newInput, loopPointers)
  max = max or 1000
  input = newInput or input or ""

  out = out or ""
  tape = tape or {}
  tapePointer = tapePointer or 1
  codePointer = codePointer or 1
  loopPointers = loopPointers or {}

  local function getToken(chars)
    if chars:match("[%+%-]") then
      local _, add = chars:gsub("%+", "")
      local _, sub = chars:gsub("%-", "")

      return {
        token = "add",
        count = add - sub
      }
    elseif chars:match("[<>]") then
      local _, add = chars:gsub(">", "")
      local _, sub = chars:gsub("<", "")

      return {
        token = "shiftTape",
        count = add - sub
      }
    elseif chars:match("%.") then
      return {
        token = "print",
        count = #chars
      }
    elseif chars:match(",") then
      return {
        token = "input",
        count = #chars
      }
    elseif chars:match("%[") then
      return {
        token = "startLoop",
        count = 1
      }
    elseif chars:match("%]") then
      return {
        token = "endLoop",
        count = 1
      }
    end

    return {token="",count=0}
  end

  local instructions = 0

  while (codePointer <= #code) and (instructions <= max) do
    instructions = instructions + 1
    local pointerChanged = false
    tape[tapePointer] = (tape[tapePointer] or 0) % 256

    local token = string.sub(code, codePointer, codePointer)
    local tkn = token

    if tkn == "+" then
      tape[tapePointer] = (tape[tapePointer] + 1) % 256
    elseif tkn == "-" then
      tape[tapePointer] = (tape[tapePointer] - 1) % 256
    elseif tkn == "<" then
      tapePointer = tapePointer - 1
    elseif tkn == ">" then
      tapePointer = tapePointer + 1
    elseif tkn == "." then
      out = out .. string.char(tape[tapePointer])
    elseif tkn == "," then
        tape[tapePointer] = input[1]
        table.remove(input, 1)
    elseif tkn == "[" then
      if tape[tapePointer] > 0 then
        instructions = instructions - 1
        table.insert(loopPointers, codePointer)
      else
        local bracketCount = 1
        while (instructions <= max) and bracketCount > 0 do
          instructions = instructions + 1
          codePointer = codePointer + 1
          if tkn == "[" then
            bracketCount = bracketCount + 1
          elseif tkn == "]" then
            bracketCount = bracketCount - 1
          end
        end
      end
    elseif tkn == "]" then
      instructions = instructions - 1
      local pointer = loopPointers[#loopPointers]
      loopPointers[#loopPointers] = nil

      if (tape[tapePointer] % 256) == 0 then
        goto continue
      else
        pointerChanged = true
        codePointer = pointer
        goto continue
      end
    end

    ::continue::
    if not pointerChanged then
      codePointer = codePointer + 1
    end
  end

  if instructions > max then
    return false, codePointer, tokens, tape, tapePointer, out, input, loopPointers
  end

  return out
end

return lib

