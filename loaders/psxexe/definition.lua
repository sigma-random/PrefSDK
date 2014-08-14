local oop = require("sdk.lua.oop")
local ByteOrder = require("sdk.types.byteorder")
local SegmentType = require("sdk.disassembler.blocks.segmenttype")
local ProcessorLoader = require("sdk.disassembler.processor.processorloader")
local PsxExeFormat = require("formats.psxexe.definition")
local MIPS32Processor = require("processors.mips32")

local PsxExeLoader = oop.class(ProcessorLoader)

function PsxExeLoader:__ctor(listing, databuffer)
  ProcessorLoader.__ctor(self, listing, databuffer, PsxExeFormat, MIPS32Processor, ByteOrder.LittleEndian)
end

function PsxExeLoader:createSegments(listing, formattree)
  local taddrfield = formattree.ExeHeader.t_addr
  local tsizefield = formattree.ExeHeader.t_size
  
  listing:addSegment("TEXT", SegmentType.Code, taddrfield:value() - self:baseAddress(), (taddrfield:value() + tsizefield:value()) - self:baseAddress(), 0x800)
end

function PsxExeLoader:createEntryPoints(listing, formattree)
  local pc0field = formattree.ExeHeader.pc0
  listing:addEntryPoint("main", pc0field:value() - self:baseAddress())
end

function PsxExeLoader:baseAddress()
  return 0x80000000
end

function PsxExeLoader:elaborateFunction(func)
  
end

return PsxExeLoader