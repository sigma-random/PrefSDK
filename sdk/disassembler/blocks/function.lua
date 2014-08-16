local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local FunctionType = require("sdk.disassembler.blocks.functiontype")
local Instruction = require("sdk.disassembler.instructions.instruction")

ffi.cdef
[[
  int Function_getInstructionCount(void* __this);
  uint64_t Function_getStartAddress(void* __this);
  void Function_addInstruction(void* __this, void* instruction);
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

function Function:addInstruction(instruction)
  return C.Function_addInstruction(self.cthis, instruction.cthis)
end

function Function:instructionAt(idx)
  return Instruction(C.Function_getInstruction(self.cthis, idx))
end

function Function:startAddress()
  return tonumber(C.Function_getStartAddress(self.cthis))
end

return Function
