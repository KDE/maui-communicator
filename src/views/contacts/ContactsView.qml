import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.mauikit.controls 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import org.maui.communicator 1.0

StackView
{
    id: control

    property alias list : _contactsList
    property alias listModel : _contactsModel
    property alias holder : _contactsPage.holder
    property alias viewType: _contactsPage.viewType

    property bool showAccountFilter: false
    property bool showNewButton: false

    property var currentContact : ({})

    initialItem: Maui.AltBrowser
    {
        id: _contactsPage
        holder.visible: !currentView.count
        holder.emojiSize: Maui.Style.iconSizes.huge
        headBar.visible: true
        //        onActionTriggered: _newContactDialog.open()

        model: Maui.BaseModel
        {
            id: _contactsModel
            list: ContactsList
            {
                id: _contactsList
            }
            sort: "n"
            sortOrder: Qt.AscendingOrder
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        headBar.leftContent: ToolButton
        {
            enabled: _contactsList.count > 0
           icon.name: _contactsPage.viewType === Maui.AltBrowser.ViewType.List ? "view-list-icons" : "view-list-details"

            onClicked:
            {
                _contactsPage.viewType =  _contactsPage.viewType === Maui.AltBrowser.ViewType.List ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List
            }
        }

        headBar.middleContent: Maui.TextField
        {
            id: _searchField
            Layout.fillWidth: true
            Layout.maximumWidth: 500
            focusReason : Qt.PopupFocusReason
            placeholderText: i18n("Search %1 contacts", _contactsList.count)
            onAccepted: _contactsModel.filter = text
            onCleared: _contactsModel.filter = ""
        }

        headBar.rightContent: ToolButton
        {
            visible: control.showNewButton

            icon.name: "list-add-user"
            onClicked:
            {
                control.openContact(({}))
            }
        }

        gridView.itemSize: 140

        listView.spacing: Maui.Style.space.big
        listView.flickable.header: Item
        {
            visible: showAccountFilter
            height: visible ? Maui.Style.toolBarHeight * 1.5 : 0
            width: visible ? parent.width : 0
            ComboBox
            {
                id: _accountsCombobox
                width: isWide ? control.width * 0.8 : control.width * 0.95
                textRole: "account"
                anchors.centerIn: parent

                onActivated:
                {

                    console.log("filter by:"+currentText)
                    if(currentText === "All")
                        list.reset()
                    else
                        list.query = "account="+currentText

                    positionViewAtBeginning()
                }

                Component.onCompleted:
                {
                    var androidAccounts = [{account: "All"}]
                    var accounts = []
                    accounts = list.getAccounts()

                    for(var i in accounts)
                        androidAccounts.push(accounts[i])
                    _accountsCombobox.model = androidAccounts;
                }

            }

        }

        listView.section.property: "n"
        listView.section.criteria: ViewSection.FirstCharacter
        listView.section.labelPositioning: ViewSection.InlineLabels
        listView.section.delegate: Maui.LabelDelegate
        {
            label: section.toUpperCase()
            isSection: true
            width: parent.width
            opacity: 0.6
        }

        gridDelegate: Item
        {
            width: _contactsPage.gridView.cellWidth
            height: _contactsPage.gridView.cellHeight

            property bool isCurrentItem : GridView.isCurrentItem

            GridContactDelegate
            {
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium
                isCurrentItem: parent.isCurrentItem

                onClicked:
                {
                    _contactsPage.currentIndex = index

                    if(Maui.Handy.singleClick)
                    {
                        openContact(_contactsModel.get(index))
                    }
                }

                onDoubleClicked:
                {
                    _contactsPage.currentIndex = index

                    if(!Maui.Handy.singleClick)
                    {
                        openContact(_contactsModel.get(index))
                    }
                }

                onFavClicked:
                {
                    var item = _contactsList.get(index)
                    item["fav"] = item.fav == "1" ? "0" : "1"
                    _contactsList.update(item, index)
                }
            }
        }

        listDelegate: ContactDelegate
        {
            height: Maui.Style.unit * 60
            width: Math.min(isWide ? ListView.view.width * 0.8 : ListView.view.width, 500)
            anchors.horizontalCenter: parent.horizontalCenter
            showQuickActions: true

            template.iconComponent: Item
            {
                id: _contactPic

                Rectangle
                {
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    Kirigami.Theme.inherit: false
                    height: parent.height * 0.8
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Maui.Style.radiusV
                    color: Kirigami.Theme.backgroundColor
                    border.color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.7))

                    Loader
                    {
                        id: _contactPicLoader
                        anchors.fill: parent
                        anchors.margins: 1
                        sourceComponent: model.photo ? _imgComponent : _iconComponent
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
                            color: Kirigami.Theme.textColor
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
                    enabled: Kirigami.Settings.isMobile
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
            onClicked:
            {
                _contactsPage.currentIndex = index

                if(Maui.Handy.singleClick)
                {
                    openContact(_contactsModel.get(index))
                }
            }

            onDoubleClicked:
            {
                _contactsPage.currentIndex = index

                if(!Maui.Handy.singleClick)
                {
                    openContact(_contactsModel.get(index))
                }
            }

            onFavClicked:
            {
                var item = _contactsList.get(index)
                item["fav"] = item.fav == "1" ? "0" : "1"
                _contactsList.update(item, index)
            }
        }
    }

    Component
    {
        id: _contactPageComponent

        ContactPage
        {
            id: _contactPage
            contact: control.currentContact
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked:
                {
                    if(editing)
                    {
                        _confirmExit.open()

                    }else
                    {
                         control.pop()
                    }
                }
            }

            Maui.Dialog
            {
                id: _confirmExit
                title: i18n("Discard")
                message: i18n("If you chose to exit the changes made will be lost. Click Discard to exit or cancel to go back and save the changes")

                acceptButton.text : i18n("Cancel")
                rejectButton.text : i18n("Discard")

                onAccepted: close()
                onRejected:
                {
                    _contactPage.editing = false

                    if(!_contactPage.contact.id)
                    {
                        control.pop()
                    }

                    _confirmExit.close()
                }
            }

            onEditCanceled:
            {
                if(!contact.id)
                {
                    control.pop()
                }
            }

            onContactEdited:
            {
                console.log(contact.id)

                if(contact.n.length && contact.tel.length)
                {
                    if(contact.id)
                    {
                        _contactsList.update(contact, _contactsPage.currentIndex)
                    }else
                    {
                        _contactsList.insert(contact)
                        notify("list-add-user", i18n("New contact added"), contact.n)
                    }
                }else
                {
                    control.pop()
                }
            }
        }
    }

    function openContact(contact)
    {
        control.currentContact = contact
        control.push(_contactPageComponent)
    }

}

