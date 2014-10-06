local ZipFunctions = { }

function ZipFunctions.getZipRecordFileName(recordfnfield, formattree)
  local buffer = formattree.buffer
  
  return "'" .. buffer:readString(recordfnfield.frFileName.offset, recordfnfield.frFileNameLength.value) .. "'"
end

function ZipFunctions.getZipDirEntryFileName(direntryfnfield, formattree)
  local buffer = formattree.buffer
  
  return "'" .. buffer:readString(direntryfnfield.deFileName.offset, direntryfnfield.deFileNameLength.value) .. "'"
end

function ZipFunctions.defineFileRecord(formattree) -- 0x04034B50
  local zipfilerecord = formattree:addStructure("ZipFileRecord")
  
  zipfilerecord:addField(pref.datatype.Character, "frSignature", 4)
  zipfilerecord:addField(pref.datatype.UInt16_LE, "frVersion")
  zipfilerecord:addField(pref.datatype.UInt16_LE, "frFlags")
  zipfilerecord:addField(pref.datatype.UInt16_LE, "frCompression")
  zipfilerecord:addField(pref.datatype.UInt16_LE, "frFileTime")
  zipfilerecord:addField(pref.datatype.UInt16_LE, "frFileDate")
  zipfilerecord:addField(pref.datatype.UInt32_LE, "frCrc")
  zipfilerecord:addField(pref.datatype.UInt32_LE, "frCompressedSize")
  zipfilerecord:addField(pref.datatype.UInt32_LE, "frUncompressedSize")
  zipfilerecord:addField(pref.datatype.UInt16_LE, "frFileNameLength")
  zipfilerecord:addField(pref.datatype.UInt16_LE, "frExtraFieldLength")
  
  local compressedsize = zipfilerecord.frCompressedSize.value
  local filenamelen = zipfilerecord.frFileNameLength.value
  local extrafieldlen = zipfilerecord.frExtraFieldLength.value
  
  if filenamelen > 0 then
    local ffilename = zipfilerecord:addField(pref.datatype.Character, "frFileName", filenamelen)
    zipfilerecord:dynamicInfo(ZipFunctions.getZipRecordFileName)
  end
  
  if extrafieldlen > 0 then
    zipfilerecord:addField(pref.datatype.Blob, "frExtraField", extrafieldlen)
  end
  
  if compressedsize > 0 then
    zipfilerecord:addField(pref.datatype.Blob, "frData", compressedsize)
  end
  
  return zipfilerecord.size
end

function ZipFunctions.defineDataDescriptor(formattree) -- 0x08074B50
  local zipdatadescriptor = formattree:addStructure("ZipDataDescriptor")
  
  zipdatadescriptor:addField(pref.datatype.Character, "ddSignature", 4)
  zipdatadescriptor:addField(pref.datatype.UInt32_LE, "ddCrc")
  zipdatadescriptor:addField(pref.datatype.UInt32_LE, "frCompressedSize")
  zipdatadescriptor:addField(pref.datatype.UInt32_LE, "frUncompressedSize")
  
  return zipdatadescriptor.size
end

function ZipFunctions.defineDirEntry(formattree) -- 0x02014B50
  local zipdirectoryentry = formattree:addStructure("ZipDirectoryEntry")
  
  zipdirectoryentry:addField(pref.datatype.Character, "deSignature", 4)
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deVersionMadeBy")
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deVersionToExtract")
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deFlags")
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deCompression")
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deFileTime")
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deDateTime")
  zipdirectoryentry:addField(pref.datatype.UInt32_LE, "deCrc")
  zipdirectoryentry:addField(pref.datatype.UInt32_LE, "deCompressedSize")
  zipdirectoryentry:addField(pref.datatype.UInt32_LE, "deUncompressedSize")
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deFileNameLength")
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deExtraFieldLength")
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deFileCommentLength")
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deDiskNumberStart")
  zipdirectoryentry:addField(pref.datatype.UInt16_LE, "deInternalAttributes")
  zipdirectoryentry:addField(pref.datatype.UInt32_LE, "deExternalAttributes")
  zipdirectoryentry:addField(pref.datatype.UInt32_LE, "deHeaderOffset")
  
  local filenamelength = zipdirectoryentry.deFileNameLength.value
  local extrafieldlength = zipdirectoryentry.deExtraFieldLength.value
  local filecommentlength = zipdirectoryentry.deFileCommentLength.value
  
  if filenamelength > 0 then
    local ffilename = zipdirectoryentry:addField(pref.datatype.Character, "deFileName", filenamelength)
    zipdirectoryentry:dynamicInfo(ZipFunctions.getZipDirEntryFileName)
  end
  
  if extrafieldlength > 0 then
    zipdirectoryentry:addField(pref.datatype.Blob, "deExtraField", extrafieldlength)
  end
  
  if filecommentlength > 0 then
    zipdirectoryentry:addField(pref.datatype.Character, "deFileComment", filecommentlength)
  end
  
  return zipdirectoryentry.size
end

function ZipFunctions.defineDigitalSignature(formattree) -- 0x05054B50
  local zipdigitalsignature = formattree:addStructure("ZipDigitalSignature")
  zipdigitalsignature:addField(pref.datatype.Character, "dsSignature", 4)
  zipdigitalsignature:addField(pref.datatype.UInt16_LE, "dsDataLength")
  
  local datalength = zipdigitalsignature.dsDataLength.value
  
  if datalength > 0 then
    zipdigitalsignature:addField(pref.datatype.Blob, "dsData", datalength)
  end
  
  return zipdigitalsignature.size
end

function ZipFunctions.defineEndLocator(formattree) -- 0x06054B50
  local zipendlocator = formattree:addStructure("ZipEndLocator")
  zipendlocator:addField(pref.datatype.Character, "elSignature", 4)
  zipendlocator:addField(pref.datatype.UInt16_LE, "elDiskNumber")
  zipendlocator:addField(pref.datatype.UInt16_LE, "elStartDiskNumber")
  zipendlocator:addField(pref.datatype.UInt16_LE, "elEntriesOnDisk")
  zipendlocator:addField(pref.datatype.UInt16_LE, "elEntriesInDirectory")
  zipendlocator:addField(pref.datatype.UInt32_LE, "elDirectorySize")
  zipendlocator:addField(pref.datatype.UInt32_LE, "elDirectoryOffset")
  zipendlocator:addField(pref.datatype.UInt16_LE, "elCommentLength")
  
  local commentlength = zipendlocator.elCommentLength.value
  
  if commentlength > 0 then
    zipendlocator:addField(pref.datatype.Character, "elComment", commentlength)
  end
  
  return zipendlocator.size
end

return ZipFunctions
