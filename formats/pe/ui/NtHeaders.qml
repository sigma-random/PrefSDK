import QtQuick 2.1
import QtQuick.Controls 1.2
import sdk.ui 1.0

Item
{
    id: ntheaders

    StructureView
    {
        id: ntheadersview
        anchors.fill: parent
        structure: formattree.structure("NtHeaders")

        Component.onCompleted: {
            var ntheaders = formattree.structure("NtHeaders");
            model.bind(ntheaders.field("FileHeader"), "FileHeader");
            model.bind(ntheaders.field("OptionalHeader"), "OptionalHeader");
        }
    }
}
 
