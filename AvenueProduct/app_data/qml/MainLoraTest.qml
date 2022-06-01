import QtQuick 2.11
import QtQuick.Window 2.11
//import QtQuick.Controls 1.4
import QtQuick.Controls 2.5
import "./component"

Window
{
    id: id_mainWindow
    visible: true
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600
    title: qsTr("AvLoraTest")

    property bool   _rw: settings.conf.adminMode
    property var    _uart: new SerialClient("flag")
    property string _time: Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss")
    property string _devEui
    property bool   _connected: _uart.state
    property int    _labelWidth: 110

    property var _mode: [
        {
            "mode" : "Stop",
            "descr" : "Stop any carier",
            "cmd" : 0
        },
        {
            "mode" : "Unmodulated",
            "descr" : "Send unmodulated carrier",
            "cmd" : 1
        },
        {
            "mode" : "Lora continuos",
            "descr" : "Send Lora modulated carier continuos mode",
            "cmd" : 2
        },
        {
            "mode" : "Lora periodical",
            "descr" : "send Lora modulated periodical frame",
            "cmd" : 3
        },
        {
            "mode" : "Receive",
            "descr" : "Receive mode",
            "cmd" : 5
        }
    ]

    property var _sf: [ "SF6", "SF7", "SF8", "SF9", "SF10", "SF11", "SF12" ]
    property var _band: [ "7.8", "10.4", "15.6", "20.8", "31.25", "41.7", "62.5", "125", "250", "500" ]
    property var _presets

    //-----------------------------------------------------------------

    on_ConnectedChanged:
    {
        if (_connected)
        {
            showMessage("darkgreen", "Port openned!")
            getTestData()
        } else
        {
            showMessage("darkgreen", "Port closed!")
        }
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

    function isSettingsValid()
    {
        if (!id_txtFreq.acceptableInput)
        {
            showMessage("red", "Error! Invalid frequency!")
            return false
        }
        return true
    }

    //-----------------------------------------------------------------

    function readPresets()
    {
        var path = AppPath + "app_data/conf/testPresets.json"
        _presets = JSON.parse(file.getFileAsString(path))
        sortByKey(_presets.presets, "name")
        id_boxPresets.model = _presets.presets
    }

    //-----------------------------------------------------------------

    function loadPreset()
    {
        var idx = id_boxPresets.currentIndex
        id_txtFreq.text = _presets.presets[idx].freq
        id_boxBand.currentIndex = _presets.presets[idx].band

//        id_boxMode.currentIndex = _presets.presets[idx].mode
//        id_boxPower.value = _presets.presets[idx].txPow
//        id_boxSf.currentIndex = _presets.presets[idx].sf
//        id_txtTimOn.text = _presets.presets[idx].timOn
//        id_txtTimOff.text = _presets.presets[idx].timOff

        showMessage("darkgreen", "Profile loaded!")
    }

    //-----------------------------------------------------------------

    function delPreset()
    {
        var name = id_boxPresets.currentText
        for (var i = 0; i < _presets.presets.length; ++i) if (_presets.presets[i].name === name) _presets.presets.splice(i, 1)

        var path = AppPath + "app_data/conf/testPresets.json"
        var res = file.saveFileAsJsonDoc(path, _presets)
        if (res === true)
        {
            showMessage("darkgreen", "Profile deleted!")
        } else
        {
            showMessage("red", "Can not delete profile!")
            return
        }
        readPresets()
    }

    //-----------------------------------------------------------------

    function savePreset()
    {
        if (id_txtPresets.text === "") { showMessage("red", "Error! Empty name of preset!"); return }
        if (!isSettingsValid()) return

        var rec = {}
        rec.name = id_txtPresets.text
        rec.freq = id_txtFreq.text
        rec.band = id_boxBand.currentIndex
//        rec.mode = id_boxMode.currentIndex
//        rec.txPow = id_boxPower.value
//        rec.sf = id_boxSf.currentIndex
//        rec.timOn = id_txtTimOn.text
//        rec.timOff = id_txtTimOff.text

        for (var i = 0; i < _presets.presets.length; ++i)
        {
            if (_presets.presets[i].name === rec.name)
            {
                _presets.presets.splice(i, 1)
                break
            }
        }
        _presets.presets.push(rec)

        var path = AppPath + "app_data/conf/testPresets.json"
        sortByKey(_presets.presets, "name")
        var res = file.saveFileAsJsonDoc(path, _presets)
        if (res === true)
        {
            showMessage("darkgreen", "Profile saved!")
        } else
        {
            showMessage("red", "Can not save profile!")
            return
        }
        id_txtPresets.clear()
        readPresets()
    }

    //-----------------------------------------------------------------

    function getTestData()
    {
        if (!_connected) return

        var FuncLoraCode = 0x01
        var FuncLoraGetTest =  0x74

        var cmd = new Uint8Array(3)
        cmd[0] = 0x03
        cmd[1] = FuncLoraCode
        cmd[2] = FuncLoraGetTest

        var resp
        var count = 0
        _uart.sendData(cmd.buffer)
        do
        {
            resp = _uart.getRespAsBin()
            count++
            wait(100)
        } while (resp.length === 0 && count < 5)

        if (resp.length !== 19 || resp[1] !== FuncLoraCode || resp[2] !== FuncLoraGetTest)
        {
            showMessage("red", "Get test settings: Device response error or timeout expired!")
            return
        }
        var data = new Uint8Array(resp)
        var mode = "Unknown"
        var modeCmd = 0
        for (var i = 0; i < _mode.length; ++i)
        {
            if (_mode[i].cmd === resp[3])
            {
                mode = _mode[i].mode
                modeCmd = _mode[i].cmd
            }
        }

        id_indMode.m_str = mode
        id_indFreq.m_int = util.arrayToInt(data.buffer, 4, 4)
        id_indPower.m_value = resp[8]
        id_indSf.m_str = resp[9] < 6 ? _sf[resp[9]] : _sf[resp[9] - 6]
        id_indBand.m_str = _band[resp[10]]
        id_indTimOn.m_value = util.arrayToInt(data.buffer, 11, 4)
        id_indTimOff.m_value = util.arrayToInt(data.buffer, 15, 4)
        showMessage("darkgreen", "Test settings: Successful!")

        if (modeCmd === 5)
        {
            var path = AppPath + "app_data/qml/component/CmpLoraRxPopup.qml"
            Qt.createComponent("./component/CmpLoraRxPopup.qml").createObject(id_mainWindow)
        }
    }

    //-----------------------------------------------------------------

    function setTestData()
    {
        if (!_connected || !isSettingsValid()) return

        var FuncLoraCode = 0x01
        var FuncLoraSetTest =  0x75

        var cmd = new Uint8Array(19)
        cmd[0] = 19
        cmd[1] = FuncLoraCode
        cmd[2] = FuncLoraSetTest
        cmd[3] = _mode[id_boxMode.currentIndex]["cmd"]

        var freq = util.intToArray(parseInt(id_txtFreq.text), 4);
        cmd.set(freq, 4)
        cmd[8] = id_boxPower.value
        cmd[9] = id_boxSf.currentIndex + 6
        cmd[10] = id_boxBand.currentIndex

        var timOn = util.intToArray(parseInt(id_txtTimOn.text), 4)
        cmd.set(timOn, 11)

        var timOff = util.intToArray(parseInt(id_txtTimOff.text), 4)
        cmd.set(timOff, 15)

        var resp
        var count = 0
        _uart.sendData(cmd.buffer)
        do
        {
            resp = _uart.getRespAsBin()
            count++
            wait(100)
        } while (resp.length === 0 && count < 5)

        if (resp.length !== 3 || resp[1] !== FuncLoraCode || resp[2] !== FuncLoraSetTest)
        {
            showMessage("red", "Set test settings: Device response error or timeout expired!")
            return
        }
        wait(100)
        getTestData()
    }

    //-----------------------------------------------------------------

    function resetTestData()
    {
        if (!_connected) return

        var FuncLoraCode = 0x01
        var FuncLoraResetTest =  0x76

        var cmd = new Uint8Array(3)
        cmd[0] = 0x03
        cmd[1] = FuncLoraCode
        cmd[2] = FuncLoraResetTest

        var resp
        var count = 0
        _uart.sendData(cmd.buffer)
        do
        {
            resp = _uart.getRespAsBin()
            count++
            wait(100)
        } while (resp.length === 0 && count < 5)

        if (resp.length !== 3 || resp[1] !== FuncLoraCode || resp[2] !== FuncLoraResetTest)
        {
            showMessage("red", "Reset test settings: Device response error or timeout expired!")
            return
        }
        wait(100)
        getTestData()
    }

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
        text: _devEui
    }

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
                    if (!_connected) _uart.connectSerial(settings.uart.port, settings.uart.speed, "even", "1", "sw" )
                    else _uart.disconnectSerial()
                }
            }
        }
    }

    Column
    {
        anchors.top: id_clmTop.bottom
        anchors.topMargin: 15
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: 15

        CmpBoard
        {
            id: id_cmpBoard
            width: parent.width - 50
            anchors.horizontalCenter: parent.horizontalCenter
            height: 50

            Row
            {
                anchors.centerIn: parent
                spacing: 15
                Text { anchors.verticalCenter: parent.verticalCenter; text: "Presets" }
                ComboBox { id: id_boxPresets; width: 170; textRole: "name"; model: _presets.presets; visible: _presets.presets.length > 0 ? true : false }
                Button { width: 60; text: "Load"; onClicked: loadPreset(); visible: _presets.presets.length > 0 ? true : false }
                Button { width: 60; text: "Del"; onClicked: delPreset(); visible: _presets.presets.length > 0 && _rw ? true : false }
                Text { text: "        " }   // separator
                TextField
                {
                    id: id_txtPresets
                    width: 170
                    visible: _rw ? true : false
                    onAccepted: savePreset()
//                    onPressed: text = id_txtFreq.text.slice(0, 3) + "." + id_txtFreq.text.charAt(3) + "MHz_" + id_boxBand.currentText + "kHz"
                    onPressed: text = id_boxBand.currentText + "kHz_" + id_txtFreq.text.slice(0, 3) + "." + id_txtFreq.text.charAt(3) + "MHz"
                }
                Button  { width: 60; text: "Save"; onClicked: savePreset(); visible: _rw ? true : false }
            }
        }

        CmpBoard
        {
            id: id_cmpBoard2
            width: parent.width - 50
            height: 380
            anchors.horizontalCenter: parent.horizontalCenter

            Text
            {
                anchors.top: parent.top; anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Test Settings"
                font.pixelSize: 16
            }

            Grid
            {
                id: id_grid
                anchors.top: parent.top
                anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                verticalItemAlignment: Grid.AlignVCenter
                columns: 3
                spacing: 15

                // Frequency
                Text { width: _labelWidth; text: "Frequency, Hz" }
                CmpIndicator { id: id_indFreq; width: 120; m_mode: 4 }
                TextField
                {
                    id: id_txtFreq
                    width: 120
                    text: "863000000"
                    color: id_txtFreq.acceptableInput ? "black" : "red"
                    validator: IntValidator { bottom: 863000000; top: 870000000 }
                }

                // Bandwitch
                Text { width: _labelWidth; text: "Bandwidth, kHz" }
                CmpIndicator { id: id_indBand; width: 100; m_mode: 2 }
                ComboBox
                {
                    id: id_boxBand
                    width: 80
                    model: _band
                }

                // Mode
                Text { width: _labelWidth; text: "Mode" }
                CmpIndicator { id: id_indMode; width: 150; m_mode: 2 }
                ComboBox
                {
                    id: id_boxMode
                    width: 150
                    textRole: "mode"
                    model: _mode
                }

                // Tx Power
                Text { width: _labelWidth; text: "Tx Power, dBm" }
                CmpIndicator { id: id_indPower; width: 100 }
                SpinBox
                {
                    id: id_boxPower
                    width: 50
                    from: 0
                    to: 14
//                    maximumValue: 14
                }

                // Spread Factor
                Text { width: _labelWidth; text: "Spread Factor" }
                CmpIndicator { id: id_indSf; width: 100; m_mode: 2 }
                ComboBox
                {
                    id: id_boxSf
                    width: 80
                    model: _sf
                }

                // Time ON
                Text { width: _labelWidth; text: "Time ON, ms" }
                CmpIndicator { id: id_indTimOn; width: 100 }
                TextField
                {
                    id: id_txtTimOn
                    width: 100
                    validator: IntValidator { bottom: 0 }
                    text: "20"
                }

                // Time OFF
                Text { width: _labelWidth; text: "Time OFF, ms" }
                CmpIndicator { id: id_indTimOff; width: 100 }
                TextField
                {
                    id: id_txtTimOff
                    width: 100
                    validator: IntValidator { bottom: 0 }
                    text: "20"
                }
            }   // Grid

            Rectangle
            {
                anchors.fill: id_grid
                color: "transparent"
                visible: _rw ? false : true

                MouseArea { anchors.fill: parent }
            }

            Row
            {
                anchors.top: id_grid.bottom
                anchors.topMargin: 15
                anchors.right: id_grid.right
                spacing: 20
                Button  { width: 80; text: "Reset"; onClicked: resetTestData() }
                Button  { width: 80; text: "Get"; onClicked: getTestData() }
                Button  { width: 80; text: "Set"; onClicked: setTestData() }
            }
        }   // CmpBoard
    } // Column

    Component.onCompleted:
    {
        readPresets()
    }
}
