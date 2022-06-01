import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import "qml/widget"
import "qml/component"

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
//    property bool   _waiting: false
    property int    _testMode: 0
    property string _testDescr: "Unknown"
    property bool   _testStarted: stand.testStarted

    property string _testImg1: ""
    property string _testImg2: ""

    // Stand
    property bool   _standFinded: false
    property int    _channelNum: 4

    //-----------------------------------------------------------------

    function getDateTime() { _time = Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss") }

    //-----------------------------------------------------------------

    function showPopup()
    {
        if (resultModel.count === 0) return

        var link1 = "=ГИПЕРССЫЛКА(\"" + _testImg1 + "\")"
        var link2 = "=ГИПЕРССЫЛКА(\"" + _testImg2 + "\")"

        var result = ""
        var last = {}
        for (var i = 0; i < resultModel.count; ++i)
        {
            var rec = resultModel.get(i)

            var v1 = (rec.val1 / 1000).toFixed(3)
            var v2 = (rec.val2 / 1000).toFixed(3)
            var v3 = (rec.val3 / 1000).toFixed(3)
            var v4 = (rec.val4 / 1000).toFixed(3)

            var m1 = (rec.meterVolume1 / 1000).toFixed(3)
            var m2 = (rec.meterVolume2 / 1000).toFixed(3)
            var m3 = (rec.meterVolume3 / 1000).toFixed(3)
            var m4 = (rec.meterVolume4 / 1000).toFixed(3)

            var p1 = (v1 == 0) ? 0 : ((m1 - v1) / v1 * 100).toFixed(3)
            var p2 = (v2 == 0) ? 0 : ((m2 - v2) / v2 * 100).toFixed(3)
            var p3 = (v3 == 0) ? 0 : ((m3 - v3) / v3 * 100).toFixed(3)
            var p4 = (v4 == 0) ? 0 : ((m4 - v4) / v4 * 100).toFixed(3)

            var str = rec.time + ";" + rec.scale + ";" +
                    v1 + ";" + m1 + ";" + p1 + ";" +
                    v2 + ";" + m2 + ";" + p2 + ";" +
                    v3 + ";" + m3 + ";" + p3 + ";" +
                    v4 + ";" + m4 + ";" + p4 + ";" +
                    link1 + ";" + link2 + "\n";
            result += str

            if (i === resultModel.count - 1)
            {
                last.scale = rec.scale
                last.v1 = v1
                last.v2 = v2
                last.v3 = v3
                last.v4 = v4
                last.m1 = m1
                last.m2 = m2
                last.m3 = m3
                last.m4 = m4
                last.p1 = p1
                last.p2 = p2
                last.p3 = p3
                last.p4 = p4
            }
        }
//        console.log("$$$$$$$$$$$$$$$")
//        console.log(result)

        var folder = AppPath + "/log/"
//        var fileName = "Result_" + Qt.formatDateTime(new Date(), "ddMMyyhhmmss") + ".csv"
        var fileName = "Result.csv"

        var path = "qml/component/CmpFilePopup.qml"
        var color = "green"
        var mes = "Test complete!  Save the result to a file?"
        var args = [color, mes, folder, fileName, result, last, _testDescr]
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
//                _serial: _uart
//                _api: _standApiObj
            }
        }

        CmpBoard
        {
            width: parent.width * 0.5
            height: 350
            WidgetWaterMeter
            {
                id: id_wWaterMeter
//                _serial: _uart
//                _api: _standApiObj
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
        anchors.bottom: parent.bottom //id_wStandDebug.visible ? id_wStandDebug.top : parent.bottom
        anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 40
        _log: avlog.mesProduct
    }

//    WidgetStandDebug
//    {
//        id: id_wStandDebug
//        visible: false
//        standObj: _uart
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 30
//    }

    RegExpValidator
    {
        id: id_regExpVolume
        regExp: /[0-9.]+/
    }

    Component.onCompleted:
    {
        avlog.show("chocolate", "Check Water stand ... Wait!", true, false)
        stand.search()

        for (var i = 0; i < 10; ++i)
        {
            if (stand.state === true) break
            util.wait(300)
        }

        if (stand.state === false)
        {
            avlog.show("red", "ERROR: Water stand not found!", false, true)
            return
        }

        avlog.show("green", "Water stand finded on " + stand.port, false, false)
        avlog.show("green", "Application started ... OK", false, false)

        stand.readPulseConfig()
        _standFinded = true
    }

}
