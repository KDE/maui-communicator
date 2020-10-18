import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami
//import org.mauikit.accounts 1.0 as Accounts
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
    Maui.App.description: i18n("Contacts keeps your contacts synced across devices and allows you to make calls, send messages and organize")
    Maui.App.iconName: "qrc:/contacts.svg"

    readonly property var views : ({
                                       favs: 0,
                                       log:  1,
                                       contacts : 2,
                                       dialer: 3,
                                   })
    /** UI PROPS**/
    property color cardColor: Qt.darker(Maui.Style.buttonBackgroundColor, 1.05)
    leftIcon.checked: footBar.visible
    leftIcon.visible: true

    headBar.rightContent:  ToolButton
    {
        id: _dialerButton
        icon.name: "dialer-call"
        checked: _actionGroup.currentIndex === views.dialer
        onClicked: _actionGroup.currentIndex = views.dialer
    }

    headBar.middleContent: Maui.ActionGroup
    {
        id: _actionGroup
        Layout.fillHeight: true
        //        Layout.fillWidth: true
        Layout.minimumWidth: implicitWidth
        currentIndex : swipeView.currentIndex
        onCurrentIndexChanged: swipeView.currentIndex = currentIndex

        Action
        {
            id: _favsButton
            icon.name: "draw-star"
            text: i18n("Favorites")
        }

        Action
        {
            id: _logButton
            icon.name: "view-media-recent"
            text: i18n("Recent")
        }

        Action
        {
            icon.name: "view-pim-contacts"
            text: i18n("Contacts")
        }
        
    }

    SwipeView
    {
        id: swipeView
        anchors.fill : parent
        currentIndex: _actionGroup.currentIndex
        interactive: Maui.Handy.isTouch

        onCurrentIndexChanged:
        {
            _actionGroup.currentIndex = currentIndex
            if(currentIndex === views.contacts)
                _contacsView.list.query = ""
            else if(currentIndex === views.dialer)
                _contacsView.list.query = _dialerView.dialString
        }

        ContactsView
        {
            id: _favsView
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

        }

        ContactsView
        {
            id: _contacsView
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
