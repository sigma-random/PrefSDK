local FormatDefinition = require("sdk.format.formatdefinition")
local DataType = require("sdk.types.datatype")
-- local MC68HC05Processor = require("processors.mc68hc05")

local MC68HC05Rom = FormatDefinition.register("MC68HC05 Microcontroller ROM", "ICs (Freescale)", "Dax", "1.0")

function MC68HC05Rom:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
end

function MC68HC05Rom:validateFormat()
  -- Ignore validation
end

function MC68HC05Rom:parseFormat(formattree)
  local mc68hc05 = formattree:addStructure("MC68HC05")
  mc68hc05:addField(DataType.Blob, "DualMapIORegs", 0x10)
  mc68hc05:addField(DataType.Blob, "GenericIORegs", 0x30)
  
  local ram = mc68hc05:addStructure("InternalRAM")
  ram:addField(DataType.Blob, "LowRam", 0x80)
  ram:addField(DataType.Blob, "Stack", 0x40)
  ram:addField(DataType.Blob, "HighRam", 0x140)
  
  mc68hc05:addField(DataType.Blob, "Unused1", 0xDC0)
  mc68hc05:addField(DataType.Blob, "MaskROM", 0x4000)
  mc68hc05:addField(DataType.Blob, "Unused2", 0xAE00)
  mc68hc05:addField(DataType.Blob, "SelfTestROM", 0x1E0)
  mc68hc05:addField(DataType.Blob, "TestVectors", 0x10)
  mc68hc05:addField(DataType.Blob, "UserVectors", 0x10)
end

-- function MC68HC05Rom:generateLoader(loader, formatmodel, buffer)
--   local mc68hc05 = formatmodel:find("MC68HC05")
--   local ram = mc68hc05:find("InternalRAM")
--   local rom = mc68hc05:find("MaskROM")
  
--   loader.processor = MC68HC05Processor:new()  
--   loader:addSegment(ram:offset(), ram:offset(), ram:endOffset(), "Ram", SegmentType.Data)
--   loader:addSegment(rom:offset(), rom:offset(), rom:endOffset(), "Rom", SegmentType.Code)
--   loader:addEntry(rom:offset(), "main")
-- end