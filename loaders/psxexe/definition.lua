local oop = require("sdk.lua.oop")
local Address = require("sdk.math.address")
local ByteOrder = require("sdk.types.byteorder")
local SegmentType = require("sdk.disassembler.segmenttype")
local ProcessorLoader = require("sdk.disassembler.processor.processorloader")
local PsxExeFormat = require("formats.psxexe.definition")
local MIPS32Processor = require("processors.mips32")

local PsxExeLoader = oop.class(ProcessorLoader)

function PsxExeLoader:__ctor(databuffer)
  ProcessorLoader.__ctor(self, databuffer, PsxExeFormat(databuffer), MIPS32Processor(), ByteOrder.LittleEndian)
end

function PsxExeLoader:createSegments(formattree)
  local pc0field = formattree.ExeHeader.pc0
  local taddrfield = formattree.ExeHeader.t_addr
  local tsizefield = formattree.ExeHeader.t_size
  
  self:addSegment("TEXT", SegmentType.Code, 0x800, tsizefield:value(), taddrfield:value())
  self:addEntry("main", Address.rebase(pc0field:value(), taddrfield:value(), 0x800))
end

return PsxExeLoader