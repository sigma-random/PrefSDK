import QtQuick 2.1
import QtQuick.Controls 1.2
import sdk.ui.models 1.0
import sdk.ui.delegates 1.0

TableView
{
    property alias structure: structuremodel.structure

    TableViewColumn { role: "name"; title: "Name"; width: parent.width / 3 }
    TableViewColumn { role: "value"; title: "Value"; width: parent.width / 3 }
    TableViewColumn { role: "info"; title: "Info"; width: parent.width / 3 }

    model: StructureModel {
        id: structuremodel
    }
  
    itemDelegate: Component {
        StructureDelegate {
            model: structuremodel
        }
    }
} 
