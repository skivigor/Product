import QtQuick 2.11
import QtQuick.Controls 1.4

Item
{
    id: root
    anchors.fill: parent

    signal login(string login, string pass)

    Column
    {
        anchors.centerIn: parent
        spacing: 10

        Text { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 16; /*font.bold: true;*/ text: "Authorization" }
        Row
        {
            spacing: 20
            Text { width: 80; anchors.verticalCenter: parent.verticalCenter; font.pixelSize: 14; /*font.bold: true;*/ text: "User" }
            TextField { id: id_txtLogin; width: 150; focus: true }
        }
        Row
        {
            spacing: 20
            Text { width: 80; anchors.verticalCenter: parent.verticalCenter; font.pixelSize: 14; /*font.bold: true;*/ text: "Password" }
            TextField { id: id_txtPass; width: 150; echoMode: TextInput.Password; onAccepted: login(id_txtLogin.text, id_txtPass.text) }
        }
        Button
        {
            width: 80
            anchors.right: parent.right
            anchors.rightMargin: 10
            text: "Login"
            onClicked: login(id_txtLogin.text, id_txtPass.text)
            Keys.onEnterPressed: login(id_txtLogin.text, id_txtPass.text)
            Keys.onReturnPressed: login(id_txtLogin.text, id_txtPass.text)
        }
    }
}
