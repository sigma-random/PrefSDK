import QtQuick 2.1
import QtQuick.Controls 1.2
import Pref.Format 1.0

Item
{
  id: datadirectory
  
  ListModel
  {
    id: structuremodel
    
    Component.onCompleted: {
      var datadirectory = formattree.structure("NtHeaders").field("OptionalHeader").field("DataDirectory")
      
      for(var i = 0; i < datadirectory.fieldCount; i++)
      {
        var entry = datadirectory.field(i)
        
        structuremodel.append({ "name": entry.displayName(), 
                                "virtualaddress": entry.field("VirtualAddress").displayValue(), 
                                "size": entry.field("Size").displayValue(),
                                "info": entry.info })
      }
    }
  }
  
  TableView
  {    
    TableViewColumn { role: "name"; title: "Name"; width: datadirectory.width / 4 }
    TableViewColumn { role: "virtualaddress"; title: "Virtual Address"; width: datadirectory.width / 4 }
    TableViewColumn { role: "size"; title: "Size"; width: datadirectory.width / 4 }
    TableViewColumn { role: "info"; title: "Section"; width: datadirectory.width / 4 }
   
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
          
          if((styleData.column === 1) || (styleData.column === 2))
            color = "navy"
          else if(styleData.column == 3)
            color = "green"
        }
      }
    }
  }
}
 
