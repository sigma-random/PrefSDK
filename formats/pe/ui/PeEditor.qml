import QtQuick 2.1
import QtQuick.Controls 1.2

Item
{
    TabView
    {
        id: tabview
        anchors.fill: parent
        tabPosition: Qt.BottomEdge

         Tab { title: "Dos Header"; DosHeader { } }
         Tab { title: "Nt Headers"; NtHeaders { } }
         Tab { title: "Data Directory"; DataDirectory { } }
         Tab { title: "Section Table"; SectionTable { } }
         Tab { title: "Export Table"; ExportTable { } }
         Tab { title: "Import Table"; ImportTable { } }
    }
}
