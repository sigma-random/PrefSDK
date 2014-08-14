local ffi = require("ffi")
local oop = require("sdk.lua.oop") 
local DataType = require("sdk.types.datatype")
local OperandType = require("sdk.disassembler.instructions.operands.operandtype")

ffi.cdef
[[
  int Operand_getType(void* __this);
  int Operand_getDataType(void* __this);
  int8_t Operand_getValueInt8(void* __this);
  int16_t Operand_getValueInt16(void* __this);
  int32_t Operand_getValueInt32(void* __this);
  int64_t Operand_getValueInt64(void* __this);
  uint8_t Operand_getValueUInt8(void* __this);
  uint16_t Operand_getValueUInt16(void* __this);
  uint32_t Operand_getValueUInt32(void* __this);
  uint64_t Operand_getValueUInt64(void* __this);
  void Operand_getRegisterName(void* __this);
  void Operand_getDisplayValue(void* __this);
  void Operand_setValueInt8(void* __this, int8_t value);
  void Operand_setValueInt16(void* __this, int16_t value);
  void Operand_setValueInt32(void* __this, int32_t value);
  void Operand_setValueInt64(void* __this, int64_t value);
  void Operand_setValueUInt8(void* __this, uint8_t value);
  void Operand_setValueUInt16(void* __this, uint16_t value);
  void Operand_setValueUInt32(void* __this, uint32_t value);
  void Operand_setValueUInt64(void* __this, uint64_t value);
  void Operand_setRegisterName(void* __this,  const char* regname);
  void Operand_setDisplayValue(void* __this,  const char* value);
]]

local C = ffi.C
local Operand = oop.class()

function Operand:__ctor(cthis)
  self.cthis = cthis
end

function Operand:value()
  local datatype = C.Operand_getDataType(self.cthis)
  
  if DataType.isInteger(datatype) then
    if DataType.isSigned(datatype) then
      if DataType.bitWidth(datatype) == 8 then
        return tonumber(C.Operand_getValueInt8(self.cthis))
      elseif DataType.bitWidth(datatype) == 16 then
        return tonumber(C.Operand_getValueInt16(self.cthis))
      elseif DataType.bitWidth(datatype) == 32 then
        return tonumber(C.Operand_getValueInt32(self.cthis))
      elseif DataType.bitWidth(datatype) == 64 then
        return tonumber(C.Operand_getValueInt64(self.cthis))
      end
    else
      if DataType.bitWidth(datatype) == 8 then
        return tonumber(C.Operand_getValueUInt8(self.cthis))
      elseif DataType.bitWidth(datatype) == 16 then
        return tonumber(C.Operand_getValueUInt16(self.cthis))
      elseif DataType.bitWidth(datatype) == 32 then
        return tonumber(C.Operand_getValueUInt32(self.cthis))
      elseif DataType.bitWidth(datatype) == 64 then
        return tonumber(C.Operand_getValueUInt64(self.cthis))
      end
    end
  end
  
  return ffi.string(C.Operand_getDisplayValue(self.cthis))
end

function Operand:setValue(value, registernames)
  local optype = C.Operand_getType(self.cthis)
  local datatype = C.Operand_getDataType(self.cthis)
  
  if optype == OperandType.Register then
    local reg = registernames and registernames[value] or nil
    C.Operand_setRegisterName(self.cthis, reg or "???")
  end
    
  if DataType.isInteger(datatype) then
    if DataType.isSigned(datatype) then
      if DataType.bitWidth(datatype) == 8 then
        C.Operand_setValueInt8(self.cthis, value)
      elseif DataType.bitWidth(datatype) == 16 then
        C.Operand_setValueInt16(self.cthis, value)
      elseif DataType.bitWidth(datatype) == 32 then
        C.Operand_setValueInt32(self.cthis, value)
      elseif DataType.bitWidth(datatype) == 64 then
        C.Operand_setValueInt64(self.cthis, value)
      end
    else
      if DataType.bitWidth(datatype) == 8 then
        C.Operand_setValueUInt8(self.cthis, value)
      elseif DataType.bitWidth(datatype) == 16 then
        C.Operand_setValueUInt16(self.cthis, value)
      elseif DataType.bitWidth(datatype) == 32 then
        C.Operand_setValueUInt32(self.cthis, value)
      elseif DataType.bitWidth(datatype) == 64 then
        C.Operand_setValueUInt64(self.cthis, value)
      end
    end
  else
    C.Operand_setDisplayValue(self.cthis, "???")
  end
end

return Operand