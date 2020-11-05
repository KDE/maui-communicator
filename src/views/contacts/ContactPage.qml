import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
    id: control
    property var contact : ({})

    property bool editing : Object.keys(contact).length === 0

    signal contactEdited(var contact)

    floatingHeader: true
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
                list.update(contact,  _contactsPage.currentIndex)
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

    footBar.visible: control.editing

    footerColumn: Maui.ToolBar
    {
        visible: !control.editing
        width: parent.width
        position: ToolBar.Footer
        rightContent: Maui.ToolButtonMenu
        {
            icon.name: "overflow-menu"
            MenuItem
            {
                icon.name: "document-edit"
                text: i18n("Edit")
                onTriggered: control.editing = !control.editing
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

        middleContent: [

            ToolButton
            {
                icon.name: "dialer-call"
                visible: contact.tel
                text: i18n("Call")
                onClicked:
                {
                    if(Maui.Handy.isAndroid)
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
                    _dialogLoader.sourceComponent =  _messageComposerComponent
                    dialog.contact = control.contact
                    dialog.open()
                }
            },

            ToolButton
            {
                icon.name: "send-sms"
                visible: contact.tel
                text: i18n("SMS")
                onClicked:
                {
                    _dialogLoader.sourceComponent =  _messageComposerComponent
                    dialog.contact = control.contact
                    dialog.open()
                }
            }
        ]
    }

    footBar.leftContent: Button
    {
        visible: control.editing
        text: i18n("Cancel")
        onClicked: control.editing = !control.editing
    }

    footBar.rightContent: [

        Button
        {
            visible: control.editing
            text: i18n("Edit")
            onClicked: control.editing = !control.editing
        },

        Button
        {
            visible: control.editing
            text: i18n("Save")
            onClicked:
            {
                var contact = control.contact
                contact.n = _nameField.text,
                contact.tel =_telField.text,
                contact.email = _emailField.text,
                contact.org = _orgField.text,
                //                          adr: _adrField.text,
                contact.photo = control.contact.photo,
                contact.account = Maui.Handy.isAndroid ? _accountsCombobox.model[_accountsCombobox.currentIndex] :({})

                if(contact.n.length && contact.tel.length)
                    control.contactEdited(contact)

                control.contact = contact
                control.editing = false

            }
        }
    ]

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
            list.remove(_contactsPage.currentIndex)
        }
    }

    Kirigami.ScrollablePage
    {
        anchors.fill: parent
        Kirigami.Theme.backgroundColor: "transparent"
        padding: 0
        leftPadding: padding
        rightPadding: padding
        topPadding: padding
        bottomPadding: padding
        flickable.bottomMargin: Maui.Style.space.big

        ColumnLayout
        {
            id: _formLayout
            width: parent.width
            spacing: Maui.Style.space.big

            Item
            {
                id: _contactPic
                Layout.fillWidth: true
                Layout.preferredHeight: 200

                Rectangle
                {
                    color: "pink"
                    //                    radius: Maui.Style.radiusV * 4
                    height: parent.height / 2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top/*
                    anchors.topMargin: 0
                    anchors.margins: Maui.Style.space.big*/
                }

                Rectangle
                {
                    height: Maui.Style.iconSizes.huge * 1.5
                    width: height
                    anchors.centerIn: parent
                    radius: Maui.Style.radiusV
                    color: Qt.rgba(Math.random(),Math.random(),Math.random(),1);
                    border.color: Qt.darker(color, 1.5)

                    MouseArea
                    {
                        visible: control.editing
                        anchors.fill: parent
                        onClicked:
                        {
                            _dialogLoader.sourceComponent = _fileDialogComponent

                            dialog.show(function(paths)
                            {
                                console.log("selected image", paths)
                                contact.photo = paths[0]
                                _contactPicLoader.sourceComponent = _imgComponent
                                _contactPicLoader.item.source = contact.photo
                            })
                        }
                    }

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
                            text: contact.n ? contact.n[0] : "+"
                        }
                    }

                }
            }


            Maui.ListItemTemplate
            {
                visible: contact.account || control.editing

                Layout.maximumWidth: 500
                Layout.minimumWidth: 100
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: leftLabels.implicitHeight
                label1.text: i18n("Account")
                label1.font.pointSize: Maui.Style.fontSizes.default
                label1.font.weight: Font.Light
                label2.visible: !control.editing
                label2.text: contact.account || ""
                label2.font.pointSize: Maui.Style.fontSizes.big
                label2.font.weight: Font.Bold
                label2.wrapMode: Text.WrapAnywhere

                leftLabels.data: ComboBox
                {
                    id: _accountsCombobox
                    visible: control.editing
                    textRole: "account"
                    popup.z: control.z +1
                    width: parent.width
                }
            }

            Maui.ListItemTemplate
            {
                visible: contact.n || control.editing

                Layout.maximumWidth: 500
                Layout.minimumWidth: 100
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: leftLabels.implicitHeight
                label1.text: i18n("Name")
                label1.font.pointSize: Maui.Style.fontSizes.default
                label1.font.weight: Font.Light
                label2.visible: !control.editing
                label2.text: contact.n || ""
                label2.font.pointSize: Maui.Style.fontSizes.big
                label2.font.weight: Font.Bold
                label2.wrapMode: Text.WrapAnywhere

                leftLabels.data: Maui.TextField
                {
                    id: _nameField
                    visible: control.editing
                    Layout.fillWidth: true
                    text: contact.n || ""
                }
            }

            Maui.ListItemTemplate
            {
                visible: contact.tel || control.editing

                Layout.maximumWidth: 500
                Layout.minimumWidth: 100
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: leftLabels.implicitHeight
                label1.text: i18n("Phone")
                label1.font.pointSize: Maui.Style.fontSizes.default
                label1.font.weight: Font.Light
                label2.visible: !control.editing
                label2.text: contact.tel || ""
                label2.font.pointSize: Maui.Style.fontSizes.big
                label2.font.weight: Font.Bold
                label2.wrapMode: Text.WrapAnywhere
                leftLabels.data: Maui.TextField
                {
                    visible: control.editing
                    id: _telField
                    Layout.fillWidth: true
                    text: contact.tel || ""
                }
            }

            Maui.ListItemTemplate
            {
                visible: contact.email || control.editing

                Layout.maximumWidth: 500
                Layout.minimumWidth: 100
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: leftLabels.implicitHeight
                label1.text: i18n("Email")
                label1.font.pointSize: Maui.Style.fontSizes.default
                label1.font.weight: Font.Light
                label2.visible: !control.editing
                label2.text: contact.email || ""
                label2.font.pointSize: Maui.Style.fontSizes.big
                label2.font.weight: Font.Bold
                label2.wrapMode: Text.WrapAnywhere
                leftLabels.data: Maui.TextField
                {
                    id: _emailField
                    visible: control.editing
                    Layout.fillWidth: true
                    text: contact.email || ""
                }
            }


            Maui.ListItemTemplate
            {
                visible: contact.org || control.editing

                Layout.maximumWidth: 500
                Layout.minimumWidth: 100
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: leftLabels.implicitHeight
                label1.text: i18n("Organization")
                label1.font.pointSize: Maui.Style.fontSizes.default
                label1.font.weight: Font.Light
                label2.visible: !control.editing
                label2.text: contact.org || ""
                label2.font.pointSize: Maui.Style.fontSizes.big
                label2.font.weight: Font.Bold
                label2.wrapMode: Text.WrapAnywhere
                leftLabels.data: Maui.TextField
                {
                    id: _orgField
                    visible: control.editing
                    Layout.fillWidth: true
                    text: contact.org || ""
                }
            }

            Maui.ListItemTemplate
            {
                visible: contact.title || control.editing

                Layout.maximumWidth: 500
                Layout.minimumWidth: 100
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: leftLabels.implicitHeight
                label1.text: i18n("Title")
                label1.font.pointSize: Maui.Style.fontSizes.default
                label1.font.weight: Font.Light
                label2.visible: !control.editing
                label2.text: contact.title || ""
                label2.font.pointSize: Maui.Style.fontSizes.big
                label2.font.weight: Font.Bold
                label2.wrapMode: Text.WrapAnywhere
                leftLabels.data: Maui.TextField
                {
                    visible: control.editing
                    Layout.fillWidth: true
                    text: contact.title || ""
                }
            }
        }
    }

    function clear()
    {
        _nameField.clear()
        _telField.clear()
        _emailField.clear()
        _orgField.clear()
        //        _adrField.clear()
        //        _img.source = ""
        _contactPicLoader.sourceComponent = _iconComponent
        control.close()

    }

    Component.onCompleted:
    {
        var androidAccounts = _contacsView.list.getAccounts();
        _accountsCombobox.model = androidAccounts;
    }
}
