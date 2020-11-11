import QtQuick 2.14
import QtQuick.Controls 2.14
import org.kde.mauikit 1.2 as Maui
import org.maui.communicator 1.0

StackView
{
    id: control

    property alias list : _contactsList
    property alias listModel : _contactsModel
    property alias holder : _contactsPage.holder
    property alias viewType: _contactsPage.viewType
    property alias headBar: _contactsPage.headBar

    property bool showAccountFilter: false

    property var currentContact : ({})

    initialItem: Maui.AltBrowser
    {
        id: _contactsPage
        margins: Maui.Style.space.big
        holder.visible: !currentView.count
        holder.emojiSize: Maui.Style.iconSizes.huge
        //        onActionTriggered: _newContactDialog.open()
        model: Maui.BaseModel
        {
            id: _contactsModel
            list:    ContactsList
            {
                id: _contactsList
            }
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
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
            showMenuIcon: true

                onClicked:
                {
                    _contactsPage.currentIndex = index
                    openContact(_contactsModel.get(index))
                }
                onFavClicked:
                {
                    var item = _contactsList.get(index)
                    item["fav"] = item.fav == "1" ? "0" : "1"
                    _contactsList.update(item, index)
                }

        }

        listDelegate:ContactDelegate
        {
            id: _delegate

            height: Maui.Style.unit * 60
            width: isWide ? control.width * 0.8 : ListView.view.width
            anchors.horizontalCenter: parent.horizontalCenter
            showMenuIcon: true

                onClicked:
                {
                    _contactsPage.currentIndex = index
                    openContact(_contactsModel.get(index))
                }
                onFavClicked:
                {
                    var item = _contactsList.get(index)
                    item["fav"] = item.fav == "1" ? "0" : "1"
                    _contactsList.update(item, index)
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
            }
        }
}

    function openContact(contact)
    {
        control.currentContact = contact
        control.push(_contactPage)
    }

}

