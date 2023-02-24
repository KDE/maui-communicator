import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

AbstractButton
{
    id: control

    Maui.Theme.colorSet: Maui.Theme.View
    Maui.Theme.inherit: false

    padding: Maui.Style.contentMargins
    hoverEnabled: !Maui.Handy.isMobile

    property alias content: _content.data

    property alias label1 : _template.label1
    property alias label2 : _template.label2
    property alias label3 : _template.label3
    property alias label4 : _template.label4
    property alias iconItem : _template.iconItem
    property alias iconVisible : _template.iconVisible
    property alias iconSizeHint : _template.iconSizeHint
    property alias imageSizeHint : _template.imageSizeHint
    property alias imageSource : _template.imageSource
    property alias iconSource : _template.iconSource

    property alias template : _template

    default property list<Action> actions

    property bool editing : false
    property bool expanded : false

    property alias leftLabels : _template.leftLabels

    checked: control.expanded

    onClicked:
    {
        if(!control.editing)
        {
            expanded = !expanded
        }
    }

    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    background: Rectangle
    {
        color: control.hovered ? Maui.Theme.hoverColor : Maui.Theme.alternateBackgroundColor
        radius: Maui.Style.radiusV
    }

    contentItem: ColumnLayout
    {
        id: _contentLayout
        spacing: Maui.Style.space.medium

        Maui.ListItemTemplate
        {
            id: _template
            Layout.fillWidth: true
            label1.font.pointSize: Maui.Style.fontSizes.default
            label1.font.weight: Font.Light
            label2.visible: !control.editing
            label2.font.pointSize: Maui.Style.fontSizes.big
            label2.font.weight: Font.Bold
            label2.wrapMode: Text.WrapAnywhere
            iconSizeHint: Maui.Style.iconSizes.medium
        }

        ColumnLayout
        {
            id: _content
            Layout.fillWidth: true
        }

        Maui.Separator
        {
            Layout.fillWidth: true
            visible: control.expanded && control.actions.length
        }

        RowLayout
        {
            visible: !control.editing && control.expanded && control.actions.length
            Layout.fillWidth: true
            Layout.margins: Maui.Style.space.medium
            implicitHeight: Maui.Style.rowHeight
            spacing: Maui.Style.space.medium

            Repeater
            {
                model: control.actions

                Button
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    action: modelData
                    //                    display: ToolButton.TextBesideIcon
                }
            }
        }
    }
}
