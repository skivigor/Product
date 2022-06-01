import QtQuick 2.12
import QtQuick.Controls 2.5
import "CmpStyle.js" as Style

Item
{
    id: root
    anchors.fill: parent
    property var _args

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
                    Button
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 80
                        text: "Ok"
                        onClicked: root.destroy()
                    }
                }
            }
        }   // CmpBoard

    }
}
