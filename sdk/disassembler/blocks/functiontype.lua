local ffi = require("ffi")

ffi.cdef
[[
  const int FunctionType_Function;
  const int FunctionType_EntryPoint;
  const int FunctionType_Export;
  const int FunctionType_Import;
]]

local C = ffi.C
local FunctionType = { Function   = C.FunctionType_Function,
                       EntryPoint = C.FunctionType_EntryPoint,
                       Export     = C.FunctionType_Export,
                       Import     = C.FunctionType_Import }

return FunctionType