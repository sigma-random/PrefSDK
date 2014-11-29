import QtQuick 2.1
import QtQuick.Controls 1.2
import Pref 1.0
import Pref.Format 1.0

Item
{
    property ListModel model;

    Text
    {
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: styleData.textAlignment
        elide: styleData.elideMode
        text: styleData.value
        font.family: "Monospace"

        Component.onCompleted: {
            if(styleData.selected === true) {
                color = styleData.textColor;
                return;
            }

            if(styleData.column === 1) {
                var element = model.get(styleData.row).element;

                if(element.isInteger)
                  color = "navy";
                else if(element.elementType === ElementType.FieldArrayType) /* Strings only */
                  color = "green";
                else
                  color = styleData.textColor;
          }
          else if(styleData.column === 2)
            color = "green";
        }
    }
}
