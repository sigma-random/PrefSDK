function class(superclass)
  local c = { }
  local meta = { }
  
  if supeclass then
    meta.__index = supeclass
  else
    meta.__index = c
  end
  
  function meta.__call(self, ...)
    local instance = setmetatable({ }, { __index = c})
    
    if instance.__ctor then
      instance.__ctor(instance, ...)
    end
    
    return instance
  end
  
  return setmetatable(c, meta)
end
