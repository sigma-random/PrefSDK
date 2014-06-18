local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local Address = require("sdk.math.address")
local Stack = require("sdk.containers.stack")
local Segment = require("sdk.disassembler.blocks.segment")
local InstructionType = require("sdk.disassembler.instructions.instructiontype")
local OperandType = require("sdk.disassembler.instructions.operands.operandtype")
local ReferenceType = require("sdk.disassembler.blocks.referencetype")
local FunctionType = require("sdk.disassembler.blocks.functiontype")

ffi.cdef
[[
  void DisassemblerListing_addSegment(void* __this, void* segment);
  void DisassemblerListing_addReference(void* __this, uint64_t srcaddress, uint64_t destaddress, int referencetype);
  void DisassemblerListing_setSymbol(void* __this, uint64_t address, int datatype, const char* name);
  bool DisassemblerListing_hasSymbol(void* __this, uint64_t address);
  const char* DisassemblerListing_getSymbolName(void* __this, uint64_t address);
]]

local C = ffi.C
local DisassemblerListing = oop.class()

function DisassemblerListing:__ctor(cthis)
  self.cthis = cthis
  self.stack = Stack()
  self.currentaddress = 0
  self.currentinstruction = nil
  self.segments = { }
  self.instructions = { }
  
  self.sortsegments = function(seg1, seg2)
    return seg1.startaddress < seg2.startaddress
  end
  
  self.sortinstructions = function(instr1, instr2)
    return instr1.address < instr2.address
  end
end

function DisassemblerListing:addSegment(segmentname, segmenttype, startaddress, endaddress, baseoffset)
  local segment = Segment(segmentname, segmenttype, startaddress, endaddress, baseoffset)
  table.bininsert(self.segments, segment, self.sortsegments)
end

function DisassemblerListing:addEntry(name, address)
  self:addFunction(FunctionType.EntryPoint, address, name)
  self.stack:push(address)
end

function DisassemblerListing:addFunction(type, address, name)
  self:setSymbol(address, 0, name or string.format("sub_%X", address))
  local segment = self:segmentAt(address)
  segment:addFunction(type, address)
end

function DisassemblerListing:setSymbol(address, datatype, name)
  C.DisassemblerListing_setSymbol(self.cthis, address, datatype, name)
end

function DisassemblerListing:hasSymbol(address)
  return C.DisassemblerListing_hasSymbol(self.cthis, address)
end

function DisassemblerListing:symbolName(address)
  return ffi.string(C.DisassemblerListing_getSymbolName(self.cthis, address))
end

function DisassemblerListing:addInstruction(instruction)
  self.currentinstruction = instruction
  self.instructions[instruction.address] = instruction
end

function DisassemblerListing:segmentAt(address)
  for _, seg in pairs(self.segments) do    
    if (address >= seg.startaddress) and (address <= seg.endaddress) then
      return seg
    end
  end
  
  error(string.format("Segment not found at: %08X", address))
end

function DisassemblerListing:inSegment(address)
  local segment = self:segmentAt(address)
  
  if segment then
    return true
  end
  
  return false
end

function DisassemblerListing:segmentOffset(address)
  local segment = self:segmentAt(address)  
  
  if segment then
    return Address.rebase(address, segment.startaddress, segment.baseoffset)
  end
  
  return address
end

function DisassemblerListing:hasMoreInstructions()
  return (not self.stack:isEmpty())
end

function DisassemblerListing:pop()
  -- Pop until we find a not decoded instruction
  repeat
    self.currentaddress = self.stack:pop()
  until self.instructions[self.currentaddress] == nil
  
  return self.currentaddress
end

function DisassemblerListing:push(address, referencetype)
  if self.instructions[address] then -- Instruction already disassembled, ignore it
    return
  end
  
  if ReferenceType.isCall(referencetype) or ReferenceType.isJump(referencetype) then
    if ReferenceType.isCall(referencetype) and (not self:hasSymbol(address)) then
      self:addFunction(FunctionType.Function, address)
    end
    
    C.DisassemblerListing_addReference(self.cthis, self.currentaddress, address, referencetype)    
  end
  
  self.stack:push(address)
end

function DisassemblerListing:analyzeOperands(instruction)
  for __, op in ipairs(instruction.operands) do    
    if (op.type == OperandType.Address) and self:hasSymbol(op.value) then
      op.displayvalue = self:symbolName(op.value)
    end
  end
end

function DisassemblerListing:populateFunction(func, processor)
  local instruction = nil
  local currentaddress = func.startaddress
  
  repeat
    instruction = self.instructions[currentaddress]
    currentaddress = currentaddress + instruction.size
    func:addInstruction(instruction)
  until (instruction ~= nil) and (bit.band(instruction.type, InstructionType.Stop) ~= 0)
  
  func.instructions = processor:analyzeInstructions(func.instructions)
  
  for _, instr in ipairs(func.instructions) do
    self:analyzeOperands(instr)
  end
end

function DisassemblerListing:compile(loader)  
  for _, segment in pairs(self.segments) do
    for __, func in pairs(segment.functions) do      
      self:populateFunction(func, loader.processor)
      loader:elaborateFunction(func) -- HACK: Horrible hack in order to do post function processing
    end
    
    C.DisassemblerListing_addSegment(self.cthis, segment.cthis)
    segment:compile()
  end
end

return DisassemblerListing