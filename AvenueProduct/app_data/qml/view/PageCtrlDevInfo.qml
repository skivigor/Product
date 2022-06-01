import QtQuick 2.12
import QtQuick.Controls 1.4 as OldCtrl
import QtQuick.Controls.Styles 1.2
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import "../component/CmpStyle.js" as Style
import "../component"
import "../../tools/db_service.js" as JDbServ

Page
{
    id: root
    title: qsTr("Device Info")

    property int _butWidth: 80
    property var _devInfo

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

    function getDevInfoByOrder()
    {
        console.log("QML: getDeviceInfoByOrder: " + id_txtOrder1cInf2.text)
        id_txtOutput.text = ""
        if (id_txtOrder1cInf2.length === 0) return

        // getDeviceInfoByOrder
        var req = {}
        req.req = "getDeviceInfoByOrder"
        req.args = [id_txtOrder1cInf2.text]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true) { showMessage("red", "Can NOT get Device info: " + resp["errorString"], true); return }
        var data = resp["data"]
        if (data.length === 0) return

        processDevInfo(data)
    }

    //-----------------------------------------------------------------

    function getDevInfoByEui()
    {
        console.log("QML: getDeviceInfoByEui: " + id_txtStartEui.text + " " + id_txtEndEui.text)
        id_txtOutput.text = ""

        var startEui = parseInt(id_txtStartEui.text, 16)
        if (startEui === 0) return
        var endEui = parseInt(id_txtEndEui.text, 16)
        if (isNaN(endEui) || endEui === undefined || endEui < startEui) endEui = startEui

        // getDeviceInfoByEui
        var req = {}
        req.req = "getDeviceInfoByEui"
        req.args = [startEui, endEui]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
//        console.log(JSON.stringify(resp))
        if (resp["error"] === true) { showMessage("red", "Can NOT get Device info: " + resp["errorString"], true); return }
        var data = resp["data"]
        if (data.length === 0) return

        processDevInfo(data)
    }

    //-----------------------------------------------------------------

    function processDevInfo(data)
    {
        id_txtOutput.text = ""

        var count = 0
        var doc = {}
        for (var i = 0; i < data.length; ++i)
        {
            var rec = {}
            var obj = data[i]

            var eui = obj["feui"]
            var hex = eui.toString(16).toUpperCase()
            while (hex.length < 16) hex = "0" + hex

            if (doc[hex] !== undefined) rec = doc[hex]
            else count++

            var fdata = JSON.parse(obj["fdata"])
            rec[obj["fkeyname"]] = fdata
            doc[hex] = rec
        }

        var strDevices = (count > 1) ? " devices" : " device"
        console.log("QML: processDevInfo: information received for " + count + strDevices)
        showMessage("green", "DevInfo received for " + count + strDevices, true)
        _devInfo = doc
        id_txtOutput.text = JSON.stringify(doc, null, 4)
    }

    //-----------------------------------------------------------------

    function saveDevInfo()
    {
        if (_devInfo === null) return

        var name = "DevInfo_" + Qt.formatDateTime(new Date(), "ddMMyyhhmmss") + ".json"
        var path = AppPath + "log/" + name
        var ret = file.saveFileAsJsonDoc(path, _devInfo)

        if (ret === false) { showMessage("red", "Error! Can not save to file", true); return }
        showMessage("green", "Saved to: " + name, true)
    }

    //-----------------------------------------------------------------

    function clearDevInfo()
    {
        id_txtOutput.text = ""
        _devInfo = null
    }

    //-----------------------------------------------------------------

    function createCsv()
    {
        console.log("QML: createCsv: " + id_txtOrder1cInf3.text)
        if (id_txtOrder1cInf3.length === 0) return

        var order = id_txtOrder1cInf3.text

        // getOrderInfo
        var req = {}
        req.req = "getOrderInfo"
        req.args = [id_txtOrder1cInf3.text]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        console.log("Order info " + JSON.stringify(resp))
        if (resp["error"] === true) { showMessage("red", "Can NOT get Order info: " + resp["errorString"], true); return }
        var data = resp["data"]
        if (data.length === 0) return
        var kt = data[0]["fkt"]
        var inicount = data[0]["forderedinicount"]

        // getDeviceInfoByOrder
        req = {}
        req.req = "getDeviceInfoByOrder"
        req.args = [id_txtOrder1cInf3.text]
        resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true) { showMessage("red", "Can NOT get Device info: " + resp["errorString"], true); return }
        data = resp["data"]
//        console.log("Data " + JSON.stringify(data))
        if (data.length === 0) return

        var arrEui = []
        var count = 0
        var doc = ""

        for (var i = 0; i < data.length; ++i)
        {
            var obj = data[i]
            if (obj["fkeyname"] !== "lora") continue

            arrEui.push(obj["feui"])
            count++
        }
        arrEui.sort()

        if (count !== inicount) { showMessage("red", "Data amount error!!! " + count + "/" + inicount, true); return }

        for (i = 0; i < arrEui.length; ++i)
        {
            var hex = arrEui[i].toString(16).toUpperCase()
            while (hex.length < 16) hex = "0" + hex

            var str = hex + ";" + kt + ";" + "expostroy_building;demo;;;;\r\n"
            doc += str
        }

//        console.log(doc)
        var name = Qt.formatDateTime(new Date(), "ddMMyyhhmmss_") + order + "_" + count + "devices" + ".csv"
        var path = AppPath + "log/" + name
        var ret = file.saveFile(path, doc)

        if (ret === false) { showMessage("red", "Error! Can not save to file", true); return }
        showMessage("green", "Saved to: " + name, true)
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

            // Device info
            CmpBoard
            {
                Layout.fillWidth: true
                height: 600
                Column
                {
                    anchors.centerIn: parent
                    spacing: 10
                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.txtHeaderSize
                        text: "Get Device information"
                    }

                    Row
                    {
                        spacing: 20
                        Text { width: 80; anchors.verticalCenter: parent.verticalCenter; text: "By Order" }
                        TextField { id: id_txtOrder1cInf2; width: 120; selectByMouse: true; placeholderText: "1C code"; onAccepted: getDevInfoByOrder() }
                        Button { width: _butWidth; text: "Get"; onClicked: getDevInfoByOrder(); Keys.onReturnPressed: getDevInfoByOrder() }
                    }   // row
                    Row
                    {
                        spacing: 20
                        Text { width: 80; anchors.verticalCenter: parent.verticalCenter; text: "By DevEUI" }
                        TextField
                        {
                            id: id_txtStartEui
                            width: 170
                            color: id_txtStartEui.acceptableInput ? "black" : "red"
                            validator: id_regExpHex8
                            selectByMouse: true
                            placeholderText: "Start EUI"
                            placeholderTextColor: "gray"
                            onAccepted: getDevInfoByEui()
                        }
                        TextField
                        {
                            id: id_txtEndEui
                            width: 170
                            color: id_txtEndEui.acceptableInput ? "black" : "red"
                            validator: id_regExpHex8
                            selectByMouse: true
                            placeholderText: "End EUI"
                            placeholderTextColor: "gray"
                            onAccepted: getDevInfoByEui()
                        }
                        Button
                        {
                            width: _butWidth
                            text: "Get"
                            onClicked: getDevInfoByEui()
                            Keys.onReturnPressed: getDevInfoByEui()
                        }
                    }   // row
                    Rectangle
                    {
                        width: 700
                        //                    anchors.horizontalCenter: parent.horizontalCenter
                        height: 400
                        color: "#ccffffff"

                        OldCtrl.TextArea
                        {
                            id: id_txtOutput

                            style: TextAreaStyle {
                                textColor: "#333"
                                selectionColor: "steelblue"
                                selectedTextColor: "#eee"
                                //backgroundColor: "#77ffffff"
                            }

                            anchors.fill: parent
                            anchors.margins: 5
                            readOnly: true
                            selectByMouse: true
                            backgroundVisible: false
                            textFormat: TextEdit.AutoText     // PlainText, AutoText, RichText
                            font.pixelSize: 14
                            wrapMode: TextEdit.WrapAnywhere
                            cursorPosition: id_txtOutput.length
                            //text: standObj.resp //Qt.formatDateTime(new Date(), "dd.MM.yy  hh:mm:ss:zzz") + " <=> " + "SYSTEM" + ": " + "Run application"
                        }
                    }

                    Row
                    {
                        spacing: 20
                        anchors.right: parent.right
                        Button { width: _butWidth; text: "Clear"; onClicked: clearDevInfo() }
                        Button { width: _butWidth; text: "Save"; onClicked: saveDevInfo() }
                    }
                }   // column
            }   // CmpBoard

            // Create CSV
            CmpBoard
            {
                Layout.fillWidth: true
                height: 100
                Column
                {
                    anchors.centerIn: parent
                    spacing: 10
                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.txtHeaderSize
                        text: "Create CSV"
                    }

                    Row
                    {
                        spacing: 20
                        Text { width: 80; anchors.verticalCenter: parent.verticalCenter; text: "By Order" }
                        TextField { id: id_txtOrder1cInf3; width: 120; selectByMouse: true; placeholderText: "1C code"; onAccepted: createCsv() }
                        Button { width: _butWidth; text: "Create"; onClicked: createCsv(); Keys.onReturnPressed: createCsv() }
                    }   // row

                }   // column
            }   // CmpBoard

        }    // ColumnLayout
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
        id: id_regExpHex8
        regExp: /[0-9A-Fa-f/\s]{16}/
    }
}
