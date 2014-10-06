local pref = require("pref")

local BinaryExporter = pref.exporter.create("Binary Exporter", "Exports Raw Bytes to File", "Dax", "1.0")

function BinaryExporter:dump(bufferin, bufferout, startoffset, endoffset)
  bufferin:copyTo(bufferout, startoffset, endoffset)
end

return BinaryExporter