local oop = require("oop")
local pref = require("pref")
local PeConstants = require("formats.pe.constants")
local PeFunctions = require("formats.pe.functions")

local DataType = pref.datatype
local NtHeaders = oop.class()

function NtHeaders:__ctor(formattree)
  self.formattree = formattree
  
  self.archdispatcher = { [0x014c] = NtHeaders.parse_i386 }
                          -- [0x8664] = NtHeaders.parse_amd64 }
end

function NtHeaders:imageFirstSection()
  local ntheaders = self.formattree.NtHeaders
  local optheadersize = ntheaders.FileHeader.SizeOfOptionalHeader.value
  return ntheaders.offset + optheadersize + 0x18
end

function NtHeaders.getMachine(machine, formattree)
  return PeConstants.ImageFileMachine[machine.value] or "Unknown"
end

function NtHeaders.getOptionalHeaderMagic(magic, formattree)
  return PeConstants.ImageOptionalHeaderMagic[magic.value] or "Unknown"
end

function NtHeaders.getSectionName(field, formattree)
   local sectionname, isvalid = PeFunctions.sectionName(field.value, formattree)
   
   if isvalid then
     sectionname = string.format("%q", sectionname)
   end
  
  return sectionname
end

function NtHeaders:parseFileHeader(ntheaders)
  local fileheader = ntheaders:addStructure("FileHeader")
  local machine = fileheader:addField(DataType.UInt16_LE, "Machine"):dynamicInfo(NtHeaders.getMachine)
  fileheader:addField(DataType.UInt16_LE, "NumberOfSections")
  fileheader:addField(DataType.UInt32_LE, "TimeDateStamp")
  fileheader:addField(DataType.UInt32_LE, "PointerToSymbolTable")
  fileheader:addField(DataType.UInt32_LE, "NumberOfSymbols")
  fileheader:addField(DataType.UInt16_LE, "SizeOfOptionalHeader")
  fileheader:addField(DataType.UInt16_LE, "Characteristics")
  
  return machine.value
end

function NtHeaders:parseOptionalHeader_i386(ntheaders)
  local optionalheader = ntheaders:addStructure("OptionalHeader")
  optionalheader:addField(DataType.UInt16_LE, "Magic"):dynamicInfo(NtHeaders.getOptionalHeaderMagic)
  optionalheader:addField(DataType.UInt8, "MajorLinkerVersion")
  optionalheader:addField(DataType.UInt8, "MinorLinkerVersion")
  optionalheader:addField(DataType.UInt32_LE, "SizeOfCode")
  optionalheader:addField(DataType.UInt32_LE, "SizeOfInitializedData")
  optionalheader:addField(DataType.UInt32_LE, "SizeOfUninitializedData")
  optionalheader:addField(DataType.UInt32_LE, "AddressOfEntryPoint"):dynamicInfo(NtHeaders.getSectionName)
  optionalheader:addField(DataType.UInt32_LE, "BaseOfCode"):dynamicInfo(NtHeaders.getSectionName)
  optionalheader:addField(DataType.UInt32_LE, "BaseOfData"):dynamicInfo(NtHeaders.getSectionName)
  optionalheader:addField(DataType.UInt32_LE, "ImageBase")
  optionalheader:addField(DataType.UInt32_LE, "SectionAlignment")
  optionalheader:addField(DataType.UInt32_LE, "FileAlignment")
  optionalheader:addField(DataType.UInt16_LE, "MajorOperatingSystemVersion")
  optionalheader:addField(DataType.UInt16_LE, "MinorOperatingSystemVersion")
  optionalheader:addField(DataType.UInt16_LE, "MajorImageVersion")
  optionalheader:addField(DataType.UInt16_LE, "MinorImageVersion")
  optionalheader:addField(DataType.UInt16_LE, "MajorSubsystemVersion")
  optionalheader:addField(DataType.UInt16_LE, "MinorSubsystemVersion")
  optionalheader:addField(DataType.UInt32_LE, "Win32VersionValue")
  optionalheader:addField(DataType.UInt32_LE, "SizeOfImage")
  optionalheader:addField(DataType.UInt32_LE, "SizeOfHeaders")
  optionalheader:addField(DataType.UInt32_LE, "CheckSum")
  optionalheader:addField(DataType.UInt16_LE, "Subsystem")
  optionalheader:addField(DataType.UInt16_LE, "DllCharacteristics")
  optionalheader:addField(DataType.UInt32_LE, "SizeOfStackReserve")
  optionalheader:addField(DataType.UInt32_LE, "SizeOfStackCommit")
  optionalheader:addField(DataType.UInt32_LE, "SizeOfHeapReserve")
  optionalheader:addField(DataType.UInt32_LE, "SizeOfHeapCommit")
  optionalheader:addField(DataType.UInt32_LE, "LoaderFlags")
  optionalheader:addField(DataType.UInt32_LE, "NumberOfRvaAndSizes")
end

function NtHeaders:parseDataDirectory_i386(optionalheader)
  local datadirectory = optionalheader:addStructure("DataDirectory")
  
  for i = 1, PeConstants.NumberOfDirectoryEntries do
    local directoryentry = datadirectory:addStructure(PeConstants.DirectoryNames[i]) -- :dynamicInfo(NtHeaders.getDirectoryEntrySection)
    directoryentry:addField(DataType.UInt32_LE, "VirtualAddress")
    directoryentry:addField(DataType.UInt32_LE, "Size")
  end
end

function NtHeaders:parse_i386(ntheaders)
  self:parseOptionalHeader_i386(ntheaders)
  self:parseDataDirectory_i386(ntheaders.OptionalHeader)
end

function NtHeaders:parse()
  local formattree = self.formattree
  local ntheaders = formattree:addStructure("NtHeaders", formattree.DosHeader.e_lfanew.value)  
  ntheaders:addField(DataType.UInt32_LE, "Signature")
  
  local arch = self:parseFileHeader(ntheaders)
  local archproc = self.archdispatcher[arch]
  
  if archproc then
    archproc(self, ntheaders)
  else
    error("Architecture not supported")
  end
end

return NtHeaders