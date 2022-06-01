import QtQuick 2.11
import QtQuick.Controls 2.5
import "../component/CmpStyle.js" as Style
import "../component"
//import "../widget"

Item
{
    id: root
    anchors.fill: parent

    property var   _serial
    property bool  _connected: _serial.state
    property var   _onoffModel: ["OFF", "ON"]
    property var   _api

    property int _cmd: 0    // 1 - getPulseConfig(), 2 - setPulseConfig(), 3 - resetPulseConfig(), 4 - startTest(), 5 - stopTest()
    //    property bool  _wait: false

    //    property var  _varPulse: [
    //        {
    //            "weight": 23.15,
    //            "enable": 1,
    //            "master": 0
    //        },
    //        {
    //            "weight": 189.2,
    //            "enable": 0,
    //            "master": 0
    //        },
    //        {
    //            "weight": 0.15,
    //            "enable": 1,
    //            "master": 0
    //        },
    //        {
    //            "weight": 123.153,
    //            "enable": 1,
    //            "master": 1
    //        }

    //    ]

    //    on_ConnectedChanged:
    //    {
    //        if (_waiting === true) return
    //        if (_connected) getPulseConfig()
    ////        else reset()
    //    }



    //-----------------------------------------------------------------

    function reset()
    {
        id_indAdc1_1.m_int = 0
        id_indAdc1_2.m_value = 0
        id_indAdc2_1.m_value = 0
        id_indAdc2_2.m_value = 0
    }

    //-----------------------------------------------------------------

    function getPulseConfig()
    {
        if (_connected === false) return

        for (var i = 0; i < _channelNum; ++i)
        {
            var ret = _api.getPulseConfig(i + 1)
            console.log("Get Pulse config RET: " + JSON.stringify(ret))
            if (ret === false)
            {
                // TODO processing
                return
            }
            //            var ret = _varPulse[i]

            var obj = id_rptPulse.itemAt(i)
            obj.indPulseValue = ret.weight
            obj.fldPulseValue = ret.weight
            obj.chkPulseEn = ret.enable === 0 ? false : true
            obj.chkPulseMaster = ret.master === 0 ? false : true
        }
    }

    //-----------------------------------------------------------------

    function setPulseConfig()
    {
        if (_connected === false) return

        for (var i = 0; i < _channelNum; ++i)
        {
            var obj = id_rptPulse.itemAt(i)

            var cfg = {}
            cfg.id = i + 1
            cfg.weight = parseFloat(obj.fldPulseValue)
            cfg.enable = obj.chkPulseEn === true ? 1 : 0
            cfg.master = obj.chkPulseMaster === true ? 1 : 0

            console.log("Set cfg " + (i + 1) + ": " + JSON.stringify(cfg))

            var ret = _api.setPulseConfig(cfg)
            if (ret === false)
            {
                // TODO processing
                avlog.show("red", "Reset pulse config ... Error!", false, false)
                return
            }
        }

        getPulseConfig()
        avlog.show("green", "Set pulse config ... OK!", false, false)
    }

    //-----------------------------------------------------------------

    function resetPulseConfig()
    {
        if (_connected === false) return

        for (var i = 0; i < _channelNum; ++i)
        {
            console.log("Reset pulse config: " + (i + 1))
            var ret = _api.resetPulseConfig(i + 1)
            if (ret === false)
            {
                // TODO processing
                avlog.show("red", "Reset pulse config ... Error!", false, false)
                return
            }
        }

        getPulseConfig()
        avlog.show("green", "Reset pulse config ... OK!", false, false)
    }

    //-----------------------------------------------------------------

    function setKey()
    {
        // if (_connected === false) return
        var code = 1 << id_boxKey.currentIndex
        console.log("Key: " + code)

        var ret = _api.setKey(code)
        if (ret === false)
        {
            // TODO processing
            return
        }
    }

    //-----------------------------------------------------------------

    function startTest()
    {
        if (_connected === false) return
        resultModel.clear()

        var mode = id_boxMode.currentIndex
        var vol = parseFloat(id_fldVolume.text)
        var modeName = id_boxMode.currentText

        var ret = _api.start(mode, vol)
        if (ret === false)
        {
            // TODO processing
            avlog.show("red", "Test start in mode " + modeName + " (" + vol + "L) ... Error!", false, false)
            return
        }

        avlog.show("chocolate", "Test started in mode " + modeName + " (" + vol + "L) ... Wait!", true, false)
        _testStarted = true
    }

    //-----------------------------------------------------------------

    function stopTest()
    {
        if (_connected === false) return
        resultModel.clear()

        var ret = _api.stop()
        if (ret === false)
        {
            // TODO processing
            return
        }

        avlog.show("chocolate", "Test stopped ... OK!", false, false)
        _testStarted = false
    }

    //-----------------------------------------------------------------

    Timer
    {
        id: id_tim
        running: true
        repeat: true
        interval: 50
        onTriggered:
        {
            // 1 - getPulseConfig(), 2 - setPulseConfig(), 3 - resetPulseConfig(), 4 - startTest(), 5 - stopTest()
            if (_cmd === 0 || _waiting === true) return

            _waiting = true
            id_tim.stop()

            if (_cmd === 1) { console.log("!!!!!!!!!!!!!!!!! $$$$$$$$$$$$$ getPulseConfig()"); getPulseConfig() }
            if (_cmd === 2) { console.log("!!!!!!!!!!!!!!!!! $$$$$$$$$$$$$ setPulseConfig()"); setPulseConfig() }
            if (_cmd === 3) { console.log("!!!!!!!!!!!!!!!!! $$$$$$$$$$$$$ resetPulseConfig()"); resetPulseConfig() }
            if (_cmd === 4) { console.log("!!!!!!!!!!!!!!!!! $$$$$$$$$$$$$ startTest()"); startTest() }
            if (_cmd === 5) { console.log("!!!!!!!!!!!!!!!!! $$$$$$$$$$$$$ stopTest()"); stopTest() }

            _waiting = false
            _cmd = 0
            id_tim.start()
        }

    }

    ButtonGroup { id: masterGroup; }

    Column
    {
        anchors.centerIn: parent
        spacing: 10

        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Pulse config" }

        Column
        {
            width: 400
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 1
            Repeater
            {
                id: id_rptPulse
                model: _channelNum
                delegate: Item {
                    width: root.width
                    height: 30

                    property alias indPulseValue: id_indPulse.m_value
                    property alias fldPulseValue: id_fldPulse.text
                    property alias chkPulseEn: id_chkPulseEn.checked
                    property alias chkPulseMaster: id_chkPulseMaster.checked

                    Row
                    {
                        spacing: 10
                        Text { text: "Ch" + (index + 1) }
                        CmpIndicator { id: id_indPulse; m_mode: 1; width: 100;  }
                        TextField
                        {
                            id: id_fldPulse
                            width: 100
                            validator: id_regExpVolume
                            placeholderText: "L/p"
                            selectByMouse: true
                        }
                        CheckBox { id: id_chkPulseEn; text: "Enable" }
                        CheckBox
                        {
                            id: id_chkPulseMaster;
                            text: "Master";
                            ButtonGroup.group: masterGroup
                        }
                    }
                }
            }
        }   // column

        Row
        {
            spacing: 10
            Button { width: 80; enabled: _standFinded && !_testStarted; text: "Get"; onClicked: _cmd = 1 }
            Button { width: 80; enabled: _standFinded && !_testStarted; text: "Set"; onClicked: _cmd = 2 }
            Button { width: 80; enabled: _standFinded && !_testStarted; text: "Reset"; onClicked: _cmd = 3 }
        }

        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Operation" }

        //        Row
        //        {
        //            spacing: 10
        //            Column
        //            {
        //                spacing: 1
        //                Text { text: "Key code" }
        //                ComboBox
        //                {
        //                    id: id_boxKey
        //                    width: 100
        //                    model: ["F1", "F2", "Zero", "T"]
        //                }
        //            }
        //            Button
        //            {
        //                anchors.bottom: parent.bottom
        //                width: 80
        //                text: "Set"
        //                onClicked: testList() //setKey()
        //            }
        //        }   // row

        Row
        {
            spacing: 10
            Column
            {
                spacing: 1
                Text { text: "Mode" }
                ComboBox
                {
                    id: id_boxMode
                    width: 100
                    model: ["Scale", "Meter"]
                }
            }
            Column
            {
                spacing: 1
                Text { text: "Volume, L" }
                TextField
                {
                    id: id_fldVolume
                    width: 100
                    text: "10.0"
                    validator: id_regExpVolume
                    selectByMouse: true
                }
            }
            Button
            {
                anchors.bottom: parent.bottom
                width: 80
                enabled: _standFinded
                text: _testStarted ? "Stop" : "Start"
                onClicked:
                {
                    if (_testStarted) _cmd = 5
                    else _cmd = 4
                }
            }
            Text
            {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                text: "[ Ctrl + S ]"
            }
        }   // row
    }   // column

    Shortcut
    {
        sequences: ["Ctrl+S"];
        onActivated:
        {
            if (!_standFinded) return
            if (_testStarted) _cmd = 5
            else _cmd = 4
        }
    }

}

