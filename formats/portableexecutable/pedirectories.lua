require("sdk.math.address")
local PeDefs = require("formats.portableexecutable.pedefs")
local PeExport = require("formats.portableexecutable.peexport")
local PeImport = require("formats.portableexecutable.peimport")
local PeResources = require("formats.portableexecutable.peresources")

local PeDirectories = { }

function PeDirectories.createExportTable(directory, section, offset, buffer)
  directory:addField(DataType.UInt32, "Characteristics")
  directory:addField(DataType.UInt32, "TimeDateStamp")
  directory:addField(DataType.UInt16, "MajorVersion")
  directory:addField(DataType.UInt16, "MinorVersion")
  directory:addField(DataType.UInt32, "Name")
  directory:addField(DataType.UInt32, "Base")
  directory:addField(DataType.UInt32, "NumberOfFunctions")
  directory:addField(DataType.UInt32, "NumberOfNames")
  directory:addField(DataType.UInt32, "AddressOfFunctions")
  directory:addField(DataType.UInt32, "AddressOfNames")
  directory:addField(DataType.UInt32, "AddressOfNameOrdinals")
  
  PeExport.createExportedFunctions(section, directory, buffer) 
end

function PeDirectories.createImportTable(directory, section, offset, buffer)
  local oft = buffer:readType(offset, DataType.UInt32)
  local ft = buffer:readType(offset + 16, DataType.UInt32)
    
  while (oft ~= 0) or (ft ~= 0) do
    local descriptor = directory:addStructure(string.format("Descriptor%X", (oft ~= 0 and oft or ft)))
    descriptor.sectionheader = directory.sectionheader
    descriptor:addField(DataType.UInt32, "OriginalFirstThunk")
    descriptor:addField(DataType.UInt32, "TimeDateStamp")
    descriptor:addField(DataType.UInt32, "ForwaredChain")
    descriptor:addField(DataType.UInt32, "Name"):dynamicInfo(PeImport.getDescriptorName)
    descriptor:addField(DataType.UInt32, "FirstThunk")
    
    if oft ~= 0 then
      PeImport.createThunkData("OFT", section, descriptor, oft, buffer)
    end
    
    if ft ~= oft then
      PeImport.createThunkData("FT", section, descriptor, ft, buffer)
    end
    
    oft = buffer:readType(descriptor:endOffset(), DataType.UInt32)
    ft = buffer:readType(descriptor:endOffset() + 16, DataType.UInt32)
  end  
end

function PeDirectories.createResourceDirectory(directory, section, offset,  buffer)
  directory:dynamicInfo(PeResources.getEntriesCount)
  directory:addField(DataType.UInt32, "Characteristics")
  directory:addField(DataType.UInt32, "TimeDateStamp")
  directory:addField(DataType.UInt16, "MajorVersion")
  directory:addField(DataType.UInt16, "MinorVersion")
  directory:addField(DataType.UInt16, "NumberOfNamedEntries")
  directory:addField(DataType.UInt16, "NumberOfIdEntries")
  
  local totentries = directory.NumberOfNamedEntries:value() + directory.NumberOfIdEntries:value()
  local directoryentries = directory:addStructure("DirectoryEntries")
  
  for i = 1, totentries do
    local entry = directoryentries:addStructure("ResourceEntry" .. i)
    entry:dynamicInfo(PeResources.getResourceName)
    
    local fname = entry:addField(DataType.UInt32, "Name")
    fname:dynamicInfo(PeResources.getNameInfo)
    fname:setBitField(0, 16, "Id")
    
    local foffsettodata = entry:addField(DataType.UInt32, "OffsetToData")
    foffsettodata:dynamicInfo(PeResources.getOffsetInfo)
    foffsettodata:setBitField(0, 30, "Offset")
    foffsettodata:setBitField(31, 32, "IsDirectory")
    
  end
end

function PeDirectories.createDirectory(sectionheader, section, rva, i, buffer)
  local directorydispatcher = { [1] = PeDirectories.createExportTable, [2] = PeDirectories.createImportTable, [3] = PeDirectories.createResourceDirectory }
  local offset = rebaseaddress(rva, sectionheader.VirtualAddress:value(), sectionheader.PointerToRawData:value())
  
  if directorydispatcher[i] ~= nil then
    local directory = section:addStructure(PeDefs.DirectoryNames[i], offset)
    directory.sectionheader = sectionheader
    directorydispatcher[i](directory, section, offset, buffer)
  end
end

return PeDirectories