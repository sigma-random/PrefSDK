local FormatDefinition = require("sdk.format.formatdefinition")
local ZLibFormat = require("formats.zlib.definition")

FormatDefinition.register(ZLibFormat, "ZLib Format", "Compression", "Dax", "1.0")