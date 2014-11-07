local InstructionType = require("processors.mips.instruction.type")
local InstructionDefinition = require("processors.mips.instruction.definition")
local OperandDefinition = require("processors.mips.operand.definition")

local JInstructions = { }

JInstructions[0x000002] = InstructionDefinition("J", InstructionType.Jump, { OperandDefinition.target })
JInstructions[0x000003] = InstructionDefinition("JAL", InstructionType.Call, { OperandDefinition.target })

return JInstructions
