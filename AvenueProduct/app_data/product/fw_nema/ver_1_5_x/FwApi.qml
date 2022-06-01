import QtQuick 2.11
import "../../../tools/hex_byte.js" as Hex

Item
{
    id: root
    property var _iface

    QtObject
    {
        id: set
        // ASC codes
        property int fnLoraCode: 0x01
        property int fnLoraSetTest: 0x75
        property int fnLoraSetProduct: 0x72
        property int fnBasicCode: 0x03
        property int fnBasicSetDevInfo: 0x72
        property int fnBasicSetVendorKey: 0x76
        property int fnLTypeCode: 0x02
        property int fnLTypeSetCfg: 0x02
        property int fnLsCode: 0x07
        property int fnLsGetLevel: 0x07
        property int fnLsIdx: 0x01
        property int fnLmCode: 0x05
        property int fnLmGetSurgeProt: 0x0A
        property int fnLmSwitchOnEna: 0x71
        property int fnLactCode: 0x04
        property int fnLactSetLevel: 0x74
        property int fnLactSetSwitch: 0x1C
        property int fnTimeCode: 0x0B
        property int fnTimeSetQuartzTest: 0x11
        property int fnTimeSetTzDls: 0x09
        property int fnTimeSetUtcByOffset: 0x0C
        property int fnEmCode: 0x06
        property int fnEmResetCalib: 0x08
        property int fnEmSetCalib: 0x07
        property int fnEmGetMeas: 0x06
        property int fnDCollCode: 0x10
        property int fnDCollReset: 0x04
        property int fnExtraCode: 0x3F
        property int fnExtraSetProductScope: 0x0A

        // Esp codes
        property int fnWifiCode: 0x71
        property int fnWifiEnableSleep: 0x11
        property int fnWifiSleep: 0x10
        property int fnWifiWake: 0x01
        property int fnWifiSetSsid: 0x07
        property int fnWifiSetPass: 0x09
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

    function enableProductScope()
    {
        var cmd = new Uint8Array(19).fill(0)
        cmd[0] = 19
        cmd[1] = set.fnExtraCode
        cmd[2] = set.fnExtraSetProductScope

        if (_vendorKey.length !== 0)
        {
            var hash = util.getProductScopeCommand(_vendorKey)
            cmd.set(hash, 3)
        }

        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnExtraCode || resp[2] !== set.fnExtraSetProductScope) return false

        return true
    }

    //-----------------------------------------------------------------

    function setVendorProductSettings(cfg)
    {
        var key = Hex.hexToBytes(cfg["key"])

        var cmd = new Uint8Array(19).fill(0)
        cmd[0] = 19
        cmd[1] = set.fnBasicCode
        cmd[2] = set.fnBasicSetVendorKey
        cmd.set(key, 3)
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnBasicCode || resp[2] !== set.fnBasicSetVendorKey) return false

        return true
    }

    //-----------------------------------------------------------------

    function setLoraProductSettings(cfg)
    {
        var devAddr = Hex.hexToBytes(cfg["devaddr"]).reverse()
        var devEui = Hex.hexToBytes(cfg["deveui"]).reverse()
        var appEui = Hex.hexToBytes(cfg["appeui"]).reverse()
        var appKey = Hex.hexToBytes(cfg["appkey"])
        var nwkSKey = Hex.hexToBytes(cfg["nwkskey"])
        var appSKey = Hex.hexToBytes(cfg["appskey"])

        var cmd = new Uint8Array(71)
        cmd[0] = 71
        cmd[1] = set.fnLoraCode
        cmd[2] = set.fnLoraSetProduct
        cmd.set(devAddr, 3)
        cmd.set(devEui, 7)
        cmd.set(appEui, 15)
        cmd.set(appKey, 23)
        cmd.set(nwkSKey, 39)
        cmd.set(appSKey, 55)
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnLoraCode || resp[2] !== set.fnLoraSetProduct) return false

        return true
    }

    //-----------------------------------------------------------------

    function setLTypeConfig(strCfg)
    {
        var ltype = Hex.hexToBytes(strCfg)
        var cmd = new Uint8Array(34);
        cmd.set(ltype, 0)
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnLTypeCode || resp[2] !== set.fnLTypeSetCfg) return false

        return true
    }

    //-----------------------------------------------------------------

    function setBasicDevInfo(serial, hwType, hwVer)
    {
        var cmd = new Uint8Array(21)
        cmd[0] = 21
        cmd[1] = set.fnBasicCode
        cmd[2] = set.fnBasicSetDevInfo
        cmd.set(serial, 3)
        cmd.set(hwType, 11)
        cmd.set(hwVer, 13)
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnBasicCode || resp[2] !== set.fnBasicSetDevInfo) return false

        return true
    }

    //-----------------------------------------------------------------

    function enableLoraTestMode()
    {
        var cmd = new Uint8Array(19).fill(0)
        cmd[0] = 19
        cmd[1] = set.fnLoraCode
        cmd[2] = set.fnLoraSetTest
        cmd[3] = 4
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnLoraCode || resp[2] !== set.fnLoraSetTest) return false

        return true
    }

    //-----------------------------------------------------------------

    function getLmProtectionStatus()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnLmCode
        cmd[2] = set.fnLmGetSurgeProt
        var resp = func.send(cmd)
        if (resp.length !== 4 || resp[1] !== set.fnLmCode || resp[2] !== set.fnLmGetSurgeProt) return false

        return resp[3]
    }

    //-----------------------------------------------------------------

    function getLsLightLevel(idx)
    {
        var cmd = new Uint8Array(4)
        cmd[0] = 4
        cmd[1] = set.fnLsCode
        cmd[2] = set.fnLsGetLevel
        cmd[3] = set.fnLsIdx
        var resp = func.send(cmd)
        if (resp.length !== 6 || resp[1] !== set.fnLsCode || resp[2] !== set.fnLsGetLevel || resp[3] !== set.fnLsIdx) return false

        var data = new Uint8Array(resp)
        var lvl = util.arrayToInt(data.buffer, 4, 2)
        return lvl
    }

    //-----------------------------------------------------------------

    function switchLmEnaOn()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnLmCode
        cmd[2] = set.fnLmSwitchOnEna
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnLmCode || resp[2] !== set.fnLmSwitchOnEna) return false

        return true
    }

    //-----------------------------------------------------------------

    function getEmPowerMeas()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnEmCode
        cmd[2] = set.fnEmGetMeas
        var resp = func.send(cmd)
        if (resp.length !== 0x1F) return false

        var data = new Uint8Array(resp)
        var empw = util.arrayToInt(data.buffer, 11, 2)
        return empw / 10
    }

    //-----------------------------------------------------------------

    function getEmVoltageMeas()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnEmCode
        cmd[2] = set.fnEmGetMeas
        var resp = func.send(cmd)
        if (resp.length !== 0x1F) return false

        var data = new Uint8Array(resp)
        var volt = util.arrayToInt(data.buffer, 17, 2)
        return volt / 100
    }

    //-----------------------------------------------------------------

    function resetEmCalibrationData()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnEmCode
        cmd[2] = set.fnEmResetCalib
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnEmCode || resp[2] !== set.fnEmResetCalib) return false

        return true
    }

    //-----------------------------------------------------------------

    function setEmCalibrationData(val)
    {
        var cmd = new Uint8Array(5)
        cmd[0] = 5
        cmd[1] = set.fnEmCode
        cmd[2] = set.fnEmSetCalib
        var coef = util.intToArray(val * 100, 2)
        cmd.set(coef, 3)
        var resp = func.send(cmd)
        if (resp.length !== 3) return false

        return true
    }

    //-----------------------------------------------------------------

    function setLactPwmLevel(val)
    {
        // Set PWM level
        var cmd = new Uint8Array(4)
        cmd[0] = 4
        cmd[1] = set.fnLactCode
        cmd[2] = set.fnLactSetLevel
        cmd[3] = val   // level
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnLactCode || resp[2] !== set.fnLactSetLevel) return false

        return true
    }

    //-----------------------------------------------------------------

    function setLactSwitch(state)
    {
        var cmd = new Uint8Array(4)
        cmd[0] = 4
        cmd[1] = set.fnLactCode
        cmd[2] = set.fnLactSetSwitch
        cmd[3] = state
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnLactCode || resp[2] !== set.fnLactSetSwitch) return false

        return true
    }

    //-----------------------------------------------------------------

    function setTimeUtc()
    {
        var cmd = new Uint8Array(7)
        cmd[0] = 7
        cmd[1] = set.fnTimeCode
        cmd[2] = set.fnTimeSetUtcByOffset   // set UTC by offset
        var val = util.intToArray(util.utcDateTimeToOffset(), 4)
        cmd.set(val, 3)
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnTimeCode || resp[2] !== set.fnTimeSetUtcByOffset) return false

        return true
    }

    //-----------------------------------------------------------------

    function setTimeTzDls()
    {
        var cmd = new Uint8Array(5)
        cmd[0] = 5
        cmd[1] = set.fnTimeCode
        cmd[2] = set.fnTimeSetTzDls
        cmd[3] = 2  // TZ
        cmd[4] = 1  // DLS
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnTimeCode || resp[2] !== set.fnTimeSetTzDls) return false

        return true
    }

    //-----------------------------------------------------------------

    function resetDCollSettings()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnDCollCode
        cmd[2] = set.fnDCollReset
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnDCollCode || resp[2] !== set.fnDCollReset) return false

        return true
    }

    //-----------------------------------------------------------------

    function wifiSetProductSettings(cfg)
    {
        // SSID
        var ssidStr = cfg["WiFi_SSID"]
        var ssidArr = new Uint8Array(ssidStr.length);
        for (var i = 0; i < ssidStr.length; ++i) ssidArr[i] = ssidStr.charCodeAt(i)

        var ssidCmd = new Uint8Array(3 + ssidStr.length)
        ssidCmd[0] = 3 + ssidStr.length
        ssidCmd[1] = set.fnWifiCode
        ssidCmd[2] = set.fnWifiSetSsid
        ssidCmd.set(ssidArr, 3)
        var resp = func.send(ssidCmd)
        if (resp.length !== 3 || resp[1] !== set.fnWifiCode || resp[2] !== set.fnWifiSetSsid) return false

        // PASS
        var passStr = cfg["WiFi_Password"]
        var passArr = new Uint8Array(passStr.length)
        for (var j = 0; j < passStr.length; ++j) passArr[j] = passStr.charCodeAt(j)

        var passCmd = new Uint8Array(3 + passStr.length)
        passCmd[0] = 3 + passStr.length
        passCmd[1] = set.fnWifiCode
        passCmd[2] = set.fnWifiSetPass
        passCmd.set(passArr, 3)
        resp = func.send(passCmd)
        if (resp.length !== 3 || resp[1] !== set.fnWifiCode || resp[2] !== set.fnWifiSetPass) return false

        return true
    }

    //-----------------------------------------------------------------

    function wifiEnableSleepMode()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnWifiCode
        cmd[2] = set.fnWifiEnableSleep
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnWifiCode || resp[2] !== set.fnWifiEnableSleep) return false

        return true
    }

    //-----------------------------------------------------------------

    function wifiSleep()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnWifiCode
        cmd[2] = set.fnWifiSleep
        var resp = func.send(cmd)
        if (resp.length !== 3 || resp[1] !== set.fnWifiCode || resp[2] !== set.fnWifiSleep) return false

        return true
    }

    //-----------------------------------------------------------------

    function wifiWakeup()
    {
        var cmd = new Uint8Array(3)
        cmd[0] = 3
        cmd[1] = set.fnWifiCode
        cmd[2] = set.fnWifiWake
        func.send(cmd)

        return true
    }

    //-----------------------------------------------------------------

    Component.onCompleted: console.log("FwApi completed")
    Component.onDestruction: console.log("FwApi destruction")
}


















