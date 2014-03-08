local ExportDefinition = require("sdk.exporter.exportdefinition")

local BinaryExporter = ExportDefinition:new("Binary Exporter", "Exports Raw Bytes to File", "Dax", "1.0")

function ExportDefinition:exportData(inbuffer, outbuffer, startoffset, endoffset)
  inbuffer:copyTo(outbuffer, startoffset, endoffset)
end