import QtQuick 2.11
import "../"
import "../../ErrorCodes.js" as Codes

Item
{
    id: root
    property string  _name: "Drv_80W"

    // TODO delete
    property int _testCount: 5

    signal executed(bool res)
    signal stop()

    QtObject
    {
        id: func

        property var _set_stage1:
        {
            "Uin_min": 120,
            "Uin_nom": 220,
            "Uin_max": 280,
            "PFactor": 0.96,
            "Iin_at_220": 410,
            "Iin_at_120": 780,
            "Iin_at_280": 350,
            "Iout_nom": 1450,
            "Iout_deviation": 7,   // +/- 7%
            "Pwm_level": 100,
            "P_nom": 83,           // 81.5W
            "P_deviation": 5       // +/- 5%
        }

        property var _set_stage2:
        {
            "Uin": 220,
            "Uctrl_min": 13,
            "Uctrl_max": 16,
            "Uhigh_min": 190, //190
            "Uhigh_max": 225
        }

        property var _set_stage3:
        {
            "Uin": 220,
            "Pwm_lev1": 0,
            "Pwm_lev2": 10,
            "Pwm_lev3": 100,
            "Iin_lev1": 20,
            "Iin_lev2": 130, // ??????
            "Iin_lev3": 1465,
            "Iin_deviation": 10   // +/- 10%
        }

//        property var _set_stage4:
//        {
//            "Uin": 220,
//            "Iin": 25
//        }

        function finish(res)
        {
            if (_power.isLoaded() === false)
            {
                avlog.show("red", "Error! The power supply output error!!!", false, true)
                console.log("!!!!!!! Error! The power supply output error!!!")
            }
            if (res === false) console.log("!!!!! Driver test ERROR")
            else console.log("!!!!! Driver test OK")

            // Power supply reset
            _power.reset()
            wait(500)
            if (_power.isLoaded() === true) avlog.show("red", "Attention! The power supply did not turn off!!!", false, true)
            _power.pwDisconnect()

            // Stand reset
            _standApiObj.resetStand()
            _standApiObj.disconnectStand()

            // TODO delete
             /*
            if (_testCount > 0)
            {
                avlog.show("black", "!!!!!!!!!!!!!!!!!!!!!!!!!!! Test finished " + _testCount, false, false)
                _testCount--
                id_tim.start()
                return
            }
            // */

            executed(res)
        }
    }

    //-----------------------------------------------------------------

    function execute()
    {
        console.log("!!!!!!!!! Execute: " + _name)
        avlog.show("chocolate", "Test starting " + _name + " ... Wait!", true, false)

        // Stand connect
        var ret = _standApiObj.connectStand()
        if (ret === false)
        {
            var code = Codes.CodeStandError
            avlog.show("red", code + ": ERROR: Stand connect ", false, true)
            executed(false)
            return
        }

        // Power supply
        _power.pwConnect()
        wait(500)
        ret = _power.isConnected()
        if (ret === false)
        {
            code = Codes.CodeExtPowerSupply
            avlog.show("red", code + ": ERROR: Power supply connect ", false, true)
            executed(false)
            return
        }

        // Check input/output current
        ret = id_test.stage1(func._set_stage1)
        if (ret === false) { func.finish(false); return }

        // Measurement voltage of Controller and High voltage
        ret = id_test.stage2(func._set_stage2)
        if (ret === false) { func.finish(false); return }

        // Check the operation of the Dimming unit
        ret = id_test.stage3(func._set_stage3)
        if (ret === false) { func.finish(false); return }

        // No-load current measurement
//        ret = id_test.stage4(func._set_stage4)
//        if (ret === false) { func.finish(false); return }

        avlog.show("green", "Test completed ... OK!", false, true)
        func.finish(true)
    }


    //-----------------------------------------------------------------

    // TODO delete
    Timer
    {
        id: id_tim
        running: false
        repeat: false
        interval: 5000
        onTriggered: execute()
    }

    BaseTests { id: id_test }

    Component.onCompleted:
    {
        console.log(_name + " completed")
//        _stand.loaded.connect(onLoadedFw)
//        _stand.error.connect(onErrorFw)
    }
    Component.onDestruction:
    {
//        _stand.loaded.disconnect(onLoadedFw)
//        _stand.error.disconnect(onErrorFw)
        console.log(_name + " destruction")
    }
}


