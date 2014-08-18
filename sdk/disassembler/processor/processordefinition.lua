local oop = require("sdk.lua.oop")
local DebugObject = require("sdk.debug.debugobject")

local ProcessorDefinition = oop.class(DebugObject)

function ProcessorDefinition:__ctor(name, instructionset, opcodes, registers, regnames, databuffer)
  DebugObject.__ctor(databuffer)
  
  self.name = name
  self.instructionset = instructionset
  self.opcodes = opcodes
  self.registers = registers
  self.registernames = regnames
end

function ProcessorDefinition:analyze(instruction, baseaddress)
  return 0 -- This Method Must Be Redefined!
end

function ProcessorDefinition:emulate(referencetable, instruction)
  -- This Method Must Be Redefined!
end

function ProcessorDefinition:analyzeInstructions(instructions)
  return instructions -- This Method Must Be Redefined!
end

return ProcessorDefinition