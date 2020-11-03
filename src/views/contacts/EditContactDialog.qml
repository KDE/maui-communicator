import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
    id: control

    property var contact : ({})
    signal newContact(var contact)



//    onAccepted:
//    {
//        var contact =({
//                          n: _nameField.text,
//                          tel: _telField.text,
//                          email: _emailField.text,
//                          org: _orgField.text,
//                          //                          adr: _adrField.text,
//                          photo: control.contact.photo,
//                          account: Maui.Handy.isAndroid ? _accountsCombobox.model[_accountsCombobox.currentIndex] :({})
//                      })

//        if(contact.n.length && contact.tel.length)
//            newContact(contact)
//        control.clear()
//    }


    ColumnLayout
    {
        id: _layout
        anchors.fill:parent

        Item
        {
            id: _contactPic
            Layout.fillWidth: true
            Layout.preferredHeight: Maui.Style.iconSizes.huge

            Rectangle
            {
                height: Math.min(parent.height, control.width)
                width: height
                anchors.centerIn: parent
                radius: Maui.Style.radiusV* 2
                color: Qt.rgba(Math.random(),Math.random(),Math.random(),1);
                border.color: Qt.darker(color, 1.5)

                MouseArea
                {
                    anchors.fill: parent
                    onClicked:{

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
                        text: "+"
                    }
                }
            }
        }

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
            //                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout
            {
                id: _formLayout
                width: _layout.width * 0.95
                //                    implicitHeight: control.height
                spacing: Maui.Style.space.large

                Column
                {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    visible: Maui.Handy.isAndroid
                    Label
                    {
                        text: i18n("Account")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.bold: true
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                    }

                    ComboBox
                    {
                        id: _accountsCombobox
                        textRole: "account"
                        popup.z: control.z +1
                        width: parent.width
                    }
                }

                Column
                {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    Label
                    {
                        text: i18n("Name")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.bold: true
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                    }

                    Maui.TextField
                    {
                        id: _nameField
                        width: parent.width
                        text: contact.n
                    }
                }

                Column
                {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    Label
                    {
                        text: i18n("Phone")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.bold: true
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                    }

                    Maui.TextField
                    {
                        id: _telField
                        width: parent.width
                        text: contact.tel
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }

                Column
                {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    Label
                    {
                        text: i18n("Email")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.bold: true
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                    }

                    Maui.TextField
                    {
                        id: _emailField
                        width: parent.width
                        text: contact.email
                    }
                }

                Column
                {
                    Layout.fillWidth: true
                    spacing: Maui.Style.space.small
                    Label
                    {
                        text: i18n("Organization")
                        font.pointSize: Maui.Style.fontSizes.default
                        font.bold: true
                        font.weight: Font.Bold
                        color: Kirigami.Theme.textColor
                    }

                    Maui.TextField
                    {
                        id: _orgField
                        width: parent.width
                        text: contact.org
                    }
                }


                //                    Column
                //                    {
                //                        Layout.fillWidth: true
                //                        spacing: space.small
                //                        Label
                //                        {
                //                            text: i18n("Phone")
                //                            font.pointSize: fontSizes.default
                //                            font.bold: true
                //                            font.weight: Font.Bold
                //                        }

                //                        Maui.TextField
                //                        {
                //                            width: parent.width
                //                            text: contact.tel
                //                            inputMethodHints: Qt.ImhDigitsOnly
                //                        }
                //                    }



                //                    Column
                //                    {
                //                        Layout.fillWidth: true
                //                        spacing: space.small
                //                        Label
                //                        {
                //                            text: i18n("Address")
                //                            font.pointSize: fontSizes.default
                //                            font.bold: true
                //                            font.weight: Font.Bold
                //                            color: textColor
                //                        }

                //                        Maui.TextField
                //                        {
                //                            id: _adrField
                //                            width: parent.width
                //                            text: contact.adr
                //                        }
                //                    }
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
