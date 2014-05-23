local FormatDefinition = require("sdk.format.formatdefinition")
local LZmaFormat = require("formats.lzma.definition")

FormatDefinition.register(LZmaFormat, "LZMA Format", "Compression", "Dax", "1.0")