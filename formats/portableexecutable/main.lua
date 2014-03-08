require("sdk.math.address")
local FormatDefinition = require("sdk.format.formatdefinition")

local PeDefs = require("formats.portableexecutable.pedefs")
local PeSection = require("formats.portableexecutable.pesection")
local PeInfo = require("formats.portableexecutable.peinfo")

PeFormat = FormatDefinition:new("Portable Executable Format", "Windows", "Dax", "1.0", Endian.LittleEndian)

function PeFormat:createDosHeader(formatmodel)
  local dosheader = formatmodel:addStructure("DosHeader")
  dosheader:addField(DataType.UInt16, "e_magic")
  dosheader:addField(DataType.UInt16, "e_cblp")
  dosheader:addField(DataType.UInt16, "e_cp")
  dosheader:addField(DataType.UInt16, "e_crlc")
  dosheader:addField(DataType.UInt16, "e_cparhdr")
  dosheader:addField(DataType.UInt16, "e_minalloc")
  dosheader:addField(DataType.UInt16, "e_maxalloc")
  dosheader:addField(DataType.UInt16, "e_ss")
  dosheader:addField(DataType.UInt16, "e_sp")
  dosheader:addField(DataType.UInt16, "e_csum")
  dosheader:addField(DataType.UInt16, "e_ip")
  dosheader:addField(DataType.UInt16, "e_cs")
  dosheader:addField(DataType.UInt16, "e_lfarlc")
  dosheader:addField(DataType.UInt16, "e_ovno")
  dosheader:addField(DataType.UInt16, 4, "e_res")
  dosheader:addField(DataType.UInt16, "e_oemid")
  dosheader:addField(DataType.UInt16, "e_oeminfo")
  dosheader:addField(DataType.UInt16, 10, "e_res2")
  dosheader:addField(DataType.UInt32, "e_lfanew")
  
  return dosheader
end

function PeFormat:createNtHeaders(dosheader, formatmodel)
  local ntheaders = formatmodel:addStructure("NtHeaders", dosheader.e_lfanew:value())  
  ntheaders:addField(DataType.UInt32, "Signature")
  
  local fileheader = ntheaders:addStructure("FileHeader")
  fileheader:addField(DataType.UInt16, "Machine"):dynamicInfo(PeInfo.getMachine)
  fileheader:addField(DataType.UInt16, "NumberOfSections")
  fileheader:addField(DataType.UInt32, "TimeDateStamp")
  fileheader:addField(DataType.UInt32, "PointerToSymbolTable")
  fileheader:addField(DataType.UInt32, "NumberOfSymbols")
  fileheader:addField(DataType.UInt16, "SizeOfOptionalHeader")
  fileheader:addField(DataType.UInt16, "Characteristics")
  
  local optionalheader = ntheaders:addStructure("OptionalHeader")
  optionalheader:addField(DataType.UInt16, "Magic"):dynamicInfo(PeInfo.getOptionalHeaderMagic)
  optionalheader:addField(DataType.UInt8, "MajorLinkerVersion")
  optionalheader:addField(DataType.UInt8, "MinorLinkerVersion")
  optionalheader:addField(DataType.UInt32, "SizeOfCode")
  optionalheader:addField(DataType.UInt32, "SizeOfInitializedData")
  optionalheader:addField(DataType.UInt32, "SizeOfUninitializedData")
  optionalheader:addField(DataType.UInt32, "AddressOfEntryPoint"):dynamicInfo(PeInfo.getOptionalHeaderFieldSection)
  optionalheader:addField(DataType.UInt32, "BaseOfCode")
  optionalheader:addField(DataType.UInt32, "BaseOfData")
  optionalheader:addField(DataType.UInt32, "ImageBase")
  optionalheader:addField(DataType.UInt32, "SectionAlignment")
  optionalheader:addField(DataType.UInt32, "FileAlignment")
  optionalheader:addField(DataType.UInt16, "MajorOperatingSystemVersion")
  optionalheader:addField(DataType.UInt16, "MinorOperatingSystemVersion")
  optionalheader:addField(DataType.UInt16, "MajorImageVersion")
  optionalheader:addField(DataType.UInt16, "MinorImageVersion")
  optionalheader:addField(DataType.UInt16, "MajorSubsystemVersion")
  optionalheader:addField(DataType.UInt16, "MinorSubsystemVersion")
  optionalheader:addField(DataType.UInt32, "Win32VersionValue")
  optionalheader:addField(DataType.UInt32, "SizeOfImage")
  optionalheader:addField(DataType.UInt32, "SizeOfHeaders")
  optionalheader:addField(DataType.UInt32, "CheckSum")
  optionalheader:addField(DataType.UInt16, "Subsystem")
  optionalheader:addField(DataType.UInt16, "DllCharacteristics")
  optionalheader:addField(DataType.UInt32, "SizeOfStackReserve")
  optionalheader:addField(DataType.UInt32, "SizeOfStackCommit")
  optionalheader:addField(DataType.UInt32, "SizeOfHeapReserve")
  optionalheader:addField(DataType.UInt32, "SizeOfHeapCommit")
  optionalheader:addField(DataType.UInt32, "LoaderFlags")
  optionalheader:addField(DataType.UInt32, "NumberOfRvaAndSizes")
  local datadirectory = optionalheader:addStructure("DataDirectory")
  
  for i = 1, PeDefs.NumberOfDirectoryEntries do
    local directoryentry = datadirectory:addStructure(PeDefs.DirectoryNames[i])
    directoryentry:addField(DataType.UInt32, "VirtualAddress")
    directoryentry:addField(DataType.UInt32, "Size")
    directoryentry:dynamicInfo(PeInfo.getDirectoryEntrySection)
  end
  
  return ntheaders
end

function PeFormat:createSectionTable(ntheaders, formatmodel)
  local numberofsections = ntheaders.FileHeader.NumberOfSections:value()
  local sectiontable = formatmodel:addStructure("SectionTable", PeSection.imageFirstSection(ntheaders))
  
  for i = 1, numberofsections do
    local section = sectiontable:addStructure("Section" .. i)
    section:dynamicInfo(PeInfo.getSectionName)
    section:addField(DataType.Char, 8, "Name")
    section:addField(DataType.UInt32, "VirtualSize")
    section:addField(DataType.UInt32, "VirtualAddress")
    section:addField(DataType.UInt32, "SizeOfRawData")
    section:addField(DataType.UInt32, "PointerToRawData")
    section:addField(DataType.UInt32, "PointertoRelocations")
    section:addField(DataType.UInt32, "PointertoLineNumbers")
    section:addField(DataType.UInt16, "NumberOfRelocations")
    section:addField(DataType.UInt16, "NumberOfLineNumbers")
    section:addField(DataType.UInt32, "Characteristics")
  end
  
  return sectiontable, numberofsections
end

function PeFormat:validateFormat(buffer)
  local mzheader = buffer:readType(0, DataType.UInt16)
  
  if mzheader ~= 0x5A4D then
    error("Invalid DOS Header")
    return false
  end
  
  local pehdroffset = buffer:readType(0x3C, DataType.UInt32)
  local peheader = buffer:readType(pehdroffset, DataType.UInt32)
  
  if peheader ~= 0x00004550 then
    error("Invalid PE Header")
    return false
  end
  
  return true
end

function PeFormat:parseFormat(formatmodel, buffer)
  local dosheader = self:createDosHeader(formatmodel)
  local ntheaders = self:createNtHeaders(dosheader, formatmodel)
  local sectiontable, numberofsections = self:createSectionTable(ntheaders, formatmodel)
  
  if numberofsections > 0 then
    local sectiondata = formatmodel:addStructure("SectionData", sectiontable.Section1.PointerToRawData:value())
    
    for i = 1, numberofsections do
      local sectionheader = sectiontable["Section" .. i]
      
      if (sectionheader.PointerToRawData:value() ~= 0) and (sectionheader.SizeOfRawData:value() ~= 0) then -- Check if the section exists In-Memory only
        local name = PeSection.sectionDisplayName(sectionheader.VirtualAddress:value(), ntheaders, buffer)
        local section = sectiondata:addStructure(name, sectionheader.PointerToRawData:value())
        PeSection.analyzeSection(sectionheader, section, ntheaders, buffer)
      end
    end
  end
end