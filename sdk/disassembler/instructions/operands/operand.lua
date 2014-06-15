local ffi = require("ffi")
local oop = require("sdk.lua.oop") 
local DataType = require("sdk.types.datatype")
local OperandType = require("sdk.disassembler.instructions.operands.operandtype")

ffi.cdef
[[
  void* Operand_create(int type);
  void Operand_setDisplayValue(void* __this,  const char* value);
]]

local C = ffi.C
local Operand = oop.class()

function Operand:__ctor(processor, type, value)
  self.processor = processor
  self.type = type
  self.value = value
  self.cthis = C.Operand_create(type)
  
  if type == OperandType.Register and processor.registernames[value] then
    self.displayvalue = "$" .. processor.registernames[value]
  elseif (type == OperandType.Immediate) or (type == OperandType.Address) then
    self.displayvalue = string.format("%08Xh", value)
  end
  
  if self.displayvalue == nil then
    self.displayvalue = "???" -- If something wrong display question marks
  end
end

function Operand:compile()
  C.Operand_setDisplayValue(self.cthis, self.displayvalue)
end

return Operand