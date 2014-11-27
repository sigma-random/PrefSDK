local oop = require("oop")
local PeFunctions = require("formats.pe.functions")

local DataType = pref.datatype
local SectionTable = oop.class()

function SectionTable:__ctor(formattree)
  self.formattree = formattree
end

function SectionTable.getSectionName(section, formattree)
  return string.format("%q", section.Name.value)
end

function SectionTable:parse()
  local formattree = self.formattree
  local numberofsections = formattree.NtHeaders.FileHeader.NumberOfSections.value
  
  if numberofsections > 0 then
    local sectionoffset = PeFunctions.imageFirstSection(formattree)
    local sectiontable = formattree:addStructure("SectionTable", sectionoffset)
    
     for i = 1, numberofsections do
      local section = sectiontable:addStructure("Section" .. i):dynamicInfo(SectionTable.getSectionName)
      section:addField(DataType.Character, "Name", 8)
      section:addField(DataType.UInt32_LE, "VirtualSize")
      section:addField(DataType.UInt32_LE, "VirtualAddress")
      section:addField(DataType.UInt32_LE, "SizeOfRawData")
      section:addField(DataType.UInt32_LE, "PointerToRawData")
      section:addField(DataType.UInt32_LE, "PointertoRelocations")
      section:addField(DataType.UInt32_LE, "PointertoLineNumbers")
      section:addField(DataType.UInt16_LE, "NumberOfRelocations")
      section:addField(DataType.UInt16_LE, "NumberOfLineNumbers")
      section:addField(DataType.UInt32_LE, "Characteristics")
    end
  end
end

return SectionTable