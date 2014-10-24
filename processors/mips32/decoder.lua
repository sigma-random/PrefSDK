local oop = require("oop")
local pref = require("pref")

local OperandType = pref.disassembler.operandtype
local OperandDescriptor = pref.disassembler.operanddescriptor
local DataType = pref.datatype

local Mips32Decoder = oop.class()

function Mips32Decoder:__ctor(instructionset, registerset)
  self.instructionset = instructionset
  self.registerset = registerset
  
  self.constantdispatcher = { [0x00000000] = Mips32Decoder.decodeSpecial,
                              [0x04000000] = Mips32Decoder.decodeRegimm,
                              [0x40000000] = Mips32Decoder.decodeCop0,
                              [0x44000000] = Mips32Decoder.decodeCop1,
                              [0x48000000] = Mips32Decoder.decodeCop2,
                              [0x4C000000] = Mips32Decoder.decodeCop1X,
                              [0x70000000] = Mips32Decoder.decodeSpecial2,
                              [0x7C000000] = Mips32Decoder.decodeSpecial3 }
                              
  self.instructiondispatcher = { [instructionset["LUI"].opcode]   = Mips32Decoder.decodeLui,
                                 [instructionset["J"].opcode]     = Mips32Decoder.decodeJump, 
                                 [instructionset["JAL"].opcode]   = Mips32Decoder.decodeJump, 
                                 [instructionset["LWC2"].opcode]  = Mips32Decoder.decodeLoadStoreCop2,
                                 [instructionset["SWC2"].opcode]  = Mips32Decoder.decodeLoadStoreCop2,
                                 [instructionset["BEQ"].opcode]   = Mips32Decoder.decodeNoRegImmCall,
                                 [instructionset["BEQL"].opcode]  = Mips32Decoder.decodeNoRegImmCall,
                                 [instructionset["BGTZ"].opcode]  = Mips32Decoder.decodeNoRegImmCall,
                                 [instructionset["BGTZL"].opcode] = Mips32Decoder.decodeNoRegImmCall,
                                 [instructionset["BLEZ"].opcode]  = Mips32Decoder.decodeNoRegImmCall,
                                 [instructionset["BLEZL"].opcode] = Mips32Decoder.decodeNoRegImmCall,
                                 [instructionset["BLEZ"].opcode]  = Mips32Decoder.decodeNoRegImmCall,
                                 [instructionset["BNE"].opcode]   = Mips32Decoder.decodeNoRegImmCall,
                                 [instructionset["BNEL"].opcode]  = Mips32Decoder.decodeNoRegImmCall,
                                 [instructionset["CACHE"].opcode] = Mips32Decoder.decodeCache,
                                 [instructionset["LB"].opcode]    = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["LBU"].opcode]   = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["LH"].opcode]    = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["LHU"].opcode]   = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["LL"].opcode]    = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["LW"].opcode]    = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["LWL"].opcode]   = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["LWR"].opcode]   = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["SB"].opcode]    = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["SC"].opcode]    = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["SH"].opcode]    = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["SW"].opcode]    = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["SWL"].opcode]   = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["SWR"].opcode]   = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["LDC2"].opcode]  = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["LWC2"].opcode]  = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["SDC2"].opcode]  = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["SWC2"].opcode]  = Mips32Decoder.decodeBaseOffset,
                                 [instructionset["ANDI"].opcode]  = Mips32Decoder.decodeLogical,
                                 [instructionset["ORI"].opcode]   = Mips32Decoder.decodeLogical,
                                 [instructionset["XORI"].opcode]  = Mips32Decoder.decodeLogical }
end

function Mips32Decoder:signExtend(address)
  if bit.band(address, 0x8000) ~= 0 then
    return bit.bor(0xFFFF0000, address)
  end
  
  return address
end

function Mips32Decoder:decodeSpecial(instruction, data)
  instruction.opcode = bit.bor(0x00000000, bit.band(data, 0x3F)) -- SPECIAL | ... | OPCODE
    
  if (instruction.opcode == self.instructionset["SLL"].opcode) or (instruction.opcode == self.instructionset["SRL"].opcode) then
    instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)   -- rd
    instruction:addOperand(OperandType.Register, OperandDescriptor.Source, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)        -- rt
    instruction:addOperand(OperandType.Immediate, OperandDescriptor.Scale, DataType.UInt8).value = bit.rshift(bit.band(data, 0x000007C0), 0x06)        -- sa
    return DataType.sizeof(DataType.UInt32)
  end
  
  if instruction.opcode == self.instructionset["JR"].opcode then
    instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)   -- rs
    return DataType.sizeof(DataType.UInt32)
  end
  
  instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)     -- rd
  instruction:addOperand(OperandType.Register, OperandDescriptor.Source, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)     -- rs
  instruction:addOperand(OperandType.Register, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)     -- rt
  
  return DataType.sizeof(DataType.UInt32)
end

function Mips32Decoder:decodeRegimm(instruction, data)
  local offset = bit.lshift(self:signExtend(bit.band(data, 0x0000FFFF)), 2)  
  instruction.opcode = bit.bor(0x04000000, bit.band(data, 0x001F0000)) -- REGIMM | ... | OPCODE
  
  local sourceop = instruction:addOperand(OperandType.Register, DataType.UInt8)
  local destop = instruction:addOperand(OperandType.Address, OperandDescriptor.Destination, DataType.UInt32)
  
  sourceop.value = bit.rshift(bit.band(data, 0x03E00000), 0x15)     -- rs
  destop.value = instruction.address + DataType.sizeof(DataType.UInt32) + offset
  
  return DataType.sizeof(DataType.UInt32)
end

function Mips32Decoder:decodeCop0(instruction, data)
  -- NOTE: COP0 Implemented yet
  
  return -4
end

function Mips32Decoder:decodeCop1(instruction, data)
  -- NOTE: COP1 (FPU) Not Implemented yet
  
  return -4
end

function Mips32Decoder:decodeCop2(instruction, data)  
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

function Mips32Decoder:decodeCop1X(instruction, data)
  -- NOTE: COP1X Not Implemented yet
  
  return -4
end

function Mips32Decoder:decodeSpecial2(instruction, data)
  instruction.opcode = bit.bor(0x70000000, bit.band(data, 0x21))  -- SPECIAL2 | ... | OPCODE
  
  instruction:addOperand(OperandType.Register, OperandDescriptor.Source, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)      -- rs
  instruction:addOperand(OperandType.Register, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)                                -- rt
  instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x0000F800), 0x0B) -- rd
  
  return DataType.sizeof(DataType.UInt32)
end

function Mips32Decoder:decodeSpecial3(instruction, data)
  -- NOTE: Not Implemented yet
  
  return -4
end

function Mips32Decoder:decodeLui(instruction, data, baseaddress)
  instruction:addOperand(OperandType.Register, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)                           -- rt
  instruction:addOperand(OperandType.Address, OperandDescriptor.Source, DataType.UInt32).value = bit.lshift(bit.band(data, 0x0000FFFF), 16)   -- address
end

function Mips32Decoder:decodeJump(instruction, data, baseaddress)
  instruction:addOperand(OperandType.Address, OperandDescriptor.Destination, DataType.UInt32).value = baseaddress + bit.lshift(bit.band(data, 0x3FFFFFF), 2)  -- instr_index
end

function Mips32Decoder:decodeLoadStoreCop2(instruction, data, baseaddress)
  instruction:addOperand(OperandType.Immediate, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)   -- COP2 Data Register
  instruction:addOperand(OperandType.Immediate, OperandDescriptor.Displacement, DataType.UInt32).value = self:signExtend(bit.band(data, 0x0000FFFF))  -- offset
  instruction:addOperand(OperandType.Register, OperandDescriptor.Base, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)           -- base
  
  instruction.format = "%1, [%3 + %2]"
end

function Mips32Decoder:decodeNoRegImmCall(instruction, data, baseaddress)
  local offset = bit.lshift(self:signExtend(bit.band(data, 0x0000FFFF)), 2)
  
  instruction:addOperand(OperandType.Register, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)                                                     -- rs
  instruction:addOperand(OperandType.Register, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)                                                     -- rt
  instruction:addOperand(OperandType.Address, OperandDescriptor.Destination, DataType.UInt32).value = instruction.address + DataType.sizeof(DataType.UInt32) + offset   -- address
end

function Mips32Decoder:decodeCache(instruction, data, baseaddress)
  instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)    -- op
  instruction:addOperand(OperandType.Immediate, OperandDescriptor.Displacement, DataType.UInt32).value = self:signExtend(bit.band(data, 0x0000FFFF))  -- offset
  instruction:addOperand(OperandType.Register, OperandDescriptor.Base, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)           -- base
  
  instruction.format = "%1, [%3 + %2]"
end

function Mips32Decoder:decodeBaseOffset(instruction, data, baseaddress)
  instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)    -- rt
  instruction:addOperand(OperandType.Immediate, OperandDescriptor.Displacement, DataType.UInt32).value = self:signExtend(bit.band(data, 0x0000FFFF))  -- offset
  instruction:addOperand(OperandType.Register, OperandDescriptor.Base, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)           -- base
  
  instruction.format = "%1, [%3 + %2]"
end

function Mips32Decoder:decodeLogical(instruction, data, baseaddress)
  instruction:addOperand(OperandType.Register, OperandDescriptor.Destination, DataType.UInt8).value = bit.rshift(bit.band(data, 0x001F0000), 0x10)    -- rt
  instruction:addOperand(OperandType.Register, DataType.UInt8).value = bit.rshift(bit.band(data, 0x03E00000), 0x15)                                   -- rs
  instruction:addOperand(OperandType.Immediate, DataType.UInt32).value = self:signExtend(bit.band(data, 0x0000FFFF))                                  -- immediate
end

return Mips32Decoder
