local pref = require("pref")
local MapperTypes = require("formats.ines.mappers")

local INesFunctions = { }

function INesFunctions.calcRomSize(romfield, formattree)
  return string.format("%dKB", romfield.value * 16)
end

function INesFunctions.calcVRomSize(vromfield, formattree)
  return string.format("%dKB", vromfield.value * 8)
end

function INesFunctions.calcRamSize(ramfield, formattree)
  local numbanks = ramfield.value
  
  if numbanks == 0 then -- As Documentation Says: "Assume 1x8KB RAM if `numbanks` is zero"
    numbanks = 1
  end
  
  return string.format("%dKB", numbanks * 8)
end

function INesFunctions.getMapperTypeFromLow(mappertypelowfield, formattree)
  local lowpart = mappertypelowfield.value
  local highpart = formattree.INesHeader.SystemFlags2.HighROMMapperType.value
  local mt = bit.bor(bit.lshift(highpart, 4), lowpart)
  return MapperTypes[mt]
end

function INesFunctions.getMapperTypeFromHigh(mappertypehighfield, formattree)
  local highpart = mappertypehighfield.value
  local lowpart = formattree.INesHeader.SystemFlags1.LowROMMapperType.value
  local mt = bit.bor(bit.lshift(highpart, 4), lowpart)
  return MapperTypes[mt]
end

function INesFunctions.getTvSystem(tvsystemfield, formattree)
  if tvsystemfield.value == 1 then
    return "PAL"
  end
  
  return "NTSC"
end

function INesFunctions.getMirroring(mirroringfield, formattree)
  if mirroringfield.value == 1 then
    return "Vertical"
  end
    
  return "Horizontal"
end

return INesFunctions