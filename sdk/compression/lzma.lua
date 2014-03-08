local LZma = { }

function LZma.getProperties(prop)
  local lc = prop % 9
  prop = prop / 9
  
  local pb = prop / 5
  local lp = prop % 5
  
  return lc, lp, pb  
end 

return LZma