local FormatDefinition = require("sdk.format.formatdefinition")
local INesFormat = require("formats.ines.definition")

FormatDefinition.register(INesFormat, "iNES Format", "Nintendo", "Dax", "1.0")