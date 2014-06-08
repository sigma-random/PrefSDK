local ffi = require("ffi")

ffi.cdef
[[
  const int OperandType_Undefined;
  const int OperandType_Register;
  const int OperandType_Immediate;
  const int OperandType_Address;
  const int OperandType_Expression;
]]

local C = ffi.C
local OperandType = { Undefined  = C.OperandType_Undefined,
                      Register   = C.OperandType_Register,
                      Immediate  = C.OperandType_Immediate,
                      Address    = C.OperandType_Address,
                      Expression = C.OperandType_Expression }

return OperandType