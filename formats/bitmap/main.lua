local FormatDefinition = require("sdk.format.formatdefinition")
local BitmapBPP = require("formats.bitmap.bpp")

local BitmapFormat = FormatDefinition:new("Bitmap Format", "Imaging", "Dax", "1.1", Endian.LittleEndian)

function BitmapFormat.readBpp(formatobject, buffer)
  local bpp = BitmapBPP[formatobject:value()]
  
  if bpp ~= nil then
    return bpp
  end

  return "Invalid Bpp"
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

function BitmapFormat:parseFormat(formatmodel, buffer)
  local bitmapfileheader = formatmodel:addStructure("BitmapFileHeader")  
  bitmapfileheader:addField(DataType.UInt16, "bfType")
  bitmapfileheader:addField(DataType.UInt32, "bfSize")
  bitmapfileheader:addField(DataType.UInt16, "bfReserved1")
  bitmapfileheader:addField(DataType.UInt16, "bfReserved2")
  bitmapfileheader:addField(DataType.UInt32, "bfOffBits")
  
  local bitmapinfoheader = formatmodel:addStructure("BitmapInfoHeader")
  bitmapinfoheader:addField(DataType.UInt32, "biSize")
  bitmapinfoheader:addField(DataType.UInt32, "biWidth")
  bitmapinfoheader:addField(DataType.UInt32, "biHeight")
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
    local clrused = bitmapinfoheader.biClrUsed:value()
    local colortable = formatmodel:addStructure("ColorTable")
    
    if clrused == 0 then
      colortable:addField(DataType.UInt32, bit.lshift(1, bitcount), "tableentry")
    else
      colortable:addField(DataType.UInt32, clrused, "tableentry")
    end
  end
end