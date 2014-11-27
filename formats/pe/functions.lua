local PeFunctions = { }

function PeFunctions.rvaInSection(rva, section)
  local sectrva = section.VirtualAddress.value
  local sectsize = section.VirtualSize.value
  
  if (rva >= sectrva) and (rva < (sectrva + sectsize)) then
    return true
  end
  
  return false
end

function PeFunctions.sectionFromRva(rva, formattree)
  local numberofsections = formattree.NtHeaders.FileHeader.NumberOfSections.value
  
  if numberofsections > 0 then
    local sectiontable = formattree.SectionTable
    
    for i = 1, numberofsections do
      local section = sectiontable["Section" .. i]
      
      if PeFunctions.rvaInSection(rva, section) then
        return section
      end
    end
  end
  
  return nil
end

function PeFunctions.sectionName(rva, formattree)
  local section = PeFunctions.sectionFromRva(rva, formattree)
  
  if section ~= nil then
    return section.Name.value, true
  end
  
  return "INVALID", false
end

function PeFunctions.imageFirstSection(formattree)
  local ntheaders = formattree.NtHeaders
  local optheadersize = ntheaders.FileHeader.SizeOfOptionalHeader.value
  return ntheaders.offset + optheadersize + 0x18
end

return PeFunctions
