import QtQuick 2.11
import "../../tools/db_service.js" as JDbServ

QtObject
{
    id: root
    property var _args

    property int _swTypeEsp:   1025   // 0x0401
    property int _swTypeJBoot: 769    // 0x0301
    property int _swTypeNema:   513    // 0x0201

    property var _espBootCfg:
    {
        "descr" : "ESP bootloader firmware",
        "cmdSetVer" : "48",
        "cmdGetVer" : "49",
        "cmdWrite" : "4A",
        "cmdCheck" : "4B",
        "cmdLoad" : "50",
        "cmdLoadState" : "51",
        "addr" : "00000000"
    }
    property var _espMainCfg:
    {
        "descr" : "ESP main firmware",
        "cmdSetVer" : "4C",
        "cmdGetVer" : "4D",
        "cmdWrite" : "4E",
        "cmdCheck" : "4F",
        "cmdLoad" : "52",
        "cmdLoadState" : "53",
        "addr" : "00001000"
    }
    property var _espInitCfg:
    {
        "descr" : "ESP init settings",
        "cmdSetVer" : "54",
        "cmdGetVer" : "55",
        "cmdWrite" : "56",
        "cmdCheck" : "57",
        "cmdLoad" : "58",
        "cmdLoadState" : "59",
        "addr" : "001FC000"
    }
    property var _ascBootCfg:
    {
        "descr" : "Main bootloader firmware",
        "cmdSetVer" : "2D",
        "cmdGetVer" : "2E",
        "cmdWrite" : "2F",
        "cmdCheck" : "30",
        "cmdLoad" : "35",
        "cmdLoadState" : "36",
        "addr" : "08000000"
    }
    property var _nemaMainCfg:
    {
        "descr" : "Nema main firmware",
        "cmdSetVer" : "31",
        "cmdGetVer" : "32",
        "cmdWrite" : "33",
        "cmdCheck" : "34",
        "cmdLoad" : "37",
        "cmdLoadState" : "38",
        "addr" : "08003000"
    }

    signal executed(bool res)
    signal stop()

    //-----------------------------------------------------------------

    function execute()
    {
//        _stand.clearModel()

        // get Esp Firmware
        var espBoot = {}
        var espMain = {}
        var espRadio = {}
        var req = {}
        req.req = "getProductFirmware"
        req.args = [_swTypeEsp]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            console.warn("Error: ESP firmwares: " + resp["errorString"])
            avlog.show("red", "ERROR!!! Firmware not received!", false, true)
            executed(false)
            return
        }
        var data = resp["data"]
        console.info("Data len: " + data.length)
        for (var i = 0; i < data.length; ++i)
        {
            console.info(data[i]["ffwname"])
            if (data[i]["ffwtype"] === "BOOT")
            {
                espBoot.name = data[i]["ffwname"]
                espBoot.md5 = data[i]["ffwmd5"]
                espBoot.fw = data[i]["ffwfile"]
                continue
            }
            if (data[i]["ffwtype"] === "MAIN")
            {
                espMain.name = data[i]["ffwname"]
                espMain.md5 = data[i]["ffwmd5"]
                espMain.fw = data[i]["ffwfile"]
                continue
            }
            if (data[i]["ffwtype"] === "RADIO")
            {
                espRadio.name = data[i]["ffwname"]
                espRadio.md5 = data[i]["ffwmd5"]
                espRadio.fw = data[i]["ffwfile"]
                continue
            }
        }

        // get JBoot Firmware
        var ascJBoot = {}
        req = {}
        req.req = "getProductFirmware"
        req.args = [_swTypeJBoot]
        resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            console.warn("Error: Jooby Boot firmware: " + resp["errorString"])
            avlog.show("red", "ERROR!!! Firmware not received!", false, true)
            executed(false)
            return
        }
        data = resp["data"]
        console.info("Data len: " + data.length)
        if (data.length !== 1)
        {
            console.warn("Error: Jooby Boot firmware: selection")
            avlog.show("red", "ERROR!!! Firmware not received!", false, true)
            executed(false)
            return
        }
        ascJBoot.name = data[0]["ffwname"]
        ascJBoot.md5 = data[0]["ffwmd5"]
        ascJBoot.fw = data[0]["ffwfile"]

        // get ASC Firmware
        var ascMain = {}
        req = {}
        req.req = "getProductFirmware"
        req.args = [_swTypeNema]
        resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            console.warn("Error: ASC main firmware: " + resp["errorString"])
            avlog.show("red", "ERROR!!! Firmware not received!", false, true)
            executed(false)
            return
        }
        data = resp["data"]
        console.info("Data len: " + data.length)
        if (data.length !== 1)
        {
            console.warn("Error: ASC main firmware: selection")
            avlog.show("red", "ERROR!!! Firmware not received!", false, true)
            executed(false)
            return
        }
        ascMain.name = data[0]["ffwname"]
        ascMain.md5 = data[0]["ffwmd5"]
        ascMain.fw = data[0]["ffwfile"]
        _fwVerPath = data[0]["fversionpath"]

        _stand.addFirmwareToModel(_espBootCfg, espBoot.name, espBoot.md5, espBoot.fw)
        _stand.addFirmwareToModel(_espMainCfg, espMain.name, espMain.md5, espMain.fw)
        _stand.addFirmwareToModel(_espInitCfg, espRadio.name, espRadio.md5, espRadio.fw)
        _stand.addFirmwareToModel(_ascBootCfg, ascJBoot.name, ascJBoot.md5, ascJBoot.fw)
        _stand.addFirmwareToModel(_nemaMainCfg, ascMain.name, ascMain.md5, ascMain.fw)

        avlog.show("chocolate", "Firmware checking ... Wait!", true, false)
        _stand.checkFw()
    }

    //-----------------------------------------------------------------

    function onCheckedFw()
    {
        avlog.show("green", "Firmware checked ... OK", false, false)
        executed(true)
    }

    //-----------------------------------------------------------------

    function onErrorFw()
    {
        avlog.show("red", "ERROR!!! Firmware not checked!", false, true)
        executed(false)
    }

    //-----------------------------------------------------------------

    Component.onCompleted:
    {
        console.log("FwCheck completed")
        _stand.checked.connect(onCheckedFw)
        _stand.error.connect(onErrorFw)
    }
    Component.onDestruction:
    {
        console.log("FwCheck destruction")
        _stand.checked.disconnect(onCheckedFw)
        _stand.error.disconnect(onErrorFw)
    }
}


















