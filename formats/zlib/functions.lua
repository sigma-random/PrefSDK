local ZLib = require("sdk.compression.zlib")

local ZLibFunctions = { }

function ZLibFunctions.compressionMethod(comprmethodfield, formattree)
  local cm = comprmethodfield.value
  
  if cm == 8 then
    return "Deflate"
  elseif cm == 15 then
    return "Reserved"
  end
  
  return ""
end

function ZLibFunctions.windowSize(windowsizefield, formattree)
  return string.format("LZ77 Window Size: %dKB", ZLib.calcLZ77WindowSize(windowsizefield.value))
end

function ZLibFunctions.checkDictionary(hasdictfield, buffer)
  local hasdict = hasdictfield.value
  
  if hasdict == 0 then
    return "Dictionary NOT Present"
  end
  
  return "Dictionary Is Present"
end

function ZLibFunctions.validateCheckFlag(checksumfield, formattree)
  local zlibheader = formattree.ZLibHeader
  
  if ZLib.isChecksumValid(zlibheader.Compression.value, zlibheader.Flag.value) == true then
    return "Checksum OK"
  end
  
  return "Checksum ERROR"
end

function ZLibFunctions.compressionLevel(comprlevelfield, formattree)
  return string.format("Compression Level: %d", comprlevelfield.value)
end

return ZLibFunctions
