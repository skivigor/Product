import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import "qml"

Window
{
    visible: true
    width: 640
    height: 480
    title: qsTr("FwTool v0.0.2")

    property bool _connected: serial.state
    property bool _wait: false

    //-----------------------------------------------------------------

    function check()
    {
        console.log("Start check!!!!!!!!!")

        _wait = true
        fwmodel.resetCheckStatus()
        fwmodel.checkFw()
    }

    //-----------------------------------------------------------------

    function load()
    {
        console.log("Start load!!!!!!!!!")

        _wait = true
        fwmodel.resetLoadStatus()
        fwmodel.loadFw()
    }

    //-----------------------------------------------------------------

    function onCheckedFw()
    {
        _wait = false
        console.log("Checked OK!!!!!!!!!")
    }

    //-----------------------------------------------------------------

    function onLoadedFw()
    {
        _wait = false
        console.log("Loaded OK!!!!!!!!!")
    }

    //-----------------------------------------------------------------

    function onErrorFw()
    {
        _wait = false
        console.log("Error!!!!!!!!!")
    }

    //-----------------------------------------------------------------

    BorderImage { anchors.fill: parent; source: "../images/wave_theme5.jpg" }

    BusyIndicator
    {
        id: id_busy
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.rightMargin: 30
        running: _wait
    }

    Column
    {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        spacing: 10

        Row
        {
            spacing: 20

            Image
            {
                source: _connected ? "../images/online_32.png" : "../images/offline_32.png"
            }

            ComboBox
            {
                id: id_boxPorts
                width: 150
                model: ports
            }

            Button
            {
                width: 110
                text: _connected ? "Disconnect" : "Connect"
                enabled: !_wait ? true : false
                onClicked:
                {
                    if (_connected)
                    {
                        serial.disconnectSerial()
                    } else
                    {
                        serial.connectSerial(id_boxPorts.currentText, 57600)
                    }
                }
            }
        }    // row
        Row
        {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Button
            {
                width: 90
                enabled: (_connected && !_wait && fwmodel.size() > 0) ? true : false
                text: "Check"
                onClicked: check()
            }
            Button
            {
                width: 90
                enabled: (_connected && !_wait && fwmodel.size() > 0) ? true : false
                text: "Load"
                onClicked: load()
            }
        }   // row

        WidgetFirmware
        {
            id: id_wFirm
//            anchors.top: parent.top
//            anchors.right: parent.right
//            anchors.margins: 10
            _model: fwmodel
        }
    }

    Component.onCompleted:
    {
        console.log("FwToolWidg completed")
        fwmodel.checked.connect(onCheckedFw)
        fwmodel.loaded.connect(onLoadedFw)
        fwmodel.error.connect(onErrorFw)
    }
    Component.onDestruction:
    {
        console.log("FwToolWidg destruction")
        fwmodel.checked.disconnect(onCheckedFw)
        fwmodel.loaded.disconnect(onLoadedFw)
        fwmodel.error.disconnect(onErrorFw)
    }
}
















