import QtQuick 2.12
import QtQuick.Controls 2.5
import "../component"
import "../../tools/db_service.js" as JDbServ

Item
{
    id: root
    anchors.fill: parent
    property var _args
    property var _orders

    signal executed(bool res)
    signal stop()

    //-----------------------------------------------------------------

    function execute()
    {
        // Get orders
        var req = {}
        req.req = "getOrders"
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        console.log("!!!!!! " + JSON.stringify(resp))
        if (resp["error"] === true)
        {
            avlog.show("red", "Receive Orders ... Error!!!")
            console.warn("Error: receive orders: " + resp["errorString"])
            stop()
            return
        }
        var data = resp["data"]
        if (data.length === 0)
        {
            avlog.show("green", "No orders available!!!", false, true)
            stop()
            return
        }
        _orders = data

        for (var i = 0; i < data.length; ++i) id_orderModel.append({ "text" : data[i]["forder1c"] })
    }

    //-----------------------------------------------------------------

    function process(order)
    {
        // getOrderByCode
        var req = {}
        req.req = "getOrderByCode"
        req.args = [order]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            avlog.show("red", "Receive Order info ... Error!!!")
            avlog.show("red", "Work stopped!!!")
            console.warn("Error: receive order info: " + resp["errorString"])
            stop()
            return
        }

        var data = resp["data"]
        if (data.length === 0)
        {
            avlog.show("red", "Order " + order + " Error!!!", false, true)
            console.warn("Error: Order " + order + " !!!")
            stop()
            return
        }
        _objOrder = data[0]

        // getBoardKtByOrderCode
        req = {}
        req.req = "getBoardKtByOrderCode"
        req.args = [order]
        resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            avlog.show("red", "Order board KT for " + order + " Error!!!", false, true)
            console.warn("Error: Order board KT for " + order + " !!!")
            stop()
            return
        }
        _objOrder.frefboard = resp["data"][0]

        // getHwTypeAttrByBoardKt
        req = {}
        req.req = "getHwTypeAttrByBoardKt"
        req.args = [_objOrder.frefboard]
        resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        console.log("!!!!!! " + JSON.stringify(resp))
        if (resp["error"] === true)
        {
            avlog.show("red", "Board info for " + _objOrder.frefboard + " Error!!!", false, true)
            console.warn("Error: Board info for " + _objOrder.frefboard + " !!!")
            stop()
            return
        }
        _standBoardPath = resp["data"][0]["fboardfolderpath"]

        if (_hwType !== resp["data"][0]["fhwtypeid"])
        {
            avlog.show("red", "Order is not compatible with the selected mode!!!", false, true)
            console.warn("Order is not compatible with the selected mode!!!")
            stop()
            return
        }

        // getOptionsForOrder
        req = {}
        req.req = "getOptionsForOrder"
        req.args = [order]
        resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true)
        {
            avlog.show("red", "Order options" + order + " Error!!!", false, true)
            console.warn("Error: Order options" + order + " !!!")
            stop()
            return
        }
        data = resp["data"]
        for (var i = 0; i < data.length; ++i)
        {
            var obj = {}
            obj.path = ""
            obj.file = data[i]["controlfile"]
            obj.descr = data[i]["name"]
            obj.args = [ data[i]["fid"], data[i]["datafile"] ]
            obj.prebuild = false
            obj.hwdefined = data[i]["hwdefined"]
            _stages.push(obj)
        }

        // Last stage
        var stage = {}
        stage.path = _stagePath
        stage.file = "BoardRemove.qml"
        stage.descr = "Board remove"
        stage.args = ["Remove the Board if it is on the Stand"]
        stage.prebuild = true
        stage.hwdefined = false
        _stages.push(stage)

        executed(true)
    }

    //-----------------------------------------------------------------

    ListModel { id: id_orderModel }

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

        CmpBoard
        {
            anchors.centerIn: parent
            width: parent.width - 200
            height: 60

            Row
            {
                anchors.centerIn: parent
                spacing: 15
                Text { width: 80; font.pixelSize: 15; text: "Order" }
                ComboBox
                {
                    id: id_boxOrder;
                    width: 150;
                    model: id_orderModel
                    onModelChanged: id_boxOrder.currentIndex = 0
                    Keys.onEscapePressed: id_boxOrder.popup.close()
                    Keys.onDownPressed:
                    {
                        if (id_boxOrder.popup.opened) id_boxOrder.incrementCurrentIndex()
                            else id_boxOrder.popup.open()
                    }

                    Keys.onUpPressed:
                    {
                        if (!id_boxOrder.popup.opened) return
                        id_boxOrder.decrementCurrentIndex()
                    }
                }
                Button
                {
                    width: 60
                    text: "Ok"
                    onClicked: id_cmpOrderAck.visible = true
                    Keys.onEnterPressed: id_cmpOrderAck.visible = true
                }
            }
        }

        CmpBoard
        {
            id: id_cmpOrderAck
            anchors.centerIn: parent
            width: parent.width - 200
            height: 180
            visible: false

            property string _ordName: ""
            property string _ordDescr: ""
            property int    _ordNum: 0

            Column
            {
                anchors.centerIn: parent
                spacing: 5
                Row
                {
                    spacing: 15
                    Text { width: 100; font.pixelSize: 13; text: "Order:" }
                    Text { font.pixelSize: 13; color: "darkgreen"; font.bold: true; text: id_cmpOrderAck._ordName }
                }
                Row
                {
                    spacing: 15
                    Text { width: 100; font.pixelSize: 13; text: "Description:" }
                    Text { font.pixelSize: 13; font.bold: true; text: id_cmpOrderAck._ordDescr }
                }
                Row
                {
                    spacing: 15
                    Text { width: 100; font.pixelSize: 13; text: "Items:" }
                    Text { font.pixelSize: 13; text: id_cmpOrderAck._ordNum + " pcs" }
                }

                Text { /*separator*/ text: " " }
                Text { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 15; text: "Are you sure?" }
                Row
                {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    Button { width: 80; text: "Ok"; onClicked: process(id_boxOrder.currentText) }
                    Button { width: 80; text: "Cancel"; onClicked: id_cmpOrderAck.visible = false }
                }

            }

            onVisibleChanged:
            {
                _ordName = id_boxOrder.currentText

                for (var i = 0; i < _orders.length; ++i)
                {
                    if (_orders[i]["forder1c"] === _ordName)
                    {
                        _ordDescr = _orders[i]["forderdescription"]
                        _ordNum = _orders[i]["fordereditems"]
                        return
                    }
                }
            }
        }
    }

    Shortcut
    {
        sequences: ["Return"]
        onActivated:
        {
            if (id_cmpOrderAck.visible === true) process(id_boxOrder.currentText)
            else id_cmpOrderAck.visible = true
        }
    }

    Shortcut
    {
        sequences: ["Esc"]
        onActivated: id_cmpOrderAck.visible = false
    }

    Component.onCompleted: console.info("Order created!")
    Component.onDestruction: console.info("Order destruction")
}
