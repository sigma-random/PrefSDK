local FormatDefinition = require("sdk.format.formatdefinition")
local PeFormat = require("formats.portableexecutable.definition")

FormatDefinition.register(PeFormat, "Portable Executable Format", "Windows", "Dax", "1.0")