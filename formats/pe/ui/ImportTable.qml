import QtQuick 2.1
import QtQuick.Controls 1.2
import Pref.Format 1.0

Item
{
    id: exporttable

    Component {
        id: entrymodel;
        ListModel { }
    }

    function createDescriptorModel(importentry)
    {
        var model = entrymodel.createObject(descrfunc);
        var oft = formattree.structure(importentry.name + "_OFT");
        var ft = formattree.structure(importentry.name + "_FT");

        for(var i = 0; i < ft.fieldCount; i++)
        {
            var ftthunk = ft.field(i);

            model.append({ "oft": (oft ? oft.field(i).displayValue() : "N/A"),
                         "ft": ftthunk.displayValue(),
                         "name": ftthunk.displayName() });
        }

        return model;
  }
  
  SplitView
  {
    orientation: Qt.Vertical
    anchors.fill: parent

    TableView
    {    
      TableViewColumn { role: "modulename"; title: "Module Name"; width: exporttable.width / 6 }
      TableViewColumn { role: "oft"; title: "OFTs"; width: exporttable.width / 6 }
      TableViewColumn { role: "timestamp"; title: "TimeDateStamp"; width: exporttable.width / 6 }
      TableViewColumn { role: "fwdchain"; title: "ForwarderChain"; width: exporttable.width / 6 }
      TableViewColumn { role: "namerva"; title: "Name RVA"; width: exporttable.width / 6 }
      TableViewColumn { role: "ft"; title: "FTs (IAT)"; width: exporttable.width / 6 }

      id: tabledescr
      width: exporttable.width

      model: ListModel {
          id: importmodel

          Component.onCompleted: {
            var importdirectory = formattree.structure("ImportDirectory")

            if(importdirectory === null) /* No Imports */
                return

            for(var i = 0; i < importdirectory.fieldCount; i++)
            {
                var importentry = importdirectory.field(i)

                importmodel.append({ "modulename": importentry.displayName() + ".DLL",
                                     "oft": importentry.field("OriginalFirstThunk").displayValue(),
                                     "timestamp": importentry.field("TimeDateStamp").displayValue(),
                                     "fwdchain": importentry.field("ForwarderChain").displayValue(),
                                     "namerva": importentry.field("Name").displayValue(),
                                     "ft": importentry.field("FirstThunk").displayValue(),
                                     "descrmodel": createDescriptorModel(importentry) })
            }
         }
      }

      itemDelegate: Component {
          Text {
              text: styleData.value
              font.family: "Monospace"

              Component.onCompleted: {
                  if(styleData.column > 0)
                      color = "navy";
                  else
                      color = styleData.textColor;
              }
          }
      }

      onClicked: {
          var entry = importmodel.get(row);
          descrfunc.model = entry.descrmodel;
      }
    }

    TableView
    {
        TableViewColumn { role: "oft"; title: "OFTs"; width: parent.width / 3 }
        TableViewColumn { role: "ft"; title: "FTs (IAT)"; width: parent.width / 3 }
        TableViewColumn { role: "name"; title: "Name"; width: parent.width / 3 }

        id: descrfunc
        width: parent.width

        itemDelegate: Component {
            Text {
                text: styleData.value
                font.family: "Monospace"

                Component.onCompleted: {
                    if(styleData.column < 2)
                        color = "navy";
                    else
                        color = styleData.textColor;
                }
            }
        }
    }
  }
}
