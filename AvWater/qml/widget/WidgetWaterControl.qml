import QtQuick 2.11
import QtQuick.Controls 2.5
import "../component"

Item
{
    id: root
    anchors.fill: parent

//    property var   _serial
    property bool  _connected: stand.state
//    property var   _api

    property var _pulseCfg: stand.pulseCfg

    on_PulseCfgChanged:
    {
        if (_standFinded == false) return
        console.log("RET: " + JSON.stringify(_pulseCfg))

        for (var i = 0; i < 4; ++i)
        {
            var ret = _pulseCfg[i]

            var obj = id_rptPulse.itemAt(i)
            obj.indPulseValue = ret.weight / 1000
            obj.fldPulseValue = ret.weight / 1000
            obj.chkPulseEn = ret.enable === 0 ? false : true
            obj.chkPulseMaster = ret.master === 0 ? false : true
        }
    }

    //-----------------------------------------------------------------

//    function reset()
//    {
//        id_indAdc1_1.m_int = 0
//        id_indAdc1_2.m_value = 0
//        id_indAdc2_1.m_value = 0
//        id_indAdc2_2.m_value = 0
//    }

    //-----------------------------------------------------------------

    function getPulseConfig()
    {
        if (_connected === false) return
        stand.readPulseConfig()
    }

    //-----------------------------------------------------------------

    function setPulseConfig()
    {
        if (_connected === false) return

        var cfg = []

        for (var i = 0; i < 4; ++i)
        {
            var obj = id_rptPulse.itemAt(i)

            var ch = {}
            ch.id = i + 1
            ch.weight = parseFloat(obj.fldPulseValue) * 1000
            ch.enable = obj.chkPulseEn === true ? 1 : 0
            ch.master = obj.chkPulseMaster === true ? 1 : 0

            cfg.push(ch)
        }

        stand.writePulseConfig(cfg)
        avlog.show("green", "Set pulse config ... OK!", false, false)
    }

    //-----------------------------------------------------------------

    function resetPulseConfig()
    {
        if (_connected === false) return

        stand.resetPulseConfig()
        avlog.show("green", "Reset pulse config ... OK!", false, false)
    }
    //-----------------------------------------------------------------

    function startTest()
    {
        if (_connected === false) return
        resultModel.clear()

        var mode = id_boxMode.currentIndex
        var vol = parseFloat(id_fldVolume.text)
        var modeName = id_boxMode.currentText

        var cfg = {}
        cfg["mode"] = mode
        cfg["volume"] = vol * 1000

        stand.startTest(cfg)
        _testDescr = modeName + " (" + vol + "L)"
        _testImg1 = ""
        _testImg2 = ""
        avlog.show("chocolate", "Test start in mode " + modeName + " (" + vol + "L) ... Wait!", true, false)
    }

    //-----------------------------------------------------------------

    function stopTest()
    {
        if (_connected === false) return
        resultModel.clear()

        stand.stopTest()
        avlog.show("chocolate", "Test stopped ... OK!", false, false)
    }

    //-----------------------------------------------------------------

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
                        CmpIndicator { id: id_indPulse; m_mode: 3; width: 100;  }
                        TextField
                        {
                            id: id_fldPulse
                            width: 100
                            validator: id_regExpVolume
                            placeholderText: "L/p"
                            selectByMouse: true
                            enabled: !_testStarted
                        }
                        CheckBox { id: id_chkPulseEn; text: "Enable"; enabled: !_testStarted }
                        CheckBox
                        {
                            id: id_chkPulseMaster;
                            text: "Master";
                            enabled: !_testStarted
                            ButtonGroup.group: masterGroup
                        }
                    }
                }
            }
        }   // column

        Row
        {
            spacing: 10
            Button { width: 80; enabled: _connected && !_testStarted; text: "Get"; onClicked: getPulseConfig() }
            Button { width: 80; enabled: _connected && !_testStarted; text: "Set"; onClicked: setPulseConfig() }
            Button { width: 80; enabled: _connected && !_testStarted; text: "Reset"; onClicked: resetPulseConfig() }
        }

        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Operation" }

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
                    enabled: !_testStarted
                    onCurrentIndexChanged:
                    {
                        console.log("!!!!!!!!! Index changed")
                        _testMode = id_boxMode.currentIndex
                    }
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
                    enabled: !_testStarted
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
                    if (_testStarted) stopTest()
                    else startTest()
                }
            }
//            Text
//            {
//                anchors.bottom: parent.bottom
//                anchors.bottomMargin: 5
//                text: "[ Ctrl + S ]"
//            }
        }   // row
    }   // column

//    Shortcut
//    {
//        sequences: ["Ctrl+S"];
//        onActivated:
//        {
//            if (!_standFinded) return
//            if (_testStarted) stopTest()
//            else startTest()
//        }
//    }

}

