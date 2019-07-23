import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.mauikit 1.0 as Maui
import UnionModels 1.0

Maui.Page
{
    id: control

//    colorScheme.accentColor: "#615f7d"
//    colorScheme.backgroundColor: backgroundColor
//    colorScheme.textColor: textColor

    property alias list : _contactsList
    property alias listModel : _contactsModel
    property alias view : _viewLoader.item

    property bool gridView : false

    property bool showAccountFilter: false

    BaseModel
    {
        id: _contactsModel
        list: _contactsList
    }

    ContactsList
    {
        id: _contactsList
    }

    Maui.Holder
    {
        id: _holder
        emoji: "qrc:/Circuit.svg"
        isMask: false
        title: qsTr("There's no contacts")
        body: qsTr("Add new contacts")
        emojiSize: iconSizes.huge
        visible: !view.count
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
            spacing: space.big
            clip: true
            header: Item
            {
                visible: showAccountFilter
                height: visible ? toolBarHeight * 1.5 : 0
                width: visible ? parent.width : 0
                ComboBox
                {
                    id: _accountsCombobox
                    width: isWide ? control.width * 0.8 : control.width * 0.95
                    textRole: "account"
                    anchors.centerIn: parent

//                    colorScheme.borderColor: "transparent"
//                    colorScheme.viewBackgroundColor: cardColor

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
                        //                   var androidAccounts = list.getAccounts()
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
                boldLabel: true
                //            colorScheme.backgroundColor: "#333"
                //            colorScheme.textColor: "#fafafa"
                //            width: iconSize

                //            background: Rectangle
                //            {
                //                color:  colorScheme.backgroundColor
                //                radius: radiusV

                //            }


            }

            model: _contactsModel
            delegate: ContactDelegate
            {
                id: _delegate

                height: unit * 60
                width: isWide ? control.width * 0.8 : control.width * 0.95
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
            model: _contactsModel
            cellWidth: unit * 120
            cellHeight: unit * 120
            itemSize: Math.min(unit * 120, control.width * 0.4)
            spacing: space.medium
            centerContent: false
                adaptContent: true
            delegate: GridContactDelegate
            {
                id: _delegate

                width: view.cellWidth * 0.95
                height: view.cellHeight * 0.95
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
        }
    }

    ContactDialog
    {
        id: _contactDialog
    }
}
