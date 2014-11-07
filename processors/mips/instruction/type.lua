local InstructionType = { Invalid         = -1,
                          Undefined       =  0,
                          Stop            =  1,
                          Nop             =  2,
                          ConditionalJump =  3,
                          ConditionalCall =  4,
                          Jump            =  5, 
                          Call            =  6, 
                          Load            =  7,
                          Store           =  8,
                          Add             =  9,
                          Sub             =  10,
                          Mul             =  11,
                          Div             =  12,
                          And             =  13,
                          Negate          =  14,
                          Or              =  15, 
                          Xor             =  16, 
                          Not             =  17,
                          Nor             =  18,
                          Lsl             =  19,
                          Lsr             =  20,
                          Asr             =  21,
                          Compare         =  22,
                          Cop1            =  23, 
                          Cop2            =  24,
                          SysCall         =  25,
                          Debug           =  26,
                          Trap            =  27,
                          
                          FPUInstructionFirst = 0x100,
                            FPUAbs = 0x100, FPUAdd = 0x101, FPUSub = 0x102, FPUMul = 0x103, FPUDiv = 0x104,
                            FPUNot = 0x105, 
                            FPUCompare = 0x106, FPULoad = 0x107, FPUStore = 0x108,
                          FPUInstructionLast = 0x200
                          }

function InstructionType.color(type)
  if type == InstructionType.Nop then
    return 0xD3D3D3
  elseif type == InstructionType.Stop then
    return 0x822222
  elseif type == InstructionType.Jump then
    return 0xDC143C
  elseif type == InstructionType.Call then
    return 0x808000
  elseif type == InstructionType.ConditionalJump then
    return 0xFF0000
  elseif type == InstructionType.ConditionalCall then
    return 0x32CD32
  elseif (type >= InstructionType.Add) and (type <= InstructionType.Div) then
    return 0xDA70D6
  elseif (type >= InstructionType.And) and (type <= InstructionType.Asr) then
    return 0x7B68EE
  end
  
  return 0x000000
end

return InstructionType
