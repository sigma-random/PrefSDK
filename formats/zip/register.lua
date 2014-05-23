local FormatDefinition = require("sdk.format.formatdefinition")
local ZipFormat = require("formats.zip.definition")

FormatDefinition.register(ZipFormat, "Zip Format", "Compression", "Dax", "1.0")