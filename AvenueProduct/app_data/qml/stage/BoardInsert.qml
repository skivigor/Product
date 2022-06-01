import QtQuick 2.12
import QtQuick.Controls 2.5
import "../component"

Item
{
    id: root
    focus: true
    anchors.fill: parent
    property var _args
    property bool _waiting: false

    signal executed(bool res)
    signal stop()

    function execute()
    {
        console.log("!!!!!! At board insert: " + _power)
        if (!_powerSupplyUsed)
        {
            _uart.connectSerial()
            wait(100)
            return
        }

        _waiting = true
        // load ON power supply
        _power.pwConnect()
        wait(500)
        if (!_power.isConnected())
        {
            avlog.show("red", "ERROR!!! Can NOT connect to Power Supply", false, true)
            executed(false)
            return
        }
//        _power.reset()
        wait(500)
        _power.loadOn()
        wait(500)

        _uart.connectSerial()
        wait(100)
        _waiting = false
    }

    function butClicked()
    {
        if (_waiting === true) return

        _waiting = true
        var ret = _standApiObj.isCoverClosed()
        _waiting = false

        if (ret === false) { avlog.show("red", "Stand cover not closed!"); return }

        executed(true)
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

        CmpBoard
        {
            anchors.centerIn: parent
//            anchors.verticalCenterOffset: -100
            width: parent.width - 200
            height: 100

            Column
            {
                anchors.centerIn: parent
                spacing: 20

                Row
                {
                    spacing: 15
                    Text
                    {
                        font.pixelSize: 15;
                        text: _waiting ? "Setting stand parameters ..." : "Insert the Board to the Stand"
                    }
                    Button
                    {
                        width: 60;
                        text: "Ok";
                        visible: _waiting ? false : true
                        onClicked: butClicked(true)
                    }
                }

                CheckBox
                {
                    id: id_chk
                    text: "  Load firmware"
                    font.pixelSize: 15
//                    checked: _fwLoadEnabled ? true : false
                    onCheckedChanged: _fwLoadEnabled = checked
                    Component.onCompleted: _fwLoadEnabled ? checked = true : checked = false
                }
            }
        }
    }

    Shortcut
    {
        sequences: ["Return"]
        onActivated: butClicked(true)
    }

    Shortcut
    {
        sequences: ["Space"]
        onActivated: { id_chk.checked = !id_chk.checked }
    }

    Component.onCompleted: console.info("BOARD INSERT created!")
    Component.onDestruction: console.info("BOARD INSERT destruction")
}
