local pref = require("pref")
local Mips32InstructionSet = require("processors.mips32.instructionset")
local Mips32RegisterSet = require("processors.mips32.registerset")
local Mips32Decoder = require("processors.mips32.decoder")
local Mips32Elaborator = require("processors.mips32.elaborator")

local OperandType = pref.disassembler.operandtype
local OperandDescriptor = pref.disassembler.operanddescriptor
local DataType = pref.datatype
local ReferenceType = pref.disassembler.referencetype

local Mips32Processor = pref.disassembler.createprocessor(Mips32InstructionSet, Mips32RegisterSet, DataType.UInt32)
local decoder = Mips32Decoder(Mips32InstructionSet, Mips32RegisterSet)
local elaborator = Mips32Elaborator(Mips32InstructionSet, Mips32RegisterSet)
local muststop = false

function Mips32Processor:analyze(instruction, baseaddress)  
  local data = instruction:next(DataType.UInt32_LE)
  local constant = bit.band(data, 0xFC000000) -- FIXME: negative in 0x8012E42C (HITPSX.EXE)
  
  if decoder.constantdispatcher[constant] ~= nil then
    return decoder.constantdispatcher[constant](decoder, instruction, data)
  end
  
  if self.instructionset[constant] == nil then
    return -4 -- Invalid Instruction
  end
  
  instruction.opcode = constant
  
  if decoder.instructiondispatcher[instruction.opcode] ~= nil then      
    decoder.instructiondispatcher[instruction.opcode](decoder, instruction, data, baseaddress)
  else
    instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)    -- rt
    instruction:addOperand(OperandType.Register, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)                                   -- rs
    instruction:addOperand(OperandType.Immediate, DataType.UInt32).value = decoder:signExtend(bit.band(data, 0x0000FFFF))                               -- immediate
  end
  
  return DataType.sizeof(DataType.UInt32) -- Fixed instruction size
end

function Mips32Processor:emulate(emulator, instruction)  
  if bit.band(self.instructionset[instruction.opcode].type, pref.disassembler.instructiontype.Stop) ~= 0 then
    if instruction.opcode == self.instructionset["JR"].opcode then
      emulator:push(instruction.address + DataType.sizeof(DataType.UInt32), ReferenceType.Flow)
      muststop = true
    end
    
    return
  end
  
  if (instruction.opcode == self.instructionset["J"].opcode) or (instruction.opcode == self.instructionset["JAL"].opcode) then
    emulator:push(instruction.firstoperand.value, ReferenceType.Call)
  elseif (self.instructionset[instruction.opcode].type == pref.disassembler.instructiontype.Jump) then
    emulator:push(instruction.lastoperand.value, ReferenceType.Jump)
  end
  
  if muststop == false then
    emulator:push(instruction.address + DataType.sizeof(DataType.UInt32), ReferenceType.Flow)
  end
  
  muststop = false
end

function Mips32Processor:elaborate(listing)
  local b = listing.firstblock
  local blocktype = pref.disassembler.blocktype
  
  while b do
    if b.blocktype == blocktype.InstructionBlock then
      elaborator:simplify(b, listing)
    end
    
    b = listing:nextBlock(b)
  end
end

return Mips32Processor