/*  Basic initialization of ASC_LR_i0 board in configuration 01_i0b
  * Opt3001 (-)
  * EM      (+)
*/


import QtQuick 2.11
import "../"
import "../../../../tools/db_service.js" as JDbServ

Item
{
    id: root
    property var     _args
    property string  _name: "Bi_ASCi0b_01"
    property bool    _repetition: false

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
            id_test.emWifiWakeup(199)
            _standApiObj.setLoadRelay(0)

            var ret

            // checkStatusVoltage33
            ret = id_test.checkStatusVoltage33(101)
            if (ret === false) { finish(false); return }

            if (_powerSupplyUsed)
            {
                // check on 120V
                ret = id_test.setInputVoltage(102, 120)
                if (ret === false) { finish(false); return }
                // checkValueVoltage33
                ret = id_test.checkValueVoltage33(102)
                if (ret === false) { finish(false); return }
                // checkValueVoltage50
                ret = id_test.checkValueVoltage50(103)
                if (ret === false) { finish(false); return }

                // check on 280V
                ret = id_test.setInputVoltage(102, 280)
                if (ret === false) { finish(false); return }
                // checkValueVoltage33
                ret = id_test.checkValueVoltage33(102)
                if (ret === false) { finish(false); return }
                // checkValueVoltage50
                ret = id_test.checkValueVoltage50(103)
                if (ret === false) { finish(false); return }

                // check on 220V
                ret = id_test.setInputVoltage(102, 220)
                if (ret === false) { finish(false); return }
                // checkValueVoltage33
                ret = id_test.checkValueVoltage33(102)
                if (ret === false) { finish(false); return }
                // checkValueVoltage50
                ret = id_test.checkValueVoltage50(103)
                if (ret === false) { finish(false); return }
            } else
            {
                // checkValueVoltage33
                ret = id_test.checkValueVoltage33(102)
                if (ret === false) { finish(false); return }
                // checkValueVoltage50
                ret = id_test.checkValueVoltage50(103)
                if (ret === false) { finish(false); return }
            }

            // setBaseParameters
            ret = id_test.setBaseParameters(104)
            if (ret === false) { finish(false); return }

            // enableProductionScope
            ret = id_test.enableProductionScope(105)
            if (ret === false) { finish(false); return }

            // checkLoraOscillatorFreq
            ret = id_test.checkLoraOscillatorFreq(106)
            if (ret === false) { finish(false); return }

//            // checkLightSensor
//            ret = id_test.checkLightSensor(107)
//            if (ret === false) { finish(false); return }

            // checkPwmLevel
            ret = id_test.checkPwmLevel(108)
            if (ret === false) { finish(false); return }

            // checkSurgeProtection
            ret = id_test.checkSurgeProtection(109)
            if (ret === false) { console.log("Bi_ASC: end checkSurgeProtection Error"); finish(false); return }

            // checkEmCalibration
            if (_powerSupplyUsed)
            {
                // TODO delete
//                id_test.crashEmCalibration(110)
//                id_test.checkEmCrash(110)

                ret = id_test.checkEmCalibration(110)
                if (ret === false) { finish(false); return }
            }

            // setDeviceInfo
            ret = id_test.setDeviceInfo(111)
            if (ret === false) { finish(false); return }

            // bindDeviceOption
            ret = JDbServ.bindDeviceOption(_dbClient, _objDevice.fid, _args[0])
            if (ret === false) { finish(false); return; }

            // updateDeviceState
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], 999, 0, "Completed")

            finish(true)
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
        var ret = _standApiObj.resetStand(100)
        if (ret === false) { executed(false); return }

        avlog.show("chocolate", "Firmware loading ... Wait!", true, false)
        if (_fwLoadEnabled) _stand.loadFw()
        else onLoadedFw()
    }

    //-----------------------------------------------------------------

    function onLoadedFw()
    {
        avlog.show("green", "Firmware loaded ... OK")
        avlog.show("chocolate", "Board starting ... Wait!", true, false)

//        _testCount++
        id_tim.start()
        _standApiObj.startStand()
    }

    //-----------------------------------------------------------------

    function onErrorFw()
    {
        avlog.show("red", "ERROR!!! Firmware not loaded!", false, true)
        JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], 100, 404, "Error Load firmware")

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
        interval: 12000   // TODO set to 10000
//        onTriggered: execute() //func.process()
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


