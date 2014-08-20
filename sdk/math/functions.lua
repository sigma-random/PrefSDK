local ffi = require("ffi")

ffi.cdef
[[
  double Math_entropy(void* hexeditdata, uint64_t start, uint64_t size);
]]

local C = ffi.C
local MathFunctions = { }

function MathFunctions.logb(n, b)
  return math.log(n) / math.log(b)
end

function MathFunctions.entropy(databuffer, start, size)
  return C.Math_entropy(databuffer.cthis, start, size)
end

return MathFunctions