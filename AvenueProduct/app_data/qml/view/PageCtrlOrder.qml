import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls 1.4 as OldControl
import QtQuick.Layouts 1.12
import "../component/CmpStyle.js" as Style
import "../component"
import "../../tools/db_service.js" as JDbServ

Page
{
    id: root
    title: qsTr("Order")

    property int _butWidth: 80

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

    function getKtInfo()
    {
        id_ktModel.clear()
//        console.log("QML: getKtInfo: " + id_txtDt.text)
        if (id_txtDt.length === 0) return

        // getKtInfoRecursively
        var req = {}
        req.req = "getKtInfoRecursively"
        req.args = [id_txtDt.text]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true) { showMessage("red", "Can NOT get Design type info: " + resp["errorString"], true); return }
//        console.log(JSON.stringify(resp))
        var data = resp["data"]
        if (data.length === 0) return

        for (var i = 0; i < data.length; ++i)
        {
            var obj = data[i]
            id_ktModel.append(obj)
        }
    }

    //-----------------------------------------------------------------

    function createOrder()
    {
        if (!id_txtOrder1c.length || !id_txtOrderDescr.length || !id_txtOrderKt.length) return

        var code1c = id_txtOrder1c.text
        var descr = id_txtOrderDescr.text
        var num = id_boxOrderNum.value
        var kt = id_txtOrderKt.text
        var opts = []
        for (var i = 0; i < id_listOpts.size(); ++i) if (id_listOpts.at(i)._checked) opts.push(id_listOpts.at(i)._fid)

        var req = {}
        req.req = "createOrder"
        req.args = [code1c, descr, num, kt, opts]
        console.log(JSON.stringify(req))
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true) showMessage("red", "Can NOT create Order: " + resp["errorString"], true)
        else showMessage("darkgreen", "Order created: " + code1c, true)
        console.log(JSON.stringify(resp))
    }

    //-----------------------------------------------------------------

    function getOrderInfo()
    {
        id_lblOptsModel.clear()
        console.log("QML: getOrderInfo: " + id_txtOrder1cInf.text)
        if (id_txtOrder1cInf.length === 0) return

        // getOrderInfo
        var req = {}
        req.req = "getOrderInfo"
        req.args = [id_txtOrder1cInf.text]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true) { showMessage("red", "Can NOT get Order info: " + resp["errorString"], true); return }
//        console.log(JSON.stringify(resp))
        var data = resp["data"]
        if (data.length === 0) return

        id_lblTime.text = data[0]["fts"]
        id_lbl1C.text = data[0]["forder1c"]
        id_lblDescr.text = data[0]["forderdescription"]
        id_lblNum.text = data[0]["fordereditems"]
        id_lblCount.text = data[0]["forderedinicount"]
        id_lblDType.text = data[0]["fkt"]
        id_lblPName.text = data[0]["fproductname"]
        id_lblPDescr.text = data[0]["fproductdescription"]

        // getOptionsForOrder
        req = {}
        req.req = "getOptionsForOrder"
        req.args = [id_txtOrder1cInf.text]
        resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true) { showMessage("red", "Can NOT get Options: " + resp["errorString"], true); return }
//        console.log(JSON.stringify(resp))
        data = resp["data"]
        if (data.length === 0) return
        for (var i = 0; i < data.length; ++i) id_lblOptsModel.append(data[i])
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

            // Get KT info
            CmpBoard
            {
                Layout.fillWidth: true
                height: 250

                Column
                {
                    anchors.centerIn: parent
                    spacing: 10
                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.txtHeaderSize
                        text: "Get Design type info"
                    }
                    Row
                    {
                        spacing: 20
                        TextField { id: id_txtDt; width: 120; selectByMouse: true; placeholderText: "Design type"; onAccepted: getKtInfo() }
                        Button
                        {
                            width: _butWidth
                            text: "Get"
                            onClicked: getKtInfo()
                            Keys.onReturnPressed: getKtInfo()
                        }
                    }   // row
                    ListModel { id: id_ktModel }
                    Component
                    {
                        id: id_delegate
                        TextInput
                        {
                            readOnly: true
                            horizontalAlignment: TextInput.AlignHCenter
                            text: styleData.value
                            selectByMouse: true
                        }
                    }
                    Component
                    {
                        id: id_delegate2
                        TextInput
                        {
                            readOnly: true
                            text: styleData.value
                            selectByMouse: true
                        }
                    }

                    OldControl.TableView
                    {
                        id: id_table
                        width: 800
                        OldControl.TableViewColumn {
                            role: "fkt"
                            title: "Design type"
                            width: 100
                            delegate: id_delegate
                        }
                        OldControl.TableViewColumn {
                            role: "fproductname"
                            title: "Product"
                            width: 400
                            delegate: id_delegate2
                        }
                        OldControl.TableViewColumn {
                            role: "fproductdescription"
                            title: "Description"
                            width: 600
                            delegate: id_delegate2
                        }
                        model: id_ktModel
                    }
                }
            }   // CmpBoard

            // Create Order
            CmpBoard
            {
                Layout.fillWidth: true
                height: 220
                Column
                {
                    anchors.centerIn: parent
                    spacing: 10
                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.txtHeaderSize
                        text: "Create Order"
                    }
                    Row
                    {
                        spacing: 20
                        TextField { id: id_txtOrder1c; width: 120; selectByMouse: true; placeholderText: "1C code" }
                        TextField { id: id_txtOrderDescr; width: 200; selectByMouse: true; placeholderText: "Description" }
                        TextField { id: id_txtOrderKt; width: 120; selectByMouse: true; placeholderText: "Design type" }
                        SpinBox
                        {
                            id: id_boxOrderNum
                            editable: true
                            width: 70
                            from: 1
                            to: 100000
                        }
                    }
                    ListView
                    {
                        id: id_listOpts
                        width: contentWidth
                        height: contentHeight
                        model: id_optsModel
                        delegate: DelegateSoftOption {
                            _fid: fid
                            _grfid: grfid
                            _name: foptionname
                            _descr: foptiondescription
                        }

                        function size() { return count; }
                        function at(index)
                        {
                            if (index < 0 || index > count - 1) return undefined;
                            return id_listOpts.contentItem.children[index]
                        }
                    }
                    ListModel  { id: id_optsModel }
                    Button
                    {
                        width: _butWidth
                        anchors.right: parent.right
                        text: "Save"
                        onClicked: createOrder()
                        Keys.onReturnPressed: createOrder()
                    }
                }
            }   // CmpBoard

            // Order info
            CmpBoard
            {
                Layout.fillWidth: true
                height: 320

                Column
                {
                    anchors.centerIn: parent
                    spacing: 10
                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.txtHeaderSize
                        text: "Get Order info"
                    }
                    Row
                    {
                        spacing: 20
                        TextField { id: id_txtOrder1cInf; width: 120; selectByMouse: true; placeholderText: "1C code"; onAccepted: getOrderInfo() }
                        Button
                        {
                            width: _butWidth
                            text: "Get"
                            onClicked: getOrderInfo()
                            Keys.onReturnPressed: getOrderInfo()
                        }
                    }   // row
                    Item
                    {
                        width: id_clmOrd.width + id_lblOpts.width + 20
                        height: id_clmOrd.height

                        Column
                        {
                            id: id_clmOrd
                            width: 400
                            spacing: 5
                            Row
                            {
//                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Time:" }
                                Text { id: id_lblTime; font.bold: true }
                            }
                            Row
                            {
//                                width: 200
                                spacing: 10
                                Text { width: 100; text: "1C Code:" }
                                Text { id: id_lbl1C; font.bold: true; color: "darkgreen" }
                            }
                            Row
                            {
//                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Description:" }
                                Text { id: id_lblDescr; width: 250; wrapMode: Text.WordWrap; font.bold: true }
                            }
                            Row
                            {
//                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Ordered Num:" }
                                Text { id: id_lblNum; font.bold: true }
                            }
                            Row
                            {
//                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Ini Count:" }
                                Text { id: id_lblCount; font.bold: true }
                            }
                            Row
                            {
//                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Design type:" }
                                Text { id: id_lblDType; font.bold: true; color: "darkgreen" }
                            }
                            Row
                            {
//                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Product name:" }
                                Text { id: id_lblPName; width: 250; wrapMode: Text.WordWrap; font.bold: true;  }
                            }
                            Row
                            {
//                                width: 200
                                spacing: 10
                                Text { width: 100; text: "Product descr:" }
                                Text { id: id_lblPDescr; width: 250; wrapMode: Text.WordWrap; font.bold: true }
                            }
                        }
                        ListView
                        {
                            id: id_lblOpts
                            width: 400
                            spacing: 5
                            height: contentHeight
                            anchors.left: id_clmOrd.right
                            anchors.leftMargin: 10
                            model: id_lblOptsModel
                            delegate: DelegateSoftOption {
                                _chkVisibled: false
                                _fid: fid
                                _name: name
                                _descr: descr
                            }

                            function size() { return count; }
                            function at(index)
                            {
                                if (index < 0 || index > count - 1) return undefined;
                                return id_listOpts.contentItem.children[index]
                            }
                        }
                        ListModel  { id: id_lblOptsModel }
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

    Component.onCompleted:
    {
        // getSoftOptionsByScheme
        var req = {}
        req.req = "getSoftOptionsByScheme"
        req.args = ["Schema1"]
        var resp = JSON.parse(JDbServ.sendDbRequest(_dbClient, req))
        if (resp["error"] === true) showMessage("red", num + " Can NOT get Options", true)
        var data = resp["data"]
        for (var i = 0; i < data.length; ++i) id_optsModel.append(data[i])
    }
}
