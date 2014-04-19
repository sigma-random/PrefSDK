local oop = { }

function oop.class(superclass)
  local c = { }
  local meta = { }
  
  c.__index = c
  
  if superclass then
    meta.__index = superclass
  end
  
  function meta.__call(cls, ...)
    local self = setmetatable({ }, cls)
    
    if self.__ctor then
      self:__ctor(...)
    end
    
    return self
  end
  
  return setmetatable(c, meta)
end
 
return oop