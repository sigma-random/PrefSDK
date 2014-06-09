local oop = require("sdk.lua.oop")

local ProcessorDefinition = oop.class()

function ProcessorDefinition:__ctor(name, instructionset, opcodes, registers, regnames)
  self.name = name
  self.instructionset = instructionset
  self.opcodes = opcodes
  self.registers = registers
  self.registernames = regnames
  self.instructionformat = { }
end

function ProcessorDefinition:overrideInstructionFormat(opcode, instructionformatfunc)
  self.instructionformat[opcode] = instructionformatfunc
end

function ProcessorDefinition:analyze(instruction)
  return 0 -- This Method Must Be Redefined!
end

function ProcessorDefinition:emulate(referencetable, instruction)
  -- This Method Must Be Redefined!
end

function ProcessorDefinition:analyzeInstructions(instructions)
  return instructions -- This Method Must Be Redefined!
end

return ProcessorDefinition