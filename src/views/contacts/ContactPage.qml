import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import org.mauikit.controls  as Maui

Maui.PopupPage
{
    id: control
    autoClose: false

    maxWidth: 500
    maxHeight: 800

    property var contact : ({})

    property bool editing : Object.keys(contact).length === 0

    signal contactEdited(var contact)
    signal editCanceled()

    actionBar.visible: control.editing

    filling: !isWide

    page.footBar.visible: control.editing
    page.headBar.visible: true

    Maui.Theme.colorSet: Maui.Theme.Window
    Maui.Theme.inherit: false

    headBar.background: null

    headBar.rightContent: [
        ToolButton
        {
            icon.name: "draw-star"
            text: i18n("Fav")
            checked: contact.fav == "1"
            checkable: false
            //                Maui.Theme.textColor: checked ? "#FFD700" : Maui.Theme.textColor
            //                Maui.Theme.backgroundColor: checked ? "#FFD700" : Maui.Theme.textColor
            onClicked:
            {
                contact["fav"] = contact.fav == "1" ? "0" : "1"
                list.update(contact, listModel.mappedToSource(list.currentIndex))
                control.contact = contact;
                //                _favsView.list.refresh()
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
            }

            MenuItem
            {
                text: i18n("Delete")
                icon.name: "user-trash"
                icon.color: Maui.Theme.negativeTextColor
                onTriggered: _removeDialog.open()
            }
        }
    ]


    actions: [
        Action
        {
            text: i18n("Save")
            onTriggered:
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
        },
        Action
        {
            text: i18n("Cancel")
            onTriggered:
            {
                control.editing = false
                editCanceled()
            }
        }
    ]

    Maui.InfoDialog
    {
        id: _removeDialog

        title: i18n("Remove contact...")
        message: i18n("Are you sure you want to remove this contact? This action can not be undone.")

        standardButtons: Dialog.Yes | Dialog.No

        onRejected: close()
        onAccepted:
        {
            list.remove(listModel.mappedToSource(list.currentIndex))
            control.close()
        }
    }



    Item
    {
        id: _contactPic
        Layout.fillWidth: true
        Layout.preferredHeight: 160

        Rectangle
        {
            id: _contactPhotoColor
            height: Maui.Style.iconSizes.huge * 1.5
            width: height
            anchors.centerIn: parent
            radius: Maui.Style.radiusV
            color: Qt.rgba(Math.random(),Math.random(),Math.random(),1);

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
                asynchronous: true
                anchors.fill: parent
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
                    layer.effect: MultiEffect
                    {
                        maskEnabled: true
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

        content: ComboBox
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

        content: TextField
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

        content: TextField
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
            icon.color: Maui.Theme.textColor
            onTriggered:
            {
                _dialogLoader.sourceComponent =  _messageComposerComponent
                dialog.contact = control.contact
                dialog.open()
            }
        }

        Action
        {
            enabled: Maui.Handy.isMobile
            icon.name: "call-start"
            text: i18n("Call")
            icon.color: Maui.Theme.textColor

            onTriggered:
            {
                _communicator.call(control.contact.tel)
            }
        }

        Action
        {
            icon.name: "edit-copy"
            text: i18n("Copy")
            icon.color: Maui.Theme.textColor
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

        content: TextField
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
            icon.color: Maui.Theme.textColor
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
            icon.color: Maui.Theme.textColor
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

        content: TextField
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

        content: TextField
        {
            visible: control.editing
            Layout.fillWidth: true
            text: contact.title || ""
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

    onClosed:
    {
        control.contact = ({})
        _dialogLoader.sourceComponent = null
    }
}
