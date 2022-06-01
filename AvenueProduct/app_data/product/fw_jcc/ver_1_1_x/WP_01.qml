import QtQuick 2.11
import "../../../tools/db_service.js" as JDbServ
import "../../ErrorCodes.js" as Codes

QtObject
{
    id: root
    property var     _args
    property string  _name: "WP_01"
    property string  _key: "wifi"

    signal executed(bool res)
    signal stop()

    //-----------------------------------------------------------------

    function execute()
    {
        avlog.show("chocolate", "Set WiFi settings " + _name + " ... Wait!", true, false)
        var set = util.createWiFiSettings(_objEui.feuistr)
        console.info("WiFi set " + _name)

        var ret = _fwApi.wifiSetProductSettings(set)
        if (ret === false)
        {
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Set WiFi settings " + _name, false, true)
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageWifi, Codes.CodeBoardError, "Error writing to device")
            executed(false)
            return
        }
        wait(2000)

        // Save to log
//        avlog.saveSettings(_objEui.feuistr, set)

        // bindDeviceOption
        ret = JDbServ.bindDeviceOption(_dbClient, _objDevice.fid, _args[0])
        if (ret === false) { executed(false); return; }

        // addBindAttributes
        ret = JDbServ.addBindAttributes(_dbClient, _objDevice.fid, _key, JSON.stringify(set))
        if (ret === false) { executed(false); return; }

        // updateDeviceState
        JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageFinish, Codes.CodeOk, "Completed")

        avlog.show("green", "Set WiFi settings <" + _name + "> ... OK", false, false)
        executed(true)
    }

    //-----------------------------------------------------------------
}
