local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")
local SegmentType = require("sdk.disassembler.segmenttype")
local ReferenceType = require("sdk.disassembler.crossreference.referencetype")

ffi.cdef
[[
  void DisassemblerDrawer_drawVirtualAddress(void* __this, const char* segmentname, const char* address);
  void DisassemblerDrawer_drawHexDump(void* __this, uint64_t offset, int dumplength, int maxwidth);
  void DisassemblerDrawer_drawMnemonic(void* __this, int width, const char* mnemonic, int instructionfeatures);
  void DisassemblerDrawer_drawImmediate(void* __this, const char* s);
  void DisassemblerDrawer_drawAddress(void* __this, const char* s);
  void DisassemblerDrawer_drawRegister(void* __this, const char* s);
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

function InstructionPrinter:hexString(value, datatype)
  if DataType.bitWidth(datatype) == 8 then
    return string.format("%02X", value)
  elseif DataType.bitWidth(datatype) == 16 then
    return string.format("%04X", value)
  elseif DataType.bitWidth(datatype) == 32 then
    return string.format("%08X", value)
  elseif DataType.bitWidth(datatype) == 64 then
    return string.format("%16X", value)
  end
  
  return string.format("%X", value)
end

function InstructionPrinter:outVirtualAddress(formatstring, address)
  local va = string.format(formatstring, tonumber(address))
  local segmentname = self.loader:segmentName(address)
  
  C.DisassemblerDrawer_drawVirtualAddress(self.drawer, segmentname, va)
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

function InstructionPrinter:outImmediate(formatstring, operand)
  local hexval = self:hexString(tonumber(operand.value), operand.datatype)
  C.DisassemblerDrawer_drawImmediate(self.drawer, string.format(formatstring, hexval))
end

function InstructionPrinter:outAddress(formatstring, operand)
  local referencetable = self.loader.referencetable
  local segment = self.loader:segment(operand.address)
  local addrstring = (segment and segment.name or "???") -- Start with segment's name (if any)
  local addrvalue = string.format(formatstring, self:hexString(tonumber(operand.address), operand.datatype))
  
  if referencetable:isReference(operand.address) then
    local reference = referencetable[operand.address]
    
    if segment and (segment.type == SegmentType.Code) then
      addrstring = addrstring .. string.format(".%s%s", reference.prefix, addrvalue)
    else
      addrstring = addrstring .. string.format("[%s%s]", reference.prefix, addrvalue)      
    end
  elseif segment and (segment.type == SegmentType.Code) then
    addrstring = addrstring .. string.format(".%s", addrvalue)
  else
    addrstring = addrstring .. string.format("[%s]", addrvalue)
  end
  
  C.DisassemblerDrawer_drawAddress(self.drawer, addrstring)
end

function InstructionPrinter:outRegister(registeridx)
  local regidx = ((type(registeridx) == "cdata") and tonumber(registeridx) or registeridx)
  local regname = self.processor.registers[regidx]
  
  if regname == nil then
    error("Invalid Register Index")
  end
  
  C.DisassemblerDrawer_drawRegister(self.drawer, regname)
end

function InstructionPrinter:out(s)
  C.DisassemblerDrawer_drawString(self.drawer, s)
end

function InstructionPrinter:outnOperand(n, instruction)
  self.processor.outoperand(self, instruction["operand" .. tostring(n)])
end

return InstructionPrinter