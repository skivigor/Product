import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "component/CmpStyle.js" as Style
import "component"
import "widget"

Window
{
    id: mainWindow
    visible: true
    width: 1000
    height: 800
    minimumWidth: 1000
    minimumHeight: 800
    title: qsTr("AvWaterTest")

    // App
    property string _time: Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss")
    property string _header: "Water test"
    property bool   _waiting: false
    property bool   _testStarted: false

    // Stand
    property var    _uart: new SerialClient("flag")
    property bool   _connected: _uart.state
    property bool   _standFinded: false
    property int    _channelNum: 4
    property string _standApiPath: AppPath + "/app_data/product/stand_water/StandApi.qml"
    property var    _standApiObj

    on_ConnectedChanged:
    {
        if (_connected === false && _standFinded === true) avlog.show("red", "ERROR: Water stand disconnected!", false, true)
    }

    //-----------------------------------------------------------------

    function getDateTime() { _time = Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss") }

    //-----------------------------------------------------------------

    function showPopup()
    {
        if (resultModel.count === 0) return

        var result = ""
        for (var i = 0; i < resultModel.count; ++i)
        {
            var rec = resultModel.get(i)
            var str = rec.time + ";" + rec.scaleVolume + ";" + rec.meterVolume1 + ";" + rec.meterVolume2 + ";" + rec.meterVolume3 + ";" + rec.meterVolume4 + "\n";
            result += str
        }
//        console.log("$$$$$$$$$$$$$$$")
//        console.log(result)

        var folder = AppPath + "/log/"
        var fileName = "Result_" + Qt.formatDateTime(new Date(), "ddMMyyhhmmss") + ".csv"

        var path = "file:///" + AppPath + "app_data/qml/component/CmpFilePopup.qml"
        var color = "green"
        var mes = "Test complete!  Save the result to a file?"
        var args = [color, mes, folder, fileName, result]
        Qt.createComponent(path).createObject(mainWindow, { "_args" : args })
    }

    //-----------------------------------------------------------------

    ListModel { id: resultModel }

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
            height: 350
            WidgetWaterControl
            {
                id: id_wWaterControl
                _serial: _uart
                _api: _standApiObj
            }
        }

        CmpBoard
        {
            width: parent.width * 0.5
            height: 350
            WidgetWaterMeter
            {
                id: id_wWaterMeter
                _serial: _uart
                _api: _standApiObj
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

    RegExpValidator
    {
        id: id_regExpVolume
        regExp: /[0-9.]+/
    }

    Component.onCompleted:
    {
        _waiting = true

        _standApiObj = Qt.createComponent(_standApiPath).createObject(mainWindow, { "_iface" : _uart })
        if (_standApiObj === null) avlog.show("red", "Application started ... Error", false, false)

        // Check stand
        avlog.show("chocolate", "Check Water stand ... Wait!", true, false)
        var finded = false
        for (var i = 0; i < serialPorts.length; ++i)
        {
            avlog.show("chocolate", "Check Water stand on " + serialPorts[i] + "... Wait!", true, false)
            _uart.connectSerial(serialPorts[i], 57600 )
            wait(50)
            if (_uart.state === false)
            {
                _uart.disconnectSerial()
                continue
            }

            var ret = _standApiObj.checkStand()
//            avlog.show("orange", "Water stand check finish ... OK", true, false)

            if (ret === true)
            {
                finded = true
                avlog.show("green", "Water stand finded on " + serialPorts[i], false, false)
                break
            }
            _uart.disconnectSerial()
            wait(50)
        }
        if (finded === false)
        {
            _waiting = false
            avlog.show("red", "ERROR: Water stand not found!", false, true)
            return
        }

        avlog.show("green", "Water stand ... OK", true, false)

        avlog.show("green", "Application started ... OK", false, false)
        _waiting = false

        //-----------------------------

//        var req = new Uint8Array(4)
//        req[0] = 0x9f
//        req[1] = 0x52
//        var v1 = (req[1] << 8) + req[0]
//        console.log("!!!!! V1 " + v1)

//        req[0] = 0x5b
//        req[1] = 0x01
//        v1 = (req[1] << 8) + req[0]
//        console.log("!!!!! V1 " + v1)

//        req[0] = 0xe3
//        req[1] = 0x98
//        req[2] = 0x03
//        req[3] = 0
//        v1 = (req[3] << 24) + (req[2] << 16) + (req[1] << 8) + req[0]
//        console.log("!!!!! V1 " + v1)

//        req[0] = 0x80
//        v1 = req[0] << 24 >> 24
//        console.log("!!!!! V1 " + v1)

//        req[0] = 0x50
//        req[1] = 0x20
//        req[2] = 0x00
//        req[3] = 0xff
//        var v2 = (req[3] << 24) + (req[2] << 16) + (req[1] << 8) + req[0]
//        console.log("!!!!! V2 " + v2)

//        req[0] = 0x8a
//        req[1] = 0xc3
//        v1 = ((req[1] << 8) + req[0]) << 16 >> 16
//        console.log("!!!!! V1 " + v1)

//        var v1 = 0x1F
//        if (v1 & 0x10) console.log("!!!!!!!!!! OK")
//        else console.log("!!!!!!!!!! NOT")

        //-----------------------------

        id_wWaterControl.getPulseConfig()


        _standFinded = true
    }
}
