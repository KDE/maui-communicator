import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.texteditor 1.0 as TE
import org.mauikit.controls 1.3 as Maui

Maui.Dialog
{
    id: control
    property var contact : ({})

    maxWidth: 500
    maxHeight: maxWidth

    hint: 1

    acceptButton.text: i18n("Send...")
    acceptButton.icon.name: "mail-send"
    rejectButton.visible: false

    page.margins: 0

    onAccepted:
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

    headBar.middleContent: ComboBox
    {
        id: _combobox
        Layout.fillWidth: true

        //                text: Maui.Handy.isAndroid ? contact.tel : contact.email
        font.bold: true
        font.weight: Font.Bold
        font.pointSize: Maui.Style.fontSizes.big
        model:
        {
            if(contact.email && contact.tel)
                return [contact.email, contact.tel]
            else if(contact.email)
                return [contact.email]
            else if(contact.tel)
                return [contact.tel]
        }

        popup.z: control.z + 1
    }

    stack: TE.TextEditor
    {
        id: _editor
        Layout.fillHeight: true
        Layout.fillWidth: true

        headBar.middleContent:  Maui.TextField
        {
            id: _subjectTextField
            visible: _combobox.currentText === contact.email
            Layout.fillWidth: true
            placeholderText: i18n("Subject")
            font.bold: true
            font.weight: Font.Bold
            font.pointSize: Maui.Style.fontSizes.big
        }
    }

}
