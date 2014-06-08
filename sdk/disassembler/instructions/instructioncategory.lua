local ffi = require("ffi")

ffi.cdef
[[
  const int InstructionCategory_Undefined;
  const int InstructionCategory_ControlFlow;
  const int InstructionCategory_StackManipulation;
  const int InstructionCategory_LoadStore;
  const int InstructionCategory_TestCompare;
  const int InstructionCategory_Arithmetic;
  const int InstructionCategory_Logical;
  const int InstructionCategory_IO;
  const int InstructionCategory_InterruptTrap;
  const int InstructionCategory_Privileged;
  const int InstructionCategory_NoOperation;
]]

local C = ffi.C
local InstructionCategory = { Undefined         = C.InstructionCategory_Undefined,
                              ControlFlow       = C.InstructionCategory_ControlFlow,
                              StackManipulation = C.InstructionCategory_StackManipulation, 
                              LoadStore         = C.InstructionCategory_LoadStore,
                              TestCompare       = C.InstructionCategory_TestCompare,
                              Arithmetic        = C.InstructionCategory_Arithmetic,
                              Logical           = C.InstructionCategory_Logical,
                              Io                = C.InstructionCategory_IO,
                              InterruptTrap     = C.InstructionCategory_InterruptTrap,
                              Privileged        = C.InstructionCategory_Privileged,
                              NoOperation       = C.InstructionCategory_NoOperation }

return InstructionCategory