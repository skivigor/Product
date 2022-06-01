import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.2
//import "../js/test.js" as JS


Window
{
    id: root
    visible: true
//    visibility: "FullScreen"
    width: 600
    height: 600
    title: qsTr("Window Stand v0.0.1")

    property bool m_connected: uart.state

    property var standUart: new SerialClient()

    BorderImage
    {
        id: id_imgMainTheme
        anchors.fill: parent
        source: "../images/wave_theme3.jpg"
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

//    WidgetFirmware
//    {
//        id: id_wFirm
//        anchors.bottom: parent.bottom
//    }

    Text
    {
        anchors.right: parent.right
//        text: uart.statusStr
    }

    Row
    {
        spacing: 50

        Button
        {
            width: 80
            text: qsTr("Create")
//            onClicked: JS.check()
            onClicked:
            {
                //var obj = fact.createObject();
//                var obj = new SerialClient();

//                JS.uart(standUart);
                //obj.test();
            }
        }

        Button
        {
            width: 80
            text: qsTr("Check")
            onClicked: uart.test()
        }

        Button
        {
            width: 80
            text: qsTr("Array")
            onClicked:
            {
//                JS.send()
//                var arr = new Uint8Array(3);
//                arr[0] = 0x03;
//                arr[1] = 0x78;
//                arr[2] = 0x01;
////                console.log("Array full: " + arr);
////                console.log("Array length: " + arr.length);
////                for (var i = 0; i < arr.length; ++i) console.log(arr[i])
//                uart.sendData(arr.buffer)
            }
        }

        Button
        {
            width: 80
            text: qsTr("Window")
            onClicked:
            {
                // Qt.createComponent("qrc:/qml/ViewAutoTest.qml").createObject(id_vMain)
                var cmp = Qt.createComponent("WindowStandTest.qml").createObject()
            }
        }
    }

    Row
    {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -150
        spacing: 50

        Image
        {
            source: m_connected ? "../images/online_32.png" : "../images/offline_32.png"
        }

        Button
        {
            width: 100
            text: m_connected ? qsTr("Disconnect") : qsTr("Connect")
            onClicked:
            {
                if (!m_connected)
                {
                    uart.connectSerial("ttyUSB0")
                } else
                {
                    uart.disconnectSerial()
                }
            }
        }
    }

    Column
    {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 50
        spacing: 10

        Row
        {
            id: id_rowCmd
            spacing: 20

            TextField
            {
                id: id_txtPayload
                width: 220
                validator: id_regExpHex
            }

            Button
            {
                width: 80
                text: qsTr("Send")
                onClicked: uart.sendData(id_txtPayload.displayText)
            }
        }

        Rectangle
        {
            width: 330
            height: 200
            color: "#ccffffff"

            TextArea
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
                cursorPosition: id_txtOutput.text.length
                text: uart.resp //Qt.formatDateTime(new Date(), "dd.MM.yy  hh:mm:ss:zzz") + " <=> " + "SYSTEM" + ": " + "Run application"
            }
        }
    }

    RegExpValidator
    {
        id: id_regExpHex
        regExp: /[0-9A-Fa-f/\s]+/
    }

//    Button
//    {
//        width: 80
//        text: qsTr("Click")
//        onClicked: console.warn("Click Stand window")
//    }

//    Column
//    {
//        spacing: 15
//        anchors.centerIn: parent

//        Button
//        {
//            width: 80
//            text: qsTr("Debug")
//            onClicked: test.debug()
//        }

//        Button
//        {
//            width: 80
//            text: qsTr("Warn")
//            onClicked: test.warn()
//        }

//        Button
//        {
//            width: 80
//            text: qsTr("Info")
//            onClicked: test.info()
//        }
//    }

}
