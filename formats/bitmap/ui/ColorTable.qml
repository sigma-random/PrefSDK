import QtQuick 2.1
import QtQuick.Controls 1.2

Item
{
    id: colortableview
    ListModel { id: colortablemodel }

    GroupBox
    {
      title: "Color Table"
      anchors.fill: parent
      
      GridView
      {
          id: colorgrid
          anchors.fill: parent
          model: colortablemodel

          delegate: Item {
              Text {
                  id: indextext
                  horizontalAlignment: Text.AlignHCenter
                  text: index
                  width: colorgrid.cellWidth - 2
              }

              Rectangle {
                  anchors.top: indextext.bottom
                  color: rgb
                  width: colorgrid.cellWidth - 2
                  height: colorgrid.cellHeight - indextext.height - 2
                  border.color: "black"
              }
          }


          Component.onCompleted: {
              var ctable = formattree.structure("ColorTable")

              for(var i = 0; i < ctable.fieldCount; i++)
              {
                  var entry = ctable.field("Color_" + i)
                  var colorrgb = "#" + entry.field("Red").displayValue() + entry.field("Green").displayValue() + entry.field("Blue").displayValue()
                  colortablemodel.append({ "index": i, "rgb": colorrgb })
              }
          }
      }
    }
}
