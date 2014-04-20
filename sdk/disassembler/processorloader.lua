local ffi = require("ffi")
local oop = require("sdk.lua.oop")

ffi.cdef
[[
  void ProcessorLoader_addSegment(FormatId formatid, const char* name, uint64_t segmenttype, uint64_t startoffset, uint64_t endoffset, uint64_t baseaddress);
  void ProcessorLoader_addEntryPoint(FormatId formatid, const char* name, uint64_t offset);  
]]

local C = ffi.C
local ProcessorLoader = oop.class()

function ProcessorLoader:__ctor(formatdefinition)
  self.formatdefinition = formatdefinition
  self.entrypoints = { }
  self.segments = { }
  
  C.Format_enableDisassembler(formatdefinition.id)
end

function ProcessorLoader:addEntryPoint(name, offset)
  C.ProcessorLoader_addEntryPoint(self.formatdefinition.id, name, offset)
end

function ProcessorLoader:addSegment(name, segmenttype, startoffset, endoffset, baseaddress)
  C.ProcessorLoader_addSegment(self.formatdefinition.id, name, segmenttype, startoffset, endoffset, baseaddress or startoffset)
end

return ProcessorLoader
