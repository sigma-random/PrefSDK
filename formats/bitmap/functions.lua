local pref = require("pref")

local BitmapFunctions = { bpp = { [1]  = "1 Bpp",
                                  [4]  = "4 Bpp",
                                  [8]  = "8 Bpp",
                                  [16] = "16 Bpp",
                                  [24] = "24 Bpp",
                                  [32] = "32 Bpp" } }

function BitmapFunctions.displaySize(sizefield, formattree)
  if sizefield.value < 0 then
    return string.format("%dpx (Reversed)", math.abs(sizefield.value))
  end
   
  return string.format("%dpx", sizefield.value)
end

function BitmapFunctions.displayBpp(bitcountfield, formattree)
  local bpp = BitmapFunctions.bpp[bitcountfield.value]
  
  if bpp == nil then
    return "Invalid BPP"
  end
  
  return bpp
end

function BitmapFunctions.displayColorHex(colorentry, formattree)
  return string.format("#%02X%02X%02X%02X", colorentry.Reserved.value, colorentry.Red.value, colorentry.Green.value, colorentry.Blue.value)
end

function BitmapFunctions.parseBits(bitmapbits, formattree)
  local w = formattree.BitmapInfoHeader.biWidth.value
  local h = formattree.BitmapInfoHeader.biHeight.value
  local bpp = formattree.BitmapInfoHeader.biBitCount.value
  local rowsize = (((bpp * w) + 31) / 32) * 4
  
  local line = 0
    
  if h < 0 then
    h = math.abs(h)
  end
  
  while line < h do
    bitmapbits:addField(pref.datatype.UInt8, string.format("ScanLine_%d", line), rowsize)
    line = line + 1
  end
end

function BitmapFunctions.parseColorTable(formattree, bitmapinfoheader, bitcount)
  local clrused = bitmapinfoheader.biClrUsed.value
  local colortable = formattree:addStructure("ColorTable")
  local tablesize = (clrused and clrused or bit.lshift(1, bitcount))
  
  for i = 1, tablesize do
    local colorentry = colortable:addStructure(string.format("Color_%d", i - 1)):dynamicInfo(BitmapFunctions.displayColorHex)
    colorentry:addField(pref.datatype.UInt8, "Blue")
    colorentry:addField(pref.datatype.UInt8, "Green")
    colorentry:addField(pref.datatype.UInt8, "Red")
    colorentry:addField(pref.datatype.UInt8, "Reserved")
  end
end

return BitmapFunctions
