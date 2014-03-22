local FormatDefinition = require("sdk.format.formatdefinition")

local ZipFormat = FormatDefinition:new("Zip Format", "Compression", "Dax", "1.0", Endian.LittleEndian)

function ZipFormat.getZipRecordFileName(formatobject, buffer)
  return "'" .. buffer:readString(formatobject.frFileName:offset(), formatobject.frFileNameLength:value()) .. "'"
end

function ZipFormat.getZipDirEntryFileName(formatobject, buffer)
  return "'" .. buffer:readString(formatobject.deFileName:offset(), formatobject.deFileNameLength:value()) .. "'"
end

function ZipFormat:validateFormat(buffer)
  local sign = buffer:readType(0, DataType.UInt32)
  
  if sign ~= 0x04034B50 then
    return false
  end
  
  return true
end
    
function ZipFormat:parseFormat(formatmodel, buffer)  
  local pos = 0
  
  while pos < buffer:size() do
    local tag = buffer:readType(pos, DataType.UInt32)
    
    if tag == 0x04034B50 then
      pos = pos + ZipFormat:defineFileRecord(formatmodel, buffer)
    elseif tag == 0x08074b50 then
      pos = pos + ZipFormat:defineDataDescriptor(formatmodel, buffer)
    elseif tag == 0x02014b50 then
      pos = pos + ZipFormat:defineDirEntry(formatmodel, buffer)
    elseif tag == 0x05054b50 then
      pos = pos + ZipFormat:defineDigitalSignature(formatmodel, buffer)
    elseif tag == 0x06054b50 then
      pos = pos + ZipFormat:defineEndLocator(formatmodel, buffer)
    else
      print("Unknown Tag")
      break
    end
  end
end 

function ZipFormat:defineFileRecord(formatmodel, buffer) -- 0x04034B50
  local zipfilerecord = formatmodel:addStructure("ZipFileRecord")
  
  zipfilerecord:addField(DataType.Char, "frSignature", 4)
  zipfilerecord:addField(DataType.UInt16, "frVersion")
  zipfilerecord:addField(DataType.UInt16, "frFlags")
  zipfilerecord:addField(DataType.UInt16, "frCompression")
  zipfilerecord:addField(DataType.UInt16, "frFileTime")
  zipfilerecord:addField(DataType.UInt16, "frFileDate")
  zipfilerecord:addField(DataType.UInt32, "frCrc")
  zipfilerecord:addField(DataType.UInt32, "frCompressedSize")
  zipfilerecord:addField(DataType.UInt32, "frUncompressedSize")
  zipfilerecord:addField(DataType.UInt16, "frFileNameLength")
  zipfilerecord:addField(DataType.UInt16, "frExtraFieldLength")
  
  local compressedsize = zipfilerecord.frCompressedSize:value()
  local filenamelen = zipfilerecord.frFileNameLength:value()
  local extrafieldlen = zipfilerecord.frExtraFieldLength:value()
  
  if filenamelen > 0 then
    local ffilename = zipfilerecord:addField(DataType.Char, "frFileName", filenamelen)
    zipfilerecord:dynamicInfo(ZipFormat.getZipRecordFileName)
  end
  
  if extrafieldlen > 0 then
    zipfilerecord:addField(DataType.Blob, "frExtraField", extrafieldlen)
  end
  
  if compressedsize > 0 then
    zipfilerecord:addField(DataType.Blob, "frData", compressedsize)
  end
  
  return zipfilerecord:size()
end

function ZipFormat:defineDataDescriptor(formatmodel, buffer) -- 0x08074B50
  local zipdatadescriptor = formatmodel:addStructure("ZipDataDescriptor")
  
  zipdatadescriptor:addField(DataType.Char, "ddSignature", 4)
  zipdatadescriptor:addField(DataType.UInt32, "ddCrc")
  zipdatadescriptor:addField(DataType.UInt32, "frCompressedSize")
  zipdatadescriptor:addField(DataType.UInt32, "frUncompressedSize")
  
  return zipdatadescriptor:size()
end

function ZipFormat:defineDirEntry(formatmodel, buffer) -- 0x02014B50
  local zipdirectoryentry = formatmodel:addStructure("ZipDirectoryEntry")
  
  zipdirectoryentry:addField(DataType.Char, "deSignature", 4)
  zipdirectoryentry:addField(DataType.UInt16, "deVersionMadeBy")
  zipdirectoryentry:addField(DataType.UInt16, "deVersionToExtract")
  zipdirectoryentry:addField(DataType.UInt16, "deFlags")
  zipdirectoryentry:addField(DataType.UInt16, "deCompression")
  zipdirectoryentry:addField(DataType.UInt16, "deFileTime")
  zipdirectoryentry:addField(DataType.UInt16, "deDateTime")
  zipdirectoryentry:addField(DataType.UInt32, "deCrc")
  zipdirectoryentry:addField(DataType.UInt32, "deCompressedSize")
  zipdirectoryentry:addField(DataType.UInt32, "deUncompressedSize")
  zipdirectoryentry:addField(DataType.UInt16, "deFileNameLength")
  zipdirectoryentry:addField(DataType.UInt16, "deExtraFieldLength")
  zipdirectoryentry:addField(DataType.UInt16, "deFileCommentLength")
  zipdirectoryentry:addField(DataType.UInt16, "deDiskNumberStart")
  zipdirectoryentry:addField(DataType.UInt16, "deInternalAttributes")
  zipdirectoryentry:addField(DataType.UInt32, "deExternalAttributes")
  zipdirectoryentry:addField(DataType.UInt32, "deHeaderOffset")
  
  local filenamelength = zipdirectoryentry.deFileNameLength:value()
  local extrafieldlength = zipdirectoryentry.deExtraFieldLength:value()
  local filecommentlength = zipdirectoryentry.deFileCommentLength:value()
  
  if filenamelength > 0 then
    local ffilename = zipdirectoryentry:addField(DataType.Char, "deFileName", filenamelength)
    zipdirectoryentry:dynamicInfo(ZipFormat.getZipDirEntryFileName)
  end
  
  if extrafieldlength > 0 then
    zipdirectoryentry:addField(DataType.Blob, "deExtraField", extrafieldlength)
  end
  
  if filecommentlength > 0 then
    zipdirectoryentry:addField(DataType.Char, "deFileComment", filecommentlength)
  end
  
  return zipdirectoryentry:size()
end

function ZipFormat:defineDigitalSignature(formatmodel, buffer) -- 0x05054B50
  local zipdigitalsignature = formatmodel:addStructure("ZIP_DIGITAL_SIGNATURE")
  zipdigitalsignature:addField(DataType.Char, "dsSignature", 4)
  zipdigitalsignature:addField(DataType.UInt16, "dsDataLength")
  
  local datalength = zipdigitalsignature.dsDataLength:value()
  
  if datalength > 0 then
    zipdigitalsignature:addField(DataType.Blob, "dsData", datalength)
  end
  
  return zipdigitalsignature:size()
end

function ZipFormat:defineEndLocator(formatmodel, buffer) -- 0x06054B50
  local zipendlocator = formatmodel:addStructure("ZipEndLocator")
  zipendlocator:addField(DataType.Char, "elSignature", 4)
  zipendlocator:addField(DataType.UInt16, "elDiskNumber")
  zipendlocator:addField(DataType.UInt16, "elStartDiskNumber")
  zipendlocator:addField(DataType.UInt16, "elEntriesOnDisk")
  zipendlocator:addField(DataType.UInt16, "elEntriesInDirectory")
  zipendlocator:addField(DataType.UInt32, "elDirectorySize")
  zipendlocator:addField(DataType.UInt32, "elDirectoryOffset")
  zipendlocator:addField(DataType.UInt16, "elCommentLength")
  
  local commentlength = zipendlocator.elCommentLength:value()
  
  if commentlength > 0 then
    zipendlocator:addField(DataType.Char, "elComment", commentlength)
  end
  
  return zipendlocator:size()
end