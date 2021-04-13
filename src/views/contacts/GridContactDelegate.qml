import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.mauikit.controls 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami

Maui.ItemDelegate
{
    id: control
    property bool showMenuIcon: false
    signal favClicked(int index)

    Kirigami.Theme.inherit: false
    Kirigami.Theme.backgroundColor: "#333";
    Kirigami.Theme.textColor: "#fafafa"

    ToolButton
    {
        anchors
        {
            top: parent.top
            right: parent.right
            margins: Maui.Style.space.medium
        }

        icon.color: "#fff"
        visible: showMenuIcon
        icon.name: "overflow-menu"
        //        onClicked: swipe.position < 0 ? swipe.close() : swipe.open(SwipeDelegate.Right)

    }

    Rectangle
    {
        id: _cover
        anchors.fill: parent
        radius: Maui.Style.radiusV
        color: Kirigami.Theme.backgroundColor
        //        {
        //            var c = Qt.rgba(Math.random(),Math.random(),Math.random(),1)
        //            return Qt.hsla(c.hslHue, 0.7, c.hslLightness, c.a);
        //        }

        Loader
        {
            id: _contactPicLoader
            anchors.fill: parent
            sourceComponent: model.photo ? _imgComponent : _iconComponent
        }

        Component
        {
            id: _imgComponent

            Image
            {
                id: _img
                width: parent.width
                height: width

                anchors.centerIn: parent

                sourceSize.width: parent.width
                sourceSize.height: parent.height

                fillMode: Image.PreserveAspectCrop
                cache: true
                antialiasing: true
                smooth: true
                asynchronous: true

                source: "image://contact/"+ model.id
            }
        }
        Component
        {
            id: _iconComponent

            Label
            {
                anchors.fill: parent
                anchors.centerIn: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter

                color: "#fff"
                font.pointSize: Maui.Style.fontSizes.enormous * 3
                font.bold: true
                font.weight: Font.Bold
                text: model.n[0].toUpperCase()
            }
        }

        Item
        {
            id: _labelBg
            height: Math.min (parent.height * 0.3, _labelsLayout.implicitHeight ) + Maui.Style.space.big
            width: parent.width
            anchors.bottom: parent.bottom

            Rectangle
            {
                anchors.fill: parent
                color: control.isCurrentItem ? Kirigami.Theme.highlightColor : _labelBg.Kirigami.Theme.backgroundColor
                opacity: control.isCurrentItem || control.hovered ? 1 : 0.7
            }

            Maui.ListItemTemplate
            {
                id: _labelsLayout
                anchors.centerIn: parent
                width: parent.width * 0.9
                height: Math.min(parent.height * 0.9, implicitHeight)
                implicitHeight: label1.implicitHeight + label2.implicitHeight + spacing

                label1.font.pointSize: Maui.Style.fontSizes.big
                label1.text: model.n
                //                label2.text: model.tel

                label1.visible: label1.text && control.width > 50
                label1.font.bold: true
                label1.font.weight: Font.Bold
                label1.wrapMode: Text.WordWrap

                label2.visible: label2.text && (control.width > 70)
                label2.font.pointSize: Maui.Style.fontSizes.medium
                label2.wrapMode: Text.NoWrap
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask
        {
            maskSource: Item
            {
                width: _cover.width
                height: _cover.height

                Rectangle
                {
                    anchors.centerIn: parent
                    width: _cover.width
                    height: _cover.height
                    radius: Maui.Style.radiusV
                }
            }
        }
    }

    Rectangle
    {
        anchors.centerIn: _cover

        width: _cover.width
        height:  _cover.height

        color: "transparent"
        border.color: control.isCurrentItem || control.hovered ? Kirigami.Theme.highlightColor : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
        radius: Maui.Style.radiusV
        opacity: 0.6

        Rectangle
        {
            anchors.fill: parent
            color: "transparent"
            radius: parent.radius - 0.5
            border.color: Qt.lighter(Kirigami.Theme.backgroundColor, 2)
            opacity: 0.8
            anchors.margins: 1
        }
    }

}
