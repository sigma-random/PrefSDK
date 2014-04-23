local ffi = require("ffi")

ffi.cdef
[[
  const int OperandType_Void;
  const int OperandType_Register;
  const int OperandType_Memory;
  const int OperandType_Phrasse;
  const int OperandType_Displacement;
  const int OperandType_Immediate;
  const int OperandType_JumpFar;
  const int OperandType_JumpNear;
  const int OperandType_CallFar;
  const int OperandType_CallNear;
]]

local C = ffi.C
local OperandType = { Void      = C.OperandType_Void,
                      Register  = C.OperandType_Register,
                      Memory    = C.OperandType_Memory,
                      Phrase    = C.OperandType_Phrasse,
                      Immediate = C.OperandType_Immediate,
                      JumpFar   = C.OperandType_JumpFar,
                      JumpNear  = C.OperandType_JumpNear,
                      CallFar   = C.OperandType_CallFar,
                      CallNear  = C.OperandType_CallNear }

return OperandType