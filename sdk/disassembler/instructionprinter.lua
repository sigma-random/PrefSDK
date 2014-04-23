local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")
local ReferenceType = require("sdk.disassembler.crossreference.referencetype")

ffi.cdef
[[
  void DisassemblerDrawer_drawVirtualAddress(void* __this, const char* segmentname, const char* address);
  void DisassemblerDrawer_drawHexDump(void* __this, uint64_t offset, int dumplength, int maxwidth);
  void DisassemblerDrawer_drawMnemonic(void* __this, int width, const char* mnemonic, int instructionfeatures);
  void DisassemblerDrawer_drawImmediate(void* __this, const char* s);
  void DisassemblerDrawer_drawAddress(void* __this, const char* s);
  void DisassemblerDrawer_drawString(void* __this, const char* s);
]]

local C = ffi.C
local InstructionPrinter = oop.class()

function InstructionPrinter:__ctor(drawer, loader, index)
  self.drawer = drawer
  self.loader = loader
  self.processor = loader.processor
  self.index = index
end

function InstructionPrinter:hexString(datatype, value, prefix, postfix)
  if DataType.bitWidth(datatype) == 8 then
    return string.format("%s%02X%s", prefix or "", value, postfix or "")
  elseif DataType.bitWidth(datatype) == 16 then
    return string.format("%s%04X%s", prefix or "", value, postfix or "")
  elseif DataType.bitWidth(datatype) == 32 then
    return string.format("%s%08X%s", prefix or "", value, postfix or "")
  elseif DataType.bitWidth(datatype) == 64 then
    return string.format("%s%16X%s", prefix or "", value, postfix or "")
  end
  
  return string.format("%X", prefix or "", value, postfix or "")
end

function InstructionPrinter:outVirtualAddress(segmentname, address)
  C.DisassemblerDrawer_drawVirtualAddress(self.drawer, segmentname, address)
end

function InstructionPrinter:outHexDump(address, size)
  C.DisassemblerDrawer_drawHexDump(self.drawer, address, size, self.loader.maxinstructionsize)
end

function InstructionPrinter:outMnemonic(width, instruction)
  local mnemonic = self.processor.mnemonics[instruction.type]
  local features = self.processor.features[instruction.type]
  
  if mnemonic then
    C.DisassemblerDrawer_drawMnemonic(self.drawer, width, mnemonic, features)
  else
    C.DisassemblerDrawer_drawMnemonic(self.drawer, width, string.format("db %X", instruction.type), features or 0)
  end
end

function InstructionPrinter:outImmediate(value, datatype, prefix, postfix)
  C.DisassemblerDrawer_drawImmediate(self.drawer, self:hexString(datatype, value, prefix, postfix))
end

function InstructionPrinter:outAddress(value, datatype, prefix, postfix)
  local referencetable = self.loader.referencetable
  local segmentname = self.loader:segmentName(value)
  
  if referencetable:isReference(value) then
    local reference = referencetable[value]
    
    if #segmentname > 0 then
      C.DisassemblerDrawer_drawAddress(self.drawer, string.format("%s.%s%s", segmentname, reference.prefix, self:hexString(datatype, tonumber(value), prefix, postfix)))
    else
      C.DisassemblerDrawer_drawAddress(self.drawer, string.format("%s%s", reference.prefix, self:hexString(datatype, tonumber(value), prefix, postfix)))
    end
  elseif #segmentname > 0 then
    C.DisassemblerDrawer_drawAddress(self.drawer, string.format("%s.%s", segmentname, self:hexString(datatype, tonumber(value), prefix, postfix)))
  else
    C.DisassemblerDrawer_drawAddress(self.drawer, string.format("%s", self:hexString(datatype, tonumber(value), prefix, postfix)))
  end
end

function InstructionPrinter:outRegister(registeridx)
  -- TODO: To Be Implemented
end

function InstructionPrinter:out(s)
  C.DisassemblerDrawer_drawString(self.drawer, s)
end

function InstructionPrinter:outnOperand(n, instruction)
  self.processor.outoperand(self, instruction["operand" .. tostring(n)])
end

return InstructionPrinter