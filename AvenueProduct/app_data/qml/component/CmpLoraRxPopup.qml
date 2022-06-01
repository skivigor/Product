import QtQuick 2.12
import QtQuick.Controls 2.5
//import "CmpStyle.js" as Style

Item
{
    id: root
    anchors.fill: parent
    property int  _period: 500
    property bool _busy: false

    //-----------------------------------------------------------------

    function bytesToHex(bytes)
    {
        for (var hex = [], i = 0; i < bytes.length; i++)
        {
            var current = bytes[i] < 0 ? bytes[i] + 256 : bytes[i];
            hex.push((current >>> 4).toString(16));
            hex.push((current & 0xF).toString(16));
        }
        return hex.join("");
    }

    //-----------------------------------------------------------------

    function readRxData()
    {
        console.log("Read RX data")
        if (!_connected) return
        _busy = true

        var FuncLoraCode = 0x01
        var FuncLoraGetTestData =  0x77

        var cmd = new Uint8Array(3)
        cmd[0] = 0x03
        cmd[1] = FuncLoraCode
        cmd[2] = FuncLoraGetTestData

        var resp
        var count = 0
        _uart.sendData(cmd.buffer)
        do
        {
            resp = _uart.getRespAsBin()
            count++
            wait(100)
        } while (resp.length === 0 && count < 5)

        _busy = false
        if (resp.length === 0) { id_tim.start(); return }
        if (resp[1] !== FuncLoraCode || resp[2] !== FuncLoraGetTestData) { id_tim.start(); return }
        var len = resp[3]
        console.log("Len " + len)
        if (len === 0) { id_tim.start(); return }
        if (len !== resp.length - 6) { id_tim.start(); return }

        // Data
        var data = new Uint8Array(resp).subarray(4, 4 + len)
        var rec = Qt.formatDateTime(new Date(), "hh:mm:ss.zzz") + " | RX data ---------------------------------------------------------\n"
        rec += "  Dump: " + bytesToHex(data) + "\n"

        // RSSI
        var rssi = resp[resp.length - 2]
        rec += "  RSSI: " + rssi + "\n"

        // SNR
        var snr = resp[resp.length - 1]
        rec += "  SNR: " + snr + "\n"

        id_txtOutput.text += rec
        id_tim.start()
    }

    //-----------------------------------------------------------------

    Timer
    {
        id: id_tim
        interval: _period
        repeat: false
        running: false
        onTriggered: readRxData()
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

        Text
        {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            text: "RX log"
        }

        Rectangle
        {
            anchors.fill: parent
            anchors.topMargin: 30
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.bottomMargin: 50
            color: "transparent"
            border.width: 1
            border.color: "#909090"

            ScrollView
            {
                width: parent.width
                height: parent.height
                clip: true

                TextArea
                {
                    id: id_txtOutput
                    font.pixelSize: 16
                    readOnly: true
                    selectByMouse: true
                    wrapMode: TextEdit.WrapAnywhere
                    cursorPosition: id_txtOutput.text.length
                    onTextChanged: if (lineCount > 2000) id_txtOutput.clear()
                }
            }
        }
    }

    Row
    {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        spacing: 20
        Button
        {
            width: 100
            text: "Stop"
            onClicked:
            {
                if (_busy === true) return
                id_tim.stop()
                resetTestData()
                root.destroy()
            }
        }
        Button
        {
            width: 100
            text: "Clear"
            onClicked: id_txtOutput.clear()
        }
    }

    Component.onCompleted: id_tim.start()
}
