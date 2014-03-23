local FormatDefinition = require("sdk.format.formatdefinition")
local BitmapBPP = require("formats.bitmap.bpp")

local BitmapFormat = FormatDefinition:new("Bitmap Format", "Imaging", "Dax", "1.1", Endian.LittleEndian)

function BitmapFormat.readBpp(formatelement, buffer)
  local bpp = BitmapBPP[formatelement:value()]
  
  if bpp ~= nil then
    return bpp
  end

  return "Invalid Bpp"
end

function BitmapFormat.displayColorHex(fcolorentry, buffer)
  return string.format("#%02X%02X%02X%02X", fcolorentry.Reserved:value(), fcolorentry.Red:value(), fcolorentry.Green:value(), fcolorentry.Blue:value())
end

function BitmapFormat.parseBits(bitmapbits)
  local tree = bitmapbits:tree();
  local buffer = bitmapbits:buffer();
  
  local w = tree.BitmapInfoHeader.biWidth:value()
  local h = tree.BitmapInfoHeader.biHeight:value()
  local bpp = tree.BitmapInfoHeader.biBitCount:value()
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

function BitmapFormat:validateFormat(buffer)
  local sign = buffer:readString(0, 2)
  
  if sign ~= "BM" then
    return false
  end
  
  local bmpsize = buffer:readType(2, DataType.UInt32)
  
  if bmpsize == 0 then
    return false
  end
  
  local bmpbits = buffer:readType(10, DataType.UInt32)
  
  if (bmpbits == 0) or (bmpbits >= bmpsize) then
    return false
  end
  
  local bmpplanes = buffer:readType(26, DataType.UInt16)
  
  if bmpplanes ~= 1 then
    return false
  end
  
  local bmpbpp = buffer:readType(28, DataType.UInt16)
  
  -- Check if Bitmap's Bpp is valid --
  if (bmpbpp ~= 1) and (bmpbpp ~= 2) and (bmpbpp ~= 4) and (bmpbpp ~= 8) and (bmpbpp ~= 16) and (bmpbpp ~= 24) and (bmpbpp ~= 32) then
    return false
  end
  
  local bmpcompression = buffer:readType(30, DataType.UInt16)
  
  if bmpcompression > 6 then
    return false
  end
  
  return true
end

function BitmapFormat:parseFormat(formattree, buffer)
  local bitmapfileheader = formattree:addStructure("BitmapFileHeader")  
  bitmapfileheader:addField(DataType.UInt16, "bfType")
  bitmapfileheader:addField(DataType.UInt32, "bfSize")
  bitmapfileheader:addField(DataType.UInt16, "bfReserved1")
  bitmapfileheader:addField(DataType.UInt16, "bfReserved2")
  bitmapfileheader:addField(DataType.UInt32, "bfOffBits")
  
  local bitmapinfoheader = formattree:addStructure("BitmapInfoHeader")
  bitmapinfoheader:addField(DataType.UInt32, "biSize")
  bitmapinfoheader:addField(DataType.Int32, "biWidth")
  bitmapinfoheader:addField(DataType.Int32, "biHeight")
  bitmapinfoheader:addField(DataType.UInt16, "biPlanes")
  bitmapinfoheader:addField(DataType.UInt16, "biBitCount"):dynamicInfo(BitmapFormat.readBpp)
  bitmapinfoheader:addField(DataType.UInt32, "biCompression")
  bitmapinfoheader:addField(DataType.UInt32, "biSizeImage")
  bitmapinfoheader:addField(DataType.Int32, "biXPelsPerMeter")
  bitmapinfoheader:addField(DataType.Int32, "biYPelsPerMeter")
  bitmapinfoheader:addField(DataType.UInt32, "biClrUsed")
  bitmapinfoheader:addField(DataType.UInt32, "biClrImportant");
  
  local bitcount = bitmapinfoheader.biBitCount:value()
  
  if bitcount < 24 then
    self:parseColorTable(formattree, bitmapinfoheader, bitcount)
  end
  
  local bits = formattree:addStructure("BitmapBits")
  bits:dynamicParser((bitmapinfoheader.biSizeImage:value() > 0), BitmapFormat.parseBits)
end

function BitmapFormat:parseColorTable(formattree, bitmapinfoheader, bitcount)
  local clrused = bitmapinfoheader.biClrUsed:value()
  local colortable = formattree:addStructure("ColorTable")
  local tablesize = (clrused and clrused or bit.lshift(1, bitcount))
      
  for i=1, tablesize do
    local colorentry = colortable:addStructure(string.format("Color_%d", i - 1))
    
    colorentry:addField(DataType.UInt8, "Blue")
    colorentry:addField(DataType.UInt8, "Green")
    colorentry:addField(DataType.UInt8, "Red")
    colorentry:addField(DataType.UInt8, "Reserved")
    
    colorentry:dynamicInfo(BitmapFormat.displayColorHex)
  end
end