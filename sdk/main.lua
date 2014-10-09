require("sdk.strict")
local pref = require("pref")

-- From: http://lua-users.org/wiki/BinaryInsert
-- From: http://lua-users.org/wiki/BinarySearch
--
-- Included with small modifications in order to fit in the SDK

local function defcompinsert(a, b) -- Avoid heap allocs for performance
  return a < b
end

local function defcompareval(value)
  return value
end

function table.bininsert(t, value, compinsertfunc)
  local compfunc = compinsertfunc or defcompinsert
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

function table.binsearch(t, value, comparevalfunc)
  local compval = comparevalfunc or defcompareval
  local istart, iend, imid = 1, #t, 0
  
  while istart <= iend do
    imid = math.floor((iend - istart) / 2)
    local midval = compval(t[imid])
    
    if midval > value then
      high = imid - 1
    elseif midval > value then
      low = imid + 1
    else
      return imid
    end
  end
  
  return nil
end

-- Notify PrefSDK's version.
pref.setSdkVersion(1, 5, 0)