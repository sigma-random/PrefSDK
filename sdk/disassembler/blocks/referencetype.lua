local ffi = require("ffi")

ffi.cdef
[[
  const int ReferenceType_Flow;
  const int ReferenceType_Code;
  const int ReferenceType_Data;
  const int ReferenceType_Unconditional;
  const int ReferenceType_Conditional;
  const int ReferenceType_Call;
  const int ReferenceType_ConditionalCall;
  const int ReferenceType_Jump;
  const int ReferenceType_ConditionalJump;
  const int ReferenceType_Address;
  const int ReferenceType_Read;
  const int ReferenceType_Write;
]]

local C = ffi.C
local ReferenceType = { Flow            = C.ReferenceType_Flow,
                        Code            = C.ReferenceType_Code,
                        Data            = C.ReferenceType_Data,
                        
                        Unconditional   = C.ReferenceType_Unconditional,
                        Conditional     = C.ReferenceType_Conditional,
                        
                        Call            = C.ReferenceType_Call,
                        ConditionalCall = C.ReferenceType_ConditionalCall,
                        Jump            = C.ReferenceType_Jump,
                        ConditionalJump = C.ReferenceType_ConditionalJump,

                        Address         = C.ReferenceType_Address,
                        Read            = C.ReferenceType_Read,
                        Write           = C.ReferenceType_Write }
                        
function ReferenceType.isDataReference(referencetype)
  return (bit.band(referencetype, ReferenceType.Data) ~= 0)
end

function ReferenceType.isCodeReference(referencetype)
  return (bit.band(referencetype, ReferenceType.Code) ~= 0)
end

function ReferenceType.isCall(referencetype)
  return ReferenceType.isCodeReference(referencetype) and ((referencetype == ReferenceType.Call) or (referencetype == ReferenceType.ConditionalCall))
end

function ReferenceType.isJump(referencetype)
  return ReferenceType.isCodeReference(referencetype) and ((referencetype == ReferenceType.Jump) or (referencetype == ReferenceType.ConditionalJump))
end

function ReferenceType.isConditional(referencetype)
  return ReferenceType.isCodeReference(referencetype) and (bit.band(referencetype, ReferenceType.Conditional) ~= 0)
end

return ReferenceType