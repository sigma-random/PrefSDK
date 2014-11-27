local oop = require("oop")
local pref = require("pref")
local PdfTypes = require("formats.pdf.types")

local PdfParser = oop.class()

function PdfParser:__ctor()
  self.filepos = 0
  self.errorstate = false
end

function PdfParser:isWhitespace(ch)
  if type(ch) ~= "string" then
    ch = string.char(ch)
  end
  
  return ((ch == '\r') or (ch == '\n') or (ch == '\t') or (ch == ' '))
end

function PdfParser:createPdfObject(objtype, objpos)
  return { type = objtype, startpos = objpos, endpos = objpos }
end

function PdfParser:eatWhitespaces(buffer)
  while (self.filepos < buffer.length) and self:isWhitespace(buffer[self.filepos]) do
    self.filepos = self.filepos + 1
  end
end

function PdfParser:createWhitespaceObj(buffer)
  local obj = self:createPdfObject(PdfTypes.PdfWhitespace, self.filepos)
  
  self:eatWhitespaces(buffer)
  obj.endpos = self.filepos
  return obj
end

function PdfParser:indexOfEol(buffer, startpos)
  local cr = buffer:indexOf("\r", startpos)
  local lf = buffer:indexOf("\n", startpos)
      
  if cr ~= -1 and lf ~= -1 then
    return math.min(cr, lf)
  elseif cr == -1 and lf ~= -1 then
    return lf
  elseif cr ~= -1 and lf == -1 then
    return cr
  end
  
  return -1
end

function PdfParser:createCommentObj(buffer)
  local obj = self:createPdfObject(PdfTypes.PdfComment, self.filepos)
  
  if buffer:readString(self.filepos, 4) == "%PDF" then
    obj.type = PdfTypes.PdfHeader
  elseif buffer:readString(self.filepos, 5) == "%%EOF" then
    obj.type = PdfTypes.PdfTrailer
  end
  
  self.filepos = self:indexOfEol(buffer, self.filepos) -- Eat Comment Line
  
  if self:isWhitespace(buffer[self.filepos]) then
    self.filepos = self.filepos + 1 -- Eat Single NewLine Char
  end
  
  obj.endpos = self.filepos
  return obj
end

function PdfParser:createObjObj(buffer)
  local objpos = buffer:indexOf("obj", self.filepos)
  local endobjpos = buffer:indexOf("endobj", self.filepos)
  
  if (objpos == -1) or (endobjpos == -1) then
    pref.error("Wrong PdfObject at: %08X", self.filepos)
    self.errorstate = true
    return
  end
  
  local obj = self:createPdfObject(PdfTypes.PdfObject, self.filepos)
  self.filepos = endobjpos + string.len("endobj") -- Eat Entire PdfObject
  self:eatWhitespaces(buffer)
  
  obj.endpos = self.filepos
  return obj
end

function PdfParser:createXRefObj(buffer)
  local startxrefpos = buffer:indexOf("startxref", self.filepos)
  
  if startxrefpos == -1 then
    pref.error("Wrong PdfXRef at: %08X", self.filepos)
    self.errorstate = true
    return
  end
  
  local obj = self:createPdfObject(PdfTypes.PdfXRef, self.filepos)
  
  self.filepos = startxrefpos + string.len("startxref") -- Eat Entire PdfXRef
  self:eatWhitespaces(buffer)
  self.filepos = self.filepos + string.len(buffer:readLine(self.filepos)) -- Eat XRef Offset
  self:eatWhitespaces(buffer)
  
  obj.endpos = self.filepos
  return obj
end

function PdfParser:analyze(buffer)
  local objtable = { }
  local i = 1
  
  while (not self.errorstate) and (self.filepos < buffer.length) do
    local ch = string.char(buffer[self.filepos])
    local t = nil -- Single PdfObject (if any)
    
    if self:isWhitespace(ch) then
      t = self:createWhitespaceObj(buffer)
    elseif (ch == '%') then
      t = self:createCommentObj(buffer)
    elseif (ch >= '0') and (ch <= '9') then
      t = self:createObjObj(buffer)
    elseif (ch == 'x') and (buffer:readString(self.filepos, 4) == "xref") then
      t = self:createXRefObj(buffer)
    else
      pref.error("Unknown Character: '%s' at offset: %08X", ch, self.filepos)
    end
    
    if t ~= nil then
      objtable[i] = t
      i = i + 1
    end
  end
  
  return objtable
end

function PdfParser:pdfTypeName(pdftype)
  if pdftype == PdfTypes.PdfUnknown then
    return "PdfUnknown"
  elseif pdftype == PdfTypes.PdfWhitespace then
    return "PdfWhitespace"
  elseif pdftype == PdfTypes.PdfComment then
    return "PdfComment"
  elseif pdftype == PdfTypes.PdfObject then
    return "PdfObject"
  elseif pdftype == PdfTypes.PdfHeader then
    return "PdfHeader"
  elseif pdftype == PdfTypes.PdfXRef then
    return "PdfXRef"
  elseif pdftype == PdfTypes.PdfTrailer then
    return "PdfTrailer"
  end

  return "???"
end

function PdfParser:printTable(objtable)
  for i,v in ipairs(objtable) do
    pref.logline("%s: %08X -> %08X", self:pdfTypeName(v.type), v.startpos, v.endpos)
  end
end 

return PdfParser
