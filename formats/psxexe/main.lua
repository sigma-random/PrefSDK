-- require("disassembler.mips32")
local FormatDefinition = require("sdk.format.formatdefinition")

local PsxExeFormat = FormatDefinition:new("PSX-EXE Format", "Sony Playstation 1", "Dax", "1.0", Endian.LittleEndian)

function PsxExeFormat:validateFormat(buffer)
  local sign = buffer:readString(0, 8)
  
  if sign ~= "PS-X EXE" then
    return false
  end
    
  return true
end
    
function PsxExeFormat:parseFormat(formattree, buffer)
  local exeheader = formattree:addStructure("ExeHeader")
  exeheader:addField(DataType.Char, "id", 8)  
  exeheader:addField(DataType.UInt32, "text")
  exeheader:addField(DataType.UInt32, "data")
  exeheader:addField(DataType.UInt32, "pc0")
  exeheader:addField(DataType.UInt32, "gp0")
  exeheader:addField(DataType.UInt32, "t_addr")
  exeheader:addField(DataType.UInt32, "t_size")
  exeheader:addField(DataType.UInt32, "d_addr")
  exeheader:addField(DataType.UInt32, "d_size")
  exeheader:addField(DataType.UInt32, "b_addr")
  exeheader:addField(DataType.UInt32, "b_size")
  exeheader:addField(DataType.UInt32, "s_addr")
  exeheader:addField(DataType.UInt32, "s_size")
  exeheader:addField(DataType.UInt32, "SavedSP")
  exeheader:addField(DataType.UInt32, "SavedFP")
  exeheader:addField(DataType.UInt32, "SavedGP")
  exeheader:addField(DataType.UInt32, "SavedRA")
  exeheader:addField(DataType.UInt32, "SavedS0")
  
  local strmarker = buffer:readString(exeheader:size())
  local regionmarker = formattree:addStructure("RegionMarker")
  regionmarker:addField(DataType.Char, "Marker", string.len(strmarker))
  
  local textsection = formattree:addStructure("TextSection", 0x800)
  textsection:addField(DataType.Blob, "Data", exeheader.t_size:value())
end


-- function PsxExeFormat:generateDisassembler(formattree, buffer)
--  local exeheader = formattree:find("EXE_HEADER")
--  local fpc0 = exeheader:find("pc0")
--  local ft_addr = exeheader:find("t_addr")
--  local ft_size = exeheader:find("t_size")
--  local t_addr = ft_addr:value()
--  local t_size = ft_size:value()
  
--  local d = Mips32Disassembler:new()
--  d.baseva = t_addr 
--  d.baseoffset = 0x800 -- Static Offset of PSX-EXE's Text Section
--  d.startoffset = d:vaToOffset(fpc0:value())
  -- self.disassembler.segmentprocedure = nil -- getSectionName
  -- self.disassembler.bytestodisassemble = t_size
--  return d
--end