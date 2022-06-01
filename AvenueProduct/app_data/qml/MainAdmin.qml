import QtQuick 2.11
import QtQuick.Window 2.11
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
    property bool _connected: _dbClient.connected

    property string _time: Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss")
    property string _header
    property var _operatorFid
    property var _objOperator

    function getDateTime() { _time = Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss") }

    function onLogin(login, pass)
    {
        // checkUser
        var req = {}
        req.req = "checkUser"
//        req.uuid = "bla bla uuid"
        req.args = [ login, pass ]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        console.log(JSON.stringify(resp))
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

        var path = "file:///" + AppPath + "app_data/qml/view/ViewAdmin.qml"
        Qt.createComponent(path).createObject(id_mainWindow)
    }

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
//        style: Text.Sunken
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
        for (var i = 0; i < 30; ++i) { wait(100); if (_dbClient.connected) break; }
        if (!_dbClient.connected) { id_cmpBoard.visible = true; return; }

        id_wAuth.login.connect(onLogin)
        id_wAuth.visible = true
    }

    Component.onDestruction: console.log("MainControl destruction")

}
