local pref = require("pref")
local Mips32InstructionSet = require("processors.mips32.instructionset")
local Mips32RegisterSet = require("processors.mips32.registerset")

local OperandDescriptor = pref.disassembler.operanddescriptor
local OperandType = pref.disassembler.operandtype
local DataType = pref.datatype

local Mips32 = { muststop = false }

function Mips32.signExtend(address)
  if bit.band(address, 0x8000) ~= 0 then
    return bit.bor(0xFFFF0000, address)
  end
  
  return address
end

function Mips32.parseSpecial(instruction, data)
  instruction.opcode = bit.bor(0x00000000, bit.band(data, 0x3F)) -- SPECIAL | ... | OPCODE
    
  if (instruction.opcode == Mips32InstructionSet["SLL"].opcode) or (instruction.opcode == Mips32InstructionSet["SRL"].opcode) then
    instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)   -- rd
    instruction:addOperand(OperandType.Register, OperandDescriptor.Source, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)        -- rt
    instruction:addOperand(OperandType.Immediate, OperandDescriptor.Scale, DataType.UInt8).value = bit.rshift(bit.band(data, 0x000007C0), 0x06)        -- sa
    return DataType.sizeof(DataType.UInt32)
  end
  
  if instruction.opcode == Mips32InstructionSet["JR"].opcode then
    instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)   -- rs
    return DataType.sizeof(DataType.UInt32)
  end
  
  instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)     -- rd
  instruction:addOperand(OperandType.Register, OperandDescriptor.Source, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)     -- rs
  instruction:addOperand(OperandType.Register, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)     -- rt
  
  return DataType.sizeof(DataType.UInt32)
end

function Mips32.parseRegimm(instruction, data)
  local offset = bit.lshift(Mips32.signExtend(bit.band(data, 0x0000FFFF)), 2)  
  instruction.opcode = bit.bor(0x04000000, bit.band(data, 0x001F0000)) -- REGIMM | ... | OPCODE
  
  local sourceop = instruction:addOperand(OperandType.Register, DataType.UInt8)
  local destop = instruction:addOperand(OperandType.Address, OperandDescriptor.Destination, DataType.UInt32)
  
  sourceop.value = bit.rshift(bit.band(data, 0x03E00000), 0x15)     -- rs
  destop.value = instruction.address + DataType.sizeof(DataType.UInt32) + offset
  
  return DataType.sizeof(DataType.UInt32)
end

function Mips32.parseCop0(instruction, data)
  -- NOTE: COP0 Implemented yet
  
  return -4
end

function Mips32.parseCop1(instruction, data)
  -- NOTE: COP1 (FPU) Not Implemented yet
  
  return -4
end

function Mips32.parseCop2(instruction, data)  
  if bit.band(data, 0x02000000) ~= 0 then -- Check for 'COP2' Instruction
    instruction.opcode = bit.bor(0x48000000, bit.band(data, 0x02000000)) -- COP2 | CO | ...
    instruction:addOperand(OperandType.Immediate, OperandDescriptor.Destination, DataType.UInt32).value = bit.band(data, 0x01FFFFFF) 
    return DataType.sizeof(DataType.UInt32)
  end
  
  local cop2op = bit.band(data, 0x03E00000) 
  
  if cop2op == 0x01000000 then -- Branch Operation
    instruction.opcode = bit.bor(0x48000000, bit.band(data, 0x3E30000)) -- COP2 | COP2OP | ... | ND | TF | ...
    instruction:addOperand(OperandType.Immediate, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001C0000), 0x12)
    instruction:addOperand(OperandType.Immediate, OperandDescriptor.Destination, DataType.UInt32).value = bit.lshift(bit.band(data, 0x0000FFFF), 2)
  else
    instruction.opcode = bit.bor(0x48000000, cop2op) -- COP2 | COP2OP | ...
    instruction:addOperand(OperandType.Register, OperandDescriptor.Source, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
    instruction:addOperand(OperandType.Immediate, OperandDescriptor.Destination, DataType.UInt32).value = bit.band(data, 0x0000FFFF)
  end
  
  return DataType.sizeof(DataType.UInt32)
end

function Mips32.parseCop1X(instruction, data)
  -- NOTE: COP1X Not Implemented yet
  
  return -4
end

function Mips32.parseSpecial2(instruction, data)
  instruction.opcode = bit.bor(0x70000000, bit.band(data, 0x21))  -- SPECIAL2 | ... | OPCODE
  
  instruction:addOperand(OperandType.Register, OperandDescriptor.Source, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15) -- rs
  instruction:addOperand(OperandType.Register, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10) -- rt
  instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x0000F800), 0x0B) -- rd
  
  return DataType.sizeof(DataType.UInt32)
end

function Mips32.parseSpecial3(instruction, data)
  -- NOTE: Not Implemented yet
  
  return -4
end

function Mips32.simplifyInstruction(instruction, listing)
  local blocktype = pref.disassembler.blocktype
  
  if not instruction.valid then
    return
  end
  
  if (instruction.opcode == Mips32InstructionSet["SLL"].opcode) and (instruction:operand(0).value == Mips32RegisterSet["zero"]) and (instruction:operand(1).value == Mips32RegisterSet["zero"]) and (instruction:operand(2).value == Mips32RegisterSet["zero"]) then
    Mips32.simplifyToNop(instruction)
  elseif (instruction.opcode == Mips32InstructionSet["ADD"].opcode) or (instruction.opcode == Mips32InstructionSet["ADDU"].opcode) then
    Mips32.simplifyToMove(instruction)
  elseif (instruction.opcode == Mips32InstructionSet["ADDIU"].opcode) and (instruction:operand(0).value == Mips32RegisterSet["zero"]) then
    Mips32.simplifyAddiu(instruction)
  elseif instruction.opcode == Mips32InstructionSet["LUI"].opcode then
    Mips32.simplifyLui(instruction, listing)
  elseif instruction.opcode == Mips32InstructionSet["BREAK"].opcode then
    instruction:clearOperands()
  elseif instruction.opcode == Mips32InstructionSet["JR"].opcode then
    instruction:removeOperand(1)
    instruction:removeOperand(2)
  elseif Mips32.baseoffsetinstruction[instruction.opcode] and ((instruction:operand(2).value == 0) or (instruction:operand(0).value == Mips32RegisterSet["zero"])) then
    Mips32.simplifyToMove(instruction)
  elseif (Mips32.baseoffsetinstruction[instruction.opcode] == nil) and (instruction.operandscount == 3) and (instruction:operand(0).type == OperandType.Register) and (instruction:operand(1).type == OperandType.Register) and (instruction:operand(0).value == instruction:operand(1).value) then
    instruction:removeOperand(1)
  end
end

function Mips32.simplifyToNop(instruction)  
  instruction.mnemonic = "NOP"
  instruction.category = pref.disassembler.instructioncategory.NoOperation
  instruction.type = pref.disassembler.instructiontype.Nop
  instruction:clearOperands()
end

function Mips32.simplifyLui(instruction, listing)
  instruction:removeOperand(0)
  
  if not listing:hasNextBlock(instruction) then
    return
  end
  
  local nextblock = listing:nextBlock(instruction)
  
  if nextblock.blocktype ~= pref.disassembler.blocktype.InstructionBlock then
    return
  end
  
  if not nextblock.valid then
    return
  end
  
  local pseudoinstruction, luireg, luivalue = nil, instruction:operand(0).value, instruction:operand(1).value
  
  if (Mips32.mathimminstructions[nextblock.opcode] ~= nil) and (luireg == nextblock:operand(0).value) and (luireg == nextblock:operand(1).value) then
    local opvalue = nextblock:operand(2).value
      
    if nextblock.type == pref.disassembler.instructiontype.Add then
      luivalue = luivalue + opvalue
    elseif nextblock.type == pref.disassembler.instructiontype.And then
      luivalue = bit.band(luivalue, opvalue)
    elseif nextblock.type == pref.disassembler.instructiontype.Or then
      luivalue = bit.bor(luivalue, opvalue)
    elseif nextblock.type == pref.disassembler.instructiontype.Xor then
      luivalue = bit.bxor(luivalue, opvalue)
    end
    
    pseudoinstruction = listing:replaceInstructions(instruction, nextblock, "LI", pref.disassembler.instructioncategory.LoadStore)
    pseudoinstruction:cloneOperand(instruction:operand(0))
    pseudoinstruction:addOperand(OperandType.Address, DataType.UInt32).value = luivalue
  elseif (nextblock.opcode == Mips32InstructionSet["LW"].opcode) or (nextblock.opcode == Mips32InstructionSet["LH"].opcode) then
    pseudoinstruction = listing:replaceInstructions(instruction, nextblock, nextblock.mnemonic, pref.disassembler.instructioncategory.LoadStore)
    pseudoinstruction:cloneOperand(nextblock:operand(0))
    pseudoinstruction:addOperand(OperandType.Address, DataType.UInt32).value = luivalue + nextblock:operand(2).value
  elseif (nextblock.opcode == Mips32InstructionSet["SW"].opcode) or (nextblock.opcode == Mips32InstructionSet["SH"].opcode) then
    pseudoinstruction = listing:replaceInstructions(instruction, nextblock, nextblock.mnemonic, pref.disassembler.instructioncategory.LoadStore)
    pseudoinstruction:addOperand(OperandType.Address, DataType.UInt32).value = luivalue + nextblock:operand(2).value
    pseudoinstruction:cloneOperand(nextblock:operand(1))
  end
end

function Mips32.simplifyToMove(instruction)
  if Mips32.baseoffsetinstruction[instruction.opcode] then
    if instruction:operand(2).value == 0 then
      instruction:removeOperand(2)
    elseif instruction:operand(0).value == Mips32RegisterSet["zero"] then
      instruction:removeOperand(0)
    end
  else
    local op1value, op2value = instruction:operand(1).value, instruction:operand(2).value
    
    if (op1value ~= Mips32RegisterSet["zero"]) and (op2value ~= Mips32RegisterSet["zero"]) then
      return
    end
    
    if op1value == Mips32RegisterSet["zero"] then
      instruction:removeOperand(1)
    elseif op2value == Mips32RegisterSet["zero"] then
      instruction:removeOperand(2)
    end
  end
  
  instruction.mnemonic = "MOVE"
  instruction.format = ""
  instruction.category = pref.disassembler.instructioncategory.LoadStore
  instruction.type = pref.disassembler.instructiontype.Undefined
end

function Mips32.simplifyAddiu(instruction)
  instruction:removeOperand(0)
  
  instruction.mnemonic = "LI"
  instruction.category = pref.disassembler.instructioncategory.LoadStore
  instruction.type = pref.disassembler.instructiontype.Undefined
end

Mips32.constantdispatcher = { [0x00000000] = Mips32.parseSpecial,
                              [0x04000000] = Mips32.parseRegimm,
                              [0x40000000] = Mips32.parseCop0,
                              [0x44000000] = Mips32.parseCop1,
                              [0x48000000] = Mips32.parseCop2,
                              [0x4C000000] = Mips32.parseCop1X,
                              [0x70000000] = Mips32.parseSpecial2,
                              [0x7C000000] = Mips32.parseSpecial3 }

Mips32.noregimmccall = { [Mips32InstructionSet["BEQ"].opcode]    = true,
                         [Mips32InstructionSet["BEQL"].opcode]   = true,
                         [Mips32InstructionSet["BGTZ"].opcode]   = true,
                         [Mips32InstructionSet["BGTZL"].opcode]  = true,
                         [Mips32InstructionSet["BLEZ"].opcode]   = true,
                         [Mips32InstructionSet["BLEZL"].opcode]  = true,
                         [Mips32InstructionSet["BLEZ"].opcode]   = true,
                         [Mips32InstructionSet["BNE"].opcode]    = true,
                         [Mips32InstructionSet["BNEL"].opcode]   = true }

Mips32.baseoffsetinstruction = { [Mips32InstructionSet["CACHE"].opcode]  = "%2, [%1 + %3]",
                         [Mips32InstructionSet["LB"].opcode]     = "%2, [%1 + %3]",
                         [Mips32InstructionSet["LBU"].opcode]    = "%2, [%1 + %3]",
                         [Mips32InstructionSet["LH"].opcode]     = "%2, [%1 + %3]",
                         [Mips32InstructionSet["LHU"].opcode]    = "%2, [%1 + %3]",
                         [Mips32InstructionSet["LL"].opcode]     = "%2, [%1 + %3]",
                         [Mips32InstructionSet["LW"].opcode]     = "%2, [%1 + %3]",
                         [Mips32InstructionSet["LWL"].opcode]    = "%2, [%1 + %3]",
                         [Mips32InstructionSet["LWR"].opcode]    = "%2, [%1 + %3]",
                         [Mips32InstructionSet["SB"].opcode]     = "%2, [%1 + %3]",
                         [Mips32InstructionSet["SC"].opcode]     = "%2, [%1 + %3]",
                         [Mips32InstructionSet["SH"].opcode]     = "%2, [%1 + %3]",
                         [Mips32InstructionSet["SW"].opcode]     = "%2, [%1 + %3]",
                         [Mips32InstructionSet["SWL"].opcode]    = "%2, [%1 + %3]",
                         [Mips32InstructionSet["SWR"].opcode]    = "%2, [%1 + %3]",
                         [Mips32InstructionSet["LDC2"].opcode]   = "%2, [%1 + %3]",
                         [Mips32InstructionSet["LWC2"].opcode]   = "%2, [%1 + %3]",
                         [Mips32InstructionSet["SDC2"].opcode]   = "%2, [%1 + %3]",
                         [Mips32InstructionSet["SWC2"].opcode]   = "%2, [%1 + %3]" }

Mips32.mathimminstructions = { [Mips32InstructionSet["ADDI"].opcode]   = true,
                               [Mips32InstructionSet["ADDIU"].opcode]  = true,
                               [Mips32InstructionSet["ANDI"].opcode]   = true,
                               [Mips32InstructionSet["ORI"].opcode]    = true,
                               [Mips32InstructionSet["XORI"].opcode]   = true }

return Mips32