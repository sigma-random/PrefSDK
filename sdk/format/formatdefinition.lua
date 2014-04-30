-- local FormatOption = require("sdk.format.formatoption")
local oop = require("sdk.lua.oop")
local uuid = require("sdk.math.uuid")
local ffi = require("ffi")
local DataBuffer = require("sdk.io.databuffer")
local DataType = require("sdk.types.datatype")
local FormatOption = require("sdk.format.formatoption")

ffi.cdef
[[
  typedef const char* FormatId;
  
  void Format_register(const char* name, const char* category, const char* author, const char* version, FormatId formatid);
  void Format_registerOption(FormatId formatid, int optionidx, const char* name);
  void Format_enableDisassembler(FormatId formatid);
  
  bool Format_checkUInt8(void* hexeditdata, uint64_t offset,  uint8_t value);
  bool Format_checkUInt16(void* hexeditdata, uint64_t offset, uint16_t value, int byteorder);
  bool Format_checkUInt32(void* hexeditdata, uint64_t offset, uint32_t value, int byteorder);
  bool Format_checkUInt64(void* hexeditdata, uint64_t offset, uint64_t value, int byteorder);
  bool Format_checkInt8(void* hexeditdata, uint64_t offset, int8_t value);
  bool Format_checkInt16(void* hexeditdata, uint64_t offset, int16_t value, int byteorder);
  bool Format_checkInt32(void* hexeditdata, uint64_t offset, int32_t value, int byteorder);
  bool Format_checkInt64(void* hexeditdata, uint64_t offset, int64_t value, int byteorder);
  bool Format_checkAsciiString(void* hexeditdata, uint64_t offset, const char* value);
]]

local C = ffi.C
local FormatDefinition = oop.class()

function FormatDefinition:__ctor(databuffer)
  self.validated = false
  self.databuffer = databuffer
  self.elementsinfo = { }
  self.dynamicelements = { }
end

function FormatDefinition.register(name, category, author, version)
  local formatid = uuid()
  local formattype = oop.class(FormatDefinition)
  
  formattype.id = formatid
  formattype.options = { }
  
  Sdk.formatlist[formatid] = formattype -- Store Format Definition's type
  C.Format_register(name, category, author, version, formatid) -- Notify PREF that a new format has been created
  return formattype
end

function FormatDefinition:registerOption(name, action)
  local opt = FormatOption(name, action)
  
  table.insert(self.options, opt)
  C.Format_registerOption(self.id, #self.options, name)
end

function FormatDefinition:checkData(offset, datatype, value)  
  local values = { }
    
  if type(value) == "table" then
    values = value    
  else
    table.insert(values, value)
  end
  
  local baseoffset = self.databuffer.baseoffset
  
  for i,v in ipairs(values) do  
    if datatype == DataType.AsciiString then
      self.validated = C.Format_checkAsciiString(self.databuffer.cthis, offset, v)
    elseif DataType.isSigned(datatype) then
      if DataType.bitWidth(datatype) == 8 then
        self.validated = C.Format_checkInt8(self.databuffer.cthis, baseoffset + offset, ffi.new("int8_t", v))
      elseif DataType.bitWidth(datatype) == 16 then
        self.validated = C.Format_checkInt16(self.databuffer.cthis, baseoffset + offset, ffi.new("int16_t", v), DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 32 then
        self.validated = C.Format_checkInt32(self.databuffer.cthis, baseoffset + offset, ffi.new("int32_t", v), DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 64 then
        self.validated = C.Format_checkInt64(self.databuffer.cthis, baseoffset + offset, ffi.new("int64_t", v), DataType.byteOrder(datatype))
      else
        error("FormatDefinition:checkData(): Unsupported DataType")
      end
    else
      if DataType.bitWidth(datatype) == 8 then
        self.validated = C.Format_checkUInt8(self.databuffer.cthis, baseoffset + offset, ffi.new("uint8_t", v))
      elseif DataType.bitWidth(datatype) == 16 then
        self.validated = C.Format_checkUInt16(self.databuffer.cthis, baseoffset + offset, ffi.new("uint16_t", v), DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 32 then
        self.validated = C.Format_checkUInt32(self.databuffer.cthis, baseoffset + offset, ffi.new("uint32_t", v), DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 64 then
        self.validated = C.Format_checkUInt64(self.databuffer.cthis, baseoffset + offset, ffi.new("uint64_t", v), DataType.byteOrder(datatype))
      else
        error("FormatDefinition:checkData(): Unsupported DataType")
      end
    end
    
    if self.validated == true then
      break
    end
  end
  
  if self.validated == false then
    if type(value) ~= "table" and DataType.isInteger(datatype) then
      error(string.format("Expected %X at offset %08X", value, baseoffset + offset))
    else
      error(string.format("Expected %s at offset %08X", value, baseoffset + offset))
    end
  end
end

function FormatDefinition:validateFormat()
  -- This method must be reimplemented
end

function FormatDefinition:parseFormat(formattree)
  -- This method must be reimplemented
end

function FormatDefinition:generateLoader()
  return nil
end

return FormatDefinition