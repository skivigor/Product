import QtQuick 2.11
import "../../../tools/db_service.js" as JDbServ
import "../../ErrorCodes.js" as Codes

QtObject
{
    id: root
    property var     _args
    property int     _typeId: 0
    property string  _name: "LT_01"
    property string  _descr: ""
    property string  _cmd: ""
    property string  _key: "lamptype"

    signal executed(bool res)
    signal stop()

    //-----------------------------------------------------------------

    function execute()
    {
        var path = _args[2] + _args[1]
        path = path.replace(/^(file:\/{3})/,"")
        console.log("!!!!! PATH: " + path)
        var ret = file.isFileExists(path)
        if (ret === false)
        {
            avlog.show("red", "ERROR!!! LT: Data file " + _args[1] + " not found!", false, true)
            executed(false)
            return
        }

        var jsdata = JSON.parse(file.getFileAsString(path))
        _typeId = jsdata["typeId"]
        _descr = jsdata["descr"]
        _cmd = jsdata["cmd"]

        avlog.show("chocolate", "LampType: " + _descr)
        avlog.show("chocolate", "Set Lamp Type settings " + _name + " ... Wait!", true, false)

//        // getLampType
//        var req = {}
//        req.req = "getLampType"
//        req.args = [_typeId]
//        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
//        if (resp["error"] === true)
//        {
//            avlog.show("red", "ERROR!!! Get Lamp Type info " + _name, false, true)
//            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], 100, 404, "Error on get Lamp Type info")
//            executed(false)
//            return
//        }
//        var data = resp["data"]
//        var ltValue = data[0]["fjson"]

        // Set config
        ret = _fwApi.setLTypeConfig(_cmd)
        if (ret === false)
        {
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Set Lamp Type settings " + _name, false, true)
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageLampType, Codes.CodeBoardError, "Error writing to device")
            executed(false)
            return
        }

//        // Save to log
//        avlog.saveSettings(_objEui.feuistr, ltValue)

        // bindDeviceOption
        ret = JDbServ.bindDeviceOption(_dbClient, _objDevice.fid, _args[0])
        if (ret === false) { executed(false); return; }

//        // addBindAttributes
//        ret = JDbServ.addBindAttributes(_dbClient, _objDevice.fid, _key, ltValue)
//        if (ret === false) { executed(false); return; }

        // updateDeviceState
        JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageFinish, Codes.CodeOk, "Completed")

        avlog.show("green", "Set Lamp Type settings <" + _name + "> ... OK", false, false)
        executed(true)
    }

    //-----------------------------------------------------------------

//    Component.onCompleted: console.log(_name + " completed")
//    Component.onDestruction: console.log(_name + " destruction")
}
