local oop = require("sdk.lua.oop")
local uuid = require("sdk.math.uuid")

local ProcessorDefinition = oop.class()

function ProcessorDefinition:__ctor()
end

function ProcessorDefinition.register(name, mnemonics, features, outoperand)  
  local processorid = uuid()
  local processortype = oop.class(ProcessorDefinition)
  
  processortype.id = processorid
  processortype.mnemonics = mnemonics
  processortype.features = features
  processortype.outoperand = outoperand
  
  return processortype
end

function ProcessorDefinition:outmnemonic(width, outputbuffer, instruction)
  local line = " "
  local mnemonic = self.mnemonics[instruction.type]
  
  for i = 1, width do
    line = line .. " "
  end
  
  if mnemonic then
    line = line .. mnemonic
  else
    line = line .. string.format("db %X", instruction.type)
  end
  
  outputbuffer:out(line .. " ");
end

function ProcessorDefinition:outnoperand(n, outputbuffer, instruction)
  self.outoperand(outputbuffer, instruction[string.format("operand%d", n)])
end

function ProcessorDefinition:analyze(instruction)
  return 0 -- This Method Must Be Redefined!
end

function ProcessorDefinition:emulate(addressqueue, referencetable, instruction)
  return 1 -- This Method Must Be Redefined!
end

function ProcessorDefinition:output(outputbuffer, instruction)
  -- This Method Must Be Redefined!
end

return ProcessorDefinition