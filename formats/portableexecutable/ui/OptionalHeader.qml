import QtQuick 2.1
import QtQuick.Controls 1.2

Item
{
  id: optionalheader
  
  StructureModel
  {
    id: structuremodel
    
    Component.onCompleted: {
      var ntheaders = formattree.structure("NtHeaders")
      structuremodel.bind(ntheaders.field(2))
    }
  }
  
  TableView
  {    
    TableViewColumn { role: "name"; title: "Name"; width: optionalheader.width / 3 }
    TableViewColumn { role: "type"; title: "Type"; width: optionalheader.width / 3 }
    TableViewColumn { role: "value"; title: "Value"; width: optionalheader.width / 3 }
   
    anchors.fill: parent
    model: structuremodel
    itemDelegate: Component {
      Text {
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: styleData.textAlignment
        elide: styleData.elideMode
        text: styleData.value
        font.family: "Monospace"
          
        Component.onCompleted: {
          if(styleData.selected === true)
          {
            color = styleData.textColor
            return
          }
          
          if(styleData.column === 2)
          {
            var element = structuremodel.get(styleData.row).element
            
            if(element.isInteger)
              color = "navy"
            else if(element.elementType == ElementType.FieldArray) /* Strings only */
              color = "green"
            else
              color = styleData.textColor
          }
          else if(styleData.column === 3)
            color = "green"
        }
      }
    }
  }
}