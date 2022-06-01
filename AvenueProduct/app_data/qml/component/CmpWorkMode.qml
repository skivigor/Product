import QtQuick 2.12
import QtQuick.Controls 2.5
//import "CmpStyle.js" as Style

Rectangle
{
    id: root
    anchors.fill: parent
    color: "#ddffffff"

    property string _image
    property string _text

    signal modeAck()

    Column
    {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -50
        spacing: 10

        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30
            Text { font.pixelSize: 16; text: "Selected production mode:" }
            Text { font.pixelSize: 16; color: "darkgreen"; font.bold: true; text: _text  }
        }
        Image { width: 400; fillMode: Image.PreserveAspectFit; source: _image }
        Text { text: "    " }
        Text { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 20; text: "Are you sure?" }
        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30
            Button
            {
                id: id_butOk
                width: 80
                text: "Ok"
                onClicked: modeAck()
            }
            Button
            {
                id: id_butQuit
                width: 80
                text: "Quit"
                onClicked: Qt.quit()
            }
        }
    }

    Shortcut
    {
        sequences: ["Return"];
        onActivated:
        {
            if (id_butOk.activeFocus) { modeAck(); return; }
            if (id_butQuit.activeFocus) { Qt.quit(); return; }
            modeAck()
        }
    }
    Shortcut { sequences: ["Esc"]; onActivated: Qt.quit() }
}
