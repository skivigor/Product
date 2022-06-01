import QtQuick 2.12
import QtQuick.Controls 2.5
import "../component"
import "../../tools/db_service.js" as JDbServ
import "../../tools/lbl_service.js" as JLblServ
//import "../../tools/stand_service.js" as JStand


Item
{
    id: root
    anchors.fill: parent
    property var _args
    property bool _waiting: false

    property string _profDouble: ""
    property string _profTriple: ""
    property bool   _profDoubleExisted: false
    property bool   _profTripleExisted: false
    property int    _profDoubleCopyNum: 1
    property int    _profTripleCopyNum: 1


    signal executed(bool res)
    signal stop()

    QtObject
    {
        id: set
        // Stand codes
        property int fnStandCode: 0x78
        property int fnSetPwRelOn: 0x21
        property int fnSetConnRelOn: 0x1A
        property int fnSetPwRelOff: 0x22
        property int fnSetConnRelOff: 0x1B
    }

    //-----------------------------------------------------------------

    function execute()
    {
        _waiting = true

        if (_powerSupplyUsed)
        {
            _power.loadOff()
            wait(500)
            _power.pwDisconnect()
        }

        _standApiObj.resetStand()
        _uart.disconnectSerial()
        _waiting = false

        if (_deviceRepetition === true && _optionErrored === true) decrementOrderIniCount()
        if (_optionErrored === true) return

        printLabel()

        avlog.show("green", "Device Completed ... OK", false, true)
        if (_deviceRepetition === true) return

        incrementOrderIniCount()
    }

    //-----------------------------------------------------------------

    function incrementOrderIniCount()
    {
        // incrementOrderIniCount
        var req = {}
        req.req = "incrementOrderIniCount"
        req.args = [_objOrder.forder1c]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        var data = resp["data"]
        if (resp["error"] === true || data.length === 0)
        {
            avlog.show("red", "Increment Ini counter of order ... Error!!!", false, true)
            console.warn("Error: Increment Ini counter of order: " + resp["errorString"])
            executed(false)
            return
        }
        _objOrder.forderedinicount = data[0]["forderedinicount"]
    }

    //-----------------------------------------------------------------

    function decrementOrderIniCount()
    {
        // decrementOrderIniCount
        var req = {}
        req.req = "decrementOrderIniCount"
        req.args = [_objOrder.forder1c]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        var data = resp["data"]
        if (resp["error"] === true || data.length === 0)
        {
            avlog.show("red", "Decrement Ini counter of order ... Error!!!", false, true)
            console.warn("Error: Decrement Ini counter of order: " + resp["errorString"])
            executed(false)
            return
        }
        _objOrder.forderedinicount = data[0]["forderedinicount"]
    }

    //-----------------------------------------------------------------

    function printLabel()
    {
        if (settings.printerClient.enabled === false) return

        var profile
        var args = []
        var req = {}
        var resp

        var arrLabel = settings.printerClient.label
        for (var i = 0; i < arrLabel.length; ++i)
        {
            var setProf = arrLabel[i]
            if (setProf.name === "double")
            {
                console.log("Double prof: " + setProf.profile)
                _profDouble = setProf.profile
                _profDoubleExisted = file.isFileExists(AppConfPath + _profDouble)
                _profDoubleCopyNum = setProf.copyNum
            }
            if (setProf.name === "triple")
            {
                console.log("Triple prof: " + setProf.profile)
                _profTriple = setProf.profile
                _profTripleExisted = file.isFileExists(AppConfPath + _profTriple)
                _profTripleCopyNum = setProf.copyNum
            }
        }

        if (_imeiUsed === true)
        {
            if (_profTripleExisted === false) return

            profile = file.getFileAsString(AppConfPath + _profTriple)
            args = [id_wStat._eui, id_wStat._board, _devImei]
            // print
            req = {}
            req.req = "print"
            req.args = [profile, args, _profTripleCopyNum]

            console.log("Print label: " + id_wStat._eui + " : " + id_wStat._board + " : " + _devImei)
            JLblServ.sendLblRequest(req)
        } else
        {
            if (_profDoubleExisted === false) return

            profile = file.getFileAsString(AppConfPath + _profDouble)
            args = [id_wStat._eui, id_wStat._board]
            // print
            req = {}
            req.req = "print"
            req.args = [profile, args, _profDoubleCopyNum]

            console.log("Print label: " + id_wStat._eui + " : " + id_wStat._board)
            JLblServ.sendLblRequest(req)
        }
    }

    //-----------------------------------------------------------------

    function butClicked()
    {
        if (_waiting === true) return

        id_wStat._eui = ""
        id_wStat._board = ""
        avlog.show("green", "Board removed ... Ok")
        executed(true);
    }

    Rectangle
    {
        id: id_rcOrder
        anchors.fill: parent
        color: "#ddffffff"
        onVisibleChanged: animation.running = true

        PropertyAnimation { id: animation;
            target: id_rcOrder; property: "opacity";
            duration: 400; from: 0; to: 1;
            easing.type: Easing.InOutQuad ; running: true }

        Column
        {
            anchors.centerIn: parent
//            anchors.verticalCenterOffset: -100
            spacing: 30

            CmpBoard
            {
                width: root.width - 200
                height: 60

                CmpTransparant { id: id_cmpMes }
            }

            CmpBoard
            {
                width: root.width - 200
                height: 60

                Row
                {
                    spacing: 15
                    anchors.centerIn: parent
                    Text
                    {
                        font.pixelSize: 15
                        text: _waiting ? "Reset Stand settings ..." : "Remove Board from Stand"
                    }
                    Button
                    {
                        width: 60
                        text: "Ok"
                        visible: _waiting ? false : true
                        onClicked: butClicked()
                    }
                }
            }    // CmpBoard
        }   // Column
    }

    Shortcut
    {
        sequences: ["Return"]
        onActivated: butClicked()
    }

    Component.onCompleted:
    {
        console.info("BOARD REMOVE created!")
        var lblAddr = settings.printerClient.secured === true ? "wss://" : "ws://"
        lblAddr += settings.printerClient.host + ":" + settings.printerClient.port
        label.connect(lblAddr)
        wait(500)
    }

    Component.onDestruction:
    {
        console.info("BOARD REMOVE destruction")
        label.disconnect()
    }

}
