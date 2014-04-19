local DataType = require("sdk.types.datatype")
local FormatDefinition = require("sdk.format.formatdefinition")
local BitmapBPP = require("formats.bitmap.bpp")

local BitmapFormat = FormatDefinition.register("Bitmap Format", "Imaging", "Dax", "1.1")

function BitmapFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
end

function BitmapFormat:validateFormat()
  self:checkData(0, DataType.AsciiString, "BM")                 -- Bitmap's Signature
  self:checkData(14, DataType.UInt32_LE, 40)                    -- BitmapInfoHeader.biSize
  self:checkData(26, DataType.UInt16_LE, 0x00000001)            -- BitmapInfoHseader.biPlanes
  self:checkData(28, DataType.UInt16_LE, {1, 4, 8, 16, 24, 32}) -- BitmapInfoHeader.biBitCount
end

function BitmapFormat:displaySize(sizefield)
  if sizefield:value() < 0 then
    return string.format("%dpx (Reversed)", math.abs(sizefield:value()))
  end
  
  return string.format("%dpx", sizefield:value())
end

function BitmapFormat:parseFormat(formattree)
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
  bitmapinfoheader:addField(DataType.UInt16_LE, "biBitCount")
  bitmapinfoheader:addField(DataType.UInt32_LE, "biCompression")
  bitmapinfoheader:addField(DataType.UInt32_LE, "biSizeImage")
  bitmapinfoheader:addField(DataType.Int32_LE, "biXPelsPerMeter")
  bitmapinfoheader:addField(DataType.Int32_LE, "biYPelsPerMeter")
  bitmapinfoheader:addField(DataType.UInt32_LE, "biClrUsed")
  bitmapinfoheader:addField(DataType.UInt32_LE, "biClrImportant");
  
  local bitcount = bitmapinfoheader.biBitCount:value()
  
  if bitcount < 24 then
    self:parseColorTable(formattree, bitmapinfoheader, bitcount)
  end
  
  formattree:addStructure("BitmapBits"):dynamicParser(bitmapinfoheader.biSizeImage:value() > 0, BitmapFormat.parseBits)
end

function BitmapFormat:parseColorTable(formattree, bitmapinfoheader, bitcount)
  local clrused = bitmapinfoheader.biClrUsed:value()
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

function BitmapFormat:displayColorHex(colorentry)
  return string.format("#%02X%02X%02X%02X", colorentry.Reserved:value(), colorentry.Red:value(), colorentry.Green:value(), colorentry.Blue:value())
end

function BitmapFormat:parseBits(bitmapbits)
  local tree = self.formattree
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