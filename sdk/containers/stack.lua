local Stack = { }

function Stack:new()
  local o = setmetatable({ }, { __index = Stack })
  return o
end

function Stack:push(...)
  for _, v in ipairs{...} do
    self[#self + 1] = v
  end
end

function Stack:pop(count)
  local num = count or 1
  
  if num > #self then
    error("Stack Underflow")
  end
  
  local ret = { }
  
  for i = num, 1, -1 do
    ret[#ret + 1] = table.remove(self)
  end
  
  return unpack(ret)
end

return Stack