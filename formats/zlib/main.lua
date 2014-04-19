-- ZLib Data Structure: http://software.intel.com/sites/products/documentation/hpc/ipp/ipps/ipps_ch13/ch13_22_ZLIB.html#fig13-1

local ZLib = require("sdk.compression.zlib")
local FormatDefinition = require("sdk.format.formatdefinition")
local DataType = require("sdk.types.datatype")

local ZLibFormat = FormatDefinition.register("ZLib Format", "Compression", "Dax", "1.0")

function ZLibFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
end

function ZLibFormat:compressionMethod(comprmethodfield)
  local cm = comprmethodfield:value()
  
  if cm == 8 then
    return "Deflate"
  elseif cm == 15 then
    return "Reserved"
  end
  
  return ""
end

function ZLibFormat:windowSize(windowsizefield)
  return string.format("LZ77 Window Size: %dKB", ZLib.calcLZ77WindowSize(windowsizefield:value()))
end

function ZLibFormat:checkDictionary(hasdictfield, buffer)
  local hasdict = hasdictfield:value()
  
  if hasdict == 0 then
    return "Dictionary NOT Present"
  end
  
  return "Dictionary Is Present"
end

function ZLibFormat:validateCheckFlag(checksumfield)
  local zlibheader = self.formattree.ZLibHeader
  
  if ZLib.isChecksumValid(zlibheader.Compression:value(), zlibheader.Flag:value()) == true then
    return "Checksum OK"
  end
  
  return "Checksum ERROR"
end

function ZLibFormat:compressionLevel(comprlevelfield)
  return string.format("Compression Level: %d", comprlevelfield:value())
end

function ZLibFormat:validateFormat()
  local compression = self.databuffer:readUInt8(0)
  local cm = bit.band(compression, 0xF)
  local cinfo = bit.rshift(bit.band(compression, 0xF0), 4)
  
  if (cm ~= 8) then
    error("Invalid Compression Method")
  elseif not ZLib.isWindowSizeValid(cinfo) then
    error("Invalid Window Size")
  end
  
  local flag = self.databuffer:readUInt8(1)
  local check = bit.band(flag, 0x1F)
  local dict = bit.rshift(bit.band(flag, 0x20), 5)
  local level = bit.rshift(bit.band(flag, 0xC0), 6)
  
  if not ZLib.isChecksumValid(compression, flag) then
    error("Invalid Checksum")
  end
  
  if ((dict ~= 0) and (dict ~= 1)) or ((level < 0) or (level > 3)) then
    error("Invalid Flags")
  end
  
  self.validated = true
end

function ZLibFormat:parseFormat(formattree)
  local zlibheader = formattree:addStructure("ZLibHeader")
  local fcompression = zlibheader:addField(DataType.UInt8, "Compression")
  fcompression:setBitField("Method", 0, 3):dynamicInfo(ZLibFormat.compressionMethod)
  local fcinfo = fcompression:setBitField("Info", 4, 7)
  
  if zlibheader.Compression.Method:value() == 8 then
    fcinfo:dynamicInfo(ZLibFormat.windowSize)
  end
  
  local fflag = zlibheader:addField(DataType.UInt8, "Flag")
  fflag:setBitField("Check", 0, 4):dynamicInfo(ZLibFormat.validateCheckFlag)
  fflag:setBitField("Dict", 5):dynamicInfo(ZLibFormat.checkDictionary)
  fflag:setBitField("Level", 6, 7):dynamicInfo(ZLibFormat.compressionLevel)
end
