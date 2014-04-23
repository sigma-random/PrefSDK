-- From: http://lua-users.org/wiki/BinaryInsert
-- From: http://lua-users.org/wiki/BinarySearch
--
-- Included with small modifications in order to fit in the SDK

do
  -- Avoid heap allocs for performance
  local function comp(a, b)
    return a < b
  end

  function table.bininsert(t, value, compfn)
    local compfunc = compfn or comp     -- Initialize compare function
    local istart, iend, imid, istate = 1, #t, 1, 0  -- Initialize numbers
    
    while istart <= iend do -- Get insert position  
      imid = math.floor((istart + iend) / 2) -- Calculate middle
      
      if compfunc(value, t[imid]) then -- Compare
        iend, istate = imid - 1, 0
      else
        istart, istate = imid + 1, 1
      end
    end
    
    table.insert(t, (imid + istate), value)
    return (imid + istate)
  end

  local function compval(value)
    return value
  end

  local function compareforward(a, b)
    return a < b
  end

  local function comparereverse(a, b)
    return a > b
  end

  function table.binsearch(t, value, compvalfunc, reversed)
    -- Initialize functions
    local compval = compvalfunc or compval
    local compfunc = reversed and comparereverse or compareforward
    
    local istart, iend, imid = 1, #t, 0 --  Initialize numbers
    
    while istart <= iend do -- Binary Search
      imid = math.floor((istart + iend) / 2) -- Calculate middle
      local value2 = compval(t[imid]) -- Get compare value
      
      -- get all values that match
      if value == value2 then
        local tfound, num = {imid, imid}, imid - 1
        
        while value == compval(t[num]) do
          tfound.first, num = num, num - 1
        end
        
        num = imid + 1
        
        while value == compval(t[num]) do
          tfound.last, num = num, num + 1
        end
        
        return tfound
      elseif compfunc(value, value2) then -- keep searching
        iend = imid - 1
      else
        istart = imid + 1
      end
    end
  end
end