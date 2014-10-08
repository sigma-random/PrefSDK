local pref = require("pref")
local Mips32InstructionSet = require("processors.mips32.instructionset")
local Mips32Registers = require("processors.mips32.registers")
local Mips32 = require("processors.mips32.functions")

local Mips32Processor = pref.disassembler.createprocessor(Mips32InstructionSet, Mips32Registers, pref.datatype.UInt32)

function Mips32Processor:analyze(instruction, baseaddress)  
  local data = instruction:next(pref.datatype.UInt32_LE)
  local constant = bit.band(data, 0xFC000000)
  
  if Mips32.constantdispatcher[constant] ~= nil then
    local res = Mips32.constantdispatcher[constant](instruction, data)
    
    if (res > 0) and Mips32.customformats[instruction.opcode] then
      instruction.format = Mips32.customformats[instruction.opcode] -- Set Custom Format
    end
    
    return res    
  else
    instruction.opcode = constant
    
    if Mips32InstructionSet[instruction.opcode] == nil then
      return -4 -- Invalid Instruction
    end
    
    if (instruction.opcode == Mips32InstructionSet["J"].opcode) or (instruction.opcode == Mips32InstructionSet["JAL"].opcode) then
      instruction:addOperand(pref.disassembler.operandtype.Address, pref.datatype.UInt32).value = baseaddress + bit.lshift(bit.band(data, 0x3FFFFFF), 2)                       -- instr_index
    else
      instruction:addOperand(pref.disassembler.operandtype.Register, pref.datatype.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)                                 -- rs
      instruction:addOperand(pref.disassembler.operandtype.Register, pref.datatype.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)                                 -- rt
      
      if Mips32.noregimmccall[instruction.opcode] then
        local offset = bit.lshift(Mips32.signExtend(bit.band(data, 0x0000FFFF)), 2)      
        instruction:addOperand(pref.disassembler.operandtype.Address, pref.datatype.UInt32).value = instruction.address + pref.datatype.sizeof(pref.datatype.UInt32) + offset  -- address
      else
        if instruction.opcode == Mips32InstructionSet["LUI"].opcode then
          instruction:addOperand(pref.disassembler.operandtype.Immediate, pref.datatype.UInt32).value = bit.lshift(bit.band(data, 0x0000FFFF), 16)                             -- immediate
        else
          instruction:addOperand(pref.disassembler.operandtype.Immediate, pref.datatype.UInt32).value = bit.band(data, 0x0000FFFF)                                             -- immediate
        end
      end
    end
  end
  
  if Mips32.customformats[instruction.opcode] then
    instruction.format = Mips32.customformats[instruction.opcode] -- Set Custom Format
  end
  
  return pref.datatype.sizeof(pref.datatype.UInt32) -- Fixed instruction size
end

function Mips32Processor:emulate(emulator, instruction)  
  if bit.band(Mips32InstructionSet[instruction.opcode].type, pref.disassembler.instructiontype.Stop) ~= 0 then
    if instruction.opcode == Mips32InstructionSet["JR"].opcode then
      emulator:push(instruction.address + pref.datatype.sizeof(pref.datatype.UInt32), pref.disassembler.referencetype.Flow)
      Mips32.muststop = true
    end
    
    return
  end
  
  if instruction.opcode == Mips32InstructionSet["JAL"].opcode then
    emulator:push(instruction.firstoperand.value, pref.disassembler.referencetype.Call)
  elseif instruction.opcode == Mips32InstructionSet["J"].opcode then
    emulator:push(instruction.firstoperand.value, pref.disassembler.referencetype.Jump)
  elseif (Mips32InstructionSet[instruction.opcode].type == pref.disassembler.instructiontype.Jump) then
    emulator:push(instruction.lastoperand.value, pref.disassembler.referencetype.Jump)
  end
  
  if Mips32.muststop == false then
    emulator:push(instruction.address + pref.datatype.sizeof(pref.datatype.UInt32), pref.disassembler.referencetype.Flow)
  end
  
  Mips32.muststop = false
end

function Mips32Processor:elaborate(listing)
  local b = listing.firstblock
  local blocktype = pref.disassembler.blocktype
  
  while b do
    if b.blocktype == blocktype.InstructionBlock then
      Mips32.simplifyInstruction(b, listing)
    end
    
    b = listing:nextBlock(b)
  end
end

return Mips32Processor