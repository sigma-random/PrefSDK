local FormatDefinition = require("sdk.format.formatdefinition")
local PdfFormat = require("formats.pdf.definition")

FormatDefinition.register(PdfFormat, "Portable Document Format", "Documents", "Dax", "1.1b")