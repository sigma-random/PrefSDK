-- require("sdk.strings.encoding.escape")
local oop = require("sdk.lua.oop")
local FormatDefinition = require("sdk.format.formatdefinition")
local DataType = require("sdk.types.datatype")
local PdfTypes = require("formats.pdf.pdftypes")
local PdfDebug = require("formats.pdf.pdfdebug")

local PdfFormat = oop.class(FormatDefinition)

function PdfFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
  
  self.filepos = 0
  
  self.pdfobject = { type = PdfTypes.PdfUnknown, startpos = 0, endpos = 0 }
  self.pdfobject.__index = self._pdfobject
end

function PdfFormat:getObjectName(objstruct)
  local offset = objstruct:offset()
  local objpos = self.databuffer:indexOf("obj", offset)
  return "Object(Number, Revision): " .. self.databuffer:readString(offset, (objpos - offset) - 1)
end

function PdfFormat:validateFormat()
  self:checkData(0, DataType.AsciiString, "%PDF-")
end

function PdfFormat:parseFormat(formattree)  
  local objtable = self:findAllKeywords(self.databuffer)
  -- PdfDebug.printObjectTable(objtable)

  for i, v in ipairs(objtable) do
    if v.type == PdfTypes.PdfWhitespace then
      self:createPdfWhitespaceStruct(formattree, v)
    elseif v.type == PdfTypes.PdfComment then
      self:createPdfCommentStruct(formattree, v)
    elseif v.type == PdfTypes.PdfObject then
      self:createPdfObjectStruct(formattree, v)
    elseif v.type == PdfTypes.PdfHeader then
      self:createPdfHeaderStruct(formattree, v)
    elseif v.type == PdfTypes.PdfXRef then
      self:createPdfXRefStruct(formattree, v)
    elseif v.type == PdfTypes.PdfTrailer then
      self:createPdfTrailerStruct(formattree, v)
    else
      error("Unknown PdfType")
    end
  end
end

function PdfFormat:createPdfWhitespaceStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFWHITESPACE", obj.startpos)
  pdfobj:addField(DataType.Blob, "Whitespace", obj.endpos - obj.startpos)
end

function PdfFormat:createPdfCommentStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFCOMMENT", obj.startpos)
  pdfobj:addField(DataType.Blob, "Comment", obj.endpos - obj.startpos)
end

function PdfFormat:createPdfObjectStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFOBJECT", obj.startpos):dynamicInfo(PdfFormat.getObjectName)
  pdfobj:addField(DataType.Blob, "Data", obj.endpos - obj.startpos)
end

function PdfFormat:createPdfHeaderStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFHEADER", obj.startpos)
  pdfobj:addField(DataType.Character, "Header", obj.endpos - obj.startpos)
end

function PdfFormat:createPdfXRefStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFXREF", obj.startpos)
  pdfobj:addField(DataType.Blob, "Data", obj.endpos - obj.startpos)
end

function PdfFormat:createPdfTrailerStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFTRAILER", obj.startpos)
  pdfobj:addField(DataType.Character, "Trailer", obj.endpos - obj.startpos)
end

function PdfFormat:findAllKeywords(buffer)
  local objtable = { }
  local i = 1
  
  self.filepos = 0 -- Reset File Cursor
  
  while self.filepos < buffer:length() do
    local ch = buffer:readChar(self.filepos)
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
      error("Unknown Character: '" .. ch .. "' at offset: " .. tostring(self.filepos))
    end
    
    if t ~= nil then
      objtable[i] = t
      i = i + 1
    end
  end
  
  return objtable
end

function PdfFormat:isWhitespace(ch)
  return ((ch == '\r') or (ch == '\n') or (ch == '\t') or (ch == ' '))
end

function PdfFormat:eatWhitespaces(buffer)
  while self:isWhitespace(buffer:readChar(self.filepos)) do
    self.filepos = self.filepos + 1
  end
end

function PdfFormat:createWhitespaceObj(buffer)
  local obj = setmetatable({ }, self.pdfobject)
  
  obj.type = PdfTypes.PdfWhitespace
  obj.startpos = self.filepos
    
  while self:isWhitespace(buffer:readChar(self.filepos)) do
    self.filepos = self.filepos + 1
  end
   
  obj.endpos = self.filepos
  return obj
end

function PdfFormat:createCommentObj(buffer)
  local obj = setmetatable({ }, self.pdfobject)
  local commenttype = PdfTypes.PdfComment
  
  if buffer:readString(self.filepos, 4) == "%PDF" then
    commenttype = PdfTypes.PdfHeader
  elseif buffer:readString(self.filepos, 5) == "%%EOF" then
    commenttype = PdfTypes.PdfTrailer
  end
 
  obj.type = commenttype
  obj.startpos = self.filepos
  
  self.filepos = buffer:indexOfEol(self.filepos) -- Eat Comment Line
  
  if self:isWhitespace(buffer:readChar(self.filepos)) then
    self.filepos = self.filepos + 1 -- Eat Single NewLine Char
  end
  
  obj.endpos = self.filepos
  return obj
end

function PdfFormat:createObjObj(buffer)
  local obj = setmetatable({ }, self.pdfobject)
  local objpos = buffer:indexOf("obj", self.filepos)
  local endobjpos = buffer:indexOf("endobj", self.filepos)
  
  if (objpos == -1) or (endobjpos == -1) then
    error("Wrong PdfObject at: " .. tostring(self.filepos))
  end
  
  obj.type = PdfTypes.PdfObject
  obj.startpos = self.filepos
  
  self.filepos = endobjpos + string.len("endobj") -- Eat Entire PdfObject
  self:eatWhitespaces(buffer)
  
  obj.endpos = self.filepos
  return obj
end

function PdfFormat:createXRefObj(buffer)
  local obj = setmetatable({ }, self.pdfobject)
  local startxrefpos = buffer:indexOf("startxref", self.filepos)
  
  if startxrefpos == -1 then
    error("Wrong PdfXRef at: " .. tostring(self.filepos))
  end
  
  obj.type = PdfTypes.PdfXRef
  obj.startpos = self.filepos
  
  self.filepos = startxrefpos + string.len("startxref") -- Eat Entire PdfXRef
  self:eatWhitespaces(buffer)
  self.filepos = self.filepos + string.len(buffer:readLine(self.filepos)) -- Eat XRef Offset
  self:eatWhitespaces(buffer)
  
  obj.endpos = self.filepos
  return obj
end

return PdfFormat