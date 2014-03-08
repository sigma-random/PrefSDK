-- ZLib Data Structure: http://software.intel.com/sites/products/documentation/hpc/ipp/ipps/ipps_ch13/ch13_22_ZLIB.html#fig13-1

local ZLibInfo = require("formats.zlib.zlibinfo")
local ZLib = require("sdk.compression.zlib")
local FormatDefinition = require("sdk.format.formatdefinition")

local ZLibFormat = FormatDefinition:new("ZLib Format", "Compression", "Dax", "1.0", Endian.LittleEndian)

function ZLibFormat:validateFormat(buffer)
  local compression = buffer:readType(0, DataType.UInt8)  
  local cm = bit32.band(compression, 0xF)
  local cinfo = bit32.rshift(bit32.band(compression, 0xF0), 4)
  
  if (cm ~= 8) or (not ZLib.isWindowSizeValid(cinfo)) then
    return false
  end
  
  local flag = buffer:readType(1, DataType.UInt8)
  local check = bit32.band(flag, 0x1F)
  local dict = bit32.rshift(bit32.band(flag, 0x20), 5)
  local level = bit32.rshift(bit32.band(flag, 0xC0), 6)
  
  if not ZLib.isChecksumValid(compression, flag) then
    return false
  end
  
  if ((dict ~= 0) and (dict ~= 1)) or ((level < 0) or (level > 3)) then
    return false
  end
  
  return true
end

function ZLibFormat:parseFormat(formatmodel, buffer)
  local zlibheader = formatmodel:addStructure("ZLibHeader")
  local fcompression = zlibheader:addField(DataType.UInt8, "Compression")
  fcompression:setBitField(0, 3, "Method"):dynamicInfo(ZLibInfo.compressionMethod)
  local fcinfo = fcompression:setBitField(4, 7, "Info")
  
  if zlibheader.Compression.Method:value() == 8 then
    fcinfo:dynamicInfo(ZLibInfo.windowSize)
  end
  
  local fflag = zlibheader:addField(DataType.UInt8, "Flag")
  fflag:setBitField(0, 4, "Check"):dynamicInfo(ZLibInfo.validateCheckFlag)
  fflag:setBitField(5, "Dict"):dynamicInfo(ZLibInfo.checkDictionary)
  fflag:setBitField(6, 7, "Level"):dynamicInfo(ZLibInfo.compressionLevel)
  
  if fflag.Dict ~= 0 then
  end
end
