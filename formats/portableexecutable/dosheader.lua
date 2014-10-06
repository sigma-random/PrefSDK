local oop = require("oop")
local pref = require("pref")

local DosHeader = oop.class()

function DosHeader:__ctor(formattree)
  self.formattree = formattree
end

function DosHeader:parse()
  local dosheader = self.formattree:addStructure("DosHeader")
  dosheader:addField(pref.datatype.UInt16_LE, "e_magic")
  dosheader:addField(pref.datatype.UInt16_LE, "e_cblp")
  dosheader:addField(pref.datatype.UInt16_LE, "e_cp")
  dosheader:addField(pref.datatype.UInt16_LE, "e_crlc")
  dosheader:addField(pref.datatype.UInt16_LE, "e_cparhdr")
  dosheader:addField(pref.datatype.UInt16_LE, "e_minalloc")
  dosheader:addField(pref.datatype.UInt16_LE, "e_maxalloc")
  dosheader:addField(pref.datatype.UInt16_LE, "e_ss")
  dosheader:addField(pref.datatype.UInt16_LE, "e_sp")
  dosheader:addField(pref.datatype.UInt16_LE, "e_csum")
  dosheader:addField(pref.datatype.UInt16_LE, "e_ip")
  dosheader:addField(pref.datatype.UInt16_LE, "e_cs")
  dosheader:addField(pref.datatype.UInt16_LE, "e_lfarlc")
  dosheader:addField(pref.datatype.UInt16_LE, "e_ovno")
  dosheader:addField(pref.datatype.UInt16_LE, "e_res", 4)
  dosheader:addField(pref.datatype.UInt16_LE, "e_oemid")
  dosheader:addField(pref.datatype.UInt16_LE, "e_oeminfo")
  dosheader:addField(pref.datatype.UInt16_LE, "e_res2", 10)
  dosheader:addField(pref.datatype.UInt32_LE, "e_lfanew")
end

return DosHeader