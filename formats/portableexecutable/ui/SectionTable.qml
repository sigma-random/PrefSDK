import QtQuick 2.1
import QtQuick.Controls 1.2

Item
{
  id: sectiontable
  
  ListModel
  {
    id: sectionmodel
    
    Component.onCompleted: {
      var sections = formattree.structure("SectionTable")
      
      for(var i = 0; i < sections.fieldCount; i++)
      {
        var s = sections.field(i)
        sectionmodel.append( { "name": s.field("Name").displayValue(), 
                               "virtualaddress": s.field("VirtualAddress").displayValue(), 
                               "virtualsize": s.field("VirtualSize").displayValue(), 
                               "rawaddress": s.field("PointerToRawData").displayValue(), 
                               "rawsize": s.field("SizeOfRawData").displayValue(), 
                               "characteristics": s.field("Characteristics").displayValue() } )
      }
    }
  }
  
  TableView
  {    
    TableViewColumn { role: "name"; title: "Name"; width: sectiontable.width / 6 }
    TableViewColumn { role: "virtualaddress"; title: "Virtual Address"; width: sectiontable.width / 6 }
    TableViewColumn { role: "virtualsize"; title: "Virtual Size"; width: sectiontable.width / 6 }
    TableViewColumn { role: "rawaddress"; title: "Raw Address"; width: sectiontable.width / 6 }
    TableViewColumn { role: "rawsize"; title: "Raw Size"; width: sectiontable.width / 6 }
    TableViewColumn { role: "characteristics"; title: "Characteristics"; width: sectiontable.width / 6 }
   
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
          
          if(styleData.column === 0)
            color = "green"
          else
            color = "navy"
        }
      }
    }
   
    anchors.fill: parent
    model: sectionmodel
  }
}
