import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Dialog
{
    id: control
    property var contact : ({})

    maxWidth: Maui.Style.unit * 500
    maxHeight: maxWidth

    page.margins: 0

    onAccepted:
    {
        if(!Kirigami.Settings.isMobile && !Maui.Handy.isAndroid)
            Maui.KDE.email(contact.email, "", "", _subjectTextField.text, _editor.text)
        else if(!Maui.Handy.isAndroid)
        {
            if(_combobox.currentText === contact.email)
                Qt.openUrlExternally("mailto:" + contact.email)
            else if(_combobox.currentText === contact.tel)
            {
                Qt.openUrlExternally("sms:" + contact.tel +"&sms_body:" + _editor.text)
                notify("emblem-info", i18n("Message sent"), contact.tel)
            }
        }else
        {
            if(_combobox.currentText === contact.email)
                Qt.openUrlExternally("mailto:" + contact.email)
            else if(_combobox.currentText === contact.tel)
                Maui.Android.sendSMS(contact.tel, _subjectTextField.text, _editor.text)
        }
        close();
    }

    acceptButton.text: i18n("Send...")
    acceptButton.icon.name: "mail-send"
    rejectButton.visible: false


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

    Maui.Editor
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
