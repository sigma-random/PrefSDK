local oop = require("sdk.lua.oop")

local ProcessorDefinition = oop.class()

function ProcessorDefinition:__ctor(name, mnemonics, features, outoperand)
  self.name = name
  self.mnemonics = mnemonics
  self.features = features
  self.outoperand = outoperand
end

function ProcessorDefinition:analyze(instruction)
  return 0 -- This Method Must Be Redefined!
end

function ProcessorDefinition:emulate(addressqueue, referencetable, instruction)
  return 1 -- This Method Must Be Redefined!
end

function ProcessorDefinition:output(loader, instructionprinter, instruction)
  -- This Method Must Be Redefined!
end

return ProcessorDefinition