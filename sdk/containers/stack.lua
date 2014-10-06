local oop = require("oop")

local Stack = oop.class()

function Stack:push(...)
  if ... then
    local args = { ... }
  
    for _, v in ipairs(args) do
      table.insert(self, v)
    end
  end
end

function Stack:pop(count)
  local num = count or 1
  
  if num > #self then
    error("Stack Underflow")
  end
  
  local entries = { }
  
  for i = 1, num do
    if #self ~= 0 then
      table.insert(entries, self[#self])
      table.remove(self)
    else
      break
    end
  end
  
  return unpack(entries)
end

function Stack:isEmpty()
  return #self <= 0
end

return Stack