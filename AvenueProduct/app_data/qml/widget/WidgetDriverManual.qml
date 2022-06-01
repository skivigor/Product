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
    property bool  _wait: false

    on_ConnectedChanged:
    {
        if (_waiting === true) return
        if (_connected) id_tim.start()
        else reset()
    }

    //-----------------------------------------------------------------

    function reset()
    {
        id_indAdc1_1.m_int = 0
        id_indAdc1_2.m_value = 0
        id_indAdc2_1.m_value = 0
        id_indAdc2_2.m_value = 0
    }

    //-----------------------------------------------------------------

    function checkStand()
    {
        console.log("checkStand manual")
        if (_connected === false) return
        _wait = true
        var ret = _api.checkStand()
        _wait = false
        if (ret === false) _serial.disconnectSerial()
    }

    //-----------------------------------------------------------------

    function getAdcValue(id)
    {
        if (_connected === false) return
        _wait = true

        var val = _api.getAdcValue(id)
        if (val === false) { _wait = false; return }

        if (id === 1)
        {
            id_indAdc1_1.m_int = val.ch1
            id_indAdc1_2.m_value = val.ch2 / 10
        }
        if (id === 2)
        {
            id_indAdc2_1.m_value = val.ch1 / 10
            id_indAdc2_2.m_value = val.ch2 / 10
        }
        _wait = false
    }


    //-----------------------------------------------------------------

    function setPioValue(id, val)
    {
        if (_connected === false) return
        _wait = true
        var ret = _api.setPioValue(id, val)
        _wait = false
    }

    //-----------------------------------------------------------------

    function setPwmLevel(lvl)
    {
        if (_connected === false) return
        _wait = true
        var ret = _api.setPwmLevel(lvl)
        _wait = false
    }

    Timer
    {
        id: id_tim
        running: false
        repeat: false
        interval: 100
        onTriggered: checkStand()
    }

    Column
    {
        anchors.centerIn: parent
        spacing: 10

        Row
        {
            spacing: 20
            Image { source: _connected ? "../../images/online_32.png" : "../../images/offline_32.png" }
            ComboBox
            {
                id: id_boxSerial
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                enabled: !_connected && !_waiting
                model: serialPorts
            }
            Button
            {
                width: 80
                anchors.verticalCenter: parent.verticalCenter
                enabled: !_wait && !_waiting
                text: _connected ? "Close" : "Open"
                onClicked:
                {
                    if (!_connected) _serial.connectSerial(id_boxSerial.currentText, 57600 )
                    else _serial.disconnectSerial()
                }
                Keys.onReturnPressed:
                {
                    if (!_connected) _serial.connectSerial(id_boxSerial.currentText, 57600 )
                    else _serial.disconnectSerial()
                }
            }
            BusyIndicator
            {
                running: _wait
            }
        }   // row

        Row
        {
            spacing: 20
            Text { width: 40; text: "Relay" }
            ComboBox { id: id_boxRel1; width: 80; enabled: !_waiting; model: _onoffModel }
            Button { width: 60; text: "Set"; enabled: _connected && !_wait && !_waiting;
                onClicked: setPioValue(1, id_boxRel1.currentIndex); Keys.onReturnPressed: setPioValue(1, id_boxRel1.currentIndex) }
        }

        Row
        {
            spacing: 20
            Text { width: 40; text: "PWM" }
            TextField { id: id_fldPwm; width: 80; enabled: !_waiting; validator: IntValidator{ bottom: 0; top: 100 }
                selectByMouse: true; text: "0"; onAccepted: setPwmLevel(parseInt(id_fldPwm.text)) }
            Button { width: 60; text: "Set"; enabled: _connected && !_wait && !_waiting;
                onClicked: setPwmLevel(parseInt(id_fldPwm.text)); Keys.onReturnPressed: setPwmLevel(parseInt(id_fldPwm.text)) }
        }
        Row
        {
            spacing: 20
            Text { width: 40; text: "ADC1" }
            CmpIndicator { id: id_indAdc1_1; m_mode: 4; width: 100;  }
            CmpIndicator { id: id_indAdc1_2; m_mode: 3; m_toFix: 1; width: 100 }
            Button { width: 60; text: "Get"; enabled: _connected && !_wait && !_waiting;
                onClicked: getAdcValue(1); Keys.onReturnPressed: getAdcValue(1) }
        }
        Row
        {
            spacing: 20
            Text { width: 40; text: "ADC2" }
            CmpIndicator { id: id_indAdc2_1; m_mode: 3; m_toFix: 1; width: 100 }
            CmpIndicator { id: id_indAdc2_2; m_mode: 3; m_toFix: 1; width: 100 }
            Button { width: 60; text: "Get"; enabled: _connected && !_wait && !_waiting;
                onClicked: getAdcValue(2); Keys.onReturnPressed: getAdcValue(2) }
        }

    }   // column
}

