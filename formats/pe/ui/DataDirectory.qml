import QtQuick 2.1
import QtQuick.Controls 1.2

Item
{
  id: datadirectory

  TableView
  {
      TableViewColumn { role: "name"; title: "Name"; width: parent.width / 4 }
      TableViewColumn { role: "address"; title: "VirtualAddress"; width: parent.width / 4 }
      TableViewColumn { role: "size"; title: "Size"; width: parent.width / 4 }
      TableViewColumn { role: "info"; title: "Info"; width: parent.width / 4 }

      id: datadirectoryview
      anchors.fill: parent

      model: ListModel {
          id: datadirectorymodel
      }

      itemDelegate: Component {
          Text {
              font.family: "Monospace"
              text: styleData.value

              color: {
                  if((styleData.column === 1) || (styleData.column === 2))
                      color = "navy";
                  else if(styleData.column === 3)
                      color = "green";
                  else
                    color = styleData.textColor;
              }
          }
      }

      Component.onCompleted: {
          var datadirectory = formattree.structure("NtHeaders").field("OptionalHeader").field("DataDirectory");

          for(var i = 0; i < datadirectory.fieldCount; i++)
          {
              var entry = datadirectory.field(i);
              var addressfield = entry.field("VirtualAddress");
              var sizefield = entry.field("Size");

              datadirectorymodel.append({ "name": entry.name, "address": addressfield.displayValue(), "size": sizefield.displayValue(), "info": entry.info });
          }
      }
  }
}
 
