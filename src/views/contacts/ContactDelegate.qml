import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.2 as Maui
import org.kde.kirigami 2.9 as Kirigami

Maui.SwipeBrowserDelegate
{
    id: control
    hoverEnabled: true
    clip: true
//    Kirigami.Theme.colorSet: Kirigami.Theme.Button

    draggable: true

    signal favClicked(int index)

    iconSizeHint: Maui.Style.iconSizes.huge
    label1.text: model.n
    label1.font.pointSize: Maui.Style.fontSizes.big
    label1.font.bold: true
    label1.font.weight: Font.Bold
    label1.elide: Text.ElideMiddle

    label2.text: model.tel
    label2.font.pointSize: Maui.Style.fontSizes.small
    label2.font.weight: Font.Light
//    label2.wrapMode: Text.WrapAnywhere
    label2.elide: Text.ElideMiddle

    label3.text: model.email
    label3.font.pointSize: Maui.Style.fontSizes.small
    label3.font.weight: Font.Light
//    label3.wrapMode: Text.WrapAnywhere
    label3.elide: Text.ElideMiddle

    label4.text: model.title
    label4.font.pointSize: Maui.Style.fontSizes.small
    label4.font.weight: Font.Light
//    label4.wrapMode: Text.WrapAnywhere
    label4.elide: Text.ElideMiddle
    iconVisible:  control.width > Kirigami.Units.gridUnit * 15
}
