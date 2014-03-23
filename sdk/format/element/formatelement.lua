local uuid = require("sdk.math.uuid")
require("sdk.lua.class")
require("sdk.format.element.elementtype")
local uuid = require("sdk.math.uuid")

local FormatElement = class()

function FormatElement:__ctor(offset, name, parent, tree, buffer)
  self._offset = offset
  self._name = name
  self._parent = parent
  self._base = 16
  self._tree = tree
  self._buffer = buffer
  self._id = uuid()
  self._dynamicparser = { completed = false, haschildren = false, parseprocedure = nil }
  
  -- Add 'self' to element pool
  tree.pool[self._id] = self
  
  function self._infoprocedure(formatelement, buffer)
    return ""
  end
end

function FormatElement:tree()
  return self._tree
end

function FormatElement:buffer()
  return self._buffer
end

function FormatElement:dynamicParser(condition, func)
  self._dynamicparser.completed = false
  self._dynamicparser.haschildren = condition
  self._dynamicparser.parseprocedure = func
end

function FormatElement:parseChildren()
  if self._dynamicparser.completed then
    return -- Don't parse again
  end
  
  self._dynamicparser.parseprocedure(self)
  self._dynamicparser.completed = true
end

function FormatElement:isDynamic()
  return (not self._dynamicparser.completed) and (self._dynamicparser.parseprocedure ~= nil)
end

function FormatElement:hasChildren()
  if self._dynamicparser.parseprocedure == nil then
    return false
  elseif type(self._dynamicparser.haschildren) == "function" then
    return (self._dynamicparser.completed == false) and (self._dynamicparser.haschildren(self._tree) == true)
  end
  
  return (not self._dynamicparser.completed) and (self._dynamicparser.haschildren == true)
end

function FormatElement:elementId()
  return self._id
end

function FormatElement:buffer()
  return self._buffer
end

function FormatElement:elementType()
  return ElementType.Invalid
end

function FormatElement:base()
  return self._base
end

function FormatElement:setBase(b)
  self._base = b
end

function FormatElement:name()
  return self._name
end

function FormatElement:value()
  return 0
end

function FormatElement:indexOf(i)
  return -1
end

function FormatElement:size()
  return 0
end

function FormatElement:offset()
  return self._offset
end

function FormatElement:endOffset()
  return self._offset + self:size()
end

function FormatElement:parentElement()
  return self._parent
end

function FormatElement:parentId()
  if self:hasParent() then
    return self._parent:elementId()
  end
  
  return ""
end

function FormatElement:hasParent()
  return next(self._parent) ~= nil
end

function FormatElement:info()
  return self._infoprocedure(self, self._buffer)
end

function FormatElement:dynamicInfo(infoproc)
  self._infoprocedure = infoproc
end

function FormatElement:staticInfo(si)
  self._infoprocedure = function(formatelement, buffer)
                          return si
                        end
end

function FormatElement:displayType()
  return ""
end

function FormatElement:displayName()
  return self:name()
end

function FormatElement:displayValue()
  return ""
end

return FormatElement