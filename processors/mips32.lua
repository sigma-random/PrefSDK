local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")
local ProcessorDefinition = require("sdk.disassembler.processor.processordefinition")
local InstructionCategory = require("sdk.disassembler.instructions.instructioncategory")
local InstructionType = require("sdk.disassembler.instructions.instructiontype")
local Instruction = require("sdk.disassembler.instructions.instruction")
local OperandType = require("sdk.disassembler.instructions.operands.operandtype")
local ReferenceType = require("sdk.disassembler.blocks.referencetype")

local MIPS32InstructionSet = { [0x00000020] = { mnemonic = "ADD", category = InstructionCategory.Arithmetic, type = InstructionType.Add },
                               [0x20000000] = { mnemonic = "ADDI", category = InstructionCategory.Arithmetic, type = InstructionType.Add },
                               [0x24000000] = { mnemonic = "ADDIU", category = InstructionCategory.Arithmetic, type = InstructionType.Add },
                               [0x00000021] = { mnemonic = "ADDU", category = InstructionCategory.Arithmetic, type = InstructionType.Add },
                               [0x00000024] = { mnemonic = "AND", category = InstructionCategory.Logical, type = InstructionType.And },
                               [0x30000000] = { mnemonic = "ANDI", category = InstructionCategory.Logical, type = InstructionType.And },
                               [0x10000000] = { mnemonic = "BEQ", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x50000000] = { mnemonic = "BEQL", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x04010000] = { mnemonic = "BGEZ", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x04110000] = { mnemonic = "BGEZAL", category = InstructionCategory.ControlFlow, type = InstructionType.ConditionalCall },
                               [0x04130000] = { mnemonic = "BGEZALL", category = InstructionCategory.ControlFlow, type = InstructionType.ConditionalCall },
                               [0x04030000] = { mnemonic = "BGEZL", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x1C000000] = { mnemonic = "BGTZ", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x5C000000] = { mnemonic = "BGTZL", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x18000000] = { mnemonic = "BLEZ", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x58000000] = { mnemonic = "BLEZL", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x04000000] = { mnemonic = "BLTZ", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x04100000] = { mnemonic = "BLTZAL", category = InstructionCategory.ControlFlow, type = InstructionType.ConditionalCall },
                               [0x04120000] = { mnemonic = "BLTZALL", category = InstructionCategory.ControlFlow, type = InstructionType.ConditionalCall },
                               [0x04020000] = { mnemonic = "BLTZL", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x14000000] = { mnemonic = "BNE", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x54000000] = { mnemonic = "BNEL", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x0000000D] = { mnemonic = "BREAK", category = InstructionCategory.InterruptTrap, type = InstructionType.Stop },
                               [0xBC000000] = { mnemonic = "CACHE", category = InstructionCategory.Privileged, type = InstructionType.Undefined },
                               [0x48400000] = { mnemonic = "CFC2", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x70000021] = { mnemonic = "CLO", category = InstructionCategory.Arithmetic, type = InstructionType.Undefined },
                               [0x70000020] = { mnemonic = "CLZ", category = InstructionCategory.Arithmetic, type = InstructionType.Undefined },
                               [0x4A000000] = { mnemonic = "COP2", category = InstructionCategory.Undefined, type = InstructionType.Undefined },
                               [0x48C00000] = { mnemonic = "CTC2", category = InstructionCategory.Undefined, type = InstructionType.Undefined },
                               [0x0000001A] = { mnemonic = "DIV", category = InstructionCategory.Arithmetic, type = InstructionType.Div },
                               [0x0000001B] = { mnemonic = "DIVU", category = InstructionCategory.Arithmetic, type = InstructionType.Div },
                               [0x000000C0] = { mnemonic = "EHB", category = InstructionCategory.Undefined, type = InstructionType.Undefined },
                               [0x08000000] = { mnemonic = "J", category = InstructionCategory.ControlFlow, type = InstructionType.Jump },
                               [0x0C000000] = { mnemonic = "JAL", category = InstructionCategory.ControlFlow, type = InstructionType.Call },
                               [0x00000009] = { mnemonic = "JALR", category = InstructionCategory.ControlFlow, type = InstructionType.Call },
                               [0x00000008] = { mnemonic = "JR", category = InstructionCategory.ControlFlow, type = InstructionType.Stop },
                               [0x80000000] = { mnemonic = "LB", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x90000000] = { mnemonic = "LBU", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x84000000] = { mnemonic = "LH", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x94000000] = { mnemonic = "LHU", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0xC0000000] = { mnemonic = "LL", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x3C000000] = { mnemonic = "LUI", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x8C000000] = { mnemonic = "LW", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0xC8000000] = { mnemonic = "LWC2", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x88000000] = { mnemonic = "LWL", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x98000000] = { mnemonic = "LWR", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x70000000] = { mnemonic = "MADD", category = InstructionCategory.Arithmetic, type = InstructionType.Undefined },
                               [0x70000001] = { mnemonic = "MADDU", category = InstructionCategory.Arithmetic, type = InstructionType.Undefined },
                               [0x00000010] = { mnemonic = "MFHI", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x00000012] = { mnemonic = "MFLO", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x0000000B] = { mnemonic = "MOVN", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x0000000A] = { mnemonic = "MOVZ", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x70000004] = { mnemonic = "MSUB", category = InstructionCategory.Arithmetic, type = InstructionType.Undefined },
                               [0x70000005] = { mnemonic = "MSUBU", category = InstructionCategory.Arithmetic, type = InstructionType.Undefined },
                               [0x00000011] = { mnemonic = "MTHI", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x00000013] = { mnemonic = "MTLO", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x70000002] = { mnemonic = "MUL", category = InstructionCategory.Arithmetic, type = InstructionType.Mul },
                               [0x00000018] = { mnemonic = "MULT", category = InstructionCategory.Arithmetic, type = InstructionType.Mul },
                               [0x00000019] = { mnemonic = "MULTU", category = InstructionCategory.Arithmetic, type = InstructionType.Mul },
                               [0x00000027] = { mnemonic = "NOR", category = InstructionCategory.Logical, type = bit.bor(InstructionType.Not, InstructionType.Or) },
                               [0x00000025] = { mnemonic = "OR", category = InstructionCategory.Logical, type = InstructionType.Or },
                               [0x34000000] = { mnemonic = "ORI", category = InstructionCategory.Logical, type = InstructionType.Or },
                               [0x7C00003B] = { mnemonic = "RDHWR", category = InstructionCategory.Privileged, type = InstructionType.Undefined },
                               [0x41400000] = { mnemonic = "RDPGPR", category = InstructionCategory.Privileged, type = InstructionType.Undefined },
                               [0xA0000000] = { mnemonic = "SB", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0xE0000000] = { mnemonic = "SC", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x7C000420] = { mnemonic = "SEB", category = InstructionCategory.Arithmetic, type = InstructionType.Undefined },
                               [0x7C000620] = { mnemonic = "SEH", category = InstructionCategory.Arithmetic, type = InstructionType.Undefined },
                               [0xA4000000] = { mnemonic = "SH", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x00000000] = { mnemonic = "SLL", category = InstructionCategory.Logical, type = InstructionType.Lsl },
                               [0x00000004] = { mnemonic = "SLLV", category = InstructionCategory.Logical, type = InstructionType.Lsl },
                               [0x0000002A] = { mnemonic = "SLT", category = InstructionCategory.TestCompare, type = InstructionType.Undefined },
                               [0x28000000] = { mnemonic = "SLTI", category = InstructionCategory.TestCompare, type = InstructionType.Undefined },
                               [0x2C000000] = { mnemonic = "SLTIU", category = InstructionCategory.TestCompare, type = InstructionType.Undefined },
                               [0x0000002B] = { mnemonic = "SLTU", category = InstructionCategory.TestCompare, type = InstructionType.Undefined },
                               [0x00000003] = { mnemonic = "SRA", category = InstructionCategory.Arithmetic, type = InstructionType.Asr },
                               [0x00000007] = { mnemonic = "SRAV", category = InstructionCategory.Arithmetic, type = InstructionType.Asr },
                               [0x00000002] = { mnemonic = "SRL", category = InstructionCategory.Logical, type = InstructionType.Lsr },
                               [0x00000006] = { mnemonic = "SRLV", category = InstructionCategory.Logical, type = InstructionType.Lsr },
                               [0x00000022] = { mnemonic = "SUB", category = InstructionCategory.Arithmetic, type = InstructionType.Sub },
                               [0x00000023] = { mnemonic = "SUBU", category = InstructionCategory.Arithmetic, type = InstructionType.Sub },
                               [0xAC000000] = { mnemonic = "SW", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0xE8000000] = { mnemonic = "SWC2", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0xA8000000] = { mnemonic = "SWL", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0xB8000000] = { mnemonic = "SWR", category = InstructionCategory.LoadStore, type = InstructionType.Undefined },
                               [0x0000000C] = { mnemonic = "SYSCALL", category = InstructionCategory.InterruptTrap, type = InstructionType.Undefined },
                               [0x00000030] = { mnemonic = "TGE", category = InstructionCategory.InterruptTrap, type = InstructionType.Undefined },
                               [0x00000026] = { mnemonic = "XOR", category = InstructionCategory.Logical, type = InstructionType.Xor },
                               [0x38000000] = { mnemonic = "XORI", category = InstructionCategory.Logical, type = InstructionType.Xor } }

local MIPS32OpCodes = { Math_ADD       = 0x00000020, Math_ADDI      = 0x20000000, Math_ADDIU     = 0x24000000, Math_ADDU      = 0x00000021, Log_AND        = 0x00000024, 
                        Log_ANDI       = 0x30000000, Branch_BEQ     = 0x10000000, Branch_BEQL    = 0x50000000, Branch_BGEZ    = 0x04010000, Branch_BGEZAL  = 0x04110000, 
                        Branch_BGEZALL = 0x04130000, Branch_BGEZL   = 0x04030000, Branch_BGTZ    = 0x1C000000, Branch_BGTZL   = 0x5C000000, Branch_BLEZ    = 0x18000000, 
                        Branch_BLEZL   = 0x58000000, Branch_BLTZ    = 0x04000000, Branch_BLTZAL  = 0x04100000, Branch_BLTZALL = 0x04120000, Branch_BLTZL   = 0x04020000, 
                        Branch_BNE     = 0x14000000, Branch_BNEL    = 0x54000000, Trap_BREAK     = 0x0000000D, Priv_CACHE     = 0xBC000000, Cop_CFC2       = 0x48400000, 
                        Math_CLO       = 0x70000021, Math_CLZ       = 0x70000020, Cop_COP2       = 0x4A000000, Cop_CTC2       = 0x48000000, Math_DIV       = 0x0000001A, 
                        Math_DIVU      = 0x0000001B, Ctrl_EHB       = 0x000000C0, Branch_J       = 0x08000000, Branch_JAL     = 0x0C000000, Branch_JALR    = 0x00000009, 
                        Branch_JR      = 0x00000008, Mem_LB         = 0x80000000, Mem_LBU        = 0x90000000, Mem_LH         = 0x84000000, Mem_LHU        = 0x94000000, 
                        Mem_LL         = 0xC0000000, Mem_LUI        = 0x3C000000, Mem_LW         = 0x8C000000, Cop_LWC2       = 0xC8000000, Mem_LWL        = 0x88000000, 
                        Mem_LWR        = 0x98000000, Math_MADD      = 0x70000000, Math_MADDU     = 0x70000001, Move_MFHI      = 0x00000010, Move_MFLO      = 0x00000012, 
                        Move_MOVN      = 0x0000000B, Move_MOVZ      = 0x0000000A, Math_MSUB      = 0x70000004, Math_MSUBU     = 0x70000005, Move_MTHI      = 0x00000011, 
                        Move_MTLO      = 0x00000013, Math_MUL       = 0x70000002, Math_MULT      = 0x00000018, Math_MULTU     = 0x00000019, Log_NOR        = 0x00000027, 
                        Log_OR         = 0x00000025, Log_ORI        = 0x34000000, Priv_RDHWR     = 0x7C00003B, Priv_RDPGPR    = 0x41400000, Mem_SB         = 0xA0000000, 
                        Mem_SC         = 0xE0000000, Math_SEB       = 0x7C000420, Math_SEH       = 0x7C000620, Mem_SH         = 0xA4000000, Log_SLL        = 0x00000000, 
                        Log_SLLV       = 0x00000004, Math_SLT       = 0x0000002A, Math_SLTI      = 0x28000000, Math_SLTIU     = 0x2C000000, Math_SLTU      = 0x0000002B, 
                        Math_SRA       = 0x00000003, Math_SRAV      = 0x00000007, Log_SRL        = 0x00000002, Log_SRLV       = 0x00000006, Math_SUB       = 0x00000022, 
                        Math_SUBU      = 0x00000023, Mem_SW         = 0xAC000000, Cop_SWC2       = 0xE8000000, Mem_SWL        = 0xA8000000, Mem_SWR        = 0xB8000000, 
                        Trap_SYSCALL   = 0x0000000C, Trap_TGE       = 0x00000030, Log_XOR        = 0x00000026, Log_XORI       = 0x38000000 }

local MIPS32RegisterNames = { [0]  = "zero", [1]  = "at", [2]  = "v0", [3]  = "v1", [4] = "a0", 
                              [5]  = "a1",   [6]  = "a2", [7]  = "a3", [8]  = "t0", [9] = "t1", 
                              [10] = "t2",   [11] = "t3", [12] = "t4", [13] = "t5", [14] = "t6", 
                              [15] = "t7",   [16] = "s0", [17] = "s1", [18] = "s2", [19] = "s3", 
                              [20] = "s4",   [21] = "s5", [22] = "s6", [23] = "s7", [24] = "t8", 
                              [25] = "t9",   [26] = "k0", [27] = "k1", [28] = "gp", [29] = "sp", 
                              [30] = "fp",   [31] = "ra" }

local MIPS32Registers = { Reg_ZERO = 0,  Reg_AT   = 1,  Reg_V0   = 2,  Reg_V1   = 3,  Reg_A0   = 4, 
                          Reg_A1   = 5,  Reg_A2   = 6,  Reg_A3   = 7,  Reg_T0   = 8,  Reg_T1   = 9, 
                          Reg_T2   = 10, Reg_T3   = 11, Reg_T4   = 12, Reg_T5   = 13, Reg_T6   = 14, 
                          Reg_T7   = 15, Reg_S0   = 16, Reg_S1   = 17, Reg_S2   = 18, Reg_S3   = 19, 
                          Reg_S4   = 20, Reg_S5   = 21, Reg_S6   = 22, Reg_S7   = 23, Reg_T8   = 24, 
                          Reg_T9   = 25, Reg_K0   = 26, Reg_K1   = 27, Reg_GP   = 28, Reg_SP   = 29, 
                          Reg_FP   = 30, Reg_RA   = 31 }

local MIPS32Processor = oop.class(ProcessorDefinition)

function MIPS32Processor:__ctor()
  ProcessorDefinition.__ctor(self, "MIPS32", MIPS32InstructionSet, MIPS32OpCodes, MIPS32Registers, MIPS32RegisterNames)
  
  self.instructionformats = { [self.opcodes.Priv_CACHE] = "%2, %3(%1)",
                              [self.opcodes.Mem_LB]     = "%2, %3(%1)",
                              [self.opcodes.Mem_LBU]    = "%2, %3(%1)",
                              [self.opcodes.Mem_LH]     = "%2, %3(%1)",
                              [self.opcodes.Mem_LHU]    = "%2, %3(%1)",
                              [self.opcodes.Mem_LL]     = "%2, %3(%1)",
                              [self.opcodes.Mem_LW]     = "%2, %3(%1)",
                              [self.opcodes.Cop_LWC2]   = "%2, %3(%1)",
                              [self.opcodes.Mem_LWL]    = "%2, %3(%1)",
                              [self.opcodes.Mem_LWR]    = "%2, %3(%1)",
                              [self.opcodes.Mem_SB]     = "%2, %3(%1)",
                              [self.opcodes.Mem_SC]     = "%2, %3(%1)",
                              [self.opcodes.Mem_SH]     = "%2, %3(%1)",
                              [self.opcodes.Mem_SW]     = "%2, %3(%1)",
                              [self.opcodes.Cop_SWC2]   = "%2, %3(%1)",
                              [self.opcodes.Mem_SWL]    = "%2, %3(%1)",
                              [self.opcodes.Mem_SWR]    = "%2, %3(%1)" }
  
  self.noregimmccall = { [self.opcodes.Branch_BEQ]   = true,
                         [self.opcodes.Branch_BEQL]  = true,
                         [self.opcodes.Branch_BGTZ]  = true,
                         [self.opcodes.Branch_BGTZL] = true,
                         [self.opcodes.Branch_BLEZ]  = true,
                         [self.opcodes.Branch_BLEZL] = true,
                         [self.opcodes.Branch_BLEZ]  = true,
                         [self.opcodes.Branch_BNE]   = true,
                         [self.opcodes.Branch_BNEL]  = true }
  
  self.constantdispatcher = { [0x00000000] = MIPS32Processor.parseSpecial,
                              [0x04000000] = MIPS32Processor.parseRegimm,
                              [0x40000000] = MIPS32Processor.parseCop0,
                              [0x44000000] = MIPS32Processor.parseCop1,
                              [0x48000000] = MIPS32Processor.parseCop2,
                              [0x4C000000] = MIPS32Processor.parseCop1X,
                              [0x70000000] = MIPS32Processor.parseSpecial2,
                              [0x7C000000] = MIPS32Processor.parseSpecial3 }
end

function MIPS32Processor:signExtend(address)
  if bit.band(address, 0x8000) ~= 0 then
    return bit.bor(0xFFFF0000, address)
  end
  
  return address
end

function MIPS32Processor:parseSpecial(instruction, data)
  instruction:setOpCode(bit.bor(0x00000000, bit.band(data, 0x3F))) -- SPECIAL | ... | OPCODE
  
  instruction:addOperand(OperandType.Register, DataType.UInt8):setValue(bit.rshift(bit.band(data, 0x03E00000), 0x15), self.registernames) -- rs
  instruction:addOperand(OperandType.Register, DataType.UInt8):setValue(bit.rshift(bit.band(data, 0x001F0000), 0x10), self.registernames) -- rt
  instruction:addOperand(OperandType.Register, DataType.UInt8):setValue(bit.rshift(bit.band(data, 0x0000F800), 0x0B), self.registernames) -- rd
end

function MIPS32Processor:parseRegimm(instruction, data)
  local offset = bit.lshift(self:signExtend(bit.band(data, 0x0000FFFF)), 2)  
  instruction:setOpCode(bit.bor(0x04000000, bit.band(data, 0x001F0000))) -- REGIMM | ... | OPCODE
  
  instruction:addOperand(OperandType.Register, DataType.UInt8):setValue(bit.rshift(bit.band(data, 0x03E00000), 0x15), self.registernames) -- rs
  instruction:addOperand(OperandType.Address, DataType.UInt32):setValue(instruction:address() + DataType.sizeOf(DataType.UInt32) + offset)
end

function MIPS32Processor:parseCop0(instruction, data)
  -- NOTE: COP0 Implemented yet
  instruction:setOpCode(0xFFFFFFFF)
end

function MIPS32Processor:parseCop1(instruction, data)
  -- NOTE: COP1 (FPU) Not Implemented yet
  instruction:setOpCode(0xFFFFFFFF)
end

function MIPS32Processor:parseCop2(instruction, data)
  -- NOTE: COP2 Not Implemented yet
  instruction:setOpCode(0xFFFFFFFF)
end

function MIPS32Processor:parseCop1X(instruction, data)
  -- NOTE: COP1X Not Implemented yet
  instruction:setOpCode(0xFFFFFFFF)
end

function MIPS32Processor:parseSpecial2(instruction, data)
  instruction:setOpCode(bit.bor(0x70000000, bit.band(data, 0x21)))  -- SPECIAL2 | ... | OPCODE
  
  instruction:addOperand(OperandType.Register, DataType.UInt8):setValue(bit.rshift(bit.band(data, 0x03E00000), 0x15), self.registernames) -- rs
  instruction:addOperand(OperandType.Register, DataType.UInt8):setValue(bit.rshift(bit.band(data, 0x001F0000), 0x10), self.registernames) -- rt
  instruction:addOperand(OperandType.Register, DataType.UInt8):setValue(bit.rshift(bit.band(data, 0x0000F800), 0x0B), self.registernames) -- rd
end

function MIPS32Processor:parseSpecial3(instruction, data)
  -- NOTE: Not Implemented yet
end

function MIPS32Processor:analyze(instruction, baseaddress)
  local data = instruction:next(DataType.UInt32)
  local constant = tonumber(ffi.cast("uint32_t", bit.band(data, 0xFC000000))) -- HACK: Force Unsigned Type
  
  if self.constantdispatcher[constant] ~= nil then
    self.constantdispatcher[constant](self, instruction, data)
    
    if self.instructionset[instruction:opCode()] == nil then
      return 0 -- Invalid Instruction
    end
  else
    instruction:setOpCode(constant)
    
    if self.instructionset[instruction:opCode()] == nil then
      return 0 -- Invalid Instruction
    end
    
    if (instruction:opCode() == self.opcodes.Branch_J) or (instruction:opCode() == self.opcodes.Branch_JAL) then
      instruction:addOperand(OperandType.Address, DataType.UInt32):setValue(baseaddress + bit.lshift(bit.band(data, 0x3FFFFFF), 2))              -- instr_index
    else
      instruction:addOperand(OperandType.Register, DataType.UInt8):setValue(bit.rshift(bit.band(data, 0x03E00000), 0x15), self.registernames)    -- rs
      instruction:addOperand(OperandType.Register, DataType.UInt8):setValue(bit.rshift(bit.band(data, 0x001F0000), 0x10), self.registernames)    -- rt
      
      if self.noregimmccall[instruction:opCode()] then
        local offset = bit.lshift(self:signExtend(bit.band(data, 0x0000FFFF)), 2)      
        instruction:addOperand(OperandType.Address, DataType.UInt32):setValue(instruction:address() + DataType.sizeOf(DataType.UInt32) + offset) -- address
      else
        instruction:addOperand(OperandType.Immediate, DataType.UInt32):setValue(bit.band(data, 0x0000FFFF))                                      -- immediate
      end
    end
  end
  
  local instrformat = self.instructionformats[instruction:opCode()]
  
  if instrformat ~= nil then
    instruction:setFormat(instrformat)
  end
  
  return DataType.sizeOf(DataType.UInt32) -- Fixed instruction size
end

function MIPS32Processor:emulate(listing, instruction)
  local instructionset = self.instructionset
  
  if bit.band(instructionset[instruction:opCode()].type, InstructionType.Stop) ~= 0 then
    return
  end
    
  if instruction:opCode() == self.opcodes.Branch_JAL then
    listing:push(instruction:operandAt(1):value(), ReferenceType.Call)
  elseif instruction:opCode() == self.opcodes.Branch_J then
    listing:push(instruction:operandAt(1):value(), ReferenceType.Jump)
  elseif (instructionset[instruction:opCode()].type == InstructionType.Jump) then
    listing:push(instruction:operandAt(instruction:operandsCount()):value(), ReferenceType.Jump)
  end
    
  listing:push(instruction:address() + DataType.sizeOf(DataType.UInt32), ReferenceType.Flow)
end

function MIPS32Processor:analyzeInstructions(listing, func)
  local i = 1
  
  while i <= func:instructionsCount() do
    local instruction = func:instructionAt(i)
    
    if instruction:opCode() == self.opcodes.Mem_LUI then
      self:simplifyLui(listing, func, instruction, i)
    elseif instruction:opCode() == self.opcodes.Log_SLL then
      self:checkNop(instruction)
    elseif instruction:opCode() == self.opcodes.Branch_JR then
      instruction:removeOperand(3)
      instruction:removeOperand(2)
    elseif instruction:opCode() == self.opcodes.Trap_BREAK then
      instruction:clearOperands()
    end
    
    i = i + 1
  end
end

function MIPS32Processor:simplifyLui(listing, func, instruction, i)
  if (i + 1) > func:instructionsCount() then
    return
  end
  
  local nextinstruction = func:instructionAt(i + 1)
  
  if nextinstruction:opCode() ~= self.opcodes.Math_ADDIU then
    return
  end
  
  local luiimmediate = bit.lshift(instruction:operandAt(3):value(), 16)
  local macroinstruction = listing:mergeInstructions(instruction, nextinstruction, "LI", InstructionCategory.LoadStore)
  
  macroinstruction:cloneOperand(nextinstruction:operandAt(1))
  macroinstruction:addOperand(OperandType.Address, DataType.UInt32):setValue(luiimmediate + nextinstruction:operandAt(3):value())
end

function MIPS32Processor:checkNop(instruction)
  for i = 1, instruction:operandsCount() do
    local operand = instruction:operandAt(i)
    
    if operand:value() ~= self.registers.Reg_ZERO then
      return
    end
  end
  
  instruction:setMnemonic("NOP")
  instruction:setCategory(InstructionCategory.NoOperation)
  instruction:setType(InstructionType.Nop)
  instruction:clearOperands()
end

return MIPS32Processor