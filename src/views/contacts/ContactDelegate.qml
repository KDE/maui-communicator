import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.9 as Kirigami

Maui.SwipeBrowserDelegate
{
    id: control
    hoverEnabled: true
    clip: true
    Kirigami.Theme.colorSet: Kirigami.Theme.Button
//    Kirigami.Theme.inherit: false

    draggable: true
//    property alias showMenuIcon: showQuickActions

    signal favClicked(int index)

    property int radius : Maui.Style.radiusV * 2

    iconSizeHint: Maui.Style.iconSizes.huge
    label1.text: model.n
    label1.font.pointSize: Maui.Style.fontSizes.big
    label1.font.bold: true
    label1.font.weight: Font.Bold
    label1.elide: Text.ElideMiddle

    label2.text: model.tel
    label2.font.pointSize: Maui.Style.fontSizes.small
    label2.font.weight: Font.Light
    label2.wrapMode: Text.WrapAnywhere
    label2.elide: Text.ElideMiddle

    label3.text: model.email
    label3.font.pointSize: Maui.Style.fontSizes.small
    label3.font.weight: Font.Light
    label3.wrapMode: Text.WrapAnywhere
    label3.elide: Text.ElideMiddle

    label4.text: model.title
    label4.font.pointSize: Maui.Style.fontSizes.small
    label4.font.weight: Font.Light
    label4.wrapMode: Text.WrapAnywhere
    label4.elide: Text.ElideMiddle
iconVisible:  control.width > Kirigami.Units.gridUnit * 15
    template.iconComponent:  Item
    {
        id: _contactPic

        Rectangle
        {
            height: parent.height * 0.7
            width: height
            anchors.centerIn: parent
            radius: control.radius
            color:
            {
                var c = Qt.rgba(Math.random(),Math.random(),Math.random(),1)
                return Qt.hsla(c.hslHue, 0.7, c.hslLightness, c.a);
            }

            //                    color: Qt.hsl(Math.random(),Math.random(),Math.random(),1);
            //                    color: "hsl(" + 360 * Math.random() + ',' +
            //                           (25 + 70 * Math.random()) + '%,' +
            //                           (85 + 10 * Math.random()) + '%)';
            border.color: Qt.darker(color, 1.5)


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

                    source:  "image://contact/"+ model.id

                    layer.enabled: true
                    layer.effect: OpacityMask
                    {
                        maskSource: Item
                        {
                            width: _img.width
                            height: _img.height

                            Rectangle
                            {
                                anchors.centerIn: parent
                                width: _img.width
                                height: _img.height
                                radius: control.radius
                            }
                        }
                    }
                }
            }

            Component
            {
                id: _iconComponent

                Label
                {
                    anchors.fill: parent
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    color: "white"
                    font.pointSize: Maui.Style.fontSizes.huge
                    font.bold: true
                    font.weight: Font.Bold
                    text: model.n[0].toUpperCase()
                }
            }

        }
    }


    quickActions: [
        Action
        {
            icon.name: "draw-star"
            onTriggered:
            {
                control.favClicked(index)
            }

            icon.color: model.fav == "1" ? "yellow" : Kirigami.Theme.textColor
        },

        Action
        {
            icon.name: "document-share"
            onTriggered: if(Maui.Handy.isAndroid) Maui.Android.shareContact(model.id)
            icon.color: Kirigami.Theme.textColor
        },

        Action
        {
            icon.name: "message-new"
            icon.color: Kirigami.Theme.textColor
            onTriggered:
            {
                _dialogLoader.sourceComponent =  _messageComposerComponent
                dialog.contact = list.get(index)
                dialog.open()
            }
        },

        Action
        {
            icon.name: "call-start"
            icon.color: Kirigami.Theme.textColor

            onTriggered:
            {
                if(Maui.Handy.isAndroid)
                    Maui.Android.call(model.tel)
                else
                    Qt.openUrlExternally("call://" + model.tel)

            }
        }
    ]

}
