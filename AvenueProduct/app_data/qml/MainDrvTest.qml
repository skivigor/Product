import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "component/CmpStyle.js" as Style
import "component"
import "widget"

Window
{
    id: root
    visible: true
    width: 1000
    height: 600
    minimumWidth: 900
    minimumHeight: 600
    title: qsTr("AvDrvTest")

    // App
    property string _time: Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss")
    property string _header: "Driver test"
    property bool   _waiting: false

    // Power source
    property var   _power: new PowerSupplyWithTcp(settings.power.tcp.defIp, settings.power.tcp.defPort)

    // Stand
    property var    _uart: new SerialClient("flag")
    property bool   _connected: _uart.state
    property string _standTestsPath: AppPath + "/app_data/product/stand_drv/tests/"
    property string _standApiPath: AppPath + "/app_data/product/stand_drv/StandApi.qml"
    property var    _standApiObj

    //-----------------------------------------------------------------

    function getDateTime() { _time = Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss") }

    //-----------------------------------------------------------------

    Timer { interval: 1000; repeat: true; running: true; onTriggered: getDateTime() }
    BorderImage { anchors.fill: parent; source: "../images/wave_theme5.jpg" }
    Image { anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 5; source: "../images/logo.png" }
    Text
    {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        font.pixelSize: 22
        font.bold: true
        color: "darkgreen"
        text: _header
    }
    Text { anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 10; color: "darkgreen"; font.pixelSize: 16; text: _time }

    Row
    {
        id: id_rowDrv
        width: parent.width - 50
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        CmpBoard
        {
            id: id_cmpStat
            width: parent.width * 0.5
            height: 200
            WidgetDriverManual
            {
                id: id_wDrvManual
                _serial: _uart
                _api: _standApiObj
            }
        }

        CmpBoard
        {
            width: parent.width * 0.5
            height: 110
            WidgetDriverAuto
            {
                id: id_wDrvAuto
            }
        }
    }

    CmpBoard
    {
        id: id_cmpMes
        anchors.top: id_rowDrv.bottom
        anchors.left: parent.left
        anchors.margins: 10
        width: parent.width - 20
        height: 60
        CmpTransparant { id: id_cmpTransparant }
    }

    WidgetLog
    {
        id: id_wLog
        anchors.top: id_cmpMes.bottom
        anchors.topMargin: 10
        anchors.bottom: id_wStandDebug.visible ? id_wStandDebug.top : parent.bottom
        anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 40
        _log: avlog.mesProduct
    }

    WidgetStandDebug
    {
        id: id_wStandDebug
        visible: settings.conf.debug
        standObj: _uart
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
    }

    Component.onCompleted:
    {
        _waiting = true

        _standApiObj = Qt.createComponent(_standApiPath).createObject(root, { "_iface" : _uart })
        if (_standApiObj === null) avlog.show("red", "Application started ... Error", false, false)

        // Check Power supply
        avlog.show("chocolate", "Check Power supply ... Wait!", true, false)
        _power.pwConnect()
        wait(1000)
        if (_power.isConnected() === false)
        {
            avlog.show("red", "ERROR: Power supply connect", false, true)
            return
        }
        avlog.show("green", "Power supply ... OK", true, false)
        _power.pwDisconnect()

        // Check stand
        avlog.show("chocolate", "Check Driver stand ... Wait!", true, false)
        var finded = false
        for (var i = 0; i < serialPorts.length; ++i)
        {
            avlog.show("chocolate", "Check Driver stand on " + serialPorts[i] + "... Wait!", true, false)
            _uart.connectSerial(serialPorts[i], 57600 )
            wait(50)
            if (_uart.state === false)
            {
                _uart.disconnectSerial()
                continue
            }

            var ret = _standApiObj.checkStand()
            _uart.disconnectSerial()
            if (ret === true)
            {
                finded = true
                avlog.show("green", "Driver stand finded on " + serialPorts[i], false, false)
                break
            }

            wait(50)
        }
        if (finded === false)
        {
            avlog.show("red", "ERROR: Driver stand not found!", false, true)
            return
        }

        avlog.show("green", "Driver stand ... OK", true, false)

        avlog.show("green", "Application started ... OK", false, false)
        _waiting = false
    }
}
