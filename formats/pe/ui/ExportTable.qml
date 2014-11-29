import QtQuick 2.1
import QtQuick.Controls 1.2

Item
{
    id: exporttable
  
    TableView
    {
        TableViewColumn { role: "name"; title: "Name"; width: parent.width / 2 }
        TableViewColumn { role: "ep"; title: "EntryPoint"; width: parent.width / 2 }

        anchors.fill: parent
        model: ListModel {
            id: exportmodel

            Component.onCompleted: {
                var exportedfunctions = formattree.structure("ExportedFunctions");

                if(exportedfunctions === null) /* No Exports */
                    return;

                for(var i = 0; i < exportedfunctions.fieldCount; i++)
                {
                    var field = exportedfunctions.field(i);
                    exportmodel.append({ "name": field.displayName(), "ep": field.displayValue() });
                }
            }
        }

        itemDelegate: Component {
            Text {
                text: styleData.value
                font.family: "Monospace"

                Component.onCompleted: {
                    if(styleData.column === 1)
                        color = "navy";
                    else
                        color = styleData.textColor;
                }
            }
        }
    }
}
