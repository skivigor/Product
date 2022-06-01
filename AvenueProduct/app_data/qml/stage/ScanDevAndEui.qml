import QtQuick 2.12
import QtQuick.Controls 2.5
import "../component"
import "../../tools/db_service.js" as JDbServ

Item
{
    id: root
    anchors.fill: parent
    property var _args

    signal executed(bool res)
    signal stop()

    function execute()
    {
        var ret
        for (var i = 0; i < 3; ++i)  // retry open scanner
        {
            ret = checkScanner()
            if (ret === true) break
            wait(3000)
        }

//        var ret = checkScanner()
        console.log("!!!!!! Scanner openned: " + ret)
        if (ret === false)
        {
            avlog.show("red", "Check scanner ... Error!!!", false, true)
            console.warn("!!!!!!! Error: Check scanner")
            executed(false)
            return
        }

        state = "scan_ini"
        scanner.clearData()
        scanStart()
    }

    function scanStart()
    {
        id_timer.start()
    }

    function scanStop()
    {
        id_timer.stop()
    }

    function scanning()
    {
        var regex
        var match
        var res

        // Scan
        var scan = scanner.getData()
        if (scan.length < 8) return
        console.log("Scan data: " + scan)

        if (root.state === "scan_ini")
        {
            regex = /N[0-9]{13}/;
            match = regex.exec(scan);
            if (match === null) return
            if (match.length !== 1) return
            scanStop()
            res = match[0]
            console.log("ScanDevId::id: " + res)
            processDevIni(res)

            if (_imeiUsed === false)
            {
                executed(true)
                return
            }

            root.state = "scan_imei"
            scanStart()
            return
        }

        if (root.state === "scan_imei")
        {
            console.log("!!!! Scan IMEI")
            regex = /IMEI:[0-9]{15}/;
            match = regex.exec(scan);
            if (match === null) return
            if (match.length !== 1) return
            scanStop()
            res = match[0]
            console.log("IMEI: " + res)
            _devImei = res.substr(5)
            console.log("IMEI to print: " + _devImei)

            executed(true)
            return
        }
    }

    function checkScanner()
    {
        scanner.open()
        wait(300)
        var ret = scanner.isOpenned()
        if (ret === false) scanner.close()
        return ret
    }

    function processDevIni(ini)
    {
        // getDevice
        var req = {}
        req.req = "getDevice"
        req.args = [ini]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            avlog.show("red", "Get Device ... Error!!!", false, true)
            console.warn("Error: Get Device: " + resp["errorString"])
            executed(false)
            return
        }

        var data = resp["data"]
        if (data.length === 0)   // device not exists
        {
            console.log("!!!!!! Device not exists")

            // Create device
            req = {}
            req.req = "createDevice"
            req.args = [ini, _objOrder.frefboard, _objOrder.fid, _objOperator.fid]
            resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
            if (resp["error"] === true)
            {
                avlog.show("red", "Create Device ... Error!!!", false, true)
                console.warn("Error: Create Device: " + resp["errorString"])
                executed(false)
                return
            }
        }
        _objDevice = resp["data"][0]

        // Check for repetition
        if (_objDevice.flastcomment === "Completed" && _objDevice.flasterrorcode === 0) _deviceRepetition = true
        else _deviceRepetition = false

        console.log("!!!!!!!!!!!! Device repetition: " + _deviceRepetition)

        if (_objDevice.freforder !== _objOrder.fid)
        {
            // Device was produced by other order
            if (_deviceRepetition === true)
            {
                avlog.show("red", "Error: The device " + ini + " matches the order " + _objDevice.forder1c, false, true)
                console.warn("Error: The device " + ini + " matches the the order " + _objDevice.forder1c)
                executed(false)
                return
            }

            console.log("!!!!!!!!!!!! Update Device Order: set ref to " + _objOrder.fid)

            // updateDeviceOrder
            req = {}
            req.req = "updateDeviceOrder"
            req.args = [ _objDevice.fid, _objOrder.fid ]
            resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
            if (resp["error"] === true)
            {
                avlog.show("red", "Update Device order ... Error!!!", false, true)
                console.warn("Error: Update Device order: " + resp["errorString"])
                executed(false)
                return
            }
            _objDevice.freforder = _objOrder.fid
        }

        id_wStat._board = ini
        var devId = ini.replace(/[a-zA-Z]/, '')

        // getBoardInfoByDevId
        console.log("!!!!!!! getBoardInfoByDevId: " + parseInt(devId))
        req = {}
        req.req = "getBoardInfoByDevId"
        req.args = [parseInt(devId)]
        resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            avlog.show("red", "Can NOT get Board info ... Error!!!", false, true)
            console.warn("Error: Can NOT get Board info: " + resp["errorString"])
            executed(false)
            return
        }
        console.log(JSON.stringify(resp))
        data = resp["data"]
        if (data.length > 1)
        {
            avlog.show("red", "Duplicated DB info for: " + ini + " ... Error!!!", false, true)
            console.warn("Error: Duplicated DB info for: " + ini + " : " + JSON.stringify(data))
            executed(false)
            return
        }

        if (data.length === 0)
        {
            console.log("!!!!!! Get free EUI resource")
            getFreeEuiResource()
        } else
        {
            var strEui = (data[0]["feui"].toString(16).toUpperCase()).padStart(16, '0')
            console.log("!!!!!! EUI binded: " + strEui)
            getEuiResource(strEui)
        }

        // bindEuiResource
        req = {}
        req.req = "bindEuiResource"
        req.args = [_objDevice.fid, _objEui.feui]
        resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            avlog.show("red", "Bind Eui Resource ... Error!!!", false, true)
            console.warn("Error: Bind Eui Resource: " + resp["errorString"])
            executed(false)
            return
        }
    }

    function getEuiResource(strEui)
    {
        var req = {}
        req.req = "getEuiResource"
        req.args = [parseInt(strEui, 16)]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            avlog.show("red", "Get EUI resource ... Error!!!", false, true)
            console.warn("Error: Get EUI resource: " + resp["errorString"])
            _scanner.close()
            executed(false)
            return
        }

        var data = resp["data"]
        if (data.length === 0)
        {
            avlog.show("red", "EUI resource not found: " + strEui + " Error!!!", false, true)
            console.warn("Error: EUI resource not found " + strEui + " !!!")
            _scanner.close()
            executed(false)
            return
        }

        _objEui = data[0]
        _objEui.feuistr = strEui
        id_wStat._eui = strEui
    }

    function getFreeEuiResource()
    {
        var req = {}
        req.req = "getFreeEuiResource"
        req.args = []
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            avlog.show("red", "Get EUI resource ... Error!!!", false, true)
            console.warn("Error: Get EUI resource: " + resp["errorString"])
            executed(false)
            return
        }

        var data = resp["data"]
        if (data.length === 0)
        {
            avlog.show("red", "EUI resource not found ... Error!!!", false, true)
            console.warn("Error: EUI resource not found!!!")
            executed(false)
            return
        }

        var strEui = (data[0]["feui"].toString(16).toUpperCase()).padStart(16, '0')
        _objEui = data[0]
        _objEui.feuistr = strEui
        id_wStat._eui = strEui
    }

    function apply()
    {
        if (!id_txtDevImei.acceptableInput) return

        _devImei = id_txtDevImei.text
        console.log("IMEI to print: " + _devImei)

        executed(true)
    }

    Timer
    {
        id: id_timer
        running: false
        repeat: true
        interval: 100
        onTriggered: scanning()
    }

    Rectangle
    {
        id: id_rcScan
        anchors.fill: parent
        color: "#ddffffff"
        onVisibleChanged: animation.running = true

        PropertyAnimation { id: animation;
            target: id_rcScan; property: "opacity";
            duration: 400; from: 0; to: 1;
            easing.type: Easing.InOutQuad ; running: true }

        CmpBoard
        {
            anchors.centerIn: parent
            width: parent.width - 200
            height: 60

            Row
            {
                anchors.centerIn: parent
                spacing: 20

                Image
                {
                    width: 96;
                    fillMode: Image.PreserveAspectFit;
                    source: _args[0]
                }
                Text
                {
                    id: id_txtLabel
                    anchors.verticalCenter: parent.verticalCenter;
                    font.pixelSize: 18;
                }
                TextField
                {
                    id: id_txtDevImei
                    anchors.verticalCenter: parent.verticalCenter;
                    width: 150
                    visible: false
                    selectByMouse: true
                    placeholderText: "IMEI"
                    placeholderTextColor: "grey"
                    color: id_txtDevImei.acceptableInput ? "darkgreen" : "red"
                    validator: id_regExpImei
                }
                Button
                {
                    id: id_butApply
                    anchors.verticalCenter: parent.verticalCenter;
                    width: 110
                    visible: id_txtDevImei.acceptableInput ? true : false
                    text: "Apply"
                    onClicked: apply()
                }
            }
        }
    }

    states: [
        State
        {
            name: "scan_check"
            PropertyChanges { target: id_txtLabel; text: "Check scanner ... Wait!"; color: "black" }
            PropertyChanges { target: id_txtDevImei; visible: false }
        },
        State
        {
            name: "scan_ini"
            PropertyChanges { target: id_txtLabel; text: "Scan board INI"; color: "black" }
            PropertyChanges { target: id_txtDevImei; visible: false }
        },
        State
        {
            name: "scan_imei"
            PropertyChanges { target: id_txtLabel; text: "Scan GSM IMEI"; color: "black" }
            PropertyChanges { target: id_txtDevImei; visible: true }
        }
    ]
    state: "scan_check"

    RegExpValidator
    {
        id: id_regExpImei
        regExp: /[0-9]{15}/
    }

    Shortcut
    {
        sequences: ["Return"]
        onActivated: apply()
    }

    Component.onCompleted: console.info("SCAN created!")
    Component.onDestruction:
    {
        scanner.close()
        console.info("SCAN destruction")
    }
}
