local ffi = require("ffi")
local oop = require("oop") 
local CapstoneLib = require("sdk.modules.capstone.ffi.library")
local CapstoneInstruction = require("sdk.modules.capstone.instruction")

local CapstoneContext = oop.class()

function CapstoneContext:__ctor()
  self.lib = CapstoneLib.load()
  
  self.__pool = { address = nil,
                  psize = nil,
                  pcode = nil }
  
  self.buffersize = 32 -- Set Max Chunk Size to 32 bytes
  self.handle = ffi.new("csh[1]") -- csh*
end

function CapstoneContext:support(query)
  return self.lib.cs_support(query)
end

function CapstoneContext:open(arch, mode)
  return self.lib.cs_open(arch, mode, self.handle)
end

function CapstoneContext:close()
  self.lib.cs_close(self.handle)  
  self.handle = nil
end

function CapstoneContext:option(opt, flag)
  self.lib.cs_option(self.handle[0], opt, flag)
end

function CapstoneContext:malloc()
  return self.lib.cs_malloc(self.handle[0])
end

function CapstoneContext:free(insn, count)
  return self.lib.cs_free(insn, (count or 1))
end

function CapstoneContext:instructionGroup(instruction, group)
  return self.lib.cs_insn_group(self.handle[0], instruction.__csinsn, group)
end

function CapstoneContext:registerName(regid)
  return ffi.string(self.lib.cs_reg_name(self.handle[0], regid))
end

function CapstoneContext:decode(address, memorybuffer)  
  local buffer = memorybuffer:readBuffer(address, self.buffersize)
  
  if self.__pool.paddress == nil then
    self.__pool.paddress = ffi.new("uint64_t[1]") -- uint64_t*
  end
  
  if self.__pool.psize == nil then
    self.__pool.psize = ffi.new("uint64_t[1]") -- uint64_t*
  end
  
  if self.__pool.pcode == nil then
    self.__pool.pcode = ffi.new("uint8_t*[1]") -- uint8_t**
  end
  
  local csinsn = self:malloc()
  
  self.__pool.paddress[0] = address
  self.__pool.psize[0] = self.buffersize
  self.__pool.pcode[0] = ffi.cast("uint8_t*", buffer.pointer)
  
  if self.lib.cs_disasm_iter(self.handle[0], ffi.cast("const uint8_t**", self.__pool.pcode), self.__pool.psize, self.__pool.paddress, csinsn) then
    return CapstoneInstruction(self, csinsn)
  end

  return nil
end

return CapstoneContext
