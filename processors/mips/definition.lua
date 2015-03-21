-- http://www.eng.ucy.ac.cy/mmichael/courses/ECE314/LabsNotes/02/MIPS_Instruction_Coding_With_Hex.pdf
-- http://web.engr.oregonstate.edu/~walkiner/cs271-wi13/slides/04-IntroAssembly.pdf

local oop = require("oop")
local pref = require("pref")
local Instruction = require("sdk.disassembler.instruction")
local Processor = require("sdk.disassembler.processor")
local OperandType = require("processors.mips.operand.type")
local InstructionSet = require("processors.mips.instruction.set")
local InstructionType = require("processors.mips.instruction.type")
local InvalidInstruction = require("processors.mips.instruction.invalid")
local InstructionEmulator = require("processors.mips.instruction.emulator")

local DataType = pref.datatype

local MipsProcessor = oop.class(Processor)

function MipsProcessor:decode(address, memorybuffer)  
  local data = memorybuffer:read(address, DataType.UInt32)
  local instructiondef = InstructionSet.decode(data)
  
  if instructiondef == nil then
    return InvalidInstruction(address)
  end
  
  local instruction = Instruction(address, instructiondef.mnemonic, instructiondef.type, instructiondef.isjump, instructiondef.iscall, instructiondef.isconditional)
  instruction.size = 4
  
  for _, opdef in pairs(instructiondef.operands) do
    if opdef.type == OperandType.Offset then
      table.insert(instruction.operands, opdef(data, address))
    elseif opdef.type == OperandType.Address  then
      table.insert(instruction.operands, opdef(data, memorybuffer.baseaddress))
    else
      table.insert(instruction.operands, opdef(data))
    end
  end
  
  if instruction.iscall then
    self:setCallDestination(instruction)
  elseif instruction.isjump then
    self:analyzeJump(instruction)
  end
  
  return instruction
end

function MipsProcessor:setCallDestination(instruction)
  if instruction.mnemonic == "JAL" then
    instruction.isdestinationvalid = true
    instruction.destination = instruction.operands[1].value
  end
end

function MipsProcessor:analyzeJump(instruction)
  if instruction.mnemonic == "BEQ" then
    instruction.isdestinationvalid = true
    instruction.destination = instruction.operands[3].value
    
    if instruction.operands[1].value == instruction.operands[2].value then
      instruction.mnemonic = "B"
      instruction.type = InstructionType.Jump
      instruction.operands = { }
    end
  elseif instruction.mnemonic == "BNE" then
    instruction.isdestinationvalid = (instruction.operands[1].value ~= instruction.operands[2].value)
    instruction.destination = instruction.operands[3].value
  elseif (instruction.mnemonic == "BGEZ") or (instruction.mnemonic == "BGTZ") or (instruction.mnemonic == "BLEZ") then
    instruction.isdestinationvalid = true
    instruction.destination = instruction.operands[2].value
    
    if instruction.operands[1].value == 0 then
      instruction.type = InstructionType.Jump
    end
  elseif instruction.mnemonic == "JR" then
    instruction.isdestinationvalid = (instruction.operands[1].value ~= 31)
  elseif instruction.mnemonic == "J" then
    instruction.isdestinationvalid = true
    instruction.destination = instruction.operands[1].value
  end
end

return MipsProcessor
