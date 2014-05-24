local ProcessorLoader = require("sdk.disassembler.processor.processorloader")
local PsxExeLoader = require("loaders.psxexe.definition")

ProcessorLoader.register(PsxExeLoader, "Sony Playstation 1 PS-EXE", "Dax", "1.0")