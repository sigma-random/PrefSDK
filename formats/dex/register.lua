local FormatDefinition = require("sdk.format.formatdefinition")
local DexFormat = require("formats.dex.definition")

FormatDefinition.register(DexFormat, "Dalvik Executable Format", "Android", "Dax", "1.0")