local FormatDefinition = require("sdk.format.formatdefinition")

local TimBpp = { [0] = "4-Bit CLUT", [1] = "8-Bit CLUT", [2] = "15-Bit Direct", [3] = "24-Bit Direct", [4] = "Mixed" } 
local TimFormat = FormatDefinition:new("TIM Format", "Sony Playstation 1", "Dax", "1.0", Endian.LittleEndian)

function TimFormat.getBpp(formatobject, buffer)
  local bpp = TimBpp[formatobject:value()]
  
  if bpp ~= nil then
    return bpp
  end
  
  return "Unknown"
end

function TimFormat:validateFormat(buffer)
  local id = buffer:readType(0, DataType.UInt32)
  
  if bit.band(id, 0xFF) ~= 0x10 then -- Id
    return false
  end
  
  if bit.rshift(bit.band(id, 0xFF00), 8) ~= 0x00 then -- Version
    return false
  end
  
  if bit.rshift(bit.band(id, 0xFFFF0000), 16) ~= 0x0000 then -- Reserved
    return false
  end
  
  local flag = buffer:readType(4, DataType.UInt32)
  local bpp = bit.band(flag, 0x7)
  
  if (bpp < 0) or (bpp > 4) then -- Bpp
    return false
  end
  
  local hasclut = bit.rshift(bit.band(flag, 0x8), 3)
  
  if (hasclut ~= 0) and (hasclut ~= 1) then
    return false
  end
  
  if bit.rshift(bit.band(flag, 0xFFFFFFF0), 4) ~= 0x000000 then
    return false
  end
  
  local pixeldatapos = 8
  
  if hasclut == 1 then
    local clblksize = buffer:readType(8, DataType.UInt32)
    local clfbx = buffer:readType(12, DataType.UInt16)
    local clfby = buffer:readType(14, DataType.UInt16)
    local clw = buffer:readType(16, DataType.UInt16)
    local clh = buffer:readType(18, DataType.UInt16)
    
    if ((clfbx < 0) or (clw < 0) or (clfby < 0) or (clh < 0)) or (clfbx >= clw) or (clfby >= clh) then
      return false
    end
    
    local clutelements = 0

    if bpp == 0 then -- 4-Bit CLUT
      clutelements = 16
    elseif bpp == 1 then -- 8-Bit CLUT
      clutelements = 256
    else
      return false
    end
    
    -- clutcount = clutsize - sizeof(CLUT_TABLE) / (cluelements * entrysize)
    local clutcount = (clblksize - 12) / (clutelements * 2)
    local clutsize = 0
    
    for i = 1, clutcount do
      clutsize = clutsize + (clutelements * 2)
    end
    
    if clutsize > buffer:size() then
      return false
    end
    
    pixeldatapos = clutsize + 20
  end
  
  pixeldatapos = pixeldatapos + 4 -- Skip Pixel Block Size
  
  local pxfbx = buffer:readType(pixeldatapos, DataType.UInt16)
  local pxfby = buffer:readType(pixeldatapos + 2, DataType.UInt16)
  local pxw = buffer:readType(pixeldatapos + 4, DataType.UInt16)
  local pxh = buffer:readType(pixeldatapos + 6, DataType.UInt16)
  
  if ((pxfbx < 0) or (pxw < 0) or (pxfby < 0) or (pxh < 0)) or (pxfbx > pxw) or (pxfby > pxh) then
    return false
  end
  
  return true
end
    
function TimFormat:parseFormat(formatmodel, buffer)
  local timheader = formatmodel:addStructure("TimHeader")
  
  local fid = timheader:addField(DataType.UInt32, "Id")
  fid:setBitField(0, 7, "Id")
  fid:setBitField(8, 15, "Version")
  fid:setBitField(16, 31, "Reserved");
  
  local fflag = timheader:addField(DataType.UInt32, "Flag")
  fflag:setBitField(0, 2, "Bpp"):dynamicInfo(TimFormat.getBpp)
  fflag:setBitField(3, "HasClut")
  fflag:setBitField(4, 31, "Reserved")
  
  if timheader.Flag.HasClut:value() == 1 then
    self:createClutBlocks(formatmodel, buffer, timheader.Flag.Bpp:value())
  end
  
  local pixeldata = formatmodel:addStructure("PixelData")
  pixeldata:addField(DataType.UInt32, "BlockSize")
  pixeldata:addField(DataType.UInt16, "FrameBufferX")
  pixeldata:addField(DataType.UInt16, "FrameBufferY")
  pixeldata:addField(DataType.UInt16, "Width")
  pixeldata:addField(DataType.UInt16, "Height")
  pixeldata:addField(DataType.Blob, "Pixel", pixeldata.BlockSize:value() - pixeldata:size())
end

function TimFormat:createClutBlocks(formatmodel, buffer, bpp)
  local clut = formatmodel:addStructure("Clut")
  clut:addField(DataType.UInt32, "BlockSize")
  clut:addField(DataType.UInt16, "FrameBufferX")
  clut:addField(DataType.UInt16, "FrameBufferY")
  clut:addField(DataType.UInt16, "Width")
  clut:addField(DataType.UInt16, "Height")
  
  local clutelements = 0

  if bpp == 0 then -- 4-Bit CLUT
    clutelements = 16
  elseif bpp == 1 then -- 8-Bit CLUT
    clutelements = 256
  end
  
  -- clutcount = clutsize - sizeof(CLUT_TABLE) / (cluelements * entrysize)
  local clutcount = (clut.BlockSize:value() - clut:size()) / (clutelements * 2)
  local colors = clut:addStructure("Colors")
  
  for i = 1, clutcount do
    colors:addField(DataType.Blob, "Clut" .. (i - 1), clutelements * 2)
  end
end