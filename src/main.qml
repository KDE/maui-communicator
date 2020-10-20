import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.kde.kirigami 2.8 as Kirigami
import QtQuick.Layouts 1.3

import "views/contacts"
import "views/dialer"
import "views/logs"
import "widgets"
//import "views/favs"

Maui.ApplicationWindow
{
    id: root
    title: Maui.App.displayName

    readonly property var views : ({
                                       favs: 0,
                                       log:  1,
                                       contacts : 2,
                                       dialer: 3,
                                   })
    /** UI PROPS**/
    property color cardColor: Qt.darker(Maui.Style.buttonBackgroundColor, 1.05)


    headBar.rightContent:  ToolButton
    {
        id: _dialerButton
        icon.name: "dialer-call"
        checked: swipeView.currentIndex === views.dialer
        onClicked: swipeView.currentIndex = views.dialer
    }

    MauiLab.AppViews
    {
        id: swipeView
        anchors.fill : parent

        onCurrentIndexChanged:
        {
            if(currentIndex === views.contacts)
                _contacsView.list.query = ""
            else if(currentIndex === views.dialer)
                _contacsView.list.query = _dialerView.dialString
        }

        ContactsView
        {
            id: _favsView
            MauiLab.AppView.iconName: "draw-star"
            MauiLab.AppView.title: qsTr("Favorites")

            list.query : "fav=1"
            headBar.visible: false
            gridView: true
            holder.emoji: "qrc:/star.svg"
            holder.title: i18n("There's no favorite contacts")
            holder.body: i18n("You can mark as favorite your contacts to quickly access them")
        }

        LogsView
        {
            id: _logView
            MauiLab.AppView.iconName: "view-media-recent"
            MauiLab.AppView.title: qsTr("Recent")
        }

        ContactsView
        {
            id: _contacsView
            MauiLab.AppView.iconName: "view-pim-contacts"
            MauiLab.AppView.title: qsTr("Contacts")
            list.query: ""
            showAccountFilter: isAndroid
            holder.emoji: "qrc:/list-add-user.svg"
            holder.title: i18n("There's no contacts")
            holder.body: i18n("You can add new contacts")

            Maui.FloatingButton
            {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: height
                height: Maui.Style.toolBarHeight
                width: height
                icon.name: "list-add-user"
                onClicked: _newContactDialog.open()
            }

            headBar.middleContent: Maui.TextField
            {
                id: _searchField
                Layout.preferredWidth: isWide ? _contacsView.width * 0.8 : _contacsView.view.width
                focusReason : Qt.PopupFocusReason
                placeholderText: i18n("Search %1 contacts... ".arg(_contacsView.view.count))
                onAccepted: _contacsView.listModel.filter = text
                onCleared: _contacsView.listModel.filter = ""
            }
        }

        DialerView
        {
            id: _dialerView
        }
    }

    /** DIALOGS **/
    EditContactDialog
    {
        id: _newContactDialog
        onNewContact:
        {
            _contacsView.list.insert(contact)
            notify("list-add-user", i18n("New contact added"), contact.n)
        }
    }

    MessageComposer
    {
        id: _messageComposer
    }

    Maui.FileDialog
    {
        id: _fileDialog
    }

    Component.onCompleted:
    {
        if(_favsView.view.count < 1)
            _actionGroup.currentIndex = views.contacts
        if(isAndroid)
            Maui.Android.statusbarColor(backgroundColor, true)
    }
}
