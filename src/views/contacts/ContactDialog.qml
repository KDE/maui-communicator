import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Dialog
{
    id: control

    maxWidth: Maui.Style.unit * 500
    maxHeight: Maui.Style.unit * 800

    property var contact : ({})
    defaultButtons: false

    page.margins: Maui.Style.space.large
    headBar.visible: true
    headBar.middleContent: [
        ToolButton
        {
            icon.name: "draw-star"
            text: i18n("Fav")
            checked: contact.fav == "1"
            checkable: false
            //                Kirigami.Theme.textColor: checked ? "#FFD700" : Kirigami.Theme.textColor
            //                Kirigami.Theme.backgroundColor: checked ? "#FFD700" : Kirigami.Theme.textColor
            onClicked:
            {
                contact["fav"] = contact.fav == "1" ? "0" : "1"
                list.update(contact,  view.currentIndex)
                control.contact = contact;
                _favsView.list.refresh()
            }
        },

        ToolButton
        {
            icon.name: "document-share"
            text: i18n("Share")
        }
    ]

    footBar.visible: true
    footBar.middleContent: [

        ToolButton
        {
            icon.name: "dialer-call"
            visible: contact.tel
            text: i18n("Call")
            onClicked:
            {
                if(isAndroid)
                    Maui.Android.call(contact.tel)
                else
                    Qt.openUrlExternally("call://" + contact.tel)
            }
        },

        ToolButton
        {
            icon.name: "send-email"
            visible: contact.email
            text: i18n("Email")
            onClicked:
            {
                _messageComposer.contact = control.contact
                _messageComposer.open()
            }
        },

        ToolButton
        {
            icon.name: "send-sms"
            visible: contact.tel
            text: i18n("SMS")
            onClicked:
            {
                _messageComposer.contact = control.contact
                _messageComposer.open()
            }
        }
    ]

    footBar.rightContent: Maui.ToolButtonMenu
    {
        icon.name: "overflow-menu"
        MenuItem
        {
            icon.name: "document-edit"
            text: i18n("Edit")
            onTriggered: _editContactDialog.open()
            icon.color: Kirigami.Theme.positiveTextColor
        }

        MenuItem
        {
            text: i18n("Delete")
            icon.name: "user-trash"
            icon.color: Kirigami.Theme.negativeTextColor
            onTriggered: _removeDialog.open()
        }
    }


    Maui.Dialog
    {
        id: _removeDialog

        title: i18n("Remove contact...")
        message: i18n("Are you sure you want to remove this contact? This action can not be undone.")

        acceptButton.text: i18n("Cancel")
        rejectButton.text: i18n("Remove")
        onAccepted: close()
        onRejected:
        {
            close()
            _contactDialog.close()
            list.remove(view.currentIndex)
        }
    }

    EditContactDialog
    {
        id: _editContactDialog
        contact: control.contact
        onNewContact:
        {
            var con = contact
            var id = control.contact.id
            con["id"] = id
            console.log("trying to edit contact", id)
            list.update(con, view.currentIndex)
            control.contact =  list.get(view.currentIndex)
            _editContactDialog.close()
        }

        headBar.rightContent:  Button
        {
            icon.name: "user-trash"
            //            text: i18n("Remove")
            onClicked:  _removeDialog.open()
            Kirigami.Theme.backgroundColor: Kirigami.Theme.negativeTextColor
            Kirigami.Theme.textColor: "#fff"
        }
    }

    ColumnLayout
    {
        id: _layout
        height: parent.height
        width: parent.width

        Item
        {
            id: _contactPic
            Layout.fillWidth: true
            Layout.preferredHeight: Maui.Style.iconSizes.huge * (contact.photo ? 1.5 : 1)

            Rectangle
            {
                height: Math.min(parent.height, control.width)
                width: height
                anchors.centerIn: parent
                radius: Maui.Style.radiusV* 2
                color: Qt.rgba(Math.random(),Math.random(),Math.random(),1);
                border.color: Qt.darker(color, 1.5)

                Loader
                {
                    id: _contactPicLoader
                    anchors.fill: parent
                    sourceComponent: contact.photo ? _imgComponent : _iconComponent
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

                        source: "image://contact/"+ contact.id

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
                                    radius: Maui.Style.radiusV* 2
                                }
                            }
                        }
                    }
                }

                Component
                {
                    id: _iconComponent

                    //                    Maui.ToolButton
                    //                    {
                    //                        iconName: "view-media-artist"
                    //                        size: iconSizes.big
                    //                        iconColor: "white"
                    //                    }

                    Label
                    {
                        anchors.fill: parent
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter

                        color: "white"
                        font.pointSize: Maui.Style.fontSizes.huge * 1.5
                        font.bold: true
                        font.weight: Font.Bold
                        text: contact.n ? contact.n[0] : "?"
                    }
                }

            }
        }

        //        Item
        //        {
        //            Layout.fillWidth: true
        //            Layout.preferredHeight: toolBarHeight

        //           Maui.Button
        //           {
        //               anchors.centerIn: parent
        //               icon.name: "document-edit"
        //               text: i18n("Edit")
        //               onClicked: _editContactDialog.open()
        //               colorScheme.backgroundColor: suggestedColor
        //               colorScheme.textColor: "#fff"
        //           }

        //        }


        Kirigami.ScrollablePage
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Kirigami.Theme.backgroundColor: "transparent"
            padding: 0
            leftPadding: padding
            rightPadding: padding
            topPadding: padding
            bottomPadding: padding

            ColumnLayout
            {
                id: _formLayout
                width: parent.width
                spacing: Maui.Style.space.large

                ColumnLayout
                {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    visible: contact.account
                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: i18n("Account")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.weight: Font.Light
                        color: Kirigami.Theme.textColor
                    }

                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        width: parent.width
                        text: contact.account
                        font.pointSize: Maui.Style.fontSizes.big
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                        wrapMode: Text.WrapAnywhere
                    }
                }

                ColumnLayout
                {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    visible: contact.n
                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: i18n("Name")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.weight: Font.Light
                        color: Kirigami.Theme.textColor
                    }

                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        width: parent.width
                        text: contact.n
                        font.pointSize: Maui.Style.fontSizes.big
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                    }
                }

                ColumnLayout
                {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    visible: contact.tel

                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: i18n("Phone")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.weight: Font.Light
                        color: Kirigami.Theme.textColor
                    }

                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pointSize: Maui.Style.fontSizes.big
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                        text: contact.tel

                    }
                }

                ColumnLayout
                {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    visible: contact.email

                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: i18n("Email")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.weight: Font.Light
                        color: Kirigami.Theme.textColor

                    }

                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pointSize: Maui.Style.fontSizes.big
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                        text: contact.email
                    }
                }


                ColumnLayout
                {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    visible: contact.org && contact.org.length

                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: i18n("Organization")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.weight: Font.Light
                        color: Kirigami.Theme.textColor
                    }

                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        width: parent.width
                        text: contact.org
                        font.pointSize: Maui.Style.fontSizes.big
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                    }
                }

                ColumnLayout
                {
                    visible: contact.title && contact.title.length
                    Layout.fillWidth: visible
                    spacing: Maui.Style.space.small

                    Label
                    {
                        Layout.fillHeight: parent.visible
                        Layout.fillWidth: parent.visible
                        text: i18n("Title")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.weight: Font.Light
                        color: Kirigami.Theme.textColor
                    }

                    Label
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        width: parent.width
                        text: parent.visible ? contact.title : undefined
                        font.pointSize: Maui.Style.fontSizes.big
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                    }
                }
            }
        }

    }


    function show(data)
    {
        control.contact = data
        console.log("curent itemn account", data.account, data.type)
        control.open()
    }
}
