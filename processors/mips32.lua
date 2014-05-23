local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")
local ProcessorDefinition = require("sdk.disassembler.processor.processordefinition")
local ReferenceType = require("sdk.disassembler.crossreference.referencetype")
local InstructionFeatures = require("sdk.disassembler.instructionfeatures")
local OperandType = require("sdk.disassembler.operandtype")

local MIPS32Mnemonics = { [0x00000020] = "ADD",     [0x20000000] = "ADDI",    [0x24000000] = "ADDIU",  [0x00000021] = "ADDU",    [0x00000024] = "AND",   [0x30000000] = "ANDI",  [0x04110000] = "BAL",   [0x10000000] = "BEQ",
                          [0x50000000] = "BEQL",    [0x04010000] = "BGEZ",    [0x04110000] = "BGEZAL", [0x04130000] = "BGEZALL", [0x04030000] = "BGEZL", [0x1C000000] = "BGTZ",  [0x5C000000] = "BGTZL", [0x18000000] = "BLEZ",
                          [0x58000000] = "BLEZL",   [0x04000000] = "BLTZ",    [0x04100000] = "BLTZAL", [0x04120000] = "BLTZALL", [0x04020000] = "BLTZL", [0x14000000] = "BNE",   [0x54000000] = "BNEL",  [0x0000000D] = "BREAK",
                          [0xBC000000] = "CACHE",   [0x48400000] = "CFC2",    [0x70000021] = "CLO",    [0x70000020] = "CLZ",     [0x4A000000] = "COP2",  [0x48C00000] = "CTC2",  [0x0000001A] = "DIV",   [0x0000001B] = "DIVU",
                          [0x000000C0] = "EHB",     [0x08000000] = "J",       [0x0C000000] = "JAL",    [0x00000009] = "JALR",    [0x00000008] = "JR",    [0x03E00008] = "JR",    [0x80000000] = "LB",    [0x90000000] = "LBU",
                          [0x84000000] = "LH",      [0x94000000] = "LHU",     [0xC0000000] = "LL",     [0x3C000000] = "LUI",     [0x8C000000] = "LW",    [0xC8000000] = "LWC2",  [0x88000000] = "LWL",   [0x98000000] = "LWR",
                          [0x70000000] = "MADD",    [0x70000001] = "MADDU",   [0x00000010] = "MFHI",   [0x00000012] = "MFLO",    [0x0000000B] = "MOVN",  [0x0000000A] = "MOVZ",  [0x70000004] = "MSUB",  [0x70000005] = "MSUBU",
                          [0x00000011] = "MTHI",    [0x00000013] = "MTLO",    [0x70000002] = "MUL",    [0x00000018] = "MULT",    [0x00000019] = "MULTU", [0x00000027] = "NOR",   [0x00000025] = "OR",    [0x34000000] = "ORI",
                          [0x7C00003B] = "RDHWR",   [0x41400000] = "RDPGPR",  [0x00000046] = "ROTRV",  [0xA0000000] = "SB",      [0xE0000000] = "SC",    [0x7C000420] = "SEB",   [0x7C000620] = "SEH",   [0xA4000000] = "SH",
                          [0x00000000] = "SLL",     [0x00000004] = "SLLV",    [0x0000002A] = "SLT",    [0x28000000] = "SLTI",    [0x2C000000] = "SLTIU", [0x0000002B] = "SLTU",  [0x00000003] = "SRA",   [0x00000007] = "SRAV",
                          [0x00000002] = "SRL",     [0x00000006] = "SRLV",    [0x00000022] = "SUB",    [0x00000023] = "SUBU",    [0xAC000000] = "SW",    [0xE8000000] = "SWC2",  [0xA8000000] = "SWL",   [0xB8000000] = "SWR",
                          [0x0000000C] = "SYSCALL", [0x00000030] = "TGE",     [0x00000026] = "XOR",    [0x38000000] = "XORI" }

local MIPS32Features = { [0x00000020] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x20000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x24000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x00000021] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000024] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x30000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x04110000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1),
                         [0x10000000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2, InstructionFeatures.Use3), 
                         [0x50000000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2, InstructionFeatures.Use3),
                         [0x04010000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x04110000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x04130000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x04030000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x1C000000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x5C000000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x18000000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x58000000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x04000000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x04100000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x04120000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x04020000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x14000000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2, InstructionFeatures.Use3),
                         [0x54000000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1, InstructionFeatures.Use2, InstructionFeatures.Use3),
                         [0x0000000D] = 0,
                         [0xBC000000] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2, InstructionFeatures.Use3),
                         [0x48400000] = bit.bor(InstructionFeatures.Change1, InstructionFeatures.Use2),
                         [0x70000021] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1),
                         [0x70000020] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1),
                         [0x4A000000] = bit.bor(InstructionFeatures.Use1),
                         [0x48C00000] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2), 
                         [0x0000001A] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x0000001B] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x000000C0] = 0,
                         [0x08000000] = bit.bor(InstructionFeatures.Jump, InstructionFeatures.Use1),
                         [0x0C000000] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1),
                         [0x00000009] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Change3, InstructionFeatures.Use1),
                         [0x00000008] = bit.bor(InstructionFeatures.Jump, InstructionFeatures.Use1),
                         [0x03E00008] = InstructionFeatures.Stop,
                         [0x80000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x90000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x84000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x94000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0xC0000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x3C000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use3),
                         [0x8C000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0xC8000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x88000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3), 
                         [0x98000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x70000000] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x70000001] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000010] = bit.bor(InstructionFeatures.Use1),
                         [0x00000012] = bit.bor(InstructionFeatures.Use1),
                         [0x0000000B] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x0000000A] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x70000004] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x70000005] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000011] = bit.bor(InstructionFeatures.Use1),
                         [0x00000013] = bit.bor(InstructionFeatures.Use1),
                         [0x70000002] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000018] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000019] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000027] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2), 
                         [0x00000025] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x34000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x7C00003B] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use3),
                         [0x41400000] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use2),
                         [0x00000046] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0xA0000000] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0xE0000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Change3, InstructionFeatures.Use1),
                         [0x7C000420] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use2),
                         [0x7C000620] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use2),
                         [0xA4000000] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x00000004] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x0000002A] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x28000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x2C000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x0000002B] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2), 
                         [0x00000003] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x00000007] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000002] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3),
                         [0x00000006] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000022] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000023] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0xAC000000] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0xE8000000] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0xA8000000] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0xB8000000] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x0000000C] = 0,
                         [0x00000030] = bit.bor(InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x00000026] = bit.bor(InstructionFeatures.Change3, InstructionFeatures.Use1, InstructionFeatures.Use2),
                         [0x38000000] = bit.bor(InstructionFeatures.Change2, InstructionFeatures.Use1, InstructionFeatures.Use3) }

local MIPS32OpCodes = { Math_ADD     = 0x00000020, Math_ADDI   = 0x20000000, Math_ADDIU   = 0x24000000, Math_ADDU    = 0x00000021, Log_AND    = 0x00000024, Log_ANDI  = 0x30000000, Bra_BAL    = 0x04110000, Bra_BEQ    = 0x10000000,
                        OBra_BEQL    = 0x50000000, Bra_BGEZ    = 0x04010000, Bra_BGEZAL   = 0x04110000, OBra_BGEZALL = 0x04130000, OBra_BGEZL = 0x04030000, Bra_BGTZ  = 0x1C000000, OBra_BGTZL = 0x5C000000, Bra_BLEZ   = 0x18000000,
                        OBra_BLEZL   = 0x58000000, Bra_BLTZ    = 0x04000000, Bra_BLTZAL   = 0x04100000, OBra_BLTZALL = 0x04120000, OBra_BLTZL = 0x04020000, Bra_BNE   = 0x14000000, OBra_BNEL  = 0x54000000, Trap_BREAK = 0x0000000D,
                        Priv_CACHE   = 0xBC000000, Cop_CFC2    = 0x48400000, Math_CLO     = 0x70000021, Math_CLZ     = 0x70000020, Cop_COP2   = 0x4A000000, Cop_CTC2  = 0x48C00000, Math_DIV   = 0x0000001A, Math_DIVU  = 0x0000001B,
                        Ctrl_EHB     = 0x000000C0, Branch_J    = 0x08000000, Branch_JAL   = 0x0C000000, Branch_JALR  = 0x00000009, Branch_JR  = 0x00000008, Stop_JR   = 0x03E00008, Mem_LB     = 0x80000000, Mem_LBU    = 0x90000000,
                        Mem_LH       = 0x84000000, Mem_LHU     = 0x94000000, Mem_LL       = 0xC0000000, Log_LUI      = 0x3C000000, Mem_LW     = 0x8C000000, Cop_LWC2  = 0xC8000000, Mem_LWL    = 0x88000000, Mem_LWR    = 0x98000000,
                        Math_MADD    = 0x70000000, Math_MADDU  = 0x70000001, Move_MFHI    = 0x00000010, Move_MFLO    = 0x00000012, Move_MOVN  = 0x0000000B, Move_MOVZ = 0x0000000A, Math_MSUB  = 0x70000004, Math_MSUBU = 0x70000005,
                        Move_MTHI    = 0x00000011, Move_MTLO   = 0x00000013, Math_MUL     = 0x70000002, Math_MULT    = 0x00000018, Math_MULTU = 0x00000019, Log_NOR   = 0x00000027, Log_OR     = 0x00000025, Log_ORI    = 0x34000000,
                        Move_RDHWR   = 0x7C00003B, Priv_RDPGPR = 0x41400000, Shift_ROTRV  = 0x00000046, Mem_SB       = 0xA0000000, Mem_SC     = 0xE0000000, Math_SEB  = 0x7C000420, Math_SEH   = 0x7C000620, Mem_SH     = 0xA4000000,
                        Shift_SLL    = 0x00000000, Shift_SLLV  = 0x00000004, Math_SLT     = 0x0000002A, Math_SLTI    = 0x28000000, Math_SLTIU = 0x2C000000, Math_SLTU = 0x0000002B, Shift_SRA  = 0x00000003, Shift_SRAV = 0x00000007,
                        Shift_SRL    = 0x00000002, Shift_SRLV  = 0x00000006, Math_SUB     = 0x00000022, Math_SUBU    = 0x00000023, Mem_SW     = 0xAC000000, Cop_SWC2  = 0xE8000000, Mem_SWL    = 0xA8000000, Mem_SWR    = 0xB8000000,
                        Trap_SYSCALL = 0x0000000C, Trap_TGE    = 0x00000030, Log_XOR      = 0x00000026, Log_XORI     = 0x38000000 }

local MIPS32Registers = { [00] = "$zero", [01] = "$at", [02] = "$v0",  [03] = "$v1", [04] = "$a0", [05] = "$a1", [06] = "$v2", [07] = "$a3",
                          [08] = "$t0",   [09] = "$t1", [10] = "$t2",  [11] = "$t3", [12] = "$t4", [13] = "$t5", [14] = "$t6", [15] = "$t7", 
                          [16] = "$s0",   [17] = "$s1", [18] = "$s2",  [19] = "$s3", [20] = "$s4", [21] = "$s5", [22] = "$s6", [23] = "$s7", 
                          [24] = "$t8",   [25] = "$r9", [26] = "$k0",  [27] = "$k1", [28] = "$gp", [29] = "$sp", [30] = "$fp", [31] = "$ra" }

local function outoperand(instructionprinter, operand)
  if operand.type == OperandType.Memory then
      instructionprinter:outAddress("%sh", operand)
  elseif operand.type == OperandType.Register then
    instructionprinter:outRegister(operand.reg)
  elseif operand.type == OperandType.Immediate then
    instructionprinter:outImmediate("%sh", operand)
  end
end

local MIPS32Processor = oop.class(ProcessorDefinition)

function MIPS32Processor:__ctor()
  ProcessorDefinition.__ctor(self, "MIPS32", MIPS32Mnemonics, MIPS32Features, MIPS32Registers, outoperand)
  
  self.constantdispatcher = { [0x00000000] = MIPS32Processor.parseSpecial,
                              [0x10000000] = MIPS32Processor.parseRegimm,
                              [0x40000000] = MIPS32Processor.parseCop0,
                              [0x44000000] = MIPS32Processor.parseCop1,
                              [0x48000000] = MIPS32Processor.parseCop2,
                              [0x4C000000] = MIPS32Processor.parseCop1X,
                              [0x70000000] = MIPS32Processor.parseSpecial2,
                              [0x7C000000] = MIPS32Processor.parseSpecial3 }
                              
end

function MIPS32Processor:parseSpecial(instruction, data)
  instruction.type = bit.bor(0x00000000, bit.band(data, 0x3F)) -- SPECIAL | ... | OPCODE
  
  instruction.operand1.type = OperandType.Register -- rs
  instruction.operand1.reg = bit.rshift(bit.band(data, 0x03E00000), 0x15) 
  
  instruction.operand2.type = OperandType.Register -- rt
  instruction.operand2.reg = bit.rshift(bit.band(data, 0x001F0000), 0x10)
  
  instruction.operand3.type = OperandType.Register -- rd
  instruction.operand3.reg = bit.rshift(bit.band(data, 0x0000F800), 0x0B)
end

function MIPS32Processor:parseRegimm(instruction, data)
  instruction.type = bit.bor(0x04000000, bit.band(data, 0x001F0000)) -- REGIMM | ... | OPCODE
  
  instruction.operand1.type = OperandType.Register -- rs
  instruction.operand1.reg = bit.rshift(bit.band(data, 0x03E00000), 0x15) 
  
  instruction.operand2.type = OperandType.Memory
  instruction.operand2.datatype = DataType.UInt32
  instruction.operand2.address = (instruction.address + DataType.sizeOf(DataType.UInt32)) + bit.lshift(bit.band(data, 0x0000FFFF), 2)
end

function MIPS32Processor:parseCop0(instruction, data)
  -- NOTE: COP0 Implemented yet 
end

function MIPS32Processor:parseCop1(instruction, data)
  -- NOTE: COP1 (FPU) Not Implemented yet
end

function MIPS32Processor:parseCop2(instruction, data)
  -- NOTE: COP2 Not Implemented yet
end

function MIPS32Processor:parseCop1X(instruction, data)
  -- NOTE: COP1X Not Implemented yet
end

function MIPS32Processor:parseSpecial2(instruction, data)
  instruction.type = bit.bor(0x70000000, bit.band(data, 0x21))  -- SPECIAL2 | ... | OPCODE
  
  instruction.operand1.type = OperandType.Register -- rs
  instruction.operand1.reg = bit.rshift(bit.band(data, 0x03E00000), 0x15) 
  
  instruction.operand2.type = OperandType.Register -- rt
  instruction.operand2.reg = bit.rshift(bit.band(data, 0x001F0000), 0x10)
  
  instruction.operand3.type = OperandType.Register -- rd
  instruction.operand3.reg = bit.rshift(bit.band(data, 0x0000F800), 0x0B)
end

function MIPS32Processor:parseSpecial3(instruction, data)
  -- NOTE: Not Implemented yet
end

function MIPS32Processor:analyze(instruction)
  local data = instruction:next(DataType.UInt32)
  local constant = tonumber(ffi.cast("uint32_t", bit.band(data, 0xFC000000))) -- HACK: Force Unsigned Type
  
  if self.constantdispatcher[constant] then
    self.constantdispatcher[constant](self, instruction, data)
    return DataType.sizeOf(DataType.UInt32) -- Fixed instruction size
  end
  
  if self.mnemonics[constant] == nil then
    return 0 -- Invalid Instruction
  end
  
  -- If we fall here we have found a "non-constant" instruction
  instruction.type = constant
  
  instruction.operand1.type = OperandType.Register -- rs
  instruction.operand1.reg = bit.rshift(bit.band(data, 0x03E00000), 0x15) 
  
  instruction.operand2.type = OperandType.Register -- rt
  instruction.operand2.reg = bit.rshift(bit.band(data, 0x001F0000), 0x10)
  
  instruction.operand3.type = OperandType.Immediate
  instruction.operand3.datatype = DataType.UInt16
  instruction.operand3.value = bit.band(data, 0x0000FFFF)
  
  return DataType.sizeOf(DataType.UInt32) -- Fixed instruction size
end

function MIPS32Processor:emulate(addressqueue, referencetable, instruction)
  if self.features[instruction.type] ~= InstructionFeatures.Stop then
    addressqueue:pushFront(instruction.address + DataType.sizeOf(DataType.UInt32))
  end
end

function MIPS32Processor:output(instructionprinter, instruction)
  instructionprinter:outVirtualAddress("%08X", instruction)
  instructionprinter:outHexDump(instruction.address, DataType.sizeOf(DataType.UInt32))
  instructionprinter:outMnemonic(0, instruction)
  
  if instruction.operand1.type == OperandType.Void then
    return
  end
  
  instructionprinter:outnOperand(1, instruction)
    
  if instruction.operand2.type == OperandType.Void then
    return
  end
  
  instructionprinter:out(", ")
  instructionprinter:outnOperand(2, instruction)
      
  if instruction.operand3.type == OperandType.Void then
    return
  end
  
  instructionprinter:out(", ")
  instructionprinter:outnOperand(3, instruction)
end

return MIPS32Processor