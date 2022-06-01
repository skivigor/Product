import QtQuick 2.11
import "../../../tools/db_service.js" as JDbServ
import "../../ErrorCodes.js" as Codes

QtObject
{
    id: root
    property var     _args
    property string  _name: "LP_01"
    property string  _key: "lora"
    property string  _keyId: "classId"

    signal executed(bool res)
    signal stop()

    //-----------------------------------------------------------------

    function execute()
    {
        avlog.show("chocolate", "Set Lora settings " + _name + " ... Wait!", true, false)
        var set = util.createLoraSettings(_objEui.feuistr)
        console.info("Lora set " + _name)

        // TODO delete
//        avlog.show("red", Codes.CodeBoardError + ": ERROR: Set Lora settings " + _name, false, true)
//        executed(false)
//        return

        var ret = _fwApi.setLoraProductSettings(set)
        if (ret === false)
        {
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Set Lora settings " + _name, false, true)
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageLora, Codes.CodeBoardError, "Error writing to device")
            executed(false)
            return
        }

        // Save to log
//        avlog.saveSettings(_objEui.feuistr, set)

        // bindDeviceOption
        ret = JDbServ.bindDeviceOption(_dbClient, _objDevice.fid, _args[0])
        if (ret === false) { executed(false); return; }

        // addBindAttributes
        ret = JDbServ.addBindAttributes(_dbClient, _objDevice.fid, _key, JSON.stringify(set))
        if (ret === false) { executed(false); return; }

        // addBindAttributes classId
        var classId = { "classId" : "JCC" }
        ret = JDbServ.addBindAttributes(_dbClient, _objDevice.fid, _keyId, JSON.stringify(classId))
        if (ret === false) { executed(false); return; }

        // updateDeviceState
        JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageFinish, Codes.CodeOk, "Completed")

        avlog.show("green", "Set Lora settings <" + _name + "> ... OK", false, false)
        executed(true)
    }

    //-----------------------------------------------------------------

//    Component.onCompleted:
//    {
//        console.log(_name + " completed")
//        console.log("Args: " + _args[0] + " " + _args[1])
//    }

    Component.onDestruction: console.log(_name + " destruction")
}
