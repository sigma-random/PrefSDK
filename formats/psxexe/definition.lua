local oop = require("sdk.lua.oop")
local FormatDefinition = require("sdk.format.formatdefinition")
local ByteOrder = require("sdk.types.byteorder")
local DataType = require("sdk.types.datatype")

local PsxExeFormat = oop.class(FormatDefinition)

function PsxExeFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
end

function PsxExeFormat:validate()
  self:checkData(0, DataType.AsciiString, "PS-X EXE")
end
    
function PsxExeFormat:parse(formattree)
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

return PsxExeFormat