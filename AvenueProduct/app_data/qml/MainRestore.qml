import QtQuick 2.11
import QtQuick.Window 2.11
//import QtQuick.Controls 1.4
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.12
import "./component"
import "./widget"
import "./view"
import "../tools/db_service.js" as JDbServ

Window
{
    id: id_mainWindow
    visible: true
    width: 500
    height: 350
    title: qsTr("AvTool")

    property var _dbClient: new DbServiceClient()
    property string _time: Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss")
    property string _header
    property var _operatorFid
    property var _objOperator

    //-----------------------------------------------------------------

    function getDateTime() { _time = Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss") }

    //-----------------------------------------------------------------

    function onLogin(login, pass)
    {
        console.log("!!!!!!! on login")

        // checkUser
        var req = {}
        req.req = "checkUser"
        req.args = [ login, pass]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            id_txtMessage.color = "red"
            id_txtMessage.text = resp["errorString"]
            id_txtMessage.visible = true
            console.warn("Error: Check user: " + resp["errorString"])
            return
        }

        // Autorization complete
        _objOperator = resp["data"][0]
        id_txtOperator.text = _objOperator.fusername + " " + _objOperator.fusersurname
        id_txtMessage.visible = false
        id_wAuth.visible = false
        id_wAuth.destroy()

        // Start Restore work
        start()
    }

    //-----------------------------------------------------------------

    function start()
    {
        var mode = settings.product.mode
        var list = settings.product.list
        var name = ""
        var image = ""
        var stand = ""
        var fw = ""

        for (var i = 0; i < list.length; ++i)
        {
            if (list[i]["mode"] === mode)
            {
                name = list[i]["name"]
                image = list[i]["image"]
                stand = list[i]["stand"]
                fw = list[i]["fw"]
                break
            }
        }

        if (name.length === 0 || stand.length === 0 || fw.length === 0)
        {
            id_txtMessage.color = "red"
            id_txtMessage.text = "Operation Mode Error: " + mode
            id_txtMessage.visible = true
            console.warn("Operation Mode Error: " + mode)
            return
        }

        var args = [name, image, stand, fw]
        var path = "file:///" + AppPath + "app_data/qml/view/ViewRestore.qml"
        var workObj = Qt.createComponent(path).createObject(id_itmWorkSpace, { "_args" : args })

        if (workObj === null)
        {
            id_txtMessage.color = "red"
            id_txtMessage.text = "Error!!! Can not load ViewRestore.qml"
            id_txtMessage.visible = true
            console.warn("Error!!! Can not load: " + path)
            return
        }
    }

    //-----------------------------------------------------------------

    Timer { interval: 1000; repeat: true; running: true; onTriggered: getDateTime() }
    BorderImage { anchors.fill: parent; source: "../images/wave_theme5.jpg" }
    Image { anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 5; source: "../images/logo.png" }
    Text
    {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        font.pixelSize: 22
        font.bold: true
        color: "darkgreen"
        text: _header
    }

    Text
    {
        id: id_txtMessage; visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom; anchors.margins: 10
        font.pixelSize: 16
    }

    Column
    {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        Text { color: "darkgreen"; font.pixelSize: 16; text: _time }
        Row
        {
            spacing: 10
            Text { text: "Operator: "; font.pixelSize: 16; /*font.bold: true*/ }
            Text { id: id_txtOperator; font.pixelSize: 16; }
        }
    }

    WidgetAuth { id: id_wAuth; visible: false }

    CmpBoard
    {
        id: id_cmpBoard
        width: parent.width - 30
        anchors.centerIn: parent
        visible: false

        Text
        {
            anchors.centerIn: parent
            color: "red"
            font.pixelSize: 16
            text: "Error! Can not connect to Database"
        }
    }

    Item
    {
        id: id_itmWorkSpace
        anchors.fill: parent
        anchors.topMargin: 60
    }

    Behavior on width {
        NumberAnimation { duration: 100 }
    }
    Behavior on height {
        NumberAnimation { duration: 100 }
    }

    Component.onCompleted:
    {
        var dbAddr = settings.wsClient.secured === true ? "wss://" : "ws://"
        dbAddr += settings.wsClient.host + ":" + settings.wsClient.port
        _dbClient.connect(dbAddr)

        // Wait DB connection
        for (var i = 0; i < 15; ++i) { wait(100); if (_dbClient.connected) break; }
        if (!_dbClient.connected) { id_cmpBoard.visible = true; return; }

        // Update product scripts
        var ret = util.runShellScript(AppPath + "update.sh")
        console.log("Resp: " + ret)

        id_wAuth.login.connect(onLogin)
        id_wAuth.visible = true
    }

    Component.onDestruction: console.log("MainRestore destruction")

}
