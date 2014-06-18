local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local Block = require("sdk.disassembler.blocks.block")
local Function = require("sdk.disassembler.blocks.function")

ffi.cdef
[[
  void* Segment_create(const char *name, int segmenttype, uint64_t startaddress, uint64_t endaddress, uint64_t baseoffset);
  void Segment_addFunction(void* __this, void* f);
]]

local C = ffi.C
local Segment = oop.class(Block)

function Segment:__ctor(name, type, startaddress, endaddress, baseoffset)
  Block.__ctor(self, startaddress, endaddress)
  
  self.name = name
  self.type = type
  self.baseoffset = baseoffset or startaddress
  self.functions = { }
  self.cthis = C.Segment_create(name, type, startaddress, endaddress, self.baseoffset)
    
  self.sortbyaddress = function(f1, f2)
    return f1.startaddress < f2.startaddress
  end
end

function Segment:functionAt(address)  
  for _, func in pairs(self.functions) do    
    if (address >= func.startaddress) and (address <= func.endaddress) then
      return func
    end
  end
  
  error(string.format("Function not found at: %X", address))
end

function Segment:addFunction(type, startaddress)
  local f = Function(type, startaddress)
  table.bininsert(self.functions, f, self.sortbyaddress)  
  return f
end

function Segment:compile()
  for _, func in pairs(self.functions) do
    C.Segment_addFunction(self.cthis, func.cthis)
    func:compile()
  end
end

return Segment