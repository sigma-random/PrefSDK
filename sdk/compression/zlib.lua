require("sdk.math.functions")

local ZLib = { CInfoMax = 32768,
               CInfoMaxKB = 32,
               ChecksumMod = 31 }

function ZLib.calcLZ77WindowSize(cinfo)
  return math.pow(2, cinfo + 8) / 1024
end

function ZLib.calcChecksum(compression, flag)
  return (compression * 256) + flag
end

function ZLib.isWindowSizeValid(cinfo)
  local windowsize = math.floor(ZLib.calcLZ77WindowSize(cinfo))
  return (windowsize > 0) and (windowsize <= ZLib.CInfoMaxKB)
end

function ZLib.isChecksumValid(compression, flag)
  return (ZLib.calcChecksum(compression, flag) % ZLib.ChecksumMod) == 0
end

return ZLib

 
