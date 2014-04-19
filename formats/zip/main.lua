local ByteOrder = require("sdk.types.byteorder")
local FormatDefinition = require("sdk.format.formatdefinition")
local DataType = require("sdk.types.datatype")

local ZipFormat = FormatDefinition.register("Zip Format", "Compression", "Dax", "1.0")

function ZipFormat:getZipRecordFileName(recordfnfield)
  return "'" .. buffer:readString(recordfnfield.frFileName:offset(), recordfnfield.frFileNameLength:value()) .. "'"
end

function ZipFormat:getZipDirEntryFileName(direntryfnfield)
  return "'" .. buffer:readString(direntryfnfield.deFileName:offset(), direntryfnfield.deFileNameLength:value()) .. "'"
end

function ZipFormat:validateFormat()
  self:checkData(0, DataType.UInt32_LE, 0x04034B50)
end
    
function ZipFormat:parseFormat(formattree)  
  local pos = 0
  local databuffer = self.databuffer
  
  while pos < databuffer:size() do
    local tag = databuffer:readUInt32(pos, ByteOrder.LittleEndian)
    
    if tag == 0x04034B50 then
      pos = pos + self:defineFileRecord(formattree)
    elseif tag == 0x08074b50 then
      pos = pos + self:defineDataDescriptor(formattree)
    elseif tag == 0x02014b50 then
      pos = pos + self:defineDirEntry(formattree)
    elseif tag == 0x05054b50 then
      pos = pos + self:defineDigitalSignature(formattree)
    elseif tag == 0x06054b50 then
      pos = pos + self:defineEndLocator(formattree)
    else
      error("Unknown Tag")
    end
  end
end 

function ZipFormat:defineFileRecord(formattree) -- 0x04034B50
  local zipfilerecord = formattree:addStructure("ZipFileRecord")
  
  zipfilerecord:addField(DataType.Char, "frSignature", 4)
  zipfilerecord:addField(DataType.UInt16_LE, "frVersion")
  zipfilerecord:addField(DataType.UInt16_LE, "frFlags")
  zipfilerecord:addField(DataType.UInt16_LE, "frCompression")
  zipfilerecord:addField(DataType.UInt16_LE, "frFileTime")
  zipfilerecord:addField(DataType.UInt16_LE, "frFileDate")
  zipfilerecord:addField(DataType.UInt32_LE, "frCrc")
  zipfilerecord:addField(DataType.UInt32_LE, "frCompressedSize")
  zipfilerecord:addField(DataType.UInt32_LE, "frUncompressedSize")
  zipfilerecord:addField(DataType.UInt16_LE, "frFileNameLength")
  zipfilerecord:addField(DataType.UInt16_LE, "frExtraFieldLength")
  
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

function ZipFormat:defineDataDescriptor(formattree) -- 0x08074B50
  local zipdatadescriptor = formattree:addStructure("ZipDataDescriptor")
  
  zipdatadescriptor:addField(DataType.Char, "ddSignature", 4)
  zipdatadescriptor:addField(DataType.UInt32_LE, "ddCrc")
  zipdatadescriptor:addField(DataType.UInt32_LE, "frCompressedSize")
  zipdatadescriptor:addField(DataType.UInt32_LE, "frUncompressedSize")
  
  return zipdatadescriptor:size()
end

function ZipFormat:defineDirEntry(formattree) -- 0x02014B50
  local zipdirectoryentry = formattree:addStructure("ZipDirectoryEntry")
  
  zipdirectoryentry:addField(DataType.Char, "deSignature", 4)
  zipdirectoryentry:addField(DataType.UInt16_LE, "deVersionMadeBy")
  zipdirectoryentry:addField(DataType.UInt16_LE, "deVersionToExtract")
  zipdirectoryentry:addField(DataType.UInt16_LE, "deFlags")
  zipdirectoryentry:addField(DataType.UInt16_LE, "deCompression")
  zipdirectoryentry:addField(DataType.UInt16_LE, "deFileTime")
  zipdirectoryentry:addField(DataType.UInt16_LE, "deDateTime")
  zipdirectoryentry:addField(DataType.UInt32_LE, "deCrc")
  zipdirectoryentry:addField(DataType.UInt32_LE, "deCompressedSize")
  zipdirectoryentry:addField(DataType.UInt32_LE, "deUncompressedSize")
  zipdirectoryentry:addField(DataType.UInt16_LE, "deFileNameLength")
  zipdirectoryentry:addField(DataType.UInt16_LE, "deExtraFieldLength")
  zipdirectoryentry:addField(DataType.UInt16_LE, "deFileCommentLength")
  zipdirectoryentry:addField(DataType.UInt16_LE, "deDiskNumberStart")
  zipdirectoryentry:addField(DataType.UInt16_LE, "deInternalAttributes")
  zipdirectoryentry:addField(DataType.UInt32_LE, "deExternalAttributes")
  zipdirectoryentry:addField(DataType.UInt32_LE, "deHeaderOffset")
  
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

function ZipFormat:defineDigitalSignature(formattree) -- 0x05054B50
  local zipdigitalsignature = formattree:addStructure("ZipDigitalSignature")
  zipdigitalsignature:addField(DataType.Char, "dsSignature", 4)
  zipdigitalsignature:addField(DataType.UInt16_LE, "dsDataLength")
  
  local datalength = zipdigitalsignature.dsDataLength:value()
  
  if datalength > 0 then
    zipdigitalsignature:addField(DataType.Blob, "dsData", datalength)
  end
  
  return zipdigitalsignature:size()
end

function ZipFormat:defineEndLocator(formattree) -- 0x06054B50
  local zipendlocator = formattree:addStructure("ZipEndLocator")
  zipendlocator:addField(DataType.Char, "elSignature", 4)
  zipendlocator:addField(DataType.UInt16_LE, "elDiskNumber")
  zipendlocator:addField(DataType.UInt16_LE, "elStartDiskNumber")
  zipendlocator:addField(DataType.UInt16_LE, "elEntriesOnDisk")
  zipendlocator:addField(DataType.UInt16_LE, "elEntriesInDirectory")
  zipendlocator:addField(DataType.UInt32_LE, "elDirectorySize")
  zipendlocator:addField(DataType.UInt32_LE, "elDirectoryOffset")
  zipendlocator:addField(DataType.UInt16_LE, "elCommentLength")
  
  local commentlength = zipendlocator.elCommentLength:value()
  
  if commentlength > 0 then
    zipendlocator:addField(DataType.Char, "elComment", commentlength)
  end
  
  return zipendlocator:size()
end