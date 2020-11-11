import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami

Rectangle
{
    id: control
    property var contact : ({})

    property bool editing : Object.keys(contact).length === 0

    signal contactEdited(var contact)
    signal editCanceled()

    property alias headBar : _cardPage.headBar

    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false

    color: Kirigami.Theme.backgroundColor

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

    Rectangle
    {
        id: _cardLayout
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.inherit: false

        width: Math.floor(Math.min(500, parent.width * 0.95))
        height: Math.floor(parent.height * 0.95)
        anchors.centerIn: parent

        radius: Maui.Style.radiusV
        color: Kirigami.Theme.backgroundColor

        Maui.Page
        {
            id: _cardPage
            anchors.fill: parent
            footBar.visible: control.editing
            headBar.visible: true
            floatingHeader: true

            headerBackground.color: "transparent"

            headBar.rightContent: [
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

                Maui.ToolButtonMenu
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
            ]

            footBar.leftContent: Button
            {
                visible: control.editing
                text: i18n("Cancel")
                onClicked:
                {
                    control.editing = false
                    editCanceled()
                }
            }

            footBar.rightContent: [

                Button
                {
                    visible: control.editing
                    text: i18n("Save")
                    onClicked:
                    {
                        var contact = control.contact
                        contact.n = _nameField.text
                        contact.tel =_telField.text
                        contact.email = _emailField.text
                        contact.org = _orgField.text
                        //                          adr: _adrField.text,
                        contact.photo = control.contact.photo
                        contact.account = Maui.Handy.isAndroid ? _accountsCombobox.model[_accountsCombobox.currentIndex] :({})

                        control.contactEdited(contact)
                        control.contact = contact
                        control.editing = false
                    }
                }
            ]

            Kirigami.ScrollablePage
            {
                anchors.fill: parent
                Kirigami.Theme.backgroundColor: "transparent"
                padding: 0
                leftPadding: padding
                rightPadding: padding
                topPadding: padding
                bottomPadding: padding
                flickable.bottomMargin: Maui.Style.space.huge
                contentHeight: _formLayout.implicitHeight
                background: Item {}

                ColumnLayout
                {
                    id: _formLayout
                    width: parent.width
                    spacing: Maui.Style.space.big

                    Item
                    {
                        id: _contactPic
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160

                        Item
                        {
                            height: parent.height / 2
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top

                            Image
                            {
                                id: artworkBg
                                height: parent.height
                                width: parent.width

                                sourceSize.width: 100
                                sourceSize.height: height

                                fillMode: Image.PreserveAspectCrop
                                antialiasing: true
                                smooth: true
                                asynchronous: true
                                cache: true

                                source: contact.photo ? _contactPicLoader.item.source : _iconComponent
                            }

                            FastBlur
                            {
                                id: fastBlur
                                anchors.fill: parent
                                source: artworkBg
                                radius: 100
                                transparentBorder: false
                                cached: true

                                Rectangle
                                {
                                    anchors.fill: parent
                                    color: Kirigami.Theme.backgroundColor
                                    opacity: 0.7
                                }
                            }

                            Maui.Separator
                            {
                                position: Qt.Horizontal
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                            }
                        }

                        Rectangle
                        {
                            id: _contactPhotoColor
                            height: Maui.Style.iconSizes.huge * 1.5
                            width: height
                            anchors.centerIn: parent
                            radius: Maui.Style.radiusV
                            color: Qt.rgba(Math.random(),Math.random(),Math.random(),1);
                            border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))

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
                                anchors.margins: 1
                                sourceComponent: contact.photo ? _imgComponent : _iconComponent
                            }

                            Component
                            {
                                id: _imgComponent

                                Image
                                {
                                    id: _img

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
                                                radius: Maui.Style.radiusV
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


                    ContactField
                    {
                        visible: contact.account || control.editing
                        editing: control.editing

                        Layout.maximumWidth: 500
                        Layout.minimumWidth: 100
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        label1.text: i18n("Account")
                        label2.text: contact.account || ""

                        iconSource: "password-show-on"

                        leftLabels.data: ComboBox
                        {
                            id: _accountsCombobox
                            visible: control.editing
                            textRole: "account"
                            popup.z: control.z +1
                            width: parent.width
                        }
                    }

                    ContactField
                                        {
                        visible: contact.n || control.editing
                        editing: control.editing

                        Layout.maximumWidth: 500
                        Layout.minimumWidth: 100
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        label1.text: i18n("Name")
                        label2.text: contact.n || ""

                        iconSource: "im-user"

                        leftLabels.data: Maui.TextField
                        {
                            id: _nameField
                            visible: control.editing
                            Layout.fillWidth: true
                            text: contact.n || ""
                        }
                    }

                    ContactField
                    {
                        visible: contact.tel || control.editing

                        editing: control.editing
                        Layout.maximumWidth: 500
                        Layout.minimumWidth: 100
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        label1.text: i18n("Phone")
                        label2.text: contact.tel || ""
                        iconSource: "call-start"

                        leftLabels.data: Maui.TextField
                        {
                            visible: control.editing
                            id: _telField
                            Layout.fillWidth: true
                            text: contact.tel || ""
                        }

                        Action
                        {
                            icon.name: "message-new"
                            text: i18n("Message")
                            icon.color: Kirigami.Theme.textColor
                            onTriggered:
                            {
                                _dialogLoader.sourceComponent =  _messageComposerComponent
                                dialog.contact = control.contact
                                dialog.open()
                            }
                        }

                        Action
                        {
                            enabled: Kirigami.Settings.isMobile
                            icon.name: "call-start"
                            text: i18n("Call")
                            icon.color: Kirigami.Theme.textColor

                            onTriggered:
                            {
                                if(Maui.Handy.isAndroid)
                                    Maui.Android.call(model.tel)
                                else
                                    Qt.openUrlExternally("call://" + model.tel)

                            }
                        }

                        Action
                        {
                            icon.name: "edit-copy"
                            text: i18n("Copy")
                            icon.color: Kirigami.Theme.textColor
                            onTriggered:
                            {
                                Maui.Handy.copyTextToClipboard(control.contact.tel)
                            }
                        }

                    }


                    ContactField
                    {
                        visible: contact.email || control.editing
                        editing: control.editing

                        Layout.maximumWidth: 500
                        Layout.minimumWidth: 100
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        label1.text: i18n("Email")
                        label2.text: contact.email || ""
                        iconSource: "mail-message"

                        leftLabels.data: Maui.TextField
                        {
                            id: _emailField
                            visible: control.editing
                            Layout.fillWidth: true
                            text: contact.email || ""
                        }

                        Action
                        {
                            icon.name: "message-new"
                            text: i18n("Message")
                            icon.color: Kirigami.Theme.textColor
                            onTriggered:
                            {
                                _dialogLoader.sourceComponent =  _messageComposerComponent
                                dialog.contact = control.contact
                                dialog.open()
                            }
                        }

                        Action
                        {
                            icon.name: "edit-copy"
                            text: i18n("Copy")
                            icon.color: Kirigami.Theme.textColor
                            onTriggered:
                            {
                                Maui.Handy.copyTextToClipboard(control.contact.tel)
                            }
                        }
                    }


                    ContactField
                    {
                        visible: contact.org || control.editing
                        editing: control.editing

                        Layout.maximumWidth: 500
                        Layout.minimumWidth: 100
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        label1.text: i18n("Organization")
                        label2.text: contact.org || ""

                        iconSource: "roll"

                        leftLabels.data: Maui.TextField
                        {
                            id: _orgField
                            visible: control.editing
                            Layout.fillWidth: true
                            text: contact.org || ""
                        }
                    }

                    ContactField
                    {
                        visible: contact.title || control.editing
                        editing: control.editing

                        Layout.maximumWidth: 500
                        Layout.minimumWidth: 100
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        label1.text: i18n("Title")
                        label2.text: contact.title || ""

                        iconSource: "actor"

                        leftLabels.data: Maui.TextField
                        {
                            visible: control.editing
                            Layout.fillWidth: true
                            text: contact.title || ""
                        }
                    }
                }
            }

            layer.enabled: true
            layer.effect: OpacityMask
            {
                maskSource: Item
                {
                    width: _cardLayout.width
                    height: _cardLayout.height

                    Rectangle
                    {
                        anchors.centerIn: parent
                        width: _cardLayout.width
                        height: _cardLayout.height
                        radius: Maui.Style.radiusV
                    }
                }
            }
        }

        Rectangle
        {
            anchors.fill: parent
            radius: Maui.Style.radiusV
            color: "transparent"
            border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))
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
