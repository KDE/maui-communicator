import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

Maui.PopupPage
{
    id: control
    property var contact : ({})

    maxWidth: 500
    maxHeight: maxWidth

    hint: 1

    actions: Action
    {
        text: i18n("Send")
        icon.name: "mail-send"

        onTriggered:
        {
            if(_combobox.currentText === contact.email)
            {
                _communicator.email(contact.email, "", "", _subjectTextField.text, _editor.text)
            }
            else if(_combobox.currentText === contact.tel)
            {
                _communicator.sendSMS(contact.tel, _subjectTextField.text, _editor.text)
            }

            notify("emblem-info", i18n("Message sent"), contact.tel);
            close();
        }
    }

    headBar.forceCenterMiddleContent: false
    headBar.middleContent:  ComboBox
    {
        id: _combobox
        Layout.fillWidth: true

        model:
        {
            if(contact.email && contact.tel)
                return [contact.email, contact.tel]
            else if(contact.email)
                return [contact.email]
            else if(contact.tel)
                return [contact.tel]
        }
    }

    page.headerColumn:[ Maui.ToolBar
    {
        width: parent.width
        visible: _combobox.currentText === contact.email

        middleContent: TextField
        {
            id: _subjectTextField
            Layout.fillWidth: true
            placeholderText: i18n("Subject")
        }

    }]

    stack:  TextArea
    {
        id: _editor
        Layout.fillHeight: true
        Layout.fillWidth: true
        placeholderText: i18n("Message")

    }
}
