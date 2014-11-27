local pref = require("pref")
local PdfTypes = require("formats.pdf.types")
local PdfParser = require("formats.pdf.parser")

local DataType = pref.datatype
local PdfFormat = pref.format.create("Portable Document Format", "Documents", "Dax", "1.1b")

function PdfFormat:validate(validator)
  validator:checkAscii(0, "%PDF-")
end

function PdfFormat:parse(formattree)  
  local pdfparser = PdfParser()
  local objtable = pdfparser:analyze(formattree.buffer)

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
      pref.error("Unknown PdfType")
      return
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

function PdfFormat.getObjectName(objstruct, formattree)
  local buffer, offset = formattree.buffer, objstruct.offset
  local objpos = buffer:indexOf("obj", offset)
  
  return "Object(Number, Revision): " .. buffer:readString(offset, (objpos - offset) - 1)
end

return PdfFormat