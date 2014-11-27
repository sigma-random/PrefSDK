import QtQuick 2.1
import QtQuick.Controls 1.2
import Pref 1.0
import Pref.Format 1.0

ListModel
{
  id: structuremodel
  
  function add(field)
  {
    structuremodel.append({ "name": field.displayName(), "type": field.displayType(), "value": field.displayValue(), "element": field });
  }
  
  function bind(structure)
  {
    for(var i = 0; i < structure.fieldCount; i++)
    {
      var field = structure.field(i)
      
      if(field.elementType === ElementType.FieldType)
        structuremodel.add(field);
      else if((field.elementType === ElementType.FieldArrayType) && (field.itemType != DataType.Character))
        structuremodel.bindFieldArray(field)
    }
  }
  
  function bindFieldArray(fieldarray)
  {
    for(var i = 0; i < fieldarray.itemCount; i++)
      structuremodel.add(fieldarray.item(i))
  }
}