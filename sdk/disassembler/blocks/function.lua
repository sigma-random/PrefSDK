local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local FunctionType = require("sdk.disassembler.blocks.functiontype")
local Instruction = require("sdk.disassembler.instructions.instruction")

ffi.cdef
[[
  int Function_getInstructionCount(void* __this);
  void* Function_getInstruction(void* __this, int idx);
]]

local C = ffi.C
local Function = oop.class()

function Function:__ctor(cthis)
  self.cthis = cthis
end

function Function:instructionsCount()
  return tonumber(C.Function_getInstructionCount(self.cthis))
end

function Function:instructionAt(idx)
  return Instruction(C.Function_getInstruction(self.cthis, idx))
end

return Function
