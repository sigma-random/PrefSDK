local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")
local Operand = require("sdk.disassembler.instructions.operands.operand")
local InstructionCategory = require("sdk.disassembler.instructions.instructioncategory")
local InstructionType = require("sdk.disassembler.instructions.instructiontype")

ffi.cdef
[[
  void* Instruction_create(uint64_t va, uint64_t offset);
  void Instruction_setSize(void* __this, uint64_t size);
  void Instruction_addOperand(void* __this, void* operand);
  void Instruction_setMnemonic(void* __this, const char* mnemonic);
  void Instruction_setCategory(void* __this, int category);
  void Instruction_setType(void* __this, int type);
]]

local C = ffi.C
local Instruction = oop.class()

function Instruction:__ctor(databuffer, endian, processor, address, offset)
  self.databuffer = databuffer
  self.endian = endian
  self.processor = processor
  self.address = address
  self.offset = offset
  self.size = 0
  self.opcode = 0
  self.mnemonic = "???"
  self.category = InstructionCategory.Undefined
  self.type = InstructionType.Undefined
  self.operands = { }
  self.cthis = C.Instruction_create(self.address, self.offset)
end

function Instruction:addOperand(type, value)
  local operand = Operand(self.processor, type, value)
  table.insert(self.operands, operand)
  return operand
end

function Instruction:copyOperand(operand)
  table.insert(self.operands, operand)
end

function Instruction:mergeWith(instr, mnemonic, category, type)
  local mergedinstr = Instruction(self.databuffer, self.endian, self.processor, self.address, self.offset)
  
  if #instr > 0 then
    local sz = 0
    for _, instr in pairs(inst) do
      sz = sz + instr.size
    end
    
    mergedinstr.size = mergedinstr.size + sz
  else
    mergedinstr.size = instr.size
  end
  
  mergedinstr.mnemonic = mnemonic
  
  if category then
    mergedinstr.category = category
  end
  
  if type then
    mergedinstr.type = type
  end
  
  return mergedinstr
end

function Instruction:next(datatype)
  local val = self.databuffer:readType(self.offset + self.size, datatype, self.endian)
  self.size = self.size + DataType.sizeOf(datatype)
  return tonumber(val)
end

function Instruction:compile()
  C.Instruction_setMnemonic(self.cthis, self.mnemonic)
  C.Instruction_setSize(self.cthis, self.size)
  C.Instruction_setCategory(self.cthis, self.category)
  C.Instruction_setType(self.cthis, self.type)
  
  for _, operand in pairs(self.operands) do
    C.Instruction_addOperand(self.cthis, operand.cthis)
    operand:compile()
  end
end

return Instruction
