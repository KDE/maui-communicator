import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.mauikit 1.2 as Maui
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
//    title: Maui.App.displayName

    readonly property var views : ({
                                       favs: 0,
                                       contacts : 1,
                                       log:  2
                                   })

   readonly property alias dialog: _dialogLoader.item

    Maui.AppViews
    {
        id: swipeView
        anchors.fill : parent

        onCurrentIndexChanged:
        {
            if(currentIndex === views.contacts)
                _contacsView.list.query = ""
        }

        ContactsView
        {
            id: _favsView
            Maui.AppView.iconName: "draw-star"
            Maui.AppView.title: qsTr("Favorites")

            list.query : "fav=1"
            viewType: Maui.AltBrowser.ViewType.Grid
            holder.emoji: "qrc:/star.svg"
            holder.title: i18n("There's no favorite contacts")
            holder.body: i18n("You can mark as favorite your contacts to quickly access them")
        }

        ContactsView
        {
            id: _contacsView
            Maui.AppView.iconName: "view-pim-contacts"
            Maui.AppView.title: qsTr("Contacts")
            list.query: ""
            showAccountFilter: Maui.Handy.isAndroid
            holder.emoji: "qrc:/list-add-user.svg"
            holder.title: i18n("There's no contacts")
            holder.body: i18n("You can add new contacts")
        }

        LogsView
        {
            id: _logView
            Maui.AppView.iconName: "view-media-recent"
            Maui.AppView.title: qsTr("Recent")
        }
    }

    /** DIALOGS **/
    Component
    {
        id: _messageComposerComponent

        MessageComposer
        {
        }
    }


    Component
    {
        id: _fileDialogComponent

        Maui.FileDialog
        {
            mode: modes.OPEN
            settings.filterType: Maui.FMList.IMAGE
            singleSelection:  true
        }
    }

    Loader
    {
        id: _dialogLoader
    }

    Component.onCompleted:
    {
        if(_favsView.currentItem.currentView.count < 1)
            _actionGroup.currentIndex = views.contacts
        if(Maui.Handy.isAndroid)
            Maui.Android.statusbarColor(backgroundColor, true)
    }
}
