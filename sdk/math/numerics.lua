local ffi = require("ffi")

local floor, insert = math.floor, table.insert
local Numerics = { }

function Numerics.toString(n, b)
  n = floor(n)
    
  if not b or b == 10 then 
    return tostring(n)
  end
  
  local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local sign = ""
  local t = { }
  
  if n < 0 then
    sign = "-"
    n = -n
  end
  
  repeat
    local d = (n % b) + 1
    n = floor(n / b)
    insert(t, 1, digits:sub(d, d))
  until n == 0
  
  return sign .. table.concat(t, "")
end

function Numerics.compl2(n)
  return bit.bnot(n) + 1
end

return Numerics