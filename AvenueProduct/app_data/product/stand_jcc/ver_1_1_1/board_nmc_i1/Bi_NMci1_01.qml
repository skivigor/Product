import QtQuick 2.11
import "../"
import "../../../../tools/db_service.js" as JDbServ

Item
{
    id: root
    property var     _args
    property string  _name: "Bi_NMci1_01"
    property bool    _repetition: false

    signal executed(bool res)
    signal stop()

    QtObject
    {
        id: func

        function finish(res)
        {
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

            // checkLightSensor
//            var lvl = _fwApi.getLsLightLevel(1)
//            if (lvl === false)
//            {
//                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], 107, 402, "Error: get light level")
//                avlog.show("red", "ERROR!!! Get light level", false, true)
//                finish(false)
//                return
//            }
//            console.log("!!!!!! Light sensor level: " + lvl)
//            var min = 5
//            var max = 10000
//            if (lvl < min || lvl > max)
//            {
//                JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], 107, 403, "Error: light level: " + lvl + " lux out of range " + min + "-" + max)
//                avlog.show("red", "ERROR!!! Get light level: " + lvl + " lux out of range " + min + "-" + max, false, true)
//                finish(false)
//                return
//            }

            // checkEmCalibration
//            if (_powerSupplyUsed)
//            {
//                ret = id_test.checkEmCalibration(108)
//                if (ret === false) { finish(false); return }
//            } else
//            {
//                ret = id_test.checkEm(108)
//                if (ret === false) { finish(false); return }
//            }

            // setDeviceInfo
            ret = id_test.setDeviceInfo(109)
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
        id_tim.start()
        _standApiObj.startStand()
    }

    //-----------------------------------------------------------------

    function onErrorFw()
    {
        avlog.show("red", "ERROR!!! Firmware not loaded!", false, true)
        JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], 100, 404, "Error Load firmware")
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


