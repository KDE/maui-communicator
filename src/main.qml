import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.2 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.communicator 1.0

import org.kde.kirigami 2.8 as Kirigami

import "views/contacts"
import "views/dialer"
import "views/logs"
import "widgets"
//import "views/favs"

Maui.ApplicationWindow
{
    id: root
    headBar.visible: false
    readonly property var views : ({
                                       favs: 0,
                                       contacts : 1,
                                       log:  2
                                   })

   readonly property alias dialog: _dialogLoader.item

//   autoHideHeader: swipeView.currentItem.currentItem ? swipeView.currentItem.currentItem.editing : false

    Maui.AppViews
    {
        id: swipeView
        anchors.fill : parent
        altHeader: Kirigami.Settings.isMobile
        showCSDControls: true
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
            holder.title: i18n("There're no favorite contacts")
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
            holder.title: i18n("There're no contacts")
            holder.body: i18n("You can add new contacts")

            contactsPage.headBar.rightContent: ToolButton
            {
                icon.name: "list-add"
                onClicked:
                {
                    _contacsView.openContact(({}))
                }
            }
        }

//        LogsView
//        {
//            id: _logView
//            Maui.AppView.iconName: "view-media-recent"
//            Maui.AppView.title: qsTr("Recent")
//        }
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

        FB.FileDialog
        {
            mode: modes.OPEN
            settings.filterType: FB.FMList.IMAGE
            singleSelection:  true
        }
    }

    Loader
    {
        id: _dialogLoader
    }

    Communicator
    {
        id: _communicator
    }

    Component.onCompleted:
    {
        if(_favsView.currentItem.currentView.count < 1)
            swipeView.currentIndex = views.contacts

        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor(headBar.Kirigami.Theme.backgroundColor, false)
            Maui.Android.navBarColor(headBar.visible ? headBar.Kirigami.Theme.backgroundColor : Kirigami.Theme.backgroundColor, false)

        }
    }
}
