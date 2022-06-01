import QtQuick 2.11

Item
{
    id: root
    property var _iface

    QtObject
    {
        id: set
        // Stand codes
        property int fnStandCode: 0x79
        property int fnGetInfo: 0x01
        property int fnGetConfig: 0x02
        property int fnSetConfig: 0x03
        property int fnGetAdcValue: 0x11
        property int fnSetDacValue: 0x12
        property int fnGetPioValue: 0x13
        property int fnSetPioValue: 0x14
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
    }

    //-----------------------------------------------------------------

    function getInfo()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetInfo

        var resp = func.send(cmd)
        if (resp.length !== 13 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetInfo) return false

        console.log("Info: " + resp)

        return true
    }

    function getConfig()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetConfig

        var resp = func.send(cmd)
        if (resp.length !== 33 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetConfig) return false

//        console.log("Info: " + resp)

        var data = new Uint8Array(resp)
        var cfg = data.subarray(3)
//        console.log("Data: " + cfg)

        return cfg
    }

    function setConfig(cfg)
    {
        var cmd = new Uint8Array(33)
        cmd[0] = 33
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnSetConfig
        cmd.set(cfg, 3)
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnSetConfig) return false

        return true
    }

    function getAdcValue(id)
    {
        var cmd = new Uint8Array(4)
        cmd[0] = 4
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetAdcValue
        cmd[3] = id
        var resp = func.send(cmd)
        if (resp.length !== 6 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetAdcValue) return false

        var data = new Uint8Array(resp)
        var val = util.arrayToInt(data.buffer, 4, 2)

        return val
    }

    function setDacValue(id, val)
    {
        var cmd = new Uint8Array(6)
        cmd[0] = 6
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnSetDacValue
        cmd[3] = id
        var param = util.intToArray(val, 2)
        cmd.set(param, 4)
        var resp = func.send(cmd)
        if (resp.length !== 4 || resp[1] !== set.fnStandCode || resp[2] !== set.fnSetDacValue || resp[3] !== id) return false

        return true
    }

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








    function isCoverClosed()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnStandCoverStat

        var resp = func.send(cmd)
        if (resp.length !== 4 || resp[1] !== set.fnStandCode || resp[2] !== set.fnStandCoverStat || resp[3] !== 1) return false

        return true
    }

    //-----------------------------------------------------------------

    function resetStand()
    {
        // Disable load
        var ret = setLoadRelay(false)
        if (ret === false) return false

        // Disable info bus
        ret = infoRelayOff()
        if (ret === false) return false

        // Disable board power
        ret = pwRelayOff()
        if (ret === false) return false

        // Disable Protection
        ret = disableProtection()
        if (ret === false) return false

        // Set Light mode 0
        ret = setLightMode(0)
        if (ret === false) return false

        return true
    }

    //-----------------------------------------------------------------

    function resetBoard()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnBoardResetOn

        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnBoardResetOn) return false

        wait(1000)

        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnBoardResetOff

        resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnBoardResetOff) return false

        return true
    }

    //-----------------------------------------------------------------

    function startStand()
    {
        console.log("!!!!!!!! Start stand func")
        _power.setVoltage(220)
        wait(500)
        _power.loadOn()
        wait(500)

        pwRelayOn()
        wait(500)
        var ret = pwRelayOn()
        if (ret === false) return false
        ret = infoRelayOn()
        if (ret === false) return false

//        resetBoard()

        return true
    }

    //-----------------------------------------------------------------

    function pwRelayOn()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnSetPwRelOn

        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnSetPwRelOn) return false
        return true
    }

    //-----------------------------------------------------------------

    function pwRelayOff()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnSetPwRelOff

        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnSetPwRelOff) return false
        return true
    }

    //-----------------------------------------------------------------

    function infoRelayOn()
    {
        console.log("!!!!! Info relay ON")
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnSetConnRelOn

        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnSetConnRelOn) return false
        return true
    }

    //-----------------------------------------------------------------

    function infoRelayOff()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnSetConnRelOff

        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnSetConnRelOff) return false
        return true
    }

    //-----------------------------------------------------------------

    function checkStatusVoltage33()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetV33Status

        var resp = func.send(cmd)
        if (resp.length !== 4 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetV33Status || resp[3] !== 1) return false

        return true
    }

    //-----------------------------------------------------------------

    function checkValueVoltage33()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetV33Value
        var resp = func.send(cmd)
        if (resp.length !== 5 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetV33Value) return false

        var data = new Uint8Array(resp)
        var v33 = util.arrayToInt(data.buffer, 3, 2)
        return v33
    }

    //-----------------------------------------------------------------

    function checkValueVoltage50()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetV50Value
        var resp = func.send(cmd)
        if (resp.length !== 5 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetV50Value) return false

        var data = new Uint8Array(resp)
        var v50 = util.arrayToInt(data.buffer, 3, 2)
        return v50
    }

    //-----------------------------------------------------------------

    function checkValueVoltage20()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetV20Value
        var resp = func.send(cmd)
        if (resp.length !== 5 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetV20Value) return false

        var data = new Uint8Array(resp)
        var v20 = util.arrayToInt(data.buffer, 3, 2)
        return v20
    }

    //-----------------------------------------------------------------

    function setLightMode(mode)
    {
        var cmd = new Uint8Array(4)
        cmd[0] = 4
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnStandSetLightMode
        cmd[3] = mode
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnStandSetLightMode) return false

        return true
    }

    //-----------------------------------------------------------------

    function getPwmLevel(channel)
    {
        var cmd = new Uint8Array(4)
        cmd[0] = 4
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnGetPwm
        cmd[3] = channel
        var resp = func.send(cmd)
        if (resp.length !== 5 || resp[1] !== set.fnStandCode || resp[2] !== set.fnGetPwm || resp[3] !== channel) return false

        return resp[4]
    }

    //-----------------------------------------------------------------

    function getLoraOscillatorFreq()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnStandGetOscFreq
        var resp = func.send(cmd)
        if (resp.length !== 7 || resp[1] !== set.fnStandCode || resp[2] !== set.fnStandGetOscFreq) return false

        var data = new Uint8Array(resp)
        var freq = util.arrayToInt(data.buffer, 3, 4)
        return freq
    }

    //-----------------------------------------------------------------

    function enableProtection()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnStandEnProt
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnStandEnProt) return false

        return true
    }

    //-----------------------------------------------------------------

    function disableProtection()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnStandDisProt
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnStandDisProt) return false

        return true
    }

    //-----------------------------------------------------------------

    function setLoadRelay(state)
    {
        var cmd = new Uint8Array(4)
        cmd[0] = 4
        cmd[1] = set.fnStandCode
        cmd[2] = set.fnStandLoad
        cmd[3] = state
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnStandCode || resp[2] !== set.fnStandLoad) return false

        return true
    }

    //-----------------------------------------------------------------

    Component.onCompleted: console.log("StandApi completed")
    Component.onDestruction: console.log("StandApi destruction")
}


















