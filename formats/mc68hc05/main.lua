local FormatDefinition = require("sdk.format.formatdefinition")
local MC68HC05Processor = require("processors.mc68hc05")

local MC68HC05Rom = FormatDefinition:new("MC68HC05 Microcontroller ROM", "ICs (Freescale)", "Dax", "1.0", Endian.BigEndian)

function MC68HC05Rom:validateFormat()
  return true
end

function MC68HC05Rom:parseFormat(formatmodel, buffer)
  local mc68hc05 = formatmodel:addStructure("MC68HC05")
  mc68hc05:addField(DataType.Blob, 0x10, "DualMapIORegs")
  mc68hc05:addField(DataType.Blob, 0x30, "GenericIORegs")
  
  local ram = mc68hc05:addStructure("InternalRAM")
  ram:addField(DataType.Blob, 0x80, "LowRam")
  ram:addField(DataType.Blob, 0x40, "Stack")
  ram:addField(DataType.Blob, 0x140, "HighRam")
  
  mc68hc05:addField(DataType.Blob, 0xDC0, "Unused1")
  mc68hc05:addField(DataType.Blob, 0x4000, "MaskROM")
  mc68hc05:addField(DataType.Blob, 0xAE00, "Unused2")
  mc68hc05:addField(DataType.Blob, 0x1E0, "SelfTestROM")
  mc68hc05:addField(DataType.Blob, 0x10, "TestVectors")
  mc68hc05:addField(DataType.Blob, 0x10, "UserVectors")
end

function MC68HC05Rom:generateLoader(loader, formatmodel, buffer)
  local mc68hc05 = formatmodel:find("MC68HC05")
  local ram = mc68hc05:find("InternalRAM")
  local rom = mc68hc05:find("MaskROM")
  
  loader.processor = MC68HC05Processor:new()  
  loader:addSegment(ram:offset(), ram:offset(), ram:endOffset(), "Ram", SegmentType.Data)
  loader:addSegment(rom:offset(), rom:offset(), rom:endOffset(), "Rom", SegmentType.Code)
  loader:addEntry(rom:offset(), "main")
end