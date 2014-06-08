local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local uuid = require("sdk.math.uuid")
local FormatTree = require("sdk.format.formattree")
local Instruction = require("sdk.disassembler.instructions.instruction")
local ReferenceType = require("sdk.disassembler.blocks.referencetype")

ffi.cdef
[[
  typedef const char* LoaderId;
  
  void Loader_register(const char* name, const char* author, const char* version, LoaderId loaderid);
]]

local C = ffi.C
local ProcessorLoader = oop.class()

function ProcessorLoader.register(loadertype, name, author, version)
  local loaderid = uuid()
  Sdk.loaderlist[loaderid] = loadertype  -- Store Loader Definition's type
  C.Loader_register(name, author, version, loaderid) -- Notify PREF that a new loader has been created
end

function ProcessorLoader:__ctor(listing, databuffer, formattype, processortype, endian)
  self.listing = listing
  self.databuffer = databuffer
  self.format = formattype(databuffer)
  self.processor = processortype()
  self.endian = endian
  self.validated = self:validate()
  
  if self.listing and self.validated then
    self.format.tree = FormatTree(nil, databuffer)
    self.format:parse(self.format.tree)
    self:createSegments(self.listing, self.format.tree)
    
    if #self.listing.segments > 0 then
      self:createEntryPoints(self.listing, self.format.tree)
    end
  end
end

function ProcessorLoader:validate()
  return pcall(self.format.validate, self.format)
end

function ProcessorLoader:createSegments(listing, formattree)
  -- This method must be reimplemented
end

function ProcessorLoader:createEntryPoints(listing, formattree)
  -- This method must be reimplemented
end

function ProcessorLoader:elaborateFunction(func)
  -- This method must be reimplemented
end

function ProcessorLoader:baseAddress()
  return 0
end

function ProcessorLoader:disassembleInstruction(listing)
  local processor = self.processor
  local address = listing.currentaddress
  
  local instruction = Instruction(self.databuffer, self.endian, processor, address, listing:segmentOffset(address))
  local size = processor:analyze(instruction)
  
  if size <= 0 then
    listing:push(address + instruction.size, ReferenceType.Flow) -- Got an Invalid Instruction: Try To Continue analysis
    
    instruction.mnemonic = "???" -- No Mnemonic
    instruction.operands = { }   -- No Operands
  else
    local instructiondef = processor.instructionset[instruction.opcode]
  
    instruction.mnemonic = instructiondef.mnemonic
    instruction.category = instructiondef.category
    instruction.type = instructiondef.type
  
    processor:emulate(listing, instruction)
  end
  
  listing:addInstruction(instruction)
end

function ProcessorLoader:disassemble()
  local listing = self.listing
  
  while listing:hasMoreInstructions() do
    local segment = listing:segmentAt(listing:pop())
        
    if segment then
      self:disassembleInstruction(listing)
    end
  end
  
  listing:compile(self)
end

return ProcessorLoader
