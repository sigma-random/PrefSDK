import QtQuick 2.1
import QtQuick.Controls 1.2

Item
{
    id: sectiontable

    TableView
    {
        TableViewColumn { role: "name"; title: "Name"; width: parent.width / 6 }
        TableViewColumn { role: "virtualaddress"; title: "Virtual Address"; width: parent.width / 6 }
        TableViewColumn { role: "virtualsize"; title: "Virtual Size"; width: parent.width / 6 }
        TableViewColumn { role: "rawaddress"; title: "Raw Address"; width: parent.width / 6 }
        TableViewColumn { role: "rawsize"; title: "Raw Size"; width: parent.width / 6 }
        TableViewColumn { role: "characteristics"; title: "Characteristics"; width: parent.width / 6 }

        id: sectiontableview
        anchors.fill: parent

        model: ListModel {
            id: sectionmodel

            Component.onCompleted: {
                var sections = formattree.structure("SectionTable");

                for(var i = 0; i < sections.fieldCount; i++)
                {
                    var s = sections.field(i);

                    sectionmodel.append( { "name": s.field("Name").displayValue(),
                                           "virtualaddress": s.field("VirtualAddress").displayValue(),
                                           "virtualsize": s.field("VirtualSize").displayValue(),
                                           "rawaddress": s.field("PointerToRawData").displayValue(),
                                           "rawsize": s.field("SizeOfRawData").displayValue(),
                                           "characteristics": s.field("Characteristics").displayValue() } );
                }
            }
        }

        itemDelegate: Component {
            Text {
                text: styleData.value
                font.family: "Monospace"

                Component.onCompleted: {
                    if(styleData.column === 0)
                        color = "green";
                    else
                        color = "navy";
                }
            }
        }
    }
}
