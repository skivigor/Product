import QtQuick 2.11
import "../../../tools/db_service.js" as JDbServ
import "../../ErrorCodes.js" as Codes

QtObject
{
    id: root
    property var     _args
    property string  _name: "AS_GPS_01"
//    property int     _classId: 0x02071A7F     // 0703747F1A0702 // Disable: LS, ZiLog, Radar; Enable: GPS
//    property string  _key: "lora"

    signal executed(bool res)
    signal stop()

    //-----------------------------------------------------------------

    function execute()
    {
        avlog.show("chocolate", "Enable GPS module " + _name + " ... Wait!", true, false)
        /*
          var cfg = {
            opt : true,
            zmov : false,
            radar : false,
            gps : true
          }
        */

        var config = {}
        config.opt = false
        config.zmov = false
        config.radar = false
        config.gps = true

        var ret = _fwApi.setClassId(config)
        if (ret === false)
        {
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Set Class ID " + _name, false, true)
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageAssembly, Codes.CodeBoardError, "Class ID: Error writing to device")
            executed(false)
            return
        }

//        // Save to log
//        avlog.saveSettings(_objEui.feuistr, set)

        // bindDeviceOption
        ret = JDbServ.bindDeviceOption(_dbClient, _objDevice.fid, _args[0])
        if (ret === false) { executed(false); return; }

//        // addBindAttributes
//        ret = JDbServ.addBindAttributes(_dbClient, _objDevice.fid, _key, JSON.stringify(set))
//        if (ret === false) { executed(false); return; }

        // updateDeviceState
        JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageFinish, Codes.CodeOk, "Completed")

        avlog.show("green", "Enable GPS module <" + _name + "> ... OK", false, false)
        executed(true)
    }

    //-----------------------------------------------------------------

//    Component.onCompleted:
//    {
//        console.log(_name + " completed")
//        console.log("Args: " + _args[0] + " " + _args[1])
//    }

//    Component.onDestruction: console.log(_name + " destruction")
}
