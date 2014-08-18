local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")

local SignatureDB = oop.class()

function SignatureDB:__ctor(dbfile)
  SignatureDB.defaultpath = "formats/portableexecutable/"
  SignatureDB.defaultdbfile = "signatures.txt"
  
  if (SignatureDB.db == nil) or (dbfile and (SignatureDB.dbfile ~= dbfile)) then
    SignatureDB.dbfile = dbfile or SignatureDB.defaultdbfile
    SignatureDB.db = self:loadDB(SignatureDB.dbfile)
  end
end

function SignatureDB:toByte(b)
  b = b:gsub("^%s*(.-)%s*$", "%1") -- Trim string
  
  if b == "??" then
    return b
  end
  
  return tonumber(b, 16)
end

function SignatureDB:signatureToArray(hexstring)
  local signature = { }
  
  for b in hexstring:gmatch("..[%s]*") do
    table.insert(signature, self:toByte(b))
  end
    
  return signature
end

function SignatureDB:loadSignature(f, signaturedb, signame)
  local k, hexstring = f:read("*line"):match("(signature) = (.+)")
  
  if (k == nil) or (hexstring == nil) then
    return false
  end
  
  local signature = self:signatureToArray(hexstring)
  local currentpath = signaturedb
  
  for i, b in ipairs(signature) do    
    if currentpath[b] == nil then
      currentpath[b] = { }
    end
    
    currentpath = currentpath[b]
    
    if i == #signature then
      currentpath.name = signame
    end
  end
  
  signaturedb.maxdepth = math.max(signaturedb.maxdepth, #signature)
  return true
end

function SignatureDB:loadDB(dbfile)  
  local sigdb = { maxdepth = 0 }
  local f = io.open(SignatureDB.defaultpath .. dbfile)
  
  if f then
    local line = f:read("*line")
    
    while line do
      local signaturename = line:match("^%[(.+)%]$")
      
      if signaturename then        
        if self:loadSignature(f, sigdb, signaturename) == false then
          break
        end
      end
      
      line = f:read("*line")
    end
    
    f:close()
  end
  
  return sigdb
end

function SignatureDB:match(databuffer, offset)
  local bestmatch, found = "Nothing Found", false
  local currentpath = SignatureDB.db
  local currentoffset = offset
  
  for i = 1, SignatureDB.db.maxdepth do
    local b = databuffer:readType(currentoffset, DataType.UInt8)
    
    if currentpath[b] then
      currentpath = currentpath[b]
    elseif currentpath["??"] then
      currentpath = currentpath["??"]
    else
      break
    end
    
    if currentpath.name then
      bestmatch = currentpath.name
      found = true
    end
    
    currentoffset = currentoffset + DataType.sizeOf(DataType.UInt8)
  end
  
  return found, bestmatch
end

return SignatureDB