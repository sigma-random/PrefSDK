require("sdk.lua.class")
require("sdk.format.element.elementtype")

FormatElement = class()

function FormatElement:__ctor(offset, name, parent, tree, buffer)
  self._offset = offset
  self._name = name
  self._parent = parent
  self._base = 16
  self._buffer = tree
  self._formattree = buffer
  
  function self._infoprocedure(formatelement, buffer)
    return ""
  end
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

function FormatElement:size()
  return 0
end

function FormatElement:offset()
  return self._offset
end

function FormatElement:endOffset()
  return self._offset + self:size()
end

function FormatElement:parent()
  return self._parent
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