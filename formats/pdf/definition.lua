local pref = require("pref")
local PdfFunctions = require("formats.pdf.functions")
local PdfTypes = require("formats.pdf.pdftypes")
local PdfDebug = require("formats.pdf.pdfdebug")

local PdfFormat = pref.format.create("Portable Document Format", "Documents", "Dax", "1.1b")

function PdfFormat:validate(validator)
  validator:checkAscii(0, "%PDF-")
end

function PdfFormat:parse(formattree)  
  local objtable = PdfFunctions.findAllKeywords(self, formattree.buffer)
  -- PdfDebug.printObjectTable(objtable)

  for i, v in ipairs(objtable) do
    if v.type == PdfTypes.PdfWhitespace then
      PdfFunctions.createPdfWhitespaceStruct(formattree, v)
    elseif v.type == PdfTypes.PdfComment then
      PdfFunctions.createPdfCommentStruct(formattree, v)
    elseif v.type == PdfTypes.PdfObject then
      PdfFunctions.createPdfObjectStruct(formattree, v)
    elseif v.type == PdfTypes.PdfHeader then
      PdfFunctions.createPdfHeaderStruct(formattree, v)
    elseif v.type == PdfTypes.PdfXRef then
      PdfFunctions.createPdfXRefStruct(formattree, v)
    elseif v.type == PdfTypes.PdfTrailer then
      PdfFunctions.createPdfTrailerStruct(formattree, v)
    else
      self:error("Unknown PdfType")
      return
    end
  end
end

return PdfFormat