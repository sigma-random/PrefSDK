local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local Instruction = require("sdk.disassembler.instructions.instruction")
local InstructionCategory = require("sdk.disassembler.instructions.instructioncategory")
local InstructionType = require("sdk.disassembler.instructions.instructiontype")
local Function = require("sdk.disassembler.blocks.function")

ffi.cdef
[[
  void DisassemblerListing_addSegment(void* __this, const char *name, int segmenttype, uint64_t startaddress, uint64_t size, uint64_t baseoffset);
  void DisassemblerListing_addEntryPoint(void* __this, const char* name, uint64_t address);
  void *DisassemblerListing_getFunction(void* __this, int idx);
  void* DisassemblerListing_addInstruction(void* __this, uint64_t address);
  void DisassemblerListing_addReference(void* __this, uint64_t srcaddress, uint64_t destaddress, int referencetype);
  void DisassemblerListing_setSymbol(void* __this, uint64_t address, int datatype, const char* name);
  bool DisassemblerListing_hasSymbol(void* __this, uint64_t address);
  bool DisassemblerListing_hasMoreInstructions(void* __this);
  int DisassemblerListing_getSegmentCount(void* __this);
  int DisassemblerListing_getFunctionCount(void* __this);
  uint64_t DisassemblerListing_pop(void* __this);
  void DisassemblerListing_push(void* __this, uint64_t address, int referencetype);
  const char* DisassemblerListing_getSymbolName(void* __this, uint64_t address);
  void* DisassemblerListing_mergeInstructions(void* __this, void* instruction1, void* instruction2, const char* mnemonic, int instrcategory, int instrtype);
]]

local C = ffi.C
local DisassemblerListing = oop.class()

function DisassemblerListing:__ctor(cthis)
  self.cthis = cthis
end

function DisassemblerListing:addSegment(segmentname, segmenttype, startaddress, size, baseoffset)
  C.DisassemblerListing_addSegment(self.cthis, segmentname, segmenttype, startaddress, size, baseoffset or startaddress)
end

function DisassemblerListing:addEntryPoint(name, address)
  C.DisassemblerListing_addEntryPoint(self.cthis, name, address)
end

function DisassemblerListing:addInstruction(address, databuffer, endian)
  return Instruction(C.DisassemblerListing_addInstruction(self.cthis, address), databuffer, endian)
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

function DisassemblerListing:segmentCount()
  return tonumber(C.DisassemblerListing_getSegmentCount(self.cthis))
end

function DisassemblerListing:functionsCount()
  return tonumber(C.DisassemblerListing_getFunctionCount(self.cthis))
end

function DisassemblerListing:hasMoreInstructions()
  return C.DisassemblerListing_hasMoreInstructions(self.cthis)
end

function DisassemblerListing:functionAt(idx)
  return Function(C.DisassemblerListing_getFunction(self.cthis, idx))
end

function DisassemblerListing:mergeInstructions(instruction1, instruction2, mnemonic, instrcategory, instrtype)
  return Instruction(C.DisassemblerListing_mergeInstructions(self.cthis, instruction1.cthis, instruction2.cthis, mnemonic, instrcategory or InstructionCategory.Undefined, instrtype or InstructionType.Undefined))
end

function DisassemblerListing:pop()
  return C.DisassemblerListing_pop(self.cthis)
end

function DisassemblerListing:push(address, referencetype)
  C.DisassemblerListing_push(self.cthis, address, referencetype)
end

return DisassemblerListing