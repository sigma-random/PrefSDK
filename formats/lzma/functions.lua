local LZma = require("sdk.compression.lzma")
local MathFunctions = require("sdk.math.functions")

local LZmaFunctions = { }

function LZmaFunctions.analyzeProperties(propfield, formattree)
  local lc, lp, pb = LZma.getProperties(propfield.value)
  return string.format("lc: %d, lp %d, pb: %d", lc, lp, pb)
end

function LZmaFunctions.getDictionarySize(dictsizefield, formattree)
  local val = MathFunctions.logb(dictsizefield.value, 2)
  return string.format("2^%d bytes", val)
end

function LZmaFunctions.checkUncompressedSize(uncomprsizefield, formattree)
  if uncomprsizefield.value == -1 then
    return "Unknown Size"
  end
  
  return ""
end

return LZmaFunctions
