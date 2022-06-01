import QtQuick 2.11

Item
{
    id: root
    property var _iface

    QtObject
    {
        id: set
        // Stand codes
        property int fnStandCode: 0x78
        property int fnStandCoverStat: 0x03
        property int fnStandEnProt: 0x05
        property int fnStandDisProt: 0x06
        property int fnStandSetLightMode: 0x1D
        property int fnGetV33Status: 0x04
        property int fnGetV33Value: 0x24
        property int fnGetV50Value: 0x25
        property int fnGetV20Value: 0x5B
        property int fnStandGetOscFreq: 0x2A
        property int fnStandGetthrRtcFreq: 0x60
        property int fnGetPwm: 0x29
        property int fnSetPwRelOn: 0x21
        property int fnSetConnRelOn: 0x1A
        property int fnSetPwRelOff: 0x22
        property int fnSetConnRelOff: 0x1B
        property int fnStandLoad: 0x1F

        property int fnBoardResetOn: 0x0A
        property int fnBoardResetOff: 0x0B
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


















