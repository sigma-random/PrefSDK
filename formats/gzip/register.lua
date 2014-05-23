local FormatDefinition = require("sdk.format.formatdefinition")
local GZipFormat = require("formats.gzip.definition")

FormatDefinition.register(GZipFormat, "GZip Format", "Compression", "Karl", "1.1")