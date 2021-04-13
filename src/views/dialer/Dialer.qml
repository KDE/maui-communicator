import QtQuick 2.9
import QtQuick.Controls 2.3
import org.mauikit.controls 1.0 as Maui
import QtQuick.Layouts 1.3

GridLayout
{
    id: _grid

    anchors.centerIn: parent
    columns: 3
    rows: 3
    rowSpacing: buttonSize * 0.1
    columnSpacing: buttonSize * 0.1
    //                spacing: space.medium
    readonly property int buttonFontSize: Maui.Style.fontSizes.huge * 1.5
    property var model : ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"]

    Repeater
    {
        model: _grid.model

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true

            DialerButton
            {
                height: buttonSize
                width: height
                anchors.centerIn: parent
                text: modelData
            }
        }
    }
}
