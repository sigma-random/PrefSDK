local oop = require("oop")
local pref = require("pref")

local DataType = pref.datatype
local DosHeader = oop.class()

function DosHeader:__ctor(formattree)
  self.formattree = formattree
end

function DosHeader:parse()
  local dosheader = self.formattree:addStructure("DosHeader")
  dosheader:addField(DataType.UInt16_LE, "e_magic")
  dosheader:addField(DataType.UInt16_LE, "e_cblp")
  dosheader:addField(DataType.UInt16_LE, "e_cp")
  dosheader:addField(DataType.UInt16_LE, "e_crlc")
  dosheader:addField(DataType.UInt16_LE, "e_cparhdr")
  dosheader:addField(DataType.UInt16_LE, "e_minalloc")
  dosheader:addField(DataType.UInt16_LE, "e_maxalloc")
  dosheader:addField(DataType.UInt16_LE, "e_ss")
  dosheader:addField(DataType.UInt16_LE, "e_sp")
  dosheader:addField(DataType.UInt16_LE, "e_csum")
  dosheader:addField(DataType.UInt16_LE, "e_ip")
  dosheader:addField(DataType.UInt16_LE, "e_cs")
  dosheader:addField(DataType.UInt16_LE, "e_lfarlc")
  dosheader:addField(DataType.UInt16_LE, "e_ovno")
  dosheader:addField(DataType.UInt16_LE, "e_res", 4)
  dosheader:addField(DataType.UInt16_LE, "e_oemid")
  dosheader:addField(DataType.UInt16_LE, "e_oeminfo")
  dosheader:addField(DataType.UInt16_LE, "e_res2", 10)
  dosheader:addField(DataType.UInt32_LE, "e_lfanew")
end

return DosHeader