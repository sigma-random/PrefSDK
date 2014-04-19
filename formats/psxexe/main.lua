-- require("disassembler.mips32")
local FormatDefinition = require("sdk.format.formatdefinition")
local DataType = require("sdk.types.datatype")

local PsxExeFormat = FormatDefinition.register("PSX-EXE Format", "Sony Playstation 1", "Dax", "1.0")

function PsxExeFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
end

function PsxExeFormat:validateFormat()
  self:checkData(0, DataType.AsciiString, "PS-X EXE")
end
    
function PsxExeFormat:parseFormat(formattree)
  local exeheader = formattree:addStructure("ExeHeader")
  exeheader:addField(DataType.Character, "id", 8)  
  exeheader:addField(DataType.UInt32_LE, "text")
  exeheader:addField(DataType.UInt32_LE, "data")
  exeheader:addField(DataType.UInt32_LE, "pc0")
  exeheader:addField(DataType.UInt32_LE, "gp0")
  exeheader:addField(DataType.UInt32_LE, "t_addr")
  exeheader:addField(DataType.UInt32_LE, "t_size")
  exeheader:addField(DataType.UInt32_LE, "d_addr")
  exeheader:addField(DataType.UInt32_LE, "d_size")
  exeheader:addField(DataType.UInt32_LE, "b_addr")
  exeheader:addField(DataType.UInt32_LE, "b_size")
  exeheader:addField(DataType.UInt32_LE, "s_addr")
  exeheader:addField(DataType.UInt32_LE, "s_size")
  exeheader:addField(DataType.UInt32_LE, "SavedSP")
  exeheader:addField(DataType.UInt32_LE, "SavedFP")
  exeheader:addField(DataType.UInt32_LE, "SavedGP")
  exeheader:addField(DataType.UInt32_LE, "SavedRA")
  exeheader:addField(DataType.UInt32_LE, "SavedS0")
  
  local regionmarker = formattree:addStructure("RegionMarker")
  regionmarker:addField(DataType.AsciiString, "Marker")
  
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