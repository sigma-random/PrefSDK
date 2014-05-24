local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local uuid = require("sdk.math.uuid")
local Address = require("sdk.math.address")
local ByteOrder = require("sdk.types.byteorder")
local FormatTree = require("sdk.format.formattree")
local AddressQueue = require("sdk.disassembler.addressqueue")
local Instruction = require("sdk.disassembler.instruction")
local ReferenceTable = require("sdk.disassembler.crossreference.referencetable")

ffi.cdef
[[
  typedef const char* LoaderId;
  
  void Loader_register(const char* name, const char* author, const char* version, LoaderId loaderid);
]]

local C = ffi.C
local ProcessorLoader = oop.class()

function ProcessorLoader.register(loadertype, name, author, version)
  local loaderid = uuid()
  Sdk.loaderlist[loaderid] = loadertype  -- Store Loader Definition's type
  C.Loader_register(name, author, version, loaderid) -- Notify PREF that a new loader has been created
end

function ProcessorLoader:__ctor(databuffer, format, processor, endian)
  self.databuffer = databuffer
  self.format = format
  self.processor = processor
  self.endian = endian
  self.entrypoints = { }
  self.segments = { }
  self.instructions = { }
  self.referencetable = ReferenceTable()
  self.isvalid = self:validate()
  
  if self.isvalid then
    self.format.tree = FormatTree(nil, databuffer)
    self.format:parse(self.format.tree)
    self:createSegments(self.format.tree)
  end
end

function ProcessorLoader:validate()
  return pcall(self.format.validate, self.format)
end

function ProcessorLoader:createSegments(formattree)
  -- This method must be reimplemented
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

function ProcessorLoader:segmentVirtualAddress(address)
  local segment = self:segment(address)
  
  if segment == nil then
    return address
  end
  
  return Address.rebase(address, segment.startaddress, segment.baseaddress)
end

function ProcessorLoader:disassemble()
  local processor = self.processor
  local instructions = self.instructions
  local referencetable = self.referencetable
  local databuffer = self.format.databuffer
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
        
        local instruction = Instruction(databuffer, self.endian, address, self:segmentVirtualAddress(address))
        local size = processor:analyze(instruction)

        if (size <= 0) and (decaddr[address + 1] == nil) then
          addressqueue:pushFront(address + 1) -- Got an Invalid Instruction: Try To Disassemble Next Byte
        else
          processor:emulate(addressqueue, referencetable, instruction)
          
          if instruction.size > maxinstructionsize then
            maxinstructionsize = instruction.size -- Save largest instruction
          end
        
          table.bininsert(instructions, instruction, insbyaddress)
        end
      end
    end
  end
  
  self.maxinstructionsize = maxinstructionsize
  return #instructions
end

return ProcessorLoader
