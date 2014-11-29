import QtQuick 2.1
import QtQuick.Controls 1.2
import Pref 1.0
import Pref.Format 1.0

ListModel
{
  property QtObject structure;
  
  id: structuremodel
  
  onStructureChanged: {
      structuremodel.clear();

      if(structure !== null)
        structuremodel.bind(structure);
  }

  function add(field, prefix)
  {
    var displayname = (prefix ? (prefix + "." + field.displayName()) : field.displayName())
    
    structuremodel.append({ "name": displayname, "value": field.displayValue(), "info": field.info, "element": field });
  }
  
  function bind(structure, prefix)
  {
    for(var i = 0; i < structure.fieldCount; i++)
    {
      var field = structure.field(i);
      
      if(field.elementType === ElementType.FieldType)
        structuremodel.add(field, prefix);
      else if((field.elementType === ElementType.FieldArrayType) && (field.itemType !== DataType.Character))
        structuremodel.bindFieldArray(field, prefix);
    }
  }
  
  function bindFieldArray(fieldarray, prefix)
  {
    for(var i = 0; i < fieldarray.itemCount; i++)
      structuremodel.add(fieldarray.item(i), prefix);
  }
}
