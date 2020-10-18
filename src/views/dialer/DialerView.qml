import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import QtQuick.Layouts 1.3
import "../contacts"

Maui.Page
{
    id: control
    property alias dialString : _textField.text

    property int buttonSize : Math.min(Maui.Style.iconSizes.big * 1.5 , Math.min(_dialerPad.width, _dialerPad.height) * 0.2)
    onDialStringChanged:
    {
        //        Qt.inputMethod.hide();
        _contacsView.list.query = "tel=" + dialString
    }
    //    colorScheme.backgroundColor: backgroundColor

    //    footBar.middleContent: Maui.ToolButton
    //    {
    //        iconName: "view-list-icons"
    //        onClicked: _dialerPad.visible = !_dialerPad.visible
    //        checkable: true
    //        checked: _dialerPad.visible

    //    }

    //    floatingBar: true
    //    footBarOverlap: true
    //    footBarAligment: Qt.AlignRight

    headBar.middleContent:  Maui.TextField
    {
        id: _textField
        Layout.fillWidth: true
        inputMethodHints: Qt.ImhDialableCharactersOnly
        placeholderText: i18n("Number...")
        readOnly: true
        font.bold: true
        font.weight: Font.Bold
        font.pointSize: Maui.Style.fontSizes.huge
        font.letterSpacing: Maui.Style.space.tiny
        horizontalAlignment: TextInput.AlignHCenter
        background: Rectangle
        {
            color: "transparent"
        }

        //            enabled: false
    }

    footBar.background: Rectangle
    {
        color: "transparent"
    }

    footBar.implicitHeight:  Maui.Style.iconSizes.big * 3
    footBar.spacing: Maui.Style.space.huge
    footBar.clip: true
    footBar.flickable: false
    footBar.middleContent: [

            ToolButton
            {
                icon.name: "send-sms"
                icon.color: Kirigami.Theme.textColor
                onClicked:
                {
                    _messageComposer.contact = ({tel : dialString})
                    _messageComposer.open()
                }
            },

            Button
            {
                id: _callButton
                icon.name: "dialer-call"
                icon.width: Maui.Style.iconSizes.big
                icon.height: Maui.Style.iconSizes.big
                height: Maui.Style.iconSizes.big * 1.5
                width: height
                //                bg.radius: Math.max(width, height)
                Kirigami.Theme.textColor: Kirigami.Theme.highlightColor
                Kirigami.Theme.backgroundColor: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.2)

                onClicked:
                {
                    if(isAndroid)
                        Maui.Android.call(dialString)
                    else
                        Qt.openUrlExternally("call://" + dialString)
                }
            },

            ToolButton
            {
                icon.name: "edit-clear"
                icon.color: Kirigami.Theme.textColor
                onClicked:
                {
                    dialString = dialString.slice(0, -1);
                }
            }
    ]

    ColumnLayout
    {
        id: _layout
        width: Math.min(isWide ? control.width * 0.8 : control.width * 0.95, Maui.Style.unit * 500)
        height: parent.height
        anchors.centerIn: parent
        spacing: Maui.Style.space.big

        ListView
        {
            id: _suggestionListView
            spacing: Maui.Style.space.big
            clip: true
            visible: dialString.length && count
            Layout.fillWidth: visible
//            Layout.fillHeight: true
            Layout.minimumHeight: visible ? 60 * 1.2 : 0
            Layout.preferredHeight: visible ? 60 * 2 : 0

            model: _contacsView.listModel

            delegate: ContactDelegate
            {
                id: _delegate

                height: Maui.Style.unit * 60
                width: _layout.width
                anchors.horizontalCenter: parent.horizontalCenter

                quickButtons: ToolButton
                {
                    icon.name: "view-fullscreen"
                    onClicked:
                    {
                        _suggestionListView.currentIndex = index
                        control.dialString = _contacsView.list.get(_suggestionListView.currentIndex).tel
                    }
                }

                Connections
                {
                    target: _delegate
                    onClicked:
                    {
                        _suggestionListView.currentIndex = index
                        if(isAndroid)
                            Maui.Android.call(_contacsView.list.get(_suggestionListView.currentIndex).tel)
                    }
                }
            }
        }

        Item
        {
            id: _dialerPad
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumHeight: Maui.Style.unit*100
            Layout.maximumHeight: Maui.Style.unit*300

//            Layout.alignment: Qt.AlignBottom
            //            visible: true

            Dialer
            {
                id: _dialer
                height: parent.height
                width: parent.width
                anchors.centerIn: parent
            }
        }
    }
}
