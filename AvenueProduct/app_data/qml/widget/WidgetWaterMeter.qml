import QtQuick 2.11
import QtQuick.Controls 2.5
import "../component/CmpStyle.js" as Style
import "../component"
//import "../widget"

Item
{
    id: root
    anchors.fill: parent

    property var   _serial
    property bool  _connected: _serial.state
//    property var   _onoffModel: ["OFF", "ON"]
    property var   _api

    property int _count: 0

    //-----------------------------------------------------------------

    function process()
    {
        if (_waiting) return

        if (_count >= 100)
        {
            console.log("!!!!!!!!!!!!!!! GARBAGE COLLECT")
            gc();
            _count = 0
        }

        _waiting = true
        if (_testStarted) getResult()
        else getData()
        _waiting = false

        _count++
    }

    function getResult()
    {
         if (_connected === false) return

        console.log("Get result")
        var ret = _standApiObj.getResult()
        if (ret === false) return

        ret.time = Qt.formatTime(new Date(), "hh:mm:ss")
        console.log("!!!! RET: " + JSON.stringify(ret))
        resultModel.append(ret)

        id_indResultScale.m_value = ret.scaleVolume

        for (var i = 0; i < _channelNum; ++i)
        {
            var resObj = id_rptResult.itemAt(i)
            if (i === 0) resObj.indValue = ret["meterVolume1"]
            if (i === 1) resObj.indValue = ret["meterVolume2"]
            if (i === 2) resObj.indValue = ret["meterVolume3"]
            if (i === 3) resObj.indValue = ret["meterVolume4"]
        }

        if (ret.state === 2)
        {
            _testStarted = false
            avlog.show("green", "Test complete ... OK", false, true)
            showPopup()
        }
    }

    function getData()
    {
        if (_connected === false) return

//        console.log("Get data")
        var ret = _standApiObj.metering(_channelNum)
        if (ret === false) return

        console.log("!!!! RET: " + JSON.stringify(ret))
        id_indScaleWeight.m_value = ret.scale.weight
        id_indScaleSpeed.m_value = ret.scale.speed
        if (ret.scale.status & 0x10) id_indScaleWeight.m_fontColor = "orange"
        else id_indScaleWeight.m_fontColor = "red"

        for (var i = 0; i < _channelNum; ++i)
        {
            var volObj = id_rptVol.itemAt(i)
            var speedObj = id_rptSpeed.itemAt(i)

            var vol = ret.meter[i].volume
            var speed = ret.meter[i].speed

            volObj.indValue = vol
            speedObj.indValue = speed
            volObj.indColor = vol < 0 ? "grey" : "orange"
            speedObj.indColor = vol < 0 ? "grey" : "orange"

//            if (vol > 0 || speed > 0) id_tim.stop()
        }
    }

    //-----------------------------------------------------------------

    Timer
    {
        id: id_tim
        running: _standFinded
        repeat: true
        interval: _testStarted ? 1000 : 2000
        onTriggered: process()
    }

    Image
    {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        source: _connected ? "../../images/online_32.png" : "../../images/offline_32.png"
    }

    Column
    {
        //        anchors.centerIn: parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 7

        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Scale measurement" }

        Row
        {
            spacing: 20
            //            Text { /*width: 80;*/ text: "Scale"; anchors.verticalCenter: parent.verticalCenter }
            Column
            {
                spacing: 1
                Text { text: "Weight, kg" }
                CmpIndicator { id: id_indScaleWeight; m_mode: 1; width: 100;  }
            }
            Column
            {
                spacing: 1
                Text { text: "Speed, kg/h" }
                CmpIndicator { id: id_indScaleSpeed; m_mode: 1; width: 100;  }
            }
        }   // row
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Meter volume, L" }
        Row
        {
            height: 45
            spacing: 2
            Repeater
            {
                id: id_rptVol
                model: _channelNum
                delegate: Item {
                    width: 110
                    height: 35

                    property alias indValue: id_indMeterVol.m_value
                    property alias indColor: id_indMeterVol.m_fontColor

                    Column
                    {
                        spacing: 1
                        Text { text: "Ch" + (index + 1) }
                        CmpIndicator { id: id_indMeterVol; m_mode: 1; width: 100;  }
                    }
                }
            }
        }   // row

        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Meter speed, L/h" }
        Row
        {
            height: 45
            spacing: 2
            Repeater
            {
                id: id_rptSpeed
                model: _channelNum
                delegate: Item {
                    width: 110
                    height: 35

                    property alias indValue: id_indMeterSpeed.m_value
                    property alias indColor: id_indMeterSpeed.m_fontColor

                    Column
                    {
                        spacing: 1
                        Text { text: "Ch" + (index + 1) }
                        CmpIndicator { id: id_indMeterSpeed; m_mode: 1; width: 100;  }
                    }
                }
            }
        }   // row

        Item
        {
            width: parent.width
            height: 110
            anchors.horizontalCenter: parent.horizontalCenter

            Column
            {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5
                Text { anchors.horizontalCenter: parent.horizontalCenter; font.bold: true; text: "Result volume, L" }
                Row
                {
                    spacing: 20
                    Text { text: "Scale" }
                    CmpIndicator { id: id_indResultScale; m_mode: 1; width: 100; m_fontColor: "lime"  }
                }

                Row
                {
                    height: 45
                    spacing: 2
                    Repeater
                    {
                        id: id_rptResult
                        model: _channelNum
                        delegate: Item {
                            width: 110
                            height: 35

                            property alias indValue: id_indResult.m_value

                            Column
                            {
                                spacing: 1
                                Text { text: "Ch" + (index + 1) }
                                CmpIndicator { id: id_indResult; m_mode: 1; width: 100; m_fontColor: "lime"  }
                            }
                        }
                    }
                }   // row
            }   // column
        }   // item result

    }   // column
}

