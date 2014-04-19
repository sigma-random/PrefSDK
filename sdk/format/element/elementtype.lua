local ffi = require("ffi")

ffi.cdef
[[
  const int ElementType_Invalid;
  const int ElementType_Structure;
  const int ElementType_Field;
  const int ElementType_FieldArray;
  const int ElementType_BitField;
]]

local C = ffi.C
local ElementType = { Invalid    = C.ElementType_Invalid,
                      Structure  = C.ElementType_Structure,
                      Field      = C.ElementType_Field,
                      FieldArray = C.ElementType_FieldArray,
                      BitField   = C.ElementType_BitField }

return ElementType
