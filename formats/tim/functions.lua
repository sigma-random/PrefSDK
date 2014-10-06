local pref = require("pref")

local TimBpp = { [0] = "4-Bit CLUT", 
                 [1] = "8-Bit CLUT", 
                 [2] = "15-Bit Direct", 
                 [3] = "24-Bit Direct", 
                 [4] = "Mixed" } 

local TimFunctions = { }

function TimFunctions.getBpp(bppfield, formattree)
  local bpp = TimBpp[bppfield.value]
  
  if bpp ~= nil then
    return bpp
  end
  
  return "Unknown"
end

function TimFunctions.createClutBlocks(formattree, bpp)
  local clut = formattree:addStructure("Clut")
  clut:addField(pref.datatype.UInt32_LE, "BlockSize")
  clut:addField(pref.datatype.UInt16_LE, "FrameBufferX")
  clut:addField(pref.datatype.UInt16_LE, "FrameBufferY")
  clut:addField(pref.datatype.UInt16_LE, "Width")
  clut:addField(pref.datatype.UInt16_LE, "Height")
  
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
    colors:addField(pref.datatype.Blob, "Clut" .. (i - 1), clutelements * 2)
  end
end

return TimFunctions