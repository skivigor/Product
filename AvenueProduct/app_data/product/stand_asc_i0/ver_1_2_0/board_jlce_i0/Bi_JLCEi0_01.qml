import QtQuick 2.11
import "../"
import "../../../../tools/db_service.js" as JDbServ
import "../../../ErrorCodes.js" as Codes

Item
{
    id: root
    property var     _args
    property string  _name: "Bi_JLCEi0_01"
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
            id_test.emWifiWakeup()
            _standApiObj.setLoadRelay(0)

            var ret

            // checkValueVoltage33
            ret = id_test.checkValueVoltage33()
            if (ret === false) { executed(false); return }

            // setBaseParameters
            ret = id_test.setBaseParameters()
            if (ret === false) { finish(false); return }

            // enableProductionScope
            ret = id_test.enableProductionScope()
            if (ret === false) { finish(false); return }

            // checkLoraOscillatorFreq
            ret = id_test.checkLoraOscillatorFreq()
            if (ret === false) { finish(false); return }

            // checkEmCalibration
            if (_powerSupplyUsed)
            {
                ret = id_test.checkEmCalibrationQuick()
                if (ret === false) { finish(false); return }
            } else
            {
                ret = id_test.checkEm()
                if (ret === false) { finish(false); return }
            }

            // setDeviceInfo
            ret = id_test.setDeviceInfo()
            if (ret === false) { finish(false); return }

            // bindDeviceOption
            ret = JDbServ.bindDeviceOption(_dbClient, _objDevice.fid, _args[0])
            if (ret === false) { finish(false); return; }

            // updateDeviceState
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageFinish, Codes.CodeOk, "Completed")

            finish(true)
        }
    }

    //-----------------------------------------------------------------

    function execute()
    {
        _stand.resetLoadStatus()

        // resetStand
        var ret = _standApiObj.resetStand()
        if (ret === false) { executed(false); return }

        wait(1000)
        _standApiObj.startStand()

        // checkValueVoltage33
        ret = id_test.checkValueVoltage33()
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
        wait(1000)
        _standApiObj.resetBoard()
    }

    //-----------------------------------------------------------------

    function onErrorFw()
    {
        avlog.show("red", Codes.CodeFirmwareError + ": ERROR: Firmware not loaded!", false, true)
        JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageBasicInit, Codes.CodeFirmwareError, "Error Load firmware")
        executed(false)
    }

    //-----------------------------------------------------------------

    BaseTests { id: id_test }

    Timer
    {
        id: id_tim
        running: false
        repeat: false
        interval: 14000   // TODO set to 10000
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


