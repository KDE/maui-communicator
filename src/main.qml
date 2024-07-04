import QtQuick
import QtCore
import QtQuick.Controls

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.communicator

import "views/contacts"
import "widgets"

Maui.ApplicationWindow
{
    id: root

    readonly property var views : ({ favs: 0, contacts : 1 })

    readonly property alias dialog: _dialogLoader.item
    property alias appSettings: settings

    Settings
    {
        id: settings
    }

    Maui.AppViews
    {
        id: swipeView
        anchors.fill : parent
        altHeader: Maui.Handy.isMobile
        Maui.Controls.showCSD: true
        //        onCurrentIndexChanged:
        //        {
        //            if(currentIndex === views.contacts)
        //                _contacsView.list.query = ""
        //        }

        Maui.AppViewLoader
        {
            Maui.Controls.iconName: "draw-star"
            Maui.Controls.title: i18n("Favorites")

            ContactsView
            {
                id: _favsView

                list.query : "fav=1"
                viewType: Maui.AltBrowser.ViewType.Grid
                holder.emoji: "qrc:/star.svg"
                holder.title: i18n("There're no favorite contacts")
                holder.body: i18n("You can mark as favorite your contacts to quickly access them")
            }
        }

        Maui.AppViewLoader
        {
            Maui.Controls.iconName: "view-pim-contacts"
            Maui.Controls.title: i18n("Contacts")

            ContactsView
            {
                id: _contacsView

                list.query: ""
                showAccountFilter: Maui.Handy.isAndroid
                holder.emoji: "qrc:/list-add-user.svg"
                holder.title: i18n("There're no contacts")
                holder.body: i18n("You can add new contacts")

                headBar.rightContent: ToolButton
                {
                    icon.name: "list-add"
                    onClicked:
                    {
                        _contacsView.openContact(({}))
                    }
                }
            }
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

        FB.FileDialog
        {
            mode: modes.OPEN
            browser.settings.filterType: FB.FMList.IMAGE
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
}
