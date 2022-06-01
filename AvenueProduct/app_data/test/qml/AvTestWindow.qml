import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.2
//import "../js/test.js" as JS
import "../../tools/db_service.js" as JDbServ
import "./option_executor.js" as OpExec


Window
{
    id: root
    visible: true
//    visibility: "FullScreen"
    width: 500
    height: 800
    title: qsTr("Window Test v0.0.1")

    property var _power: new PowerSupplyWithTcp("192.168.0.248", 30000)

    FileDialog
    {
        id: fileDialog
        title: "Please choose a file"
        nameFilters: [ "Firmware files (*.bin *.hex)", "All files (*)" ]
        onAccepted:
        {
            console.log("You chose: " + fileDialog.fileUrl)
            avtest.openFile(fileDialog.fileUrl)
            //firm.select(fileDialog.fileUrls)
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    BorderImage
    {
        id: id_imgMainTheme
        anchors.fill: parent
        source: "../../images/wave_theme3.jpg"
    }

    Rectangle
    {
        id: id_rcView
        anchors.fill: parent
        anchors.margins: 5
        color: "#bbffffff"
        radius: 10
        border.width: 1
        border.color: "#E0E0E0"
    }

    Column
    {
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Text { anchors.horizontalCenter: parent.horizontalCenter; font.bold: true; text: "Load Firmware To Db" }
        Row
        {
            spacing: 20
            TextField
            {
                id: id_fldSwtype; width: 50
                validator: IntValidator{bottom: 256; top: 65535;}
                text: "257"
            }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "SwType" }
            ComboBox
            {
                id: id_boxFwType
                width: 80
                model: ["BOOT", "MAIN", "RADIO"]
            }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "FwType" }

        }   // Row
        Row
        {
            spacing: 20
            TextField { id: id_fldVerName; width: 100; text: "1.5.0" }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "Ver. name" }
        }   // Row
        Row
        {
            spacing: 20
            TextField { id: id_fldVerDescr; width: 200; text: "With FOTA" }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "Ver. descr" }
        }   // Row
        Row
        {
            spacing: 20
            TextField { id: id_fldVerPath; width: 200; text: "ver_1_5_x/ver_1_5_0/" }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "Ver. path" }
        }   // Row
        Row
        {
            spacing: 40
            CheckBox { id: id_chkProduct; checked: true; text: " Is Product" }
            CheckBox { id: id_chkLast; checked: true; text: " Is Last" }
        }

        Row
        {
            spacing: 20
            Text { width: 180; anchors.verticalCenter: parent.verticalCenter; color: "darkgreen"; text: avtest.fwName }
            Button { width: 80; text: "Select bin"; onClicked: fileDialog.visible = true }
        }   // Row
        Row
        {
            spacing: 20
            Text { id: id_txtStatus; width: 180; anchors.verticalCenter: parent.verticalCenter }
            Button
            {
                width: 80;
                text: "Load";
                onClicked:
                {
                    id_txtStatus.color = "black"
                    id_txtStatus.text = "Processing ..."
                    // Load Firmware
                    var req = {}
                    req.req = "addFirmware"
                    // function addFirmware(swType, verName, verDescr, verPath, fwType, fwName, fwApi, fwMd5, fwFile, isProduct, isLast)
                    var swType = parseInt(id_fldSwtype.displayText)
                    var verName = id_fldVerName.displayText
                    var verDescr = id_fldVerDescr.displayText
                    var verPath = id_fldVerPath.displayText
                    var fwType = id_boxFwType.currentText
                    req.args = [swType, verName, verDescr, verPath, fwType, avtest.fwName, "{}", avtest.fwMd5,
                                avtest.fwFile, id_chkProduct.checked, id_chkLast.checked]
                    var resp = JSON.parse(JDbServ.sendDbRequest(dbClient, req))
                    if (resp["error"] === true)
                    {
                        id_txtStatus.color = "red"
                        id_txtStatus.text = "Load firmware ... Error!"
                        console.warn("Error: Add firmware: " + resp["errorString"])
                        return
                    }
                    id_txtStatus.color = "darkgreen"
                    id_txtStatus.text = "Load firmware ... Done!"
                }
            }
        }   // Row

        // Separator
        Rectangle { width: parent.width - 40; height: 1; anchors.horizontalCenter: parent.horizontalCenter; color: "#909090" }

        Text { anchors.horizontalCenter: parent.horizontalCenter; font.bold: true; text: "Get Firmware From Db" }
        Row
        {
            spacing: 20
            TextField
            {
                id: id_fldSwtype2; width: 50
                validator: IntValidator{bottom: 256; top: 65535;}
                text: "257"
            }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "SwType" }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "         " }
            ComboBox
            {
                id: id_boxVar
                width: 100
                model: [ "Product", "Last" ]
            }
        }   // Row
        Row
        {
            spacing: 20
            Text { id: id_txtStatus2; width: 180; anchors.verticalCenter: parent.verticalCenter }
            Button
            {
                width: 80;
                text: "Get";
                onClicked:
                {
                    id_txtStatus2.color = "black"
                    id_txtStatus2.text = "Processing ..."
                    //getFirmware
                    var req = {}
                    req.req = id_boxVar.currentText === "Product" ? "getProductFirmware" : "getLastFirmware"
                    req.args = [parseInt(id_fldSwtype2.displayText)]
                    var resp = JSON.parse(JDbServ.sendDbRequest(dbClient, req))
                    if (resp["error"] === true)
                    {
                        id_txtStatus2.color = "red"
                        id_txtStatus2.text = "Get firmware ... Error!"
                        console.warn("Error: receive firmware: " + resp["errorString"])
                        return
                    }
                    id_txtStatus2.color = "darkgreen"
                    id_txtStatus2.text = "Get firmware ... Done!"
                    var data = resp["data"]
                    console.info("Data len: " + data.length)
                    for (var i = 0; i < data.length; ++i)
                    {
                        console.info(data[i]["ffwname"])
                        avtest.parseFile(data[i]["ffwmd5"], data[i]["ffwfile"])
                    }
                }
            }
        }   // Row

        // Separator
        Rectangle { width: parent.width - 40; height: 1; anchors.horizontalCenter: parent.horizontalCenter; color: "#909090" }

        Text { anchors.horizontalCenter: parent.horizontalCenter; font.bold: true; text: "Get Options of Order" }
        Row
        {
            spacing: 20
            ComboBox
            {
                id: id_boxOrder
                width: 100
                model: [ "KT2 1C", "KT3 1C", "KT4 1C" ]
            }

            Button
            {
                width: 80
                text: "Get"
                onClicked:
                {
                    //getOptionsForOrder
                    var req = {}
                    req.req = "getOptionsForOrder"
                    req.args = [id_boxOrder.currentText]
                    var resp = JSON.parse(JDbServ.sendDbRequest(dbClient, req))
                    if (resp["error"] === true)
                    {
                        console.warn("Error: order options: " + resp["errorString"])
                        return
                    }
                    var data = resp["data"]
                    console.info("Data len: " + data.length)
                    for (var i = 0; i < data.length; ++i)
                    {
                        console.info(data[i]["name"] + " " + data[i]["descr"] + " " + data[i]["controlfile"] + " " + data[i]["hwdefined"])
                    }
                }
            }
        }   // Row

        // Separator
        Rectangle { width: parent.width - 40; height: 1; anchors.horizontalCenter: parent.horizontalCenter; color: "#909090" }

        Text { anchors.horizontalCenter: parent.horizontalCenter; font.bold: true; text: "User test" }
        Row
        {
            spacing: 20

            TextField { id: id_fldUser; width: 100; text: "Login" }
            TextField { id: id_fldPass; width: 100; text: "Pass" }
            Button
            {
                width: 80
                text: "Save"
                onClicked:
                {
                    // addUser
                    var req = {}
                    req.req = "addUser"
                    req.args = [ "Skiv", "FSkiv", id_fldUser.displayText, id_fldPass.displayText, "SvetLab", "Admin"]
                    var resp = JSON.parse(JDbServ.sendDbRequest(dbClient, req))
                    if (resp["error"] === true)
                    {
                        console.warn("Error: add user: " + resp["errorString"])
                        return
                    }
                }
            }
        }   // Row

        Row
        {
            spacing: 20

            Button
            {
                width: 80
                text: "Check"
                onClicked:
                {
                    // checkUser
                    var req = {}
                    req.req = "checkUser"
                    req.args = [ id_fldUser.displayText, id_fldPass.displayText]
                    var resp = JSON.parse(JDbServ.sendDbRequest(dbClient, req))
                    if (resp["error"] === true)
                    {
                        console.warn("Error: Check user: " + resp["errorString"])
                        return
                    }
                }
            }

            Button
            {
                width: 80
                text: "Test"
                onClicked:
                {
                    var req = {}
                    req.req = "getOrderByCode"
                    req.args = [ "KT3 1C; SELECT * FROM torder" ]
                    var resp = JSON.parse(JDbServ.sendDbRequest(dbClient, req))
                    console.log("!!!!!!!!!! " + JSON.stringify(resp))
                }
            }
        }

        Row
        {
            spacing: 20

            Button
            {
                width: 80
                text: "NonGui 1"
                onClicked: OpExec.execOption("NonGui1.qml", avtest)
            }
            Button
            {
                width: 80
                text: "NonGui 2"
                onClicked:
                {
                    var arg = [ 22, 33 ]
                    OpExec.execOption("NonGui2.qml", arg)
                }
            }
            Button
            {
                width: 80
                text: "TTest"
                onClicked:
                {
                    var req = {}
                    req.req = "getEuiResource"
                    req.args = [7452077798195573]
                    var resp = JSON.parse(JDbServ.sendDbRequest(dbClient, req))
                    if (resp["error"] === true)
                    {
                        console.warn("Error: ttest: " + resp["errorString"])
                        return
                    }
                    console.log("DATA: " + JSON.stringify(resp["data"][0]))
                    var eui = resp["data"][0]
                    if (eui.frefdevice === 0)
                    {
                        console.log("REF DEV is NULL ")
                    } else
                    {
                        console.log("REF DEV is NOT NULL ")
                    }
                }
            }
        }   // Row

        // Separator
        Rectangle { width: parent.width - 40; height: 1; anchors.horizontalCenter: parent.horizontalCenter; color: "#909090" }

        Text { anchors.horizontalCenter: parent.horizontalCenter; font.bold: true; text: "Log test" }
        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Button
            {
                width: 110
                text: "Save Lora"
                onClicked:
                {
                    var obj = {}
                    obj.name = "lora_blalbla"
                    obj.key = "12345678"
                    avlog.saveSettings("test", obj)
                }
            }
            Button
            {
                width: 110
                text: "Save WiFi"
                onClicked:
                {
                    var obj = {}
                    obj.name = "wifi_blalbla"
                    obj.key = "12345678"
                    avlog.saveSettings("test", obj)
                }
            }
        }   // row
        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Button
            {
                width: 110
                text: "Save Lora"
                onClicked:
                {
                    var str = "test str 1 for lora"
                    avlog.saveSettings("str 1", str)
                }
            }
            Button
            {
                width: 110
                text: "Save WiFi"
                onClicked:
                {
                    var str = "test str 2 for wifi"
                    avlog.saveSettings("str 2", str)
                }
            }
        }   // row
    }
}

















