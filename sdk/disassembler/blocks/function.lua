local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local Block = require("sdk.disassembler.blocks.block")
local FunctionType = require("sdk.disassembler.blocks.functiontype")

ffi.cdef
[[
  void* Function_create(int functiontype, const char* name, uint64_t startaddress, uint64_t endaddress);
  void Function_addReference(void* __this, uint64_t address, int referencetype);
  void Function_addInstruction(void* __this, void* instruction);
]]

local C = ffi.C
local Function = oop.class(Block)

function Function:__ctor(type, startaddress, name)
  Block.__ctor(self, startaddress, startaddress)
  
  self.type = type
  self.name = name or string.format("sub_%X", startaddress)
  self.cthis = C.Function_create(type, self.name, startaddress, startaddress)
  self.instructions = { }
  
  self.sortbyaddress = function(instr1, instr2)
    return instr1.address < instr2.address
  end
end

function Function:addReference(address, referencetype)
  C.Function_addReference(self.cthis, address, referencetype)
end

function Function:addInstruction(instruction)
  local newendaddress = instruction.address + instruction.size
  table.bininsert(self.instructions, instruction, self.sortbyaddress)
  
  if newendaddress > self.endaddress then
    self.endaddress = newendaddress
  end
end

function Function:compile()
  for _, instr in pairs(self.instructions) do
    C.Function_addInstruction(self.cthis, instr.cthis)
    instr:compile()
  end
end

return Function
