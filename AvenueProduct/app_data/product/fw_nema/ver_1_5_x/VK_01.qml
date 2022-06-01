import QtQuick 2.11
import "../../../tools/db_service.js" as JDbServ
import "../../ErrorCodes.js" as Codes

QtObject
{
    id: root
    property var     _args
    property string  _name: "VK_01"
    property string  _key: "key"

    signal executed(bool res)
    signal stop()

    //-----------------------------------------------------------------

    function execute()
    {
        if (_vendorKey.length !== 0)
        {
            console.log("Vendor key existed!!!")
            executed(true)
            return
        }

        avlog.show("chocolate", "Set Vendor settings ... Wait!", true, false)
        var set = util.createVendorSettings(_objEui.feuistr)
        console.info("Vendor set " + _name)

        var ret = _fwApi.setVendorProductSettings(set)
        if (ret === false)
        {
            avlog.show("red", Codes.CodeBoardError + ": ERROR: Set Vendor settings", false, true)
            JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageVendor, Codes.CodeBoardError, "Error Set Vendor settings")
            executed(false)
            return
        }

        // Save to log
//        avlog.saveSettings(_objEui.feuistr, set)

        // bindDeviceOption
        ret = JDbServ.bindDeviceOption(_dbClient, _objDevice.fid, _args[0])
        if (ret === false) { executed(false); return; }

        // addVendorAttributes
        ret = JDbServ.addVendorAttributes(_dbClient, _objDevice.fid, _key, JSON.stringify(set))
        if (ret === false) { executed(false); return; }

        // updateDeviceState
        JDbServ.updateDeviceState(_dbClient, _objDevice.fid, _args[0], Codes.StageFinish, Codes.CodeOk, "Completed")

        avlog.show("green", "Set Vendor settings ... OK", false, false)
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
