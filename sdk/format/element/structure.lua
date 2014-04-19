local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local FormatElement = require("sdk.format.element.formatelement")
local FieldArray = require("sdk.format.element.fieldarray")
local Field = require("sdk.format.element.field")

ffi.cdef
[[    
    void* Structure_addStructure(void* __this, const char* name);
    void* Structure_addField(void* __this, int datatype, const char* name, uint64_t count);
    uint64_t Structure_getFieldCount(void* __this);
]]

local C = ffi.C
local Structure = oop.class(FormatElement)

function Structure:__ctor(cthis, databuffer, parentelement)
  FormatElement.__ctor(self, cthis, databuffer, parentelement)
end

function Structure:addStructure(name)
  local s = Structure(C.Structure_addStructure(self._cthis, name), self._databuffer, self)
  self[name] = s
  return s
end

function Structure:addField(datatype, name, count)
  local f = nil
  local cfield = C.Structure_addField(self._cthis, datatype, name, count or 1)
  
  if count and count > 1 then
    f = FieldArray(cfield, self._databuffer, self)
  else
    f = Field(cfield, self._databuffer, self)
  end
  
  self[name] = f
  return f
end

function Structure:fieldCount()
  return C.Structure_getFieldCount(self._cthis)
end

return Structure