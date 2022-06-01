import QtQuick 2.3
//import QtQuick.Controls 1.4
import QtQuick.Controls 2.5

Item
{
    id: root
    anchors.fill: parent

    property color _color: avlog.transparant[0]
    property string _message: avlog.transparant[1]
    property bool _showBusy: avlog.transparant[2]
    property bool _blinking: avlog.transparant[3]

    on_BlinkingChanged:
    {
        if (_blinking === true)
        {
            id_tim.start()
            id_rc.border.width = 2
        } else
        {
            id_tim.stop()
            id_rc.border.width = 0
        }
    }

    Rectangle
    {
        id: id_rc
        anchors.fill: parent
        anchors.margins: 5
        radius: 5
        color: "transparent"
        border.width: 0
        border.color: _color
    }

    Timer
    {
        id: id_tim
        running: _blinking
        repeat: true
        interval: 400
        onTriggered:
        {
            if (id_rc.border.width == 0) id_rc.border.width = 2
            else id_rc.border.width = 0
        }
    }

    Text
    {
        anchors.centerIn: parent
        text: _message
        color: _color
        font.pixelSize: 18
    }

    BusyIndicator
    {
        id: id_busy
        height: root.height * 0.7
        width: height

        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        running: _showBusy
    }
}
