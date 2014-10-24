local pref = require("pref")
local PsxExeFormat = require("formats.psxexe.definition")
local MIPS32Processor = require("processors.mips32.definition")
local PsyQ = require("loaders.psxexe.psyq")

local PsxExeLoader = pref.disassembler.createloader("Sony Playstation 1 PS-EXE", "Dax", "1.0", PsxExeFormat, MIPS32Processor)

function PsxExeLoader:baseAddress(formattree)
  return 0x80000000
end

function PsxExeLoader:map(formattree)  
  local taddrfield = formattree.ExeHeader.t_addr
  local tsizefield = formattree.ExeHeader.t_size
  local pc0field = formattree.ExeHeader.pc0
  
  self:createSegment("TEXT", pref.disassembler.segment.Code, taddrfield.value, tsizefield.value, 0x800)
  self:createEntryPoint("start", pc0field.value)
end

function PsxExeLoader:elaborate(listing, formattree)
  local f = listing.firstfunction
  local psyq = PsyQ(self, listing)
  
  while f do
    psyq:analyze(f)
    f = listing:nextFunction(f)
  end
end

return PsxExeLoader