local oop = require("sdk.lua.oop")
local ExporterDefinition = require("sdk.exporter.exporterdefinition")

local BinaryExporter = ExporterDefinition.register("Binary Exporter", "Exports Raw Bytes to File", "Dax", "1.0")

function BinaryExporter:__ctor()
  ExporterDefinition.__ctor(self)
end

function BinaryExporter:exportData(databufferin, databufferout, startoffset, endoffset)
  databufferin:copyTo(databufferout, startoffset, endoffset)
end