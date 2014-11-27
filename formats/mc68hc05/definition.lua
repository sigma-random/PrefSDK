local pref = require("pref")

local DataType = pref.datatype
local MC68HC05Rom = pref.format.create("MC68HC05 Microcontroller ROM", "ICs (Freescale)", "Dax", "1.0")

function MC68HC05Rom:parse(formattree)
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

return MC68HC05Rom