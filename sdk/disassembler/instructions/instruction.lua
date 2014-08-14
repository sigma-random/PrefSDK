local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")
local Operand = require("sdk.disassembler.instructions.operands.operand")

ffi.cdef
[[
  void Instruction_updateSize(void* __this, uint64_t size);
  void Instruction_setOpCode(void* __this, uint64_t opcode);
  uint64_t Instruction_getOpCode(void* __this);
  void Instruction_setMnemonic(void* __this, const char* mnemonic);
  const char* Instruction_getMnemonic(void* __this);
  void Instruction_setCategory(void* __this, int category);
  int Instruction_getCategory(void* __this);
  void Instruction_setType(void* __this, int type);
  int Instruction_getType(void* __this);
  uint64_t Instruction_getSize(void* __this);
  uint64_t Instruction_getAddress(void* __this);
  uint64_t Instruction_getOffset(void* __this);
  void Instruction_setFormat(void* __this, const char* s);
  void* Instruction_addOperand(void* __this, int operandtype, int datatype);
  void Instruction_removeOperand(void* __this, int idx);
  void* Instruction_getOperand(void* __this, int idx);
  int Instruction_operandsCount(void* __this);
  void Instruction_clearOperands(void* __this);
  void Instruction_cloneOperand(void* __this, void* operand);
]]

local C = ffi.C
local Instruction = oop.class()

function Instruction:__ctor(cthis, databuffer, endian)
  self.cthis = cthis
  self.databuffer = databuffer
  self.endian = endian
end

function Instruction:address()
  return tonumber(C.Instruction_getAddress(self.cthis))
end

function Instruction:size()
  return tonumber(C.Instruction_getSize(self.cthis))
end

function Instruction:setFormat(instrformat)
  C.Instruction_setFormat(self.cthis, instrformat)
end

function Instruction:setOpCode(opcode)
  C.Instruction_setOpCode(self.cthis, opcode)
end

function Instruction:opCode()
  return tonumber(C.Instruction_getOpCode(self.cthis))
end

function Instruction:setMnemonic(mnemonic)
  C.Instruction_setMnemonic(self.cthis, mnemonic)
end

function Instruction:mnemonic()
  return ffi.string(C.Instruction_getMnemonic(self.cthis))
end

function Instruction:setCategory(category)
  C.Instruction_setCategory(self.cthis, category)
end

function Instruction:category()
  return C.Instruction_getCategory(self.cthis)
end

function Instruction:setType(t)
  C.Instruction_setType(self.cthis, t)
end

function Instruction:type()
  return C.Instruction_getType(self.cthis)
end

function Instruction:addOperand(operandtype, datatype)
  return Operand(C.Instruction_addOperand(self.cthis, operandtype, datatype))
end

function Instruction:removeOperand(idx)
  C.Instruction_removeOperand(self.cthis, idx)
end

function Instruction:operandAt(idx)
  return Operand(C.Instruction_getOperand(self.cthis, idx))
end

function Instruction:operandsCount()
  return tonumber(C.Instruction_operandsCount(self.cthis))
end

function Instruction:clearOperands()
  C.Instruction_clearOperands(self.cthis)
end

function Instruction:cloneOperand(operand)
  C.Instruction_cloneOperand(self.cthis, operand.cthis)
end

function Instruction:next(datatype)
  if self.databuffer == nil then -- Do not modify the instruction if databuffer is invalid
    return
  end
  
  local offset = C.Instruction_getOffset(self.cthis)
  local val = self.databuffer:readType(offset + self:size(), datatype, self.endian)
  
  C.Instruction_updateSize(self.cthis, DataType.sizeOf(datatype))  
  return tonumber(val)
end

return Instruction
