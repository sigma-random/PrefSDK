require("sdk.strings.encoding.escape")
local FormatDefinition = require("sdk.format.formatdefinition")
local PdfTypes = require("formats.pdf.pdftypes")
local PdfDebug = require("formats.pdf.pdfdebug")

local PdfObject = { type = PdfTypes.PdfUnknown, startpos = 0, endpos = 0 } 

local filepos = 0
local PdfFormat = FormatDefinition:new("Portable Document Format", "Documents", "Dax", "1.1b", Endian.LittleEndian)

function PdfFormat.getObjectName(formatobject, buffer)
  local offset = formatobject:offset()
  local objpos = buffer:find("obj", offset)
  return "Object: " .. buffer:readString(offset, (objpos - offset) - 1)
end

function PdfFormat:validateFormat(buffer)
  local hdrpos = buffer:find("%PDF-")
  
  if hdrpos == -1 then
    return false
  end
  
  return true
end

function PdfFormat:parseFormat(formatmodel, buffer)
  local objtable = self:findAllKeywords(buffer)
  -- PdfDebug.printObjectTable(objtable)

  for i, v in ipairs(objtable) do
    if v.type == PdfTypes.PdfWhitespace then
      self:createPdfWhitespaceStruct(formatmodel, v)
    elseif v.type == PdfTypes.PdfComment then
      self:createPdfCommentStruct(formatmodel, v)
    elseif v.type == PdfTypes.PdfObject then
      self:createPdfObjectStruct(formatmodel, v)
    elseif v.type == PdfTypes.PdfHeader then
      self:createPdfHeaderStruct(formatmodel, v)
    elseif v.type == PdfTypes.PdfXRef then
      self:createPdfXRefStruct(formatmodel, v)
    elseif v.type == PdfTypes.PdfTrailer then
      self:createPdfTrailerStruct(formatmodel, v)
    else
      error("Unknown PdfType")
    end
  end
end

function PdfFormat:createPdfWhitespaceStruct(formatmodel, obj)
  local pdfobj = formatmodel:addStructure("PDFWHITESPACE")
  pdfobj:addField(DataType.Blob, obj.endpos - obj.startpos, "Whitespace")
end

function PdfFormat:createPdfCommentStruct(formatmodel, obj)
  local pdfobj = formatmodel:addStructure("PDFCOMMENT")
  pdfobj:addField(DataType.Blob, obj.endpos - obj.startpos, "Comment")
end

function PdfFormat:createPdfObjectStruct(formatmodel, obj)
  local pdfobj = formatmodel:addStructure("PDFOBJECT")
  pdfobj:dynamicInfo(PdfFormat.getObjectName)
  pdfobj:addField(DataType.Blob, obj.endpos - obj.startpos, "Data")
end

function PdfFormat:createPdfHeaderStruct(formatmodel, obj)
  local pdfobj = formatmodel:addStructure("PDFHEADER")
  pdfobj:addField(DataType.Char, obj.endpos - obj.startpos, "Header")
end

function PdfFormat:createPdfXRefStruct(formatmodel, obj)
  local pdfobj = formatmodel:addStructure("PDFXREF")
  pdfobj:addField(DataType.Blob, obj.endpos - obj.startpos, "Data")
end

function PdfFormat:createPdfTrailerStruct(formatmodel, obj)
  local pdfobj = formatmodel:addStructure("PDFTRAILER")
  pdfobj:addField(DataType.Char, obj.endpos - obj.startpos, "Trailer")
end

function PdfFormat:findAllKeywords(buffer)
  local objtable = { }
  local i = 1
  
  filepos = 0 -- Reset File Cursor
  
  while filepos < buffer:size() do
    local ch = buffer[filepos]
    local t = nil -- Single PdfObject (if any)
    
    if PdfFormat:isWhitespace(ch) then
      t = PdfFormat:createWhitespaceObj(buffer)
    elseif (ch == "%") then
      t = PdfFormat:createCommentObj(buffer)
    elseif (ch >= "0") and (ch <= "9") then
      t = PdfFormat:createObjObj(buffer)
    elseif (ch == "x") and (buffer:readString(filepos, 4) == "xref") then
      t = PdfFormat:createXRefObj(buffer)
    else
      error("Unknown Character: '"..ch.."' at offset: "..filepos)
    end
    
    if t ~= nil then
      objtable[i] = t
      i = i + 1
    end
  end
  
  return objtable
end

function PdfFormat:isWhitespace(ch)
  return ((ch == "\r") or (ch == "\n") or (ch == "\t") or (ch == " "))
end

function PdfFormat:eatWhitespaces(buffer)
  while self:isWhitespace(buffer:readString(filepos, 1)) do
    filepos = filepos + 1
  end
end

function PdfFormat:createWhitespaceObj(buffer)
  local obj = setmetatable({ }, PdfObject)
  
  obj.type = PdfTypes.PdfWhitespace
  obj.startpos = filepos
    
  while PdfFormat:isWhitespace(buffer[filepos]) do
    filepos = filepos + 1
  end
   
  obj.endpos = filepos
  return obj
end

function PdfFormat:createCommentObj(buffer)
  local obj = setmetatable({ }, PdfObject)
  local commenttype = PdfTypes.PdfComment
  
  if buffer:readString(filepos, 4) == "%PDF" then
    commenttype = PdfTypes.PdfHeader
  elseif buffer:readString(filepos, 5) == "%%EOF" then
    commenttype = PdfTypes.PdfTrailer
  end
 
  obj.type = commenttype
  obj.startpos = filepos
  
  filepos = filepos + string.len(buffer:readLine(filepos)) -- Eat Comment Line
  
  if PdfFormat:isWhitespace(buffer[filepos]) then
    filepos = filepos + 1 -- Eat Single NewLine Char
  end
  
  obj.endpos = filepos
  return obj
end

function PdfFormat:createObjObj(buffer)
  local obj = setmetatable({ }, PdfObject)
  local objpos = buffer:find("obj", filepos)
  local endobjpos = buffer:find("endobj", filepos)
  
  if (objpos == -1) or (endobjpos == -1) then
    error("Wrong PdfObject at: " .. filepos)
  end
  
  obj.type = PdfTypes.PdfObject
  obj.startpos = filepos
  
  filepos = endobjpos + string.len("endobj") -- Eat Entire PdfObject
  PdfFormat:eatWhitespaces(buffer)
  
  obj.endpos = filepos  
  return obj
end

function PdfFormat:createXRefObj(buffer)
  local obj = setmetatable({ }, PdfObject)
  local startxrefpos = buffer:find("startxref", filepos)
  
  if startxrefpos == -1 then
    error("Wrong PdfXRef at: " .. filepos)
  end
  
  obj.type = PdfTypes.PdfXRef
  obj.startpos = filepos
  
  filepos = startxrefpos + string.len("startxref") -- Eat Entire PdfXRef
  PdfFormat:eatWhitespaces(buffer)
  filepos = filepos + string.len(buffer:readLine(filepos)) -- Eat XRef Offset
  PdfFormat:eatWhitespaces(buffer)
  
  obj.endpos = filepos
  return obj
end