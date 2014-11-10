local InstructionType = require("processors.mips.instruction.type")
local InstructionDefinition = require("processors.mips.instruction.definition")
local OperandDefinition = require("processors.mips.operand.definition")

-- Missing Iinstructions: 
-- EXT
-- INS
-- MOVF (Check CC Parameter?)
-- SDBBP (Missing Operands, Debug Instruction)
-- SEB
-- SEH
-- SSNOP
-- BSHFL

-- NOTE: Implement Unsigned Immediate Operand?

local RSpecialInstructions = { } -- OpCode: 0x000000
RSpecialInstructions[0x000020] = InstructionDefinition("ADD", InstructionType.Add, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000021] = InstructionDefinition("ADDU", InstructionType.Add, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000024] = InstructionDefinition("AND", InstructionType.And, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x00000D] = InstructionDefinition("BREAK", InstructionType.Stop, { OperandDefinition.code })
RSpecialInstructions[0x00001A] = InstructionDefinition("DIV", InstructionType.Div, { OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x00001B] = InstructionDefinition("DIVU", InstructionType.Div, { OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000009] = InstructionDefinition("JALR", InstructionType.ConditionalCall, { OperandDefinition.rd, OperandDefinition.rs })
RSpecialInstructions[0x000008] = InstructionDefinition("JR", InstructionType.Jump, { OperandDefinition.rs })
RSpecialInstructions[0x000010] = InstructionDefinition("MFHI", InstructionType.Load, { OperandDefinition.rd })
RSpecialInstructions[0x000012] = InstructionDefinition("MFLO", InstructionType.Load, { OperandDefinition.rd })
-- RSpecialInstructions[0x000001] = InstructionDefinition("MOVF", InstructionType.Undefined, { OperandDefinition.rd, OperandDefinition.rs })
RSpecialInstructions[0x00000B] = InstructionDefinition("MOVN", InstructionType.Undefined, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
-- RSpecialInstructions[0x00000B] = InstructionDefinition("MOVT", InstructionType.Undefined, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x00000B] = InstructionDefinition("MOVN", InstructionType.Undefined, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x00000A] = InstructionDefinition("MOVT", InstructionType.Undefined, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000011] = InstructionDefinition("MTHI", InstructionType.Store, { OperandDefinition.rs })
RSpecialInstructions[0x000013] = InstructionDefinition("MTLO", InstructionType.Store, { OperandDefinition.rs })
RSpecialInstructions[0x000018] = InstructionDefinition("MULT", InstructionType.Mul, { OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000019] = InstructionDefinition("MULTU", InstructionType.Mul, { OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000027] = InstructionDefinition("NOR", InstructionType.Nor, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000025] = InstructionDefinition("OR", InstructionType.Or, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000000] = InstructionDefinition("SLL", InstructionType.Lsl, { OperandDefinition.rd, OperandDefinition.rt, OperandDefinition.shamt })
RSpecialInstructions[0x000004] = InstructionDefinition("SLLV", InstructionType.Lsl, { OperandDefinition.rd, OperandDefinition.rt, OperandDefinition.rs })
RSpecialInstructions[0x00002A] = InstructionDefinition("SLT", InstructionType.Compare, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x00002B] = InstructionDefinition("SLTU", InstructionType.Compare, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000003] = InstructionDefinition("SRA", InstructionType.Asr, { OperandDefinition.rd, OperandDefinition.rt, OperandDefinition.shamt })
RSpecialInstructions[0x000007] = InstructionDefinition("SRAV", InstructionType.Asr, { OperandDefinition.rd, OperandDefinition.rt, OperandDefinition.rs })
RSpecialInstructions[0x000002] = InstructionDefinition("SRL", InstructionType.Lsr, { OperandDefinition.rd, OperandDefinition.rt, OperandDefinition.shamt })
RSpecialInstructions[0x000006] = InstructionDefinition("SRLV", InstructionType.Lsr, { OperandDefinition.rd, OperandDefinition.rt, OperandDefinition.rs })
RSpecialInstructions[0x000022] = InstructionDefinition("SUB", InstructionType.Sub, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000023] = InstructionDefinition("SUBU", InstructionType.Sub, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x00000C] = InstructionDefinition("SYSCALL", InstructionType.SysCall, { OperandDefinition.code })
RSpecialInstructions[0x000026] = InstructionDefinition("XOR", InstructionType.Xor, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x00000F] = InstructionDefinition("SYNC", InstructionType.Undefined)
RSpecialInstructions[0x000034] = InstructionDefinition("TEQ", InstructionType.Trap, { OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000030] = InstructionDefinition("TGE", InstructionType.Trap, { OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000031] = InstructionDefinition("TGEU", InstructionType.Trap, { OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000032] = InstructionDefinition("TLT", InstructionType.Trap, { OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000033] = InstructionDefinition("TLTU", InstructionType.Trap, { OperandDefinition.rs, OperandDefinition.rt })
RSpecialInstructions[0x000036] = InstructionDefinition("TNE", InstructionType.Trap, { OperandDefinition.rs, OperandDefinition.rt })

local RSpecial2Instructions = { } -- OpCode: 0x00001C
RSpecial2Instructions[0x000021] = InstructionDefinition("CLO", InstructionType.Undefined, { OperandDefinition.rd, OperandDefinition.rs })
RSpecial2Instructions[0x000020] = InstructionDefinition("CLZ", InstructionType.Undefined, { OperandDefinition.rd, OperandDefinition.rs })
RSpecial2Instructions[0x000000] = InstructionDefinition("MADD", InstructionType.Undefined, { OperandDefinition.rs, OperandDefinition.rt })
RSpecial2Instructions[0x000001] = InstructionDefinition("MADDU", InstructionType.Add, { OperandDefinition.rs, OperandDefinition.rt })
RSpecial2Instructions[0x000004] = InstructionDefinition("MSUB", InstructionType.Sub, { OperandDefinition.rs, OperandDefinition.rt })
RSpecial2Instructions[0x000005] = InstructionDefinition("MSUBU", InstructionType.Sub, { OperandDefinition.rs, OperandDefinition.rt })
RSpecial2Instructions[0x000002] = InstructionDefinition("MUL", InstructionType.Mul, { OperandDefinition.rd, OperandDefinition.rs, OperandDefinition.rt })
RSpecial2Instructions[0x00003F] = InstructionDefinition("SDBBP", InstructionType.Undefined)

local RSpecial3Instructions = { } -- OpCode: 0x00001F
RSpecial3Instructions[0x00003B] = InstructionDefinition("RDHWR", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.rd })

return { [0x000000] = RSpecialInstructions, [0x00001C] = RSpecial2Instructions, [0x00001F] = RSpecial3Instructions }
