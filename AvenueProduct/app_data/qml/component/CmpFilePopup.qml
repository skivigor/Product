import QtQuick 2.12
import QtQuick.Controls 2.5
import "CmpStyle.js" as Style

Item
{
    id: root
    anchors.fill: parent
    property var _args   // color: _args[0]; text: _args[1]; path: _args[2]; fileName: _args[3]; content: _args[4]

    function saveFile()
    {
        var ret = file.saveFile(_args[2] + _args[3], _args[4])
        if (ret === true) avlog.show("green", "File  " + _args[3] + " saved ... OK", false, false)
        else avlog.show("red", "File  " + _args[3] + " save ... Error!", false, false)
        root.destroy()
    }

    Rectangle
    {
        id: id_rcOrder
        anchors.fill: parent
        color: "#ddffffff"
        onVisibleChanged: animation.running = true

        PropertyAnimation { id: animation;
            target: id_rcOrder; property: "opacity";
            duration: 400; from: 0; to: 1;
            easing.type: Easing.InOutQuad ; running: true }

        CmpBoard
        {
            anchors.centerIn: parent
            width: parent.width - 200
            height: 120

            Item
            {
                anchors.fill: parent
                anchors.margins: 10

                Column
                {
                    anchors.centerIn: parent
                    spacing: 20
                    Text { font.pixelSize: 14; color: _args[0]; text: _args[1] }
                    Row
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20

                        Button
                        {
                            width: 80
                            text: "Save"
                            onClicked: saveFile()
                        }
                        Button
                        {
                            width: 80
                            text: "Cancel"
                            onClicked: root.destroy()
                        }
                    }


                }
            }
        }   // CmpBoard
    }
    Shortcut { sequences: ["Return"]; onActivated: saveFile() }
    Shortcut { sequences: ["Esc"]; onActivated: root.destroy() }
}
