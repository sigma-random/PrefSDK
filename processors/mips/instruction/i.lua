local InstructionType = require("processors.mips.instruction.type")
local InstructionDefinition = require("processors.mips.instruction.definition")
local OperandDefinition = require("processors.mips.operand.definition")

-- Missing Instructions:
-- LDC1
-- LWC1
-- ANDI (Implement: "Zero Extend Immediate")
-- PREF (Check HINT Parameter?)
-- SYNCI
-- TEQI
-- TGEI
-- TGEIU
-- TLTI
-- TLTIU
-- TNEI

local IInstructions = { } 

IInstructions[0x000008] = InstructionDefinition("ADDI", InstructionType.Add, { OperandDefinition.rt, OperandDefinition.rs, OperandDefinition.imm16 })
IInstructions[0x000009] = InstructionDefinition("ADDIU", InstructionType.Add, { OperandDefinition.rt, OperandDefinition.rs, OperandDefinition.imm16 })
IInstructions[0x00000C] = InstructionDefinition("ANDI", InstructionType.Add, { OperandDefinition.rt, OperandDefinition.rs, OperandDefinition.imm16 })
IInstructions[0x000004] = InstructionDefinition("BEQ", InstructionType.ConditionalJump, { OperandDefinition.rs, OperandDefinition.rt, OperandDefinition.offset })
IInstructions[0x000001] = InstructionDefinition("BGEZ", InstructionType.ConditionalJump, { OperandDefinition.rs, OperandDefinition.offset })
IInstructions[0x000007] = InstructionDefinition("BGTZ", InstructionType.ConditionalJump, { OperandDefinition.rs, OperandDefinition.offset })
IInstructions[0x000006] = InstructionDefinition("BLEZ", InstructionType.ConditionalJump, { OperandDefinition.rs, OperandDefinition.offset })
IInstructions[0x000005] = InstructionDefinition("BNE", InstructionType.ConditionalJump, { OperandDefinition.rs, OperandDefinition.rt, OperandDefinition.offset })
IInstructions[0x00002F] = InstructionDefinition("CACHE", InstructionType.Undefined, { OperandDefinition.op, OperandDefinition.memory })
IInstructions[0x000020] = InstructionDefinition("LB", InstructionType.Load, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x000024] = InstructionDefinition("LBU", InstructionType.Load, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x000036] = InstructionDefinition("LDC2", InstructionType.Load, { OperandDefinition.cop2datart, OperandDefinition.memory })
IInstructions[0x000021] = InstructionDefinition("LH", InstructionType.Load, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x000025] = InstructionDefinition("LHU", InstructionType.Load, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x000030] = InstructionDefinition("LL", InstructionType.Load, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x00000F] = InstructionDefinition("LUI", InstructionType.Load, { OperandDefinition.rt, OperandDefinition.imm16 })
IInstructions[0x000023] = InstructionDefinition("LW", InstructionType.Load, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x000032] = InstructionDefinition("LWC2", InstructionType.Load, { OperandDefinition.cop2datart, OperandDefinition.memory })
IInstructions[0x000031] = InstructionDefinition("LWCL", InstructionType.Load, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x000022] = InstructionDefinition("LWL", InstructionType.Load, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x000026] = InstructionDefinition("LWR", InstructionType.Load, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x00000D] = InstructionDefinition("ORI", InstructionType.Or, { OperandDefinition.rt, OperandDefinition.rs, OperandDefinition.imm16 })
IInstructions[0x000033] = InstructionDefinition("PREF", InstructionType.Undefined, { OperandDefinition.memory})
IInstructions[0x000028] = InstructionDefinition("SB", InstructionType.Store, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x000038] = InstructionDefinition("SC", InstructionType.Store, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x00003D] = InstructionDefinition("SDC1", InstructionType.Store, { OperandDefinition.ft, OperandDefinition.memory })
IInstructions[0x00003E] = InstructionDefinition("SDC2", InstructionType.Store, { OperandDefinition.cop2datart, OperandDefinition.memory })
IInstructions[0x00000A] = InstructionDefinition("SLTI", InstructionType.Compare, { OperandDefinition.rt, OperandDefinition.rs, OperandDefinition.imm16 })
IInstructions[0x00000B] = InstructionDefinition("SLTIU", InstructionType.Compare, { OperandDefinition.rt, OperandDefinition.rs, OperandDefinition.imm16 })
IInstructions[0x000029] = InstructionDefinition("SH", InstructionType.Store, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x00002B] = InstructionDefinition("SW", InstructionType.Store, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x00003A] = InstructionDefinition("SWC2", InstructionType.Store, { OperandDefinition.cop2datart, OperandDefinition.memory })
IInstructions[0x00002A] = InstructionDefinition("SWL", InstructionType.Store, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x00002E] = InstructionDefinition("SWR", InstructionType.Store, { OperandDefinition.rt, OperandDefinition.memory })
IInstructions[0x00000E] = InstructionDefinition("XORI", InstructionType.Xor, { OperandDefinition.rt, OperandDefinition.rs, OperandDefinition.imm16 })

return IInstructions