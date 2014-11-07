local RInstructions = require("processors.mips.instruction.r")
local IInstructions = require("processors.mips.instruction.i")
local JInstructions = require("processors.mips.instruction.j")
local CopXInstructionSet = require("processors.mips.instruction.copx")

local InstructionSet = { }

function InstructionSet.decode(data)
  local opcode = bit.rshift(bit.band(data, 0xFC000000), 0x1A)
  
  if (opcode == 0x000000) or (opcode == 0x00001C) or (opcode == 0x00001F) then --  R-Type Instruction
    local func = bit.band(data, 0x0000003F)
    return RInstructions[opcode][func]
  end
  
  if bit.band(opcode, 0x000002) and JInstructions[opcode] then -- J-Type Instruction
    return JInstructions[opcode]
  end
  
  if (opcode >= 0x000010) and (opcode <= 0x000013) then -- COPX Instruction
    local copn = bit.band(opcode, 0x000003)
    local op = bit.rshift(bit.band(data, 0x3E00000), 0x15)
    local func = bit.band(data, 0x0000003F)
    
    if CopXInstructionSet.isvalid(copn, op, func, data) then
      return CopXInstructionSet.operation(copn, op, func, data)
    end
  end
    
  return IInstructions[opcode] -- I-Type Instruction
end

return InstructionSet