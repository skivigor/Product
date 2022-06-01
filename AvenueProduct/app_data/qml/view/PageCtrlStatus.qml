import QtQuick 2.12
import QtQuick.Controls 2.5
//import QtQuick.Controls 1.4 as OldControl
import QtQuick.Layouts 1.12
import "../component/CmpStyle.js" as Style
import "../component"
import "../../tools/db_service.js" as JDbServ
import "../../tools/lbl_service.js" as JLblServ

Page
{
    id: root
    title: qsTr("Status")

    property int _butWidth: 80

    property string _profDouble: ""
    property string _profTriple: ""
    property bool   _profDoubleExisted: false
    property bool   _profTripleExisted: false
    property var    _printModes: ["DevEui_INI", "IMEI_DevEui_INI"]

    property string _devEui: ""
    property string _devIni: ""
    property alias  _devImei: id_txtDevImei.text

    function showMessage(color, mes, showPopup)
    {
        id_txtMessage.color = color
        id_txtMessage.text = _time + " :: " + mes

        if (showPopup === true)
        {
            var path = "file:///" + AppPath + "app_data/qml/component/CmpInfoPopup.qml"
            var args = [color, mes]
            Qt.createComponent(path).createObject(root, { "_args" : args })
        }
    }

    //-----------------------------------------------------------------

    function clearStatus()
    {
        console.log("Clear status")
        _devEui = ""
        _devIni = ""
        _devImei = ""
        id_lblTime.text = ""
        id_lblOptState.text = ""
        id_lblErrCode.text = ""
        id_lblDescr.text = ""
        id_lblOrder.text = ""
    }

    //-----------------------------------------------------------------

    function getBoardInfoByDevId()
    {
        clearStatus()
        id_txtDevEui.clear()
        // getBoardInfoByDevId
        var req = {}
        req.req = "getBoardInfoByDevId"
        req.args = [parseInt(id_txtDevId.text)]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true) { showMessage("red", "Can NOT get Board info: " + resp["errorString"], true); return }
        console.log(JSON.stringify(resp))
        var data = resp["data"]
        if (data.length === 0) return

        id_lblTime.text = data[0]["fts"]
        _devIni = data[0]["fdeviceid"]
        _devEui = "00" + data[0]["feui"].toString(16).toUpperCase()
        id_lblOptState.text = data[0]["flastoptionstate"]
        id_lblErrCode.text = data[0]["flasterrorcode"]
        id_lblDescr.text = data[0]["flastcomment"]
        id_lblOrder.text = data[0]["forder1c"]

    }

    //-----------------------------------------------------------------

    function getBoardInfoByEui()
    {
        clearStatus()
        id_txtDevId.clear()
        // getBoardInfoByEui
        var req = {}
        req.req = "getBoardInfoByEui"
        req.args = [parseInt(id_txtDevEui.text, 16)]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true) { showMessage("red", "Can NOT get Board info: " + resp["errorString"], true); return }
        console.log(JSON.stringify(resp))
        var data = resp["data"]
        if (data.length === 0) return

        id_lblTime.text = data[0]["fts"]
        _devIni = data[0]["fdeviceid"]
        _devEui = "00" + data[0]["feui"].toString(16).toUpperCase()
        id_lblOptState.text = data[0]["flastoptionstate"]
        id_lblErrCode.text = data[0]["flasterrorcode"]
        id_lblDescr.text = data[0]["flastcomment"]
        id_lblOrder.text = data[0]["forder1c"]
    }

    //-----------------------------------------------------------------

    function printLabel()
    {
        if (_devEui === "" || _devIni === "" || !label.connected) return false

        var profile
        var args = []
        var req = {}
        var resp

        if (id_boxPrintMode.currentIndex === 0)  // print double label
        {
            if (_profDoubleExisted === false) return false

            profile = file.getFileAsString(AppConfPath + _profDouble)
            args = [_devEui, _devIni]
            // print
            req = {}
            req.req = "print"
            req.args = [profile, args, id_boxLblNum.value]

            console.log("!!!!!!!!!! " + id_boxLblNum.value)

            resp = JSON.parse(JLblServ.sendLblRequest(req))
            if (resp["error"] === true) { showMessage("red", "Print error", true); return false }
            return true
        }

        if (id_boxPrintMode.currentIndex === 1)  // print triple label
        {
            if (id_txtDevImei.acceptableInput) _devImei = id_txtDevImei.text
            if (_profTripleExisted === false) return false

            profile = file.getFileAsString(AppConfPath + _profTriple)
            args = [_devEui, _devIni, _devImei]
            // print
            req = {}
            req.req = "print"
            req.args = [profile, args, id_boxLblNum.value]

            resp = JSON.parse(JLblServ.sendLblRequest(req))
            if (resp["error"] === true) { showMessage("red", "Print error", true); return false }
            return true
        }

        return false
    }

    //-----------------------------------------------------------------

    function printTestLabel()
    {
        if (!label.connected) return false

        var profile
        var args = []
        var req = {}
        var resp

        if (id_boxTestPrintMode.currentIndex === 0)  // print double label
        {
            if (_profDoubleExisted === false) return false

            profile = file.getFileAsString(AppConfPath + _profDouble)
            args = ["001A79A012000001", "N0000001234567"]
            // print
            req = {}
            req.req = "print"
            req.args = [profile, args, 1]

            resp = JSON.parse(JLblServ.sendLblRequest(req))
            if (resp["error"] === true) { showMessage("red", "Test print error", true); return false }
            return true
        }

        if (id_boxTestPrintMode.currentIndex === 1)  // print triple label
        {
            if (_profTripleExisted === false) return false

            profile = file.getFileAsString(AppConfPath + _profTriple)
            args = ["001A79A012000001", "N0000001234567", "123456789012345"]
            // print
            req = {}
            req.req = "print"
            req.args = [profile, args, 1]

            resp = JSON.parse(JLblServ.sendLblRequest(req))
            if (resp["error"] === true) { showMessage("red", "Test print error", true); return false }
            return true
        }

        return false
    }

    //-----------------------------------------------------------------

    function scanning()
    {
        // Scan
        var scan = scanner.getData()
        if (scan.length < 8) return
        console.log("ScanData: " + scan)

        var res = checkScanIni(scan)
        if (res === false) checkScanImei(scan)
    }

    function checkScanIni(data)
    {
        var regex = /N[0-9]{7,13}/;
        var match = regex.exec(data);
        if (match === null) return false
        if (match.length !== 1) return false
        var res = match[0]
        console.log("ScanDevId::id: " + res)

        id_txtDevId.text = res.substr(1)
        getBoardInfoByDevId()
        return true
    }

    function checkScanImei(data)
    {
        var regex = /IMEI:[0-9]{15}/;
        var match = regex.exec(data);
        if (match === null) return false
        if (match.length !== 1) return false
        var res = match[0]
        console.log("IMEI: " + res)

        _devImei = res.substr(5)
        return true
    }

    //-----------------------------------------------------------------

    BorderImage { anchors.fill: parent; source: Style.bgPageTheme }

    Flickable
    {
        anchors.fill: parent
        clip: true
        contentHeight: id_clm.height + 100
        contentWidth: parent.width
        ScrollBar.vertical: ScrollBar {}

        ColumnLayout
        {
            id: id_clm
            width: parent.width - 50
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            CmpBoard
            {
                Layout.fillWidth: true
                height: 520

                Row
                {
                    spacing: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    Text { text: "Scanner:  " }
                    Text
                    {
                        color: scanner.openned ? "green" : "red"
                        text: scanner.openned ? "OPENNED" : "CLOSED"
                    }
                }   // row scanner status

                Column
                {
                    anchors.centerIn: parent
                    spacing: 10
                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.txtHeaderSize
                        text: "Get board info"
                    }
                    Row
                    {
                        spacing: 20
                        Text { width: 150; text: "By device INI" }
                        TextField
                        {
                            id: id_txtDevId
                            width: 150
                            selectByMouse: true
                            placeholderText: "Device INI"
//                            canPaste: true
                            validator: IntValidator{bottom: 1; top: 99999999; }
                            onAccepted: getBoardInfoByDevId()
                        }
                        Button
                        {
                            width: _butWidth
                            text: "Get"
                            onClicked: getBoardInfoByDevId()
                            Keys.onReturnPressed: getBoardInfoByDevId()
                        }
                    }   // row by devIni
                    Row
                    {
                        spacing: 20
                        Text { width: 150; text: "By device EUI" }
                        TextField
                        {
                            id: id_txtDevEui
                            width: 150
                            selectByMouse: true
                            placeholderText: "Device EUI"
//                            canPaste: true
//                            font.capitalization: Font.AllUppercase
                            validator: id_regExpHex
                            onAccepted: getBoardInfoByEui()
                        }
                        Button
                        {
                            width: _butWidth
                            text: "Get"
                            onClicked: getBoardInfoByEui()
                            Keys.onReturnPressed: getBoardInfoByEui()
                        }
                    }   // row by devEui
                    Item
                    {
                        width: parent.width
                        height: id_clmOrd.height

                        Column
                        {
                            id: id_clmOrd
                            width: 350
                            spacing: 5
                            Row
                            {
                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Time:" }
                                Text { id: id_lblTime; font.bold: true }
                            }
                            Row
                            {
                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Device INI:" }
                                Text { /*id: id_lblDevId;*/ font.bold: true; color: "darkgreen"; text: _devIni }
                            }
                            Row
                            {
                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Device EUI:" }
                                Text { /*id: id_lblDevEui; */font.bold: true; color: "darkgreen"; text: _devEui }
                            }
                            Row
                            {
                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Order 1C:" }
                                Text { id: id_lblOrder; font.bold: true }
                            }
                            Row
                            {
                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Option state:" }
                                Text { id: id_lblOptState; font.bold: true }
                            }
                            Row
                            {
                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Error code:" }
                                Text { id: id_lblErrCode; font.bold: true }
                            }
                            Row
                            {
                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Description:" }
                                Text { id: id_lblDescr; font.bold: true }
                            }
                        } // column Info
                    }    // item info

                    Text { text: "--------------------------------" }
                    Row
                    {
                        spacing: 20
                        Text { text: "Label service:  " }
                        Text
                        {
                            color: label.connected ? "green" : "red"
                            text: label.connected ? "CONNECTED" : "DISCONNECTED"
                        }
                    }
                    Text { text: "Print label"; font.bold: true }
                    Row
                    {
                        spacing: 20
                        Text { width: 60; text: "Label type"; anchors.verticalCenter: parent.verticalCenter }
                        ComboBox
                        {
                            width: 140
                            id: id_boxPrintMode
                            model: _printModes
                        }
                        Text { text: "Copy number"; anchors.verticalCenter: parent.verticalCenter }
                        SpinBox { id: id_boxLblNum; width: 50; from: 1; to: 3; value: 1 }
                        Button
                        {
                            id: id_butPrint
                            width: _butWidth
                            enabled:
                            {
                                if (label.connected === false) return false
                                if (_devEui === "" || _devIni === "") return false
                                if (id_boxPrintMode.currentIndex === 0 && _profDoubleExisted === true) return true
                                if (id_boxPrintMode.currentIndex === 1 && _profTripleExisted === true && id_txtDevImei.acceptableInput) return true

                                return false
                            }
                            text: "Print"
                            onClicked: printLabel()
                        }
                        Text { font.pixelSize: 14; text: "[Ctrl + P]" }
                    }
                    Row
                    {
                        visible: id_boxPrintMode.currentIndex === 1 ? true : false
                        spacing: 20
                        Text { width: 60; text: "IMEI"; anchors.verticalCenter: parent.verticalCenter }
                        TextField
                        {
                            id: id_txtDevImei
                            width: 150
                            selectByMouse: true
                            placeholderText: "IMEI"
                            placeholderTextColor: "grey"
                            color: id_txtDevImei.acceptableInput ? "darkgreen" : "red"
                            validator: id_regExpImei
                            text: _devImei
                        }
                    }   // row IMEI

                    Text { text: "--------------------------------" }
                    Row
                    {
                        spacing: 20
                        Text { text: "Print test label"; anchors.verticalCenter: parent.verticalCenter }
                        ComboBox
                        {
                            width: 140
                            id: id_boxTestPrintMode
                            model: _printModes
                        }

                        Button
                        {
                            id: id_butTestPrint
                            width: _butWidth
                            enabled:
                            {
                                if (label.connected === false) return false
                                if (id_boxTestPrintMode.currentIndex === 0 && _profDoubleExisted) return true
                                if (id_boxTestPrintMode.currentIndex === 1 && _profTripleExisted) return true
                                return false
                            }

                            text: "Print"
                            onClicked: printTestLabel()
                        }
                        Text { font.pixelSize: 14; text: "[Ctrl + T]" }
                    }
                }

            }   // CmpBoard
        }   // ColumnLayout
    }

    Rectangle
    {
        width: parent.width
        height: 50
        anchors.bottom: parent.bottom
        color: "#99ffffff"
        Text { id: id_txtMessage; anchors.centerIn: parent; font.pixelSize: 16 }
    }

    RegExpValidator
    {
        id: id_regExpHex
        regExp: /[0-9A-Fa-f/\s]+/
    }
    RegExpValidator
    {
        id: id_regExpImei
        regExp: /[0-9]{15}/
    }

    Timer
    {
        id: id_timer
        running: true
        repeat: true
        interval: 1000
        onTriggered: scanning()
    }

    Shortcut { sequences: ["Ctrl+P"]; onActivated: { if (!id_butPrint.enabled) return; printLabel() } }
    Shortcut { sequences: ["Ctrl+T"]; onActivated: { if (!id_butTestPrint.enabled) return; printTestLabel() } }

    Component.onCompleted:
    {
        var lblAddr = settings.printerClient.secured === true ? "wss://" : "ws://"
        lblAddr += settings.printerClient.host + ":" + settings.printerClient.port
        label.connect(lblAddr)

        var arrLabel = settings.printerClient.label
        for (var i = 0; i < arrLabel.length; ++i)
        {
            var setProf = arrLabel[i]
            if (setProf.name === "double")
            {
                console.log("Double prof: " + setProf.profile)
                _profDouble = setProf.profile
                _profDoubleExisted = file.isFileExists(AppConfPath + _profDouble)
            }
            if (setProf.name === "triple")
            {
                console.log("Triple prof: " + setProf.profile)
                _profTriple = setProf.profile
                _profTripleExisted = file.isFileExists(AppConfPath + _profTriple)
            }
        }

        console.log("Double existed: " + file.isFileExists(AppConfPath + _profDouble))
        console.log("Triple existed: " + file.isFileExists(AppConfPath + _profTriple))

        scanner.open()
    }
    Component.onDestruction:
    {
        label.disconnect()
        scanner.close()
    }

}
