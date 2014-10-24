local oop = require("oop")
local pref = require("pref")

local BlockType = pref.disassembler.blocktype
local InstructionType = pref.disassembler.instructiontype
local InstructionCategory = pref.disassembler.instructioncategory
local OperandType = pref.disassembler.operandtype
local OperandDescriptor = pref.disassembler.operanddescriptor
local DataType = pref.datatype

local Mips32Elaborator = oop.class()

function Mips32Elaborator:__ctor(instructionset, registerset)
  self.instructionset = instructionset
  self.registerset = registerset
end

function Mips32Elaborator:simplify(instruction, listing)
  if not instruction.valid then
    return
  end
  
  if (instruction.opcode == self.instructionset["SLL"].opcode) and (instruction:operand(0).value == self.registerset["zero"].id) and (instruction:operand(1).value == self.registerset["zero"].id) and (instruction:operand(2).value == self.registerset["zero"].id) then
    self:simplifyToNop(instruction)
  elseif (instruction.opcode == self.instructionset["ADD"].opcode) or (instruction.opcode == self.instructionset["ADDU"].opcode) then
    self:simplifyAddToMove(instruction)
  elseif (instruction.opcode == self.instructionset["ADDIU"].opcode) and ((instruction:operand(0).value == self.registerset["zero"].id) or (instruction:operand(1).value == self.registerset["zero"].id)) then
    self:simplifyAddiu(instruction)
  elseif instruction.opcode == self.instructionset["LUI"].opcode then
    self:simplifyLui(instruction, listing)
  elseif instruction.opcode == self.instructionset["BREAK"].opcode then
    instruction:clearOperands()
  elseif instruction.opcode == self.instructionset["JR"].opcode then
    instruction:removeOperand(1)
    instruction:removeOperand(2)
  elseif self:isBaseOffsetInstruction(instruction) and ((instruction:operand(0).value == self.registerset["zero"].id) or (instruction:operand(1).value == self.registerset["zero"].id)) then
    self:simplifyBaseOffsetToMove(instruction)
  elseif (not self:isBaseOffsetInstruction(instruction)) and (instruction.operandscount == 3) and (instruction:operand(0).type == OperandType.Register) and (instruction:operand(1).type == OperandType.Register) and (instruction:operand(0).value == instruction:operand(1).value) then
    instruction:removeOperand(1)
  end
end

function Mips32Elaborator:simplifyToNop(instruction)  
  instruction.mnemonic = "NOP"
  instruction.category = InstructionCategory.NoOperation
  instruction.type = InstructionType.Nop
  instruction:clearOperands()
end

function Mips32Elaborator:simplifyLui(instruction, listing)
  if not listing:hasNextBlock(instruction) then
    return
  end
  
  local nextblock = listing:nextBlock(instruction)
  
  if nextblock.blocktype ~= BlockType.InstructionBlock then
    return
  end
  
  if not nextblock.valid then
    return
  end
  
  local pseudoinstruction, luireg, luivalue = nil, instruction:operand(0).value, instruction:operand(1).value
  
  if self:isMathInstruction(nextblock) and (luireg == nextblock:operand(0).value) and (luireg == nextblock:operand(1).value) then
    local opvalue = nextblock:operand(2).value
      
    if nextblock.type == InstructionType.Add then
      luivalue = luivalue + opvalue
    elseif nextblock.type == InstructionType.And then
      luivalue = bit.band(luivalue, opvalue)
    elseif nextblock.type == InstructionType.Or then
      luivalue = bit.bor(luivalue, opvalue)
    elseif nextblock.type == InstructionType.Xor then
      luivalue = bit.bxor(luivalue, opvalue)
    end
    
    pseudoinstruction = listing:replaceInstructions(instruction, nextblock, "LI", InstructionCategory.LoadStore)
    pseudoinstruction:cloneOperand(instruction:operand(0))
    pseudoinstruction:addOperand(OperandType.Address, DataType.UInt32).value = luivalue
  elseif (nextblock.opcode == self.instructionset["LW"].opcode) or (nextblock.opcode == self.instructionset["LH"].opcode) then
    pseudoinstruction = listing:replaceInstructions(instruction, nextblock, nextblock.mnemonic, InstructionCategory.LoadStore)
    pseudoinstruction:cloneOperand(nextblock:operand(0))
    pseudoinstruction:addOperand(OperandType.Address, DataType.UInt32).value = luivalue + nextblock:operand(2).value
  elseif (nextblock.opcode == self.instructionset["SW"].opcode) or (nextblock.opcode == self.instructionset["SH"].opcode) then
    pseudoinstruction = listing:replaceInstructions(instruction, nextblock, nextblock.mnemonic, InstructionCategory.LoadStore)
    pseudoinstruction:addOperand(OperandType.Address, DataType.UInt32).value = luivalue + nextblock:operand(2).value
    pseudoinstruction:cloneOperand(nextblock:operand(0))
  end
end

function Mips32Elaborator:simplifyAddToMove(instruction)
  local op1value, op2value = instruction:operand(1).value, instruction:operand(2).value
  
  if (op1value ~= self.registerset["zero"].id) and (op2value ~= self.registerset["zero"].id) then
    return
  end
  
  if op1value == self.registerset["zero"].id then
    instruction:removeOperand(1)
  elseif op2value == self.registerset["zero"].id then
    instruction:removeOperand(2)
  end
  
  instruction.mnemonic = "MOVE"
  instruction.category = InstructionCategory.LoadStore
  instruction.type = InstructionType.Undefined
  instruction:operand(0).descriptor = OperandDescriptor.Destination
  instruction:operand(1).descriptor = OperandDescriptor.Source
end

function Mips32Elaborator:simplifyBaseOffsetToMove(instruction)
  if instruction:operand(1).value == 0 then
    instruction:removeOperand(1)
  elseif instruction:operand(2).value == self.registerset["zero"].id then
    instruction:removeOperand(2)
  end
  
  instruction.mnemonic = "MOVE"
  instruction.category = InstructionCategory.LoadStore
  instruction.type = InstructionType.Undefined
  
  if self:isBaseOffsetStore(instruction) then -- NOTE: Swap Operators?
    instruction:operand(0).descriptor = OperandDescriptor.Source
    instruction:operand(1).descriptor = OperandDescriptor.Destination
    instruction.format = "%2, %1"
  else
    instruction:operand(0).descriptor = OperandDescriptor.Destination
    instruction:operand(1).descriptor = OperandDescriptor.Source
    instruction:resetFormat()
  end
end

function Mips32Elaborator:simplifyAddiu(instruction)
  if instruction:operand(0).value == self.registerset["zero"].id then
    instruction:removeOperand(0)
  elseif instruction:operand(1).value == self.registerset["zero"].id then
    instruction:removeOperand(1)
  end
  
  instruction.mnemonic = "LI"
  instruction.category = InstructionCategory.LoadStore
  instruction.type = InstructionType.Undefined
  instruction:operand(0).descriptor = OperandDescriptor.Destination
  instruction:operand(1).descriptor = OperandDescriptor.Source
end

function Mips32Elaborator:isMathInstruction(instruction)
  local opcode = instruction.opcode
  
  return (opcode == self.instructionset["ADDI"].opcode)  or
         (opcode == self.instructionset["ADDIU"].opcode) or
         (opcode == self.instructionset["ORI"].opcode)   or
         (opcode == self.instructionset["XORI"].opcode)
end

function Mips32Elaborator:isBaseOffsetStore(instruction)
  local opcode = instruction.opcode
  
  return (opcode == self.instructionset["SB"].opcode)    or
         (opcode == self.instructionset["SC"].opcode)    or
         (opcode == self.instructionset["SH"].opcode)    or
         (opcode == self.instructionset["SW"].opcode)    or
         (opcode == self.instructionset["SWL"].opcode)   or
         (opcode == self.instructionset["SWR"].opcode)   or
         (opcode == self.instructionset["SWL"].opcode)   or
         (opcode == self.instructionset["SWR"].opcode)   or
         (opcode == self.instructionset["SDC2"].opcode)  or
         (opcode == self.instructionset["SWC2"].opcode)
end

function Mips32Elaborator:isBaseOffsetInstruction(instruction)
  local opcode = instruction.opcode
  
  return (opcode == self.instructionset["CACHE"].opcode) or
         (opcode == self.instructionset["LB"].opcode)    or
         (opcode == self.instructionset["LBU"].opcode)   or
         (opcode == self.instructionset["LH"].opcode)    or
         (opcode == self.instructionset["LHU"].opcode)   or
         (opcode == self.instructionset["LL"].opcode)    or
         (opcode == self.instructionset["LW"].opcode)    or
         (opcode == self.instructionset["LWL"].opcode)   or
         (opcode == self.instructionset["LWR"].opcode)   or
         (opcode == self.instructionset["SB"].opcode)    or
         (opcode == self.instructionset["SC"].opcode)    or
         (opcode == self.instructionset["SH"].opcode)    or
         (opcode == self.instructionset["SW"].opcode)    or
         (opcode == self.instructionset["SWL"].opcode)   or
         (opcode == self.instructionset["SWR"].opcode)   or
         (opcode == self.instructionset["LDC2"].opcode)  or
         (opcode == self.instructionset["LWC2"].opcode)  or
         (opcode == self.instructionset["SDC2"].opcode)  or
         (opcode == self.instructionset["SWC2"].opcode)
end

return Mips32Elaborator
