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
    height: 800
    minimumWidth: 800
    minimumHeight: 800
    title: qsTr("AvJccTest")

    property var    _uart: new SerialClient("flag")
//    property var    _stand: new SerialClient("flag")
    property bool   _connected: _uart.state
    property string _time: Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss")

    property var _pioModel: ["PA6", "PA7", "PA8", "PA11", "PA12", "PA15",
                             "PB0", "PB1", "PB3", "PB4", "PB5", "PB8",
                             "PB9", "PB10", "PB11", "PB12", "PB13", "PB14",
                             "PB15", "PC13", "PC14", "PC15"]
    property var _onoffModel: ["OFF", "ON"]
    property var _dirModel: ["IN", "OUT"]
    property var _pioStateModel: ["RESET", "SET"]

    property var _standApiObj

    //-----------------------------------------------------------------

    on_ConnectedChanged:
    {
        if (_connected)
        {
            showMessage("darkgreen", "Port openned!")
            getConfig()
        } else
        {
            showMessage("darkgreen", "Port closed!")
        }
    }

    function startTest()
    {
        if (_connected === false) return

        var pb1 = 8
        var pb3 = 9
        var pb4 = 10

        // _standApiObj.setPioValue(id, val)
        for (var i = 0; i < 100; ++i)
        {
            _standApiObj.setPioValue(pb4, 1)
            wait(5000)
            _standApiObj.setPioValue(pb4, 0)
            wait(500)
            _standApiObj.setPioValue(pb1, 1)
            wait(5000)
            _standApiObj.setPioValue(pb1, 0)
            wait(500)
            _standApiObj.setPioValue(pb3, 1)
            wait(5000)
            _standApiObj.setPioValue(pb3, 0)

            wait(10000)
            _standApiObj.setPioValue(pb1, 1)
            _standApiObj.setPioValue(pb3, 1)
            _standApiObj.setPioValue(pb4, 1)
            wait(2000)
            _standApiObj.setPioValue(pb1, 0)
            _standApiObj.setPioValue(pb3, 0)
            _standApiObj.setPioValue(pb4, 0)
            wait(30000)
        }
    }

    //-----------------------------------------------------------------

    function getConfig()
    {
        if (_connected === false) return

        console.log("Get Config")
        var cfg = _standApiObj.getConfig()

        if (cfg === false)
        {
            showMessage("red", "Can not read stand config")
            return
        }

        console.log("CONFIG: " + cfg)
        id_boxAdcCfg1.currentIndex = cfg[0]
        id_boxAdcCfg2.currentIndex = cfg[1]
        id_boxAdcCfg3.currentIndex = cfg[2]
        id_boxAdcCfg4.currentIndex = cfg[3]
        id_boxDacCfg1.currentIndex = cfg[4]
        id_boxDacCfg2.currentIndex = cfg[5]

        id_boxPa6.currentIndex = cfg[8]
        id_boxPa7.currentIndex = cfg[9]
        id_boxPa8.currentIndex = cfg[10]
        id_boxPa11.currentIndex = cfg[11]
        id_boxPa12.currentIndex = cfg[12]
        id_boxPa15.currentIndex = cfg[13]
        id_boxPb0.currentIndex = cfg[14]
        id_boxPb1.currentIndex = cfg[15]
        id_boxPb3.currentIndex = cfg[16]
        id_boxPb4.currentIndex = cfg[17]

        id_boxPb5.currentIndex = cfg[18]
        id_boxPb8.currentIndex = cfg[19]
        id_boxPb9.currentIndex = cfg[20]
        id_boxPb10.currentIndex = cfg[21]
        id_boxPb11.currentIndex = cfg[22]
        id_boxPb12.currentIndex = cfg[23]
        id_boxPb13.currentIndex = cfg[24]
        id_boxPb14.currentIndex = cfg[25]
        id_boxPb15.currentIndex = cfg[26]
        id_boxPc13.currentIndex = cfg[27]

        id_boxPc14.currentIndex = cfg[28]
        id_boxPc15.currentIndex = cfg[29]
    }

    //-----------------------------------------------------------------

    function setConfig()
    {
        if (_connected === false) return
        console.log("Set Config")

        var cfg = new Uint8Array(30).fill(0)

        cfg[0] = id_boxAdcCfg1.currentIndex
        cfg[1] = id_boxAdcCfg2.currentIndex
        cfg[2] = id_boxAdcCfg3.currentIndex
        cfg[3] = id_boxAdcCfg4.currentIndex
        cfg[4] = id_boxDacCfg1.currentIndex
        cfg[5] = id_boxDacCfg2.currentIndex

        cfg[8] = id_boxPa6.currentIndex
        cfg[9] = id_boxPa7.currentIndex
        cfg[10] = id_boxPa8.currentIndex
        cfg[11] = id_boxPa11.currentIndex
        cfg[12] = id_boxPa12.currentIndex
        cfg[13] = id_boxPa15.currentIndex
        cfg[14] = id_boxPb0.currentIndex
        cfg[15] = id_boxPb1.currentIndex
        cfg[16] = id_boxPb3.currentIndex
        cfg[17] = id_boxPb4.currentIndex

        cfg[18] = id_boxPb5.currentIndex
        cfg[19] = id_boxPb8.currentIndex
        cfg[20] = id_boxPb9.currentIndex
        cfg[21] = id_boxPb10.currentIndex
        cfg[22] = id_boxPb11.currentIndex
        cfg[23] = id_boxPb12.currentIndex
        cfg[24] = id_boxPb13.currentIndex
        cfg[25] = id_boxPb14.currentIndex
        cfg[26] = id_boxPb15.currentIndex
        cfg[27] = id_boxPc13.currentIndex

        cfg[28] = id_boxPc14.currentIndex
        cfg[29] = id_boxPc15.currentIndex

        var ret = _standApiObj.setConfig(cfg)
        if (ret === false)
        {
            showMessage("red", "Set config ERROR!")
        } else
        {
            showMessage("green", "Set config OK!")
        }
    }

    //-----------------------------------------------------------------

    function getAdcValue()
    {
        if (_connected === false) return

        var id = id_boxAdcVal.value
        var val = _standApiObj.getAdcValue(id)
        console.log("ADC value: " + val)
        if (val === false)
        {
            showMessage("red", "Get ADC value ERROR!")
            return
        }
        id_indAdcVal.m_int = val
    }

    //-----------------------------------------------------------------

    function setDacValue()
    {
        if (_connected === false) return

        var id = id_boxDacVal.value
        var val = parseInt(id_fldDacVal.text)

        var ret = _standApiObj.setDacValue(id, val)
        if (ret === false)
        {
            showMessage("red", "Set DAC value ERROR!")
            return
        }
        showMessage("green", "Set DAC value OK!")
    }

    //-----------------------------------------------------------------

    function getPioValue()
    {
        if (_connected === false) return

        var id = id_boxGetPio.currentIndex + 1
        var val = _standApiObj.getPioValue(id)
        console.log("PIO value: " + val)
        if (val === false)
        {
            id_indPioVal.m_str = "ERROR"
            return
        }
        id_indPioVal.m_str = (val === 0) ? "RESET" : "SET"
    }

    //-----------------------------------------------------------------

    function setPioValue()
    {
        if (_connected === false) return

        var id = id_boxSetPio.currentIndex + 1
        var val = id_boxSetPioMode.currentIndex
        var ret = _standApiObj.setPioValue(id, val)

        if (ret === false)
        {
            showMessage("red", "Set PIO value ERROR!")
            return
        }
        showMessage("green", "Set PIO value OK!")
    }

    //-----------------------------------------------------------------

    function getDateTime() { _time = Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss") }

    //-----------------------------------------------------------------

    function sortByKey(array, key)
    {
        return array.sort(function(a, b) {
            var x = a[key]; var y = b[key];
            return ((x < y) ? -1 : ((x > y) ? 1 : 0));
        });
    }

    //-----------------------------------------------------------------

    function showMessage(color, mes)
    {
        id_txtMessage.color = color
        id_txtMessage.text = _time + " :: " + mes
    }

    //-----------------------------------------------------------------

    Timer { interval: 1000; repeat: true; running: true; onTriggered: getDateTime() }
    BorderImage { anchors.fill: parent; source: "../images/wave_theme5.jpg" }
    Image { anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 5; source: "../images/logo.png" }

    Rectangle
    {
        width: parent.width
        height: 50
        anchors.bottom: parent.bottom
        color: "#99ffffff"
        Text { id: id_txtMessage; anchors.centerIn: parent; font.pixelSize: 16 }
    }

    Column
    {
        id: id_clmTop
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        Text { color: "darkgreen"; font.pixelSize: 16; text: _time }
        Row
        {
            anchors.right: parent.right
            spacing: 40
            Image { source: _connected ? "../images/online_32.png" : "../images/offline_32.png" }
            Button
            {
                width: 80
                anchors.verticalCenter: parent.verticalCenter
                text: _connected ? "Close" : "Open"
                onClicked:
                {
                    if (!_connected)
                    {
                        _uart.connectSerial(settings.uart.port, settings.uart.speed )
//                        _stand.connectSerial(settings.stand.port, settings.stand.speed )
                    } else
                    {
                        _uart.disconnectSerial()
//                        _stand.disconnectSerial()
                    }
                }
            }
        }
    }


    Flickable
    {
        anchors.fill: parent
        anchors.topMargin: 100
        anchors.bottomMargin: 60
        clip: true
        contentHeight: id_clm.height + 100
        contentWidth: parent.width
        ScrollBar.vertical: ScrollBar {}

        ColumnLayout
        {
            id: id_clm
            width: parent.width - 50
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            // Stand config
            CmpBoard
            {
                Layout.fillWidth: true
                height: 300
                Column
                {
                    anchors.centerIn: parent
                    spacing: 10
                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.txtHeaderSize
                        text: "Stand config"
                    }
                    Row
                    {
                        spacing: 20
                        Text { width: 120; text: "ADC config" }
                        ComboBox { id: id_boxAdcCfg1; width: 50; model: _onoffModel }
                        ComboBox { id: id_boxAdcCfg2; width: 50; model: _onoffModel }
                        ComboBox { id: id_boxAdcCfg3; width: 50; model: _onoffModel }
                        ComboBox { id: id_boxAdcCfg4; width: 50; model: _onoffModel }
                    }    // row
                    Row
                    {
                        spacing: 20
                        Text { width: 120; text: "DAC config" }
                        ComboBox { id: id_boxDacCfg1; width: 50; model: _onoffModel }
                        ComboBox { id: id_boxDacCfg2; width: 50; model: _onoffModel }
                    }    // row
                    Row
                    {
                        spacing: 10
                        Column { spacing: 5; Text { text: "PA6" } ComboBox { id: id_boxPa6; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PA7" } ComboBox { id: id_boxPa7; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PA8" } ComboBox { id: id_boxPa8; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PA11" } ComboBox { id: id_boxPa11; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PA12" } ComboBox { id: id_boxPa12; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PA15" } ComboBox { id: id_boxPa15; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB0" } ComboBox { id: id_boxPb0; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB1" } ComboBox { id: id_boxPb1; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB3" } ComboBox { id: id_boxPb3; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB4" } ComboBox { id: id_boxPb4; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB5" } ComboBox { id: id_boxPb5; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB8" } ComboBox { id: id_boxPb8; width: 50; model: _dirModel } }
                    }
                    Row
                    {
                        spacing: 10
                        Column { spacing: 5; Text { text: "PB9" } ComboBox { id: id_boxPb9; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB10" } ComboBox { id: id_boxPb10; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB11" } ComboBox { id: id_boxPb11; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB12" } ComboBox { id: id_boxPb12; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB13" } ComboBox { id: id_boxPb13; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB14" } ComboBox { id: id_boxPb14; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PB15" } ComboBox { id: id_boxPb15; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PC13" } ComboBox { id: id_boxPc13; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PC14" } ComboBox { id: id_boxPc14; width: 50; model: _dirModel } }
                        Column { spacing: 5; Text { text: "PC15" } ComboBox { id: id_boxPc15; width: 50; model: _dirModel } }
                    }
                    Row
                    {
                        spacing: 20
                        Button { width: 80; text: "Get"; onClicked: getConfig() }
                        Button { width: 80; text: "Set"; onClicked: setConfig() }
                    }
                }
            }   // CmpBoard

            // Operation
            CmpBoard
            {
                Layout.fillWidth: true
                height: 220

                Column
                {
                    anchors.centerIn: parent
                    spacing: 10
                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.txtHeaderSize
                        text: "Operation"
                    }
                    Row
                    {
                        spacing: 20
                        Text { width: 100; text: "Get ADC val" }
                        CmpIndicator { id: id_indAdcVal; m_mode: 4; width: 100 }
                        SpinBox { id: id_boxAdcVal; width: 50; from: 1; to: 4 }
                        Button { width: 80; text: "Get"; onClicked: getAdcValue() }
                    }
                    Row
                    {
                        spacing: 20
                        Text { width: 100; text: "Set DAC val" }
                        TextField { id: id_fldDacVal; width: 100; selectByMouse: true }
                        SpinBox { id: id_boxDacVal; width: 50; from: 1; to: 2 }
                        Button { width: 80; text: "Set"; onClicked: setDacValue() }
                    }
                    Row
                    {
                        spacing: 20
                        Text { width: 100; text: "Get PIO val" }
                        CmpIndicator { id: id_indPioVal; m_mode: 2;  width: 100 }
                        ComboBox { id: id_boxGetPio; width: 80; model: _pioModel }
                        Button { width: 80; text: "Get"; onClicked: getPioValue() }
                    }
                    Row
                    {
                        spacing: 20
                        Text { width: 100; text: "Set PIO val" }
                        ComboBox { id: id_boxSetPio; width: 80; model: _pioModel }
                        ComboBox { id: id_boxSetPioMode; width: 80; model: _pioStateModel }
                        Button { width: 80; text: "Set"; onClicked: setPioValue() }
                    }
                    Button
                    {
                        width: 110
                        text: "Test"
                        onClicked: startTest()
                    }
                }

            }   // CmpBoard

            CmpBoard
            {
                Layout.fillWidth: true
                height: 300

                WidgetStandDebug
                {
                    id: id_wStandDebug
                    anchors.fill: parent
                    anchors.margins: 20
                    visible: true
                    standObj: _uart
//                    anchors.bottom: parent.bottom
//                    anchors.bottomMargin: 30
                }
            }
        }    // ColumnLayout
    }    // Flickable

    Component.onCompleted:
    {
        var path = "../product/stand_jcc/StandApi.qml"
        _standApiObj = Qt.createComponent(path).createObject(root, { "_iface" : _uart })

        if (_standApiObj === null)
        {
            showMessage("red", "Can not load Stand API object")
        } else
        {
            showMessage("green", "Stand API object load OK")
        }
    }
}
