import QtQuick 2.12
import QtQuick.Controls 2.5
import "../component"
import "../../tools/db_service.js" as JDbServ

Item
{
    id: root
    anchors.fill: parent
    property var _args
    property int _scanStage: 0

    signal executed(bool res)
    signal stop()

    function execute()
    {
        // getVendorAttributesByDevice
        var req = {}
        req.req = "getVendorAttributesByDevice"
        req.args = [_objDevice.fid]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            avlog.show("red", "Get vendor attributes ... Error!!!", false, true)
            console.warn("Error: Get vendor attributes: " + resp["errorString"])
            executed(false)
            return
        }

        var data = resp["data"]
        if (data.length === 0)
        {
            console.log("VENDOR KEY NOT EXISTED!!!")
            _vendorKey = ""
        } else
        {
            _vendorKey = JSON.parse(data[0]["fdata"])["key"]
            console.log("VENDOR KEY EXISTED: " + _vendorKey)
        }

        executed(true)
    }


    Component.onCompleted: console.info("VENDOR created!")
    Component.onDestruction: console.info("VENDOR destruction")
}
