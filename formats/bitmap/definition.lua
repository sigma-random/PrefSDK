local pref = require("pref")
local BitmapFunctions = require("formats.bitmap.functions")

local BitmapFormat = pref.format.create("Bitmap Format", "Imaging", "Dax", "1.1")

function BitmapFormat:validate(validator)
  local validbpp = {1, 4, 8, 16, 24, 32}
  
  validator:checkAscii(0, "BM")                                -- Bitmap's Signature
  validator:checkType(14, 40, pref.datatype.UInt32_LE)         -- BitmapInfoHeader.biSize
  validator:checkType(26, 0x00000001, pref.datatype.UInt16_LE) -- BitmapInfoHseader.biPlanes
  
  for _, bpp in pairs(validbpp) do
    if validator:checkType(28, bpp, pref.datatype.UInt16_LE, false) == true then  -- BitmapInfoHeader.biBitCount
      return
    end
  end
  
  validator:error("Invalid BPP")
end

function BitmapFormat:parse(formattree)  
  local bitmapfileheader = formattree:addStructure("BitmapFileHeader")
  bitmapfileheader:addField(pref.datatype.UInt16_LE, "bfType")
  bitmapfileheader:addField(pref.datatype.UInt32_LE, "bfSize")
  bitmapfileheader:addField(pref.datatype.UInt16_LE, "bfReserved1")
  bitmapfileheader:addField(pref.datatype.UInt16_LE, "bfReserved2")
  bitmapfileheader:addField(pref.datatype.UInt32_LE, "bfOffBits")
  
  local bitmapinfoheader = formattree:addStructure("BitmapInfoHeader")
  bitmapinfoheader:addField(pref.datatype.UInt32_LE, "biSize")
  bitmapinfoheader:addField(pref.datatype.Int32_LE, "biWidth"):dynamicInfo(BitmapFunctions.displaySize)
  bitmapinfoheader:addField(pref.datatype.Int32_LE, "biHeight"):dynamicInfo(BitmapFunctions.displaySize)
  bitmapinfoheader:addField(pref.datatype.UInt16_LE, "biPlanes")
  bitmapinfoheader:addField(pref.datatype.UInt16_LE, "biBitCount"):dynamicInfo(BitmapFunctions.displayBpp)
  bitmapinfoheader:addField(pref.datatype.UInt32_LE, "biCompression")
  bitmapinfoheader:addField(pref.datatype.UInt32_LE, "biSizeImage")
  bitmapinfoheader:addField(pref.datatype.Int32_LE, "biXPelsPerMeter")
  bitmapinfoheader:addField(pref.datatype.Int32_LE, "biYPelsPerMeter")
  bitmapinfoheader:addField(pref.datatype.UInt32_LE, "biClrUsed")
  bitmapinfoheader:addField(pref.datatype.UInt32_LE, "biClrImportant")
  
  local bitcount = bitmapinfoheader.biBitCount.value
  
  if bitcount < 24 then
    BitmapFunctions.parseColorTable(formattree, bitmapinfoheader, bitcount)
  end
  
  formattree:addStructure("BitmapBits"):dynamicParser(bitmapinfoheader.biSizeImage.value > 0, BitmapFunctions.parseBits)
end

function BitmapFormat:view(formattree)
  if formattree.BitmapInfoHeader.biBitCount.value >= 24 then -- No Color Table
    return nil
  end
  
  return pref.format.loadview("formats/bitmap/ui/ColorTable.qml", formattree)
end

return BitmapFormat