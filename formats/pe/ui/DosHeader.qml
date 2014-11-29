import QtQuick 2.1
import QtQuick.Controls 1.2
import sdk.ui 1.0

Item
{
  id: dosheader
  
  StructureView
  {
    id: dosheaderview
    anchors.fill: parent
    structure: formattree.structure("DosHeader")
  }
}
