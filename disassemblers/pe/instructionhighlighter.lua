local capstone = require("capstone")

local InstructionHighlighter = { }

function InstructionHighlighter.highlight(cshandle, instruction)
  if capstone.instructiongroup(cshandle, instruction.csinsn, capstone.X86_GRP_JUMP) then
    return 0xDC143C
  end
  
  if capstone.instructiongroup(cshandle, instruction.csinsn, capstone.X86_GRP_CALL) then
    return 0x808000
  end
    
  if capstone.instructiongroup(cshandle, instruction.csinsn, capstone.X86_GRP_RET) then
    return 0x822222
  end
  
  if instruction.id == capstone.X86_INS_NOP then
    return 0xD3D3D3
  end
  
--   if (type >= InstructionType.Add) and (type <= InstructionType.Div) then
--     return 0xDA70D6
--   elseif (type >= InstructionType.And) and (type <= InstructionType.Asr) then
--     return 0x7B68EE
--   end
  
  return 0x000000
end

return InstructionHighlighter