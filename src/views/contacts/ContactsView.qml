import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.2 as Maui
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
        margins: Maui.Style.space.big
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
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        headBar.leftContent:  Maui.ToolActions
        {
            autoExclusive: true
            cyclic: true
            expanded: headBar.width > Kirigami.Units.gridUnit * 32

            currentIndex: _contactsPage.viewType === Maui.AltBrowser.ViewType.Grid ? 0 : 1
            display: ToolButton.TextBesideIcon

            Action
            {
                icon.name: "view-list-icons"
                text: i18n("Grid")
                shortcut: "Ctrl+G"
                onTriggered:  _contactsPage.viewType = Maui.AltBrowser.ViewType.Grid
            }

            Action
            {
                icon.name: "view-list-details"
                text: i18n("List")
                shortcut: "Ctrl+L"
                onTriggered:  _contactsPage.viewType = Maui.AltBrowser.ViewType.List
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

        Maui.FloatingButton
        {
            visible: control.showNewButton
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Maui.Style.space.big
            height: Maui.Style.toolBarHeight
            width: height
            icon.name: "list-add-user"
            onClicked:
            {
                control.openContact(({}))
            }
        }

        gridView.cellWidth: Maui.Style.unit * 120
        gridView.cellHeight: Maui.Style.unit * 120
        gridView.itemSize: Math.min(Maui.Style.unit * 120)

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
        //        headerPositioning: ListView.PullBackHeader

        listView.section.property: "n"
        listView.section.criteria: ViewSection.FirstCharacter
        listView.section.labelPositioning: ViewSection.InlineLabels
        listView.section.delegate: Maui.LabelDelegate
        {
            label: section.toUpperCase()
            isSection: true
            width: parent.width
        }


        gridDelegate: GridContactDelegate
        {
            id: _delegate

            width: _contactsPage.gridView.cellWidth * 0.95
            height: _contactsPage.gridView.cellHeight * 0.95

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

        listDelegate: ContactDelegate
        {
            id: _delegate

            height: Maui.Style.unit * 60
            width: isWide ? control.width * 0.8 : ListView.view.width
            anchors.horizontalCenter: parent.horizontalCenter
            showQuickActions: true

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
        id: _contactPage
        ContactPage
        {
            contact: control.currentContact
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked:
                {
                    control.pop()
                }
            }

            onContactEdited:
            {
                console.log(contact.id)
                if(contact.id)
               {
                    _contactsList.update(contact, _contactsPage.currentIndex)
                }else
                {
                    _contactsList.insert(contact)
                    notify("list-add-user", i18n("New contact added"), contact.n)
                }

            }
        }
    }

    function openContact(contact)
    {
        control.currentContact = contact
        control.push(_contactPage)
    }

}

