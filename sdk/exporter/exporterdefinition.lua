local ffi = require("ffi")
local uuid = require("sdk.math.uuid")
local oop = require("sdk.lua.oop")

ffi.cdef
[[
  typedef const char* ExporterId;  
  void Exporter_register(const char* name, const char* description, const char* author, const char* version, ExporterId exporterid);
]]

local ExporterDefinition = oop.class()

function ExporterDefinition:__ctor()
  -- Does Nothing
end

function ExporterDefinition.register(name, description, author, version)
  local exporterid = uuid()
  local exportertype = oop.class(ExporterDefinition)
  exportertype.id = exporterid
  
  Sdk.exporterlist[exporterid] = exportertype
  ffi.C.Exporter_register(name, description, author, version, exporterid)
  return exportertype
end

function ExporterDefinition:exportData(databufferin, databufferout, startoffset, endoffset)
  -- This function must be reimplemented
end

return ExporterDefinition