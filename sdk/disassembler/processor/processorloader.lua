local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local uuid = require("sdk.math.uuid")
local DebugObject = require("sdk.debug.debugobject")
local FormatTree = require("sdk.format.formattree")
local Instruction = require("sdk.disassembler.instructions.instruction")
local ReferenceType = require("sdk.disassembler.blocks.referencetype")

ffi.cdef
[[
  typedef const char* LoaderId;
  
  void Loader_register(const char* name, const char* author, const char* version, LoaderId loaderid);
]]

local C = ffi.C
local ProcessorLoader = oop.class(DebugObject)

function ProcessorLoader.register(loadertype, name, author, version)
  local loaderid = uuid()
  Sdk.loaderlist[loaderid] = loadertype  -- Store Loader Definition's type
  C.Loader_register(name, author, version, loaderid) -- Notify PREF that a new loader has been created
end

function ProcessorLoader:__ctor(listing, databuffer, formattype, processortype, endian)
  DebugObject.__ctor(self, databuffer)
  
  self.listing = listing
  self.format = formattype(databuffer)
  self.processor = processortype(databuffer)
  self.endian = endian
  self.validated = self:validate()
  
  if self.listing and self.validated then
    self.format.tree = FormatTree(nil, databuffer)
    self.format:parse(self.format.tree)
    self:createSegments(self.listing, self.format.tree)
    
    if self.listing:segmentCount() > 0 then
      self:createEntryPoints(self.listing, self.format.tree)
    end
  end
end

function ProcessorLoader:validate()
  local res, msg = pcall(self.format.validate, self.format)
  
  if res == false then
    Sdk.errorDialog(msg)
  end
  
  return res
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
  local address = listing:pop()
  
  local instruction = listing:createInstruction(address, self.databuffer, self.endian)
  local size = processor:analyze(instruction, self:baseAddress())
  
  if size <= 0 then
    listing:push(address + instruction:size(), ReferenceType.Flow) -- Got an Invalid Instruction: Try To Continue analysis
  else
    local instructiondef = processor.instructionset[instruction:opCode()]
  
    instruction:setMnemonic(instructiondef.mnemonic)
    instruction:setCategory(instructiondef.category)
    instruction:setType(instructiondef.type)
  
    processor:emulate(listing, instruction)
  end
end

function ProcessorLoader:disassemble()
  local processor = self.processor
  local listing = self.listing
  
  while listing:hasMoreInstructions() do
    self:disassembleInstruction(listing)
  end
  
  for i = 1, listing:functionsCount() do
    local func = listing:functionAt(i)
    
    if func then
      processor:compileFunction(listing, func)
      self:elaborateFunction(func)
    end
  end
end

return ProcessorLoader
