// Driver stand api
import QtQuick 2.11

Item
{
    id: root
    property var _iface

    QtObject
    {
        id: set
        // Stand codes
        property int fnStandCode: 0x20
        property int fnGetPioValue: 0x01
        property int fnSetPioValue: 0x02
        property int fnGetPwmLevel: 0x03
        property int fnSetPwmLevel: 0x04
        property int fnGetAdcValue: 0x05
    }

    QtObject
    {
        id: func

        function send(req)
        {
            var resp = []
            var count = 0
            _iface.sendData(req.buffer)
            do
            {
                resp = _iface.getRespAsBin()
                count++
                wait(100)
            } while (resp.length === 0 && count < 40)

            return resp
        }

        function send2(req)
        {
            var resp = []
            var count = 0
            _iface.sendData(req.buffer)
            do
            {
                resp = _iface.getRespAsBin()
                count++
                wait(100)
            } while (resp.length === 0 && count < 10)

            return resp
        }
    }

    //-----------------------------------------------------------------

    function connectStand()
    {
        _iface.connectSerial()
        wait(100)
        return checkStand()
    }

    //-----------------------------------------------------------------

    function disconnectStand()
    {
        _iface.disconnectSerial()
        return true
    }

    //-----------------------------------------------------------------

    function checkStand()
    {
        console.log("Check stand")
        var ret = getPwmLevel()
        if (ret === false) return false
        return true
    }

    //-----------------------------------------------------------------

    function resetStand()
    {
        var resp = setPioValue(1, 0)
        if (resp === false) return false

        resp = setPwmLevel(0)
        if (resp === false) return false

        return true
    }

    //-----------------------------------------------------------------

    function getAdcValue(id)
    {
        var cmd = new Uint8Array(4)
        cmd[0] = 4
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetAdcValue
        cmd[3] = id
        var resp = func.send(cmd)
        if (resp.length !== 8 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetAdcValue || resp[3] !== id) return false

        var data = new Uint8Array(resp)
        var v1 = util.arrayToInt(data.buffer, 4, 2)
        var v2 = util.arrayToInt(data.buffer, 6, 2)
        var val = {}
        val.ch1 = v1
        val.ch2 = v2

        return val
    }

    //-----------------------------------------------------------------

    function getPioValue(id)
    {
        var cmd = new Uint8Array(4)
        cmd[0] = 4
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetPioValue
        cmd[3] = id
        var resp = func.send(cmd)
        if (resp.length !== 5 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetPioValue) return false

        return resp[4]
    }

    //-----------------------------------------------------------------

    function setPioValue(id, val)
    {
        var cmd = new Uint8Array(5)
        cmd[0] = 5
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnSetPioValue
        cmd[3] = id
        cmd[4] = val
        var resp = func.send(cmd)
        if (resp.length !== 4 || resp[1] !== set.fnStandCode || resp[2] !== set.fnSetPioValue || resp[3] !== id) return false

        return true
    }

    //-----------------------------------------------------------------

    function setPwmLevel(lvl)
    {
        var cmd = new Uint8Array(4)
        cmd[0] = 4
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnSetPwmLevel
        cmd[3] = lvl
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnSetPwmLevel) return false

        return true
    }

    //-----------------------------------------------------------------

    function getPwmLevel()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetPwmLevel
        var resp = func.send2(cmd)
        if (resp.length !== 4 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetPwmLevel) return false

        return resp[3]
    }

    //-----------------------------------------------------------------

    Component.onCompleted: console.log("StandApi completed")
    Component.onDestruction: console.log("StandApi destruction")
}


















