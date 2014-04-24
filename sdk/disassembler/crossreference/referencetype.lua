local ReferenceType = { None = 0x00000000,
                        Code = 0x10000000,
                        Data = 0x20000000,
                        
                        CallFar  = bit.bor(0x10000000, 0x00000001),
                        CallNear = bit.bor(0x10000000, 0x00000002),
                        JumpFar  = bit.bor(0x10000000, 0x00000004),
                        JumpNear = bit.bor(0x10000000, 0x00000008),

                        Offset   = bit.bor(0x20000000, 0x00000001),
                        Read     = bit.bor(0x20000000, 0x00000002),
                        Write    = bit.bor(0x20000000, 0x00000004) }

function ReferenceType.isCodeReference(reference)
  return (bit.band(bit.rshift(reference.type, 0x1C), 0x1) ~= 0)
end

function ReferenceType.isDataReference(reference)
  return (bit.band(bit.rshift(reference.type, 0x1C), 0x2) ~= 0)
end
                        
return ReferenceType