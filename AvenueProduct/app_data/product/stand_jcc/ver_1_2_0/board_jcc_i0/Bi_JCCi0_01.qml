/*  Basic initialization of JCCv2_i0 board in configuration 01_i0b
  * Opt3001 (-)
  * EM      (-)
*/


import QtQuick 2.11
import "../"
import "../../../../tools/db_service.js" as JDbServ
import "../../../ErrorCodes.js" as Codes

Item
{
    id: root
    anchors.fill: parent
    property var     _args
    property string  _name: "Bi_JCCi0_01"
    property bool    _repetition: true

    // TODO delete
    property int _testCount: 1

    signal executed(bool res)
    signal stop()

    QtObject
    {
        id: func

        function finish(res)
        {
//            console.log("!!!!!!!!!!!!!!!! Finish test: " + _testCount)
//            if (_testCount <= 10)
//            {
//                _power.loadOff()
//                wait(1000)
//                _standApiObj.resetStand()
//                wait(2000)
//                _power.loadOn()
//                wait(1000)
//                _standApiObj.startStand()

//                _testCount++
//                id_tim.interval = 100
//                id_tim.start()
//                return
//            }

            if (res === true) { executed(true); return }
            if (_repetition === true) { executed(false); return }

            _power.loadOff()
            wait(1000)
            _standApiObj.resetStand()
            wait(2000)
            _power.loadOn()
            wait(1000)
            _standApiObj.startStand()

            _repetition = true
            id_tim.interval = 100
            id_tim.start()
        }

        function process()
        {
//            console.log("!!!!!!!!!!!!!!!! Start test: " + _testCount)

            // Prepare test
            id_test.emWifiWakeup()
            _standApiObj.setLoadRelay(0)

            var ret

            // checkValueVoltage33
            ret = id_test.checkValueVoltage33()
            if (ret === false) { finish(false); return }

            // checkValueVoltage39
            ret = id_test.checkValueVoltage39()
            if (ret === false) { finish(false); return }

            // checkValueVoltage15
            ret = id_test.checkValueVoltage15()
            if (ret === false) { finish(false); return }

            // jcc_internalDiagnostic
            ret = id_test.jcc_internalDiagnostic()
            if (ret === false) { finish(false); return }

            // setBaseParameters
            ret = id_test.setBaseParameters()
            if (ret === false) { finish(false); return }

            // enableProductionScope
            ret = id_test.enableProductionScope()
            if (ret === false) { finish(false); return }

            // checkLoraOscillatorFreq
            ret = id_test.checkLoraOscillatorFreq()
            if (ret === false) { finish(false); return }

            // setDeviceInfo
            ret = id_test.setDeviceInfo()
            if (ret === false) { finish(false); return }

            // bindDeviceOption
            ret = JDbServ.bindDeviceOption(_dbClient, _objDevice.fid, _args[0])
            if (ret === false) { finish(false); return; }

            // updateDeviceState
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageFinish, Codes.CodeOk, "Completed")

            finish(true)
        }    // process

        function startingTests()
        {
            // jcc_checkStart
            var ret = id_test.jcc_checkStart()
            if (ret === false) { finish(false); return }

            avlog.show("chocolate", "Check JCC LEDs ... ", true, false)

            var ledObj = Qt.createComponent("JccLedCheck.qml").createObject(root)
            if (ledObj === null)
            {
                console.log("Work stopped: JccLedCheck.qml load error")
                avlog.show("red", "ERROR!!! Can not load JccLedCheck object", false, true)
                avlog.show("red", "Work stopped!!!")
                return
            }
            ledObj.ledChecked.connect(onLedChecked)
        }
    }

    //-----------------------------------------------------------------

    function execute()
    {
//        if (_testCount > 20)
//        {
//            console.log("Test finished")
//            avlog.show("chocolate", "Firmware loading test ... finished!", false, false)
//            return
//        }
//        console.log("!!!!!!!!!!!!!!!!!!!!!!! Start Firmware loading test " + _testCount)

        _stand.resetLoadStatus()

        // resetStand
        var ret = _standApiObj.resetStand()
        if (ret === false) { executed(false); return }

        wait(1000)
        _standApiObj.startStand()

        // checkValueVoltage33
        ret = id_test.checkValueVoltage33()
        if (ret === false) { executed(false); return }

        // checkValueVoltage39
        ret = id_test.checkValueVoltage39()
        if (ret === false) { executed(false); return }

        avlog.show("chocolate", "Firmware loading ... Wait!", true, false)
        if (_fwLoadEnabled) _stand.loadFw()
        else onLoadedFw()
    }

    //-----------------------------------------------------------------

    function onLedChecked(res)
    {
        console.log("onLedChecked: " + res)
        if (res === false)
        {
            avlog.show("red", Codes.CodeJccLeds + ": ERROR: JCC LEDs!", false, true)
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageBasicInit, Codes.CodeJccLeds, "Error JCC LEDs")
            executed(false)
            return
        }

        avlog.show("green", "JCC LEDs checked ... OK")
        id_tim2.start()
    }

    //-----------------------------------------------------------------

    function onLoadedFw()
    {
        avlog.show("green", "Firmware loaded ... OK")
        avlog.show("chocolate", "Board starting ... Wait!", true, false)
        wait(1000)

//        _testCount++
        id_tim.start()
        _standApiObj.startStand()
//        wait(3000)
    }

    //-----------------------------------------------------------------

    function onErrorFw()
    {
        avlog.show("red", Codes.CodeFirmwareError + ": ERROR: Firmware not loaded!", false, true)
        JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageBasicInit, Codes.CodeFirmwareError, "Error Load firmware")

//        _testCount++
//        id_tim.start()
        executed(false)
    }

    //-----------------------------------------------------------------

    BaseTests { id: id_test }

    Timer
    {
        id: id_tim
        running: false
        repeat: false
        interval: 17000
//        onTriggered: execute() //func.process()
        onTriggered: func.startingTests()
    }

    Timer
    {
        id: id_tim2
        running: false
        repeat: false
        interval: 1000
        onTriggered: func.process()
    }

    Component.onCompleted:
    {
        console.log(_name + " completed")
        _stand.loaded.connect(onLoadedFw)
        _stand.error.connect(onErrorFw)
    }
    Component.onDestruction:
    {
        _stand.loaded.disconnect(onLoadedFw)
        _stand.error.disconnect(onErrorFw)
        console.log(_name + " destruction")
    }
}


