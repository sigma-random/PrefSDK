local pref = require("pref")
local TimBpp = require("formats.tim.bpp")

local DataType = pref.datatype
local TimFormat = pref.format.create("TIM Image", "Sony Playstation 1", "Dax", "1.0")

function TimFormat:validate(validator)
  local buffer = validator.buffer
  local id = buffer:readType(0, DataType.UInt32_LE)
  
  if bit.band(id, 0xFF) ~= 0x10 then -- Id
    validator:error("Invalid ID")
  end
  
  if bit.rshift(bit.band(id, 0xFF00), 8) ~= 0x00 then -- Version
    validator:error("Invalid Version")
  end
  
  if bit.rshift(bit.band(id, 0xFFFF0000), 16) ~= 0x0000 then -- Reserved
    validator:error("Reserved field must be 0")
  end
    
  local flag = buffer:readType(4, DataType.UInt32_LE)
  local bpp = bit.band(flag, 0x7)
  
  if (bpp < 0) or (bpp > 4) then -- Bpp
    validator:error("Invalid BPP")
  end
  
  local hasclut = bit.rshift(bit.band(flag, 0x8), 3)
  
  if (hasclut ~= 0) and (hasclut ~= 1) then
    validator:error("Invalid CLUT field")
  end
  
  if bit.rshift(bit.band(flag, 0xFFFFFFF0), 4) ~= 0x000000 then
    validator:error("Upper part of FLAGS field must be 0")
  end
  
  local pixeldatapos = 8
  
  if hasclut == 1 then
    local clblksize = buffer:readType(8, DataType.UInt32_LE)
    local clfbx = buffer:readType(12, DataType.UInt16_LE)
    local clfby = buffer:readType(14, DataType.UInt16_LE)
    local clw = buffer:readType(16, DataType.UInt16_LE)
    local clh = buffer:readType(18, DataType.UInt16_LE)
    
    if ((clfbx < 0) or (clw < 0) or (clfby < 0) or (clh < 0)) or (clfbx >= clw) or (clfby >= clh) then
      validator:error("Invalid TIM Metrics")
    end
    
    local clutelements = 0

    if bpp == 0 then -- 4-Bit CLUT
      clutelements = 16
    elseif bpp == 1 then -- 8-Bit CLUT
      clutelements = 256
    else
      validator:error("Invalid CLUT Table Size")
    end
    
    -- clutcount = clutsize - sizeof(CLUT_TABLE) / (cluelements * entrysize)
    local clutcount = (clblksize - 12) / (clutelements * 2)
    local clutsize = 0
    
    for i = 1, clutcount do
      clutsize = clutsize + (clutelements * 2)
    end
    
    if clutsize > buffer.length then
      validator:error("CLUT's size cannot be greater than file size")
    end
    
    pixeldatapos = clutsize + 20
  end
end
    
function TimFormat:parse(formattree)
  local timheader = formattree:addStructure("TimHeader")
  
  local fid = timheader:addField(DataType.UInt32_LE, "Id")
  fid:setBitField("Id", 0, 7)
  fid:setBitField("Version", 8, 15)
  fid:setBitField("Reserved", 16, 31)
  
  local fflag = timheader:addField(DataType.UInt32_LE, "Flag")
  fflag:setBitField("Bpp", 0, 2):dynamicInfo(TimFormat.getBpp)
  fflag:setBitField("HasClut", 3)
  fflag:setBitField("Reserved", 4, 31)
  
  if timheader.Flag.HasClut.value == 1 then
    self:createClutBlocks(formattree, timheader.Flag.Bpp.value)
  end
  
  local pixeldata = formattree:addStructure("PixelData")
  pixeldata:addField(DataType.UInt32_LE, "BlockSize")
  pixeldata:addField(DataType.UInt16_LE, "FrameBufferX")
  pixeldata:addField(DataType.UInt16_LE, "FrameBufferY")
  pixeldata:addField(DataType.UInt16_LE, "Width")
  pixeldata:addField(DataType.UInt16_LE, "Height")
  pixeldata:addField(DataType.Blob, "Pixel", pixeldata.BlockSize.value - pixeldata.size)
end

function TimFormat:createClutBlocks(formattree, bpp)
  local clut = formattree:addStructure("Clut")
  clut:addField(DataType.UInt32_LE, "BlockSize")
  clut:addField(DataType.UInt16_LE, "FrameBufferX")
  clut:addField(DataType.UInt16_LE, "FrameBufferY")
  clut:addField(DataType.UInt16_LE, "Width")
  clut:addField(DataType.UInt16_LE, "Height")
  
  local clutelements = 0

  if bpp == 0 then -- 4-Bit CLUT
    clutelements = 16
  elseif bpp == 1 then -- 8-Bit CLUT
    clutelements = 256
  end
  
  -- clutcount = clutsize - sizeof(CLUT_TABLE) / (cluelements * entrysize)
  local clutcount = (clut.BlockSize.value - clut.size) / (clutelements * 2)
  local colors = clut:addStructure("Colors")
  
  for i = 1, clutcount do
    colors:addField(DataType.Blob, "Clut" .. (i - 1), clutelements * 2)
  end
end

function TimFormat.getBpp(bppfield, formattree)
  local bpp = TimBpp[bppfield.value]
  
  if bpp ~= nil then
    return bpp
  end
  
  return "Unknown"
end

return TimFormat