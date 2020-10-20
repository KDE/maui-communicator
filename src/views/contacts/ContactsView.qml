import QtQuick 2.10
import QtQuick.Controls 2.10
import org.kde.mauikit 1.0 as Maui
import org.maui.communicator 1.0

Maui.Page
{
    id: control

    property alias list : _contactsList
    property alias listModel : _contactsModel
    property alias view : _viewLoader.item
    property alias holder : _holder

    property bool gridView : false

    property bool showAccountFilter: false
    margins: Maui.Style.space.big

    Maui.BaseModel
    {
        id: _contactsModel
        list: _contactsList
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    ContactsList
    {
        id: _contactsList
    }

    Maui.Holder
    {
        id: _holder
        isMask: true
        visible: !view.count
        emojiSize: Maui.Style.iconSizes.huge
        onActionTriggered: _newContactDialog.open()
    }

    Loader
    {
        id: _viewLoader
        anchors.fill: parent
        sourceComponent: control.gridView ?  _gridViewComponent : _listViewComponent
    }

    Component
    {
        id: _listViewComponent

        ListView
        {
            id: _listView
            spacing: Maui.Style.space.big
            clip: true
            header: Item
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

            section.property: "n"
            section.criteria: ViewSection.FirstCharacter
            section.labelPositioning: ViewSection.InlineLabels
            section.delegate: Maui.LabelDelegate
            {
                label: section.toUpperCase()
                isSection: true
                width: parent.width
            }

            model: _contactsModel
            delegate: ContactDelegate
            {
                id: _delegate

                height: Maui.Style.unit * 60
                width: isWide ? control.width * 0.8 : _listView.width
                anchors.horizontalCenter: parent.horizontalCenter
                showMenuIcon: true

                Connections
                {
                    target: _delegate
                    onClicked:
                    {
                        view.currentIndex = index
                        _contactDialog.show(list.get(index))
                    }
                    onFavClicked:
                    {
                        var item = _contactsList.get(index)
                        item["fav"] = item.fav == "1" ? "0" : "1"
                        _contactsList.update(item, index)
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }
    }

    Component
    {
        id: _gridViewComponent

        Maui.GridView
        {
            id: _gridView
            model: _contactsModel
            cellWidth: Maui.Style.unit * 120
            cellHeight: Maui.Style.unit * 120
            itemSize: Math.min(Maui.Style.unit * 120)
            adaptContent: true
            visible: count > 0

            delegate: GridContactDelegate
            {
                id: _delegate

                width: _gridView.cellWidth * 0.95
                height: _gridView.cellHeight * 0.95
                showMenuIcon: true

                Connections
                {
                    target: _delegate
                    onClicked:
                    {
                        _gridView.currentIndex = index
                        _contactDialog.show(list.get(index))
                    }
                    onFavClicked:
                    {
                        var item = _contactsList.get(index)
                        item["fav"] = item.fav == "1" ? "0" : "1"
                        _contactsList.update(item, index)
                    }
                }
            }
        }
    }

    ContactDialog
    {
        id: _contactDialog
    }
}
