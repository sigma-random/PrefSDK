local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local ReferenceType = require("sdk.disassembler.crossreference.referencetype")

ffi.cdef
[[
  void DisassemblerDrawer_drawAddress(void* __this, const char* segmentname, const char* address);
  void DisassemblerDrawer_drawHexDump(void* __this, uint64_t offset, int dumplength, int maxwidth);
  void DisassemblerDrawer_drawMnemonic(void* __this, int width, const char* mnemonic);
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

function InstructionPrinter:outAddress(segmentname, address)
  C.DisassemblerDrawer_drawAddress(self.drawer, segmentname, address)
end

function InstructionPrinter:outHexDump(address, size)
  C.DisassemblerDrawer_drawHexDump(self.drawer, address, size, self.loader.maxinstructionsize)
end

function InstructionPrinter:outMnemonic(width, instruction)
  local mnemonic = self.processor.mnemonics[instruction.type]
  
  if mnemonic then
    C.DisassemblerDrawer_drawMnemonic(self.drawer, width, mnemonic)
  else
    C.DisassemblerDrawer_drawMnemonic(self.drawer, width, string.format("db %X", instruction.type))
  end
end

function InstructionPrinter:outValue(value, datatype, isaddress)
  if isaddress and (isaddress == true) then
    local referencetable = self.loader.referencetable
    
    if referencetable:isReference(value) then
      local reference = referencetable[value]
      
      if ReferenceType.isCodeReference(reference.type) then
        self:out(string.format("%s%08X", reference.prefix, tonumber(value)))
      end
    end
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