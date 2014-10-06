local pref = require("pref")

local MC68HC05Rom = pref.format.create("MC68HC05 Microcontroller ROM", "ICs (Freescale)", "Dax", "1.0")

function MC68HC05Rom:parse(formattree)
  local mc68hc05 = formattree:addStructure("MC68HC05")
  mc68hc05:addField(pref.datatype.Blob, "DualMapIORegs", 0x10)
  mc68hc05:addField(pref.datatype.Blob, "GenericIORegs", 0x30)
  
  local ram = mc68hc05:addStructure("InternalRAM")
  ram:addField(pref.datatype.Blob, "LowRam", 0x80)
  ram:addField(pref.datatype.Blob, "Stack", 0x40)
  ram:addField(pref.datatype.Blob, "HighRam", 0x140)
  
  mc68hc05:addField(pref.datatype.Blob, "Unused1", 0xDC0)
  mc68hc05:addField(pref.datatype.Blob, "MaskROM", 0x4000)
  mc68hc05:addField(pref.datatype.Blob, "Unused2", 0xAE00)
  mc68hc05:addField(pref.datatype.Blob, "SelfTestROM", 0x1E0)
  mc68hc05:addField(pref.datatype.Blob, "TestVectors", 0x10)
  mc68hc05:addField(pref.datatype.Blob, "UserVectors", 0x10)
end

-- function MC68HC05Rom:generateLoader()
--   local loader = ProcessorLoader(self, MC68HC05Processor())
--   local stackfield = self.tree.MC68HC05.InternalRAM.Stack
--   local lowramfield = self.tree.MC68HC05.InternalRAM.LowRam
--   local highramfield = self.tree.MC68HC05.InternalRAM.HighRam
--   local dmioregsfield = self.tree.MC68HC05.DualMapIORegs
--   local gpioregsfield = self.tree.MC68HC05.GenericIORegs
--   local romfield = self.tree.MC68HC05.MaskROM
--     
--   loader:addSegment("Stack", SegmentType.Data, stackfield:offset(), stackfield:endOffset())
--   loader:addSegment("LowRam", SegmentType.Data, lowramfield:offset(), lowramfield:endOffset())
--   loader:addSegment("HighRam", SegmentType.Data, highramfield:offset(), highramfield:endOffset())
--   loader:addSegment("DMIO", SegmentType.Data, dmioregsfield:offset(), dmioregsfield:endOffset())
--   loader:addSegment("GPIO", SegmentType.Data, gpioregsfield:offset(), gpioregsfield:endOffset())
--   loader:addSegment("Rom", SegmentType.Code, romfield:offset(), romfield:endOffset())
--   
--   loader:addEntry("main", romfield:offset())
--   return loader
-- end

return MC68HC05Rom