local ZLib = require("sdk.compression.zlib")
local ZLibInfo = { }

function ZLibInfo.compressionMethod(formatobject, buffer)
  local cm = formatobject:value()
  
  if cm == 8 then
    return "Deflate"
  elseif cm == 15 then
    return "Reserved"
  end
  
  return ""
end

function ZLibInfo.windowSize(formatobject, buffer)
  return string.format("LZ77 Window Size: %dKB", ZLib.calcLZ77WindowSize(formatobject:value()))
end

function ZLibInfo.checkDictionary(formatobject, buffer)
  local hasdict = formatobject:value()
  
  if hasdict == 0 then
    return "Dictionary NOT Present"
  end
  
  return "Dictionary Is Present"
end

function ZLibInfo.validateCheckFlag(formatobject, buffer)
  local zlibheader = formatobject:parent("ZLibHeader")
  
  if ZLib.isChecksumValid(zlibheader.Compression:value(), zlibheader.Flag:value()) == true then
    return "Checksum OK"
  end
  
  return "Checksum ERROR"
end

function ZLibInfo.compressionLevel(formatobject, buffer)
  return string.format("Compression Level: %d", formatobject:value())
end

return ZLibInfo