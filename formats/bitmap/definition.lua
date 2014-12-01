local pref = require("pref")
local BitmapBPP = require("formats.bitmap.bpp")

local DataType = pref.datatype
local BitmapFormat = pref.format.create("Bitmap Image", "Imaging", "Dax", "1.1")

function BitmapFormat:validate(validator)
  local validbpp = {1, 4, 8, 16, 24, 32}
  
  validator:checkAscii(0, "BM")                           -- Bitmap's Signature
  validator:checkType(14, 40, DataType.UInt32_LE)         -- BitmapInfoHeader.biSize
  validator:checkType(26, 0x00000001, DataType.UInt16_LE) -- BitmapInfoHseader.biPlanes
  
  for _, bpp in pairs(validbpp) do
    if validator:checkType(28, bpp, DataType.UInt16_LE, false) == true then  -- BitmapInfoHeader.biBitCount
      return
    end
  end
  
  validator:error("Invalid BPP")
end

function BitmapFormat:parse(formattree)  
  local bitmapfileheader = formattree:addStructure("BitmapFileHeader")
  bitmapfileheader:addField(DataType.UInt16_LE, "bfType")
  bitmapfileheader:addField(DataType.UInt32_LE, "bfSize")
  bitmapfileheader:addField(DataType.UInt16_LE, "bfReserved1")
  bitmapfileheader:addField(DataType.UInt16_LE, "bfReserved2")
  bitmapfileheader:addField(DataType.UInt32_LE, "bfOffBits")
  
  local bitmapinfoheader = formattree:addStructure("BitmapInfoHeader")
  bitmapinfoheader:addField(DataType.UInt32_LE, "biSize")
  bitmapinfoheader:addField(DataType.Int32_LE, "biWidth"):dynamicInfo(BitmapFormat.displaySize)
  bitmapinfoheader:addField(DataType.Int32_LE, "biHeight"):dynamicInfo(BitmapFormat.displaySize)
  bitmapinfoheader:addField(DataType.UInt16_LE, "biPlanes")
  bitmapinfoheader:addField(DataType.UInt16_LE, "biBitCount"):dynamicInfo(BitmapFormat.displayBpp)
  bitmapinfoheader:addField(DataType.UInt32_LE, "biCompression")
  bitmapinfoheader:addField(DataType.UInt32_LE, "biSizeImage")
  bitmapinfoheader:addField(DataType.Int32_LE, "biXPelsPerMeter")
  bitmapinfoheader:addField(DataType.Int32_LE, "biYPelsPerMeter")
  bitmapinfoheader:addField(DataType.UInt32_LE, "biClrUsed")
  bitmapinfoheader:addField(DataType.UInt32_LE, "biClrImportant")
  
  local bitcount = bitmapinfoheader.biBitCount.value
  
  if bitcount < 24 then
    self:parseColorTable(formattree, bitmapinfoheader, bitcount)
  end
  
  formattree:addStructure("BitmapBits"):dynamicParser(bitmapinfoheader.biSizeImage.value > 0, BitmapFormat.parseBits)
end

function BitmapFormat:view(formattree)
  if formattree.BitmapInfoHeader.biBitCount.value >= 24 then -- No Color Table
    return nil
  end
  
  return pref.format.loadview("formats/bitmap/ui/ColorTable.qml", formattree)
end

function BitmapFormat:parseColorTable(formattree, bitmapinfoheader, bitcount)
  local clrused = bitmapinfoheader.biClrUsed.value
  local colortable = formattree:addStructure("ColorTable")
  local tablesize = (clrused and clrused or bit.lshift(1, bitcount))
  
  for i = 1, tablesize do
    local colorentry = colortable:addStructure(string.format("Color_%d", i - 1)):dynamicInfo(BitmapFormat.displayColorHex)
    colorentry:addField(DataType.UInt8, "Blue")
    colorentry:addField(DataType.UInt8, "Green")
    colorentry:addField(DataType.UInt8, "Red")
    colorentry:addField(DataType.UInt8, "Reserved")
  end
end

function BitmapFormat.parseBits(bitmapbits, formattree)
  local w = formattree.BitmapInfoHeader.biWidth.value
  local h = formattree.BitmapInfoHeader.biHeight.value
  local bpp = formattree.BitmapInfoHeader.biBitCount.value
  local rowsize = (((bpp * w) + 31) / 32) * 4
  
  local line = 0
    
  if h < 0 then
    h = math.abs(h)
  end
  
  while line < h do
    bitmapbits:addField(DataType.UInt8, string.format("ScanLine_%d", line), rowsize)
    line = line + 1
  end
end

function BitmapFormat.displaySize(sizefield, formattree)
  if sizefield.value < 0 then
    return string.format("%dpx (Reversed)", math.abs(sizefield.value))
  end
   
  return string.format("%dpx", sizefield.value)
end

function BitmapFormat.displayBpp(bitcountfield, formattree)
  local bpp = BitmapBPP[bitcountfield.value]
  
  if bpp == nil then
    return "Invalid BPP"
  end
  
  return bpp
end

function BitmapFormat.displayColorHex(colorentry, formattree)
  return string.format("#%02X%02X%02X%02X", colorentry.Reserved.value, colorentry.Red.value, colorentry.Green.value, colorentry.Blue.value)
end

return BitmapFormat