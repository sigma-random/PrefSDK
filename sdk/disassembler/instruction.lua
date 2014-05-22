local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")
local Operand = require("sdk.disassembler.operand")

local OperandCount = 6 -- Max Operand Count
local Instruction = oop.class()

function Instruction:__ctor(databuffer, endian, address, virtualaddress)
  self.databuffer = databuffer
  self.address = address
  self.virtualaddress = virtualaddress or address
  self.endian = endian
  self.size = 0
  self.type = 0
    
  for i = 1, OperandCount do
    self["operand" .. tostring(i)] = Operand()
  end
end

function Instruction:next(datatype)
  local val = self.databuffer:readType(self.address + self.size, datatype, self.endian)
  self.size = self.size + DataType.sizeOf(datatype)
  return tonumber(val)
end

return Instruction
