import QtQuick 2.12
import QtQuick.Controls 2.5
//import "CmpStyle.js" as Style

Rectangle
{
    id: root
    anchors.fill: parent
    color: "#ddffffff"

    property string _image: "led_check.jpg"
    property bool   _checking: false
    property string _text

    signal ledChecked(bool res)

    function checkLed()
    {
        console.log("checkLed")
        if (_checking) return

        _checking = true
        _fwApi.jcc_blink()

//        _standApiObj.pwRelayOff()
//        wait(1000)
//        _standApiObj.pwRelayOn()
        _checking = false
    }

    Column
    {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -50
        spacing: 10

        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30
            Text { font.pixelSize: 16; text: "Check JCC LEDs" }
            Text { font.pixelSize: 16; color: "darkgreen"; font.bold: true; text: _text  }
        }
        Image { width: 500; fillMode: Image.PreserveAspectFit; source: _image }
        Text { text: "    " }

        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Button
            {
                id: id_butCheck
                focus: true
                width: 150
                text: "Check"
                onClicked: checkLed()
            }
            Text { font.pixelSize: 14; text: "[Enter]" }
        }
        Text { text: "    " }

        Text { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 20; text: "Are all LEDs OK?" }
        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30
            Button
            {
                id: id_butYes
                width: 80
                text: "Yes"
                onClicked: { ledChecked(true); root.destroy() }
            }
            Button
            {
                id: id_butNo
                width: 80
                text: "No"
                onClicked: { if (_checking) return; ledChecked(false); root.destroy() }
            }
        }
        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30
            Text { font.pixelSize: 14; text: "[Ctrl + Y]" }
            Text { font.pixelSize: 14; text: "[Ctrl + N]" }
        }
    }

    Shortcut { sequences: ["Return"]; onActivated: checkLed() }
    Shortcut { sequences: ["Ctrl+Y"]; onActivated: { if (_checking) return; ledChecked(true); root.destroy() } }
    Shortcut { sequences: ["Ctrl+N"]; onActivated: { if (_checking) return; ledChecked(false); root.destroy() } }
}
