-- ZLib Data Structure: http://software.intel.com/sites/products/documentation/hpc/ipp/ipps/ipps_ch13/ch13_22_ZLIB.html#fig13-1

local pref = require("pref")
local ZLib = require("sdk.compression.zlib")
local ZLibFunctions = require("formats.zlib.functions")

local ZLibFormat = pref.format.create("ZLib Format", "Compression", "Dax", "1.0")

function ZLibFormat:validate(validator)
  local buffer = validator.buffer
  local compression = buffer:readType(0, pref.datatype.UInt8)
  local cm = bit.band(compression, 0xF)
  local cinfo = bit.rshift(bit.band(compression, 0xF0), 4)
  
  if (cm ~= 8) then
    validator:error("Invalid Compression Method")
  elseif not ZLib.isWindowSizeValid(cinfo) then
    validator:error("Invalid Window Size")
  end
  
  local flag = buffer:readType(1, pref.datatype.UInt8)
  local check = bit.band(flag, 0x1F)
  local dict = bit.rshift(bit.band(flag, 0x20), 5)
  local level = bit.rshift(bit.band(flag, 0xC0), 6)
  
  if not ZLib.isChecksumValid(compression, flag) then
    validator:error("Invalid Checksum")
  end
  
  if ((dict ~= 0) and (dict ~= 1)) or ((level < 0) or (level > 3)) then
    validator:error("Invalid Flags")
  end
end

function ZLibFormat:parse(formattree)
  local zlibheader = formattree:addStructure("ZLibHeader")
  local fcompression = zlibheader:addField(pref.datatype.UInt8, "Compression")
  fcompression:setBitField("Method", 0, 3):dynamicInfo(ZLibFunctions.compressionMethod)
  local fcinfo = fcompression:setBitField("Info", 4, 7)
  
  if zlibheader.Compression.Method.value == 8 then
    fcinfo:dynamicInfo(ZLibFunctions.windowSize)
  end
  
  local fflag = zlibheader:addField(pref.datatype.UInt8, "Flag")
  fflag:setBitField("Check", 0, 4):dynamicInfo(ZLibFunctions.validateCheckFlag)
  fflag:setBitField("Dict", 5):dynamicInfo(ZLibFunctions.checkDictionary)
  fflag:setBitField("Level", 6, 7):dynamicInfo(ZLibFunctions.compressionLevel)
end

return ZLibFormat