local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")

local SectionTable = oop.class()

function SectionTable:__ctor(formattree, ntheaders)
  self.formattree = formattree
  self.ntheaders = ntheaders
end

function SectionTable:imageFirstSection()
  local ntheaders = self.formattree.NtHeaders
  local optheadersize = ntheaders.FileHeader.SizeOfOptionalHeader:value()
  return ntheaders:offset() + optheadersize + 0x18
end

function SectionTable:rvaInSection(rva, section)
  local sectrva = section.VirtualAddress:value()
  local sectsize = section.VirtualSize:value()
  
  if (rva >= sectrva) and (rva <= (sectrva + sectsize)) then
    return true
  end
  
  return false
end

function SectionTable:sectionFromRva(rva)
  local formattree = self.formattree
  local numberofsections = formattree.NtHeaders.FileHeader.NumberOfSections:value()
  
  if numberofsections > 0 then
    local sectiontable = formattree.SectionTable
    
    for i = 1, numberofsections do
      local section = sectiontable["Section" .. i]
      
      if self:rvaInSection(rva, section) then
        return section
      end
    end
  end
  
  return nil
end

function SectionTable:sectionName(rva)
  local section = self:sectionFromRva(rva)
  
  if section ~= nil then
    return section.Name:value()
  end
  
  return "INVALID"
end

function SectionTable.getSectionName(formatdefinition, section)
  return string.format("%q", section.Name:value())
end

function SectionTable:parse()
  local numberofsections = self.formattree.NtHeaders.FileHeader.NumberOfSections:value()
  
  if numberofsections > 0 then
    local sectionoffset = self:imageFirstSection()
    local sectiontable = self.formattree:addStructure("SectionTable", sectionoffset)
    
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
    
    self.ntheaders:applySectionInfo()
  end
end

return SectionTable