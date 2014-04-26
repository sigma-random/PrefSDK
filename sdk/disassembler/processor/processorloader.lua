local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local AddressQueue = require("sdk.disassembler.addressqueue")
local Instruction = require("sdk.disassembler.instruction")
local ReferenceTable = require("sdk.disassembler.crossreference.referencetable")

local C = ffi.C
local ProcessorLoader = oop.class()

function ProcessorLoader:__ctor(formatdefinition, processor)
  self.formatdefinition = formatdefinition
  self.processor = processor
  self.entrypoints = { }
  self.segments = { }
  self.instructions = { }
  self.referencetable = ReferenceTable()
  
  C.Format_enableDisassembler(formatdefinition.id)
end

function ProcessorLoader:addEntry(entryname, entryaddress)
  local entry = { name = entryname, address = entryaddress }
  table.insert(self.entrypoints, entry)
end

function ProcessorLoader:addSegment(segmentname, segmenttype, segmentstartaddress, segmentendaddress, segmentbaseaddress)
  local segment = { name = segmentname, type = segmenttype, 
                    startaddress = segmentstartaddress, endaddress = segmentendaddress,
                    baseaddress = segmentbaseaddress or segmentstartaddress }
  
  table.insert(self.segments, segment)
end

function ProcessorLoader:segment(address)
  for i = 1, #self.segments do
    local segment = self.segments[i]
    
    if (address >= segment.startaddress) and (address < segment.endaddress) then
      return segment
    end
  end
  
  return nil
end

function ProcessorLoader:inSegment(address)
  for i = 1, #self.segments do
    local segment = self.segments[i]
    
    if (address >= segment.startaddress) and (address < segment.endaddress) then
      return true
    end
  end
  
  return false
end

function ProcessorLoader:segmentName(address)
  for i = 1, #self.segments do
    local segment = self.segments[i]
    
    if (address >= segment.startaddress) and (address < segment.endaddress) then
      return segment.name
    end
  end
  
  return "???"
end

function ProcessorLoader:disassemble()
  local processor = self.processor
  local instructions = self.instructions
  local referencetable = self.referencetable
  local databuffer = self.formatdefinition.databuffer
  local decaddr = { }
  local maxinstructionsize = 0
  
  local insbyaddress = function(instr1, instr2)
    return instr1.address < instr2.address
  end
    
  for i = 1, #self.entrypoints do
    local addressqueue = AddressQueue()
    addressqueue:pushFront(self.entrypoints[i].address)
    
    while not addressqueue:isEmpty() do
      local address = addressqueue:popBack()
      
      if (decaddr[address] == nil) and self:inSegment(address) then
        decaddr[address] = true -- Mark address as disassembled
        
        local instruction = Instruction(databuffer, address)
        local size = processor:analyze(instruction)
      
        if size > 0 then
          processor:emulate(addressqueue, referencetable, instruction)
        elseif decaddr[address + 1] == nil then
          addressqueue:pushFront(address + 1) -- Got an Invalid Instruction: Try To Disassemble Next Byte
        end
        
        if instruction.size > maxinstructionsize then
          maxinstructionsize = instruction.size -- Save largest instruction
        end
        
        table.bininsert(instructions, instruction, insbyaddress)
      end
    end
  end
  
  self.maxinstructionsize = maxinstructionsize
  return #instructions
end

return ProcessorLoader