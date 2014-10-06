import QtQuick 2.1
import QtQuick.Controls 1.2

Item
{
  id: exporttable
  
  ListModel
  {
    id: exportmodel
    
    Component.onCompleted: {
      var exportedfunctions = formattree.structure("ExportedFunctions")
      
      if(exportedfunctions === null) /* No Exports */
        return
        
      for(var i = 0; i < exportedfunctions.fieldCount; i++)
      {
        var field = exportedfunctions.field(i)
        exportmodel.append({ "name": field.displayName(), "ep": field.displayValue() })
      }
    }
  }
  
  TableView
  {    
    TableViewColumn { role: "name"; title: "Name"; width: exporttable.width / 2 }
    TableViewColumn { role: "ep"; title: "EntryPoint"; width: exporttable.width / 2 }
   
    anchors.fill: parent
    model: exportmodel
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
          
          if(styleData.column === 1)
            color = "navy"
        }
      }
    }
  }
}
