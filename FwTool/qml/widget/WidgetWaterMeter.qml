import QtQuick 2.11
import QtQuick.Controls 2.5
//import "../component/CmpStyle.js" as Style
import "../component"
//import "../widget"

Item
{
    id: root
    anchors.fill: parent

    property bool  _connected: stand.state
    property var   _standData: stand.standData
    property var   _result: stand.result

    property var _count: 0

    on_StandDataChanged:
    {
        if (_standFinded === false) return

        console.log("!!!! Data RET: " + JSON.stringify(_standData))
        id_indScaleWeight.m_value = _standData.scale.weight / 1000
        id_indScaleSpeed.m_value = _standData.scale.speed / 1000
        if (_standData.scale.status & 0x10) id_indScaleWeight.m_fontColor = "red"
        else id_indScaleWeight.m_fontColor = "orange"

        for (var i = 0; i < 4; ++i)
        {
            var volObj = id_rptVol.itemAt(i)
            var speedObj = id_rptSpeed.itemAt(i)

            var vol = _standData.meter[i].volume / 1000
            var speed = _standData.meter[i].speed / 1000

            volObj.indValue = vol
            speedObj.indValue = speed
        }
    }

    on_ResultChanged:
    {
        if (_standFinded === false) return

        _result.time = Qt.formatTime(new Date(), "hh:mm:ss")
        _result.scale = (id_indScaleSpeed.m_value).toFixed(3)
        console.log("!!!! Result RET: " + JSON.stringify(_result))
//        resultModel.append(_result)

//        id_indResultScale.m_value = _result.scaleVolume / 1000

        for (var i = 0; i < 4; ++i)  // id_indVal
        {
            var resObj = id_rptResult.itemAt(i)
            if (i === 0)
            {
                resObj.valValue = _result["val1"] / 1000
                resObj.indValue = _result["meterVolume1"] / 1000
            }

            if (i === 1)
            {
                resObj.valValue = _result["val2"] / 1000
                resObj.indValue = _result["meterVolume2"] / 1000
            }

            if (i === 2)
            {
                resObj.valValue = _result["val3"] / 1000
                resObj.indValue = _result["meterVolume3"] / 1000
            }

            if (i === 3)
            {
                resObj.valValue = _result["val4"] / 1000
                resObj.indValue = _result["meterVolume4"] / 1000
            }
        }

//        _count++
//        if (_count > 3)
//        {
//            _result.state = 1
//        }

        if (_result.state == 1)
        {
            if (camera.ready === true && _testImg1.length === 0)
            {
                console.log("!!!!!!! Received test state 1")
                _testImg1 = "IMG_" + Qt.formatDateTime(new Date(), "ddMMyyhhmmss") + ".jpg"
                camera.screenshot(AppPath + "/log/" + _testImg1)
            }
        }

//        if (_count > 7)
//        {
//            _result.state = 2
//            _count = 0
//        }

        if (_result.state == 2)
        {
            console.log("!!!!!!! Received test state 2")
            if (camera.ready === true)
            {
                _testImg2 = "IMG_" + Qt.formatDateTime(new Date(), "ddMMyyhhmmss") + ".jpg"
                camera.screenshot(AppPath + "/log/" + _testImg2)
            }
            resultModel.append(_result)
            //stand.setTestStarted(false)
            stand.testStarted = false
            avlog.show("green", "Test complete ... OK", false, true)
            showPopup()
        }
    }


    //-----------------------------------------------------------------

    function process()
    {
        if (_testStarted)
        {
//            stand.readData()
            stand.readResult()
        } else
        {
            stand.readData()
        }

    }

    //-----------------------------------------------------------------

    Timer
    {
        id: id_tim
        running: _standFinded
        repeat: true
        interval: 1000
        onTriggered: process()
    }

    Row
    {
        spacing: 10
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10

        Image
        {
            visible: camera.ready
            source: "../../images/webcam_322.png"
        }
        Image
        {
            source: _connected ? "../../images/online_32.png" : "../../images/offline_32.png"
        }
    }

    Column
    {
        //        anchors.centerIn: parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Scale measurement" }

        Row
        {
            spacing: 20
            //            Text { /*width: 80;*/ text: "Scale"; anchors.verticalCenter: parent.verticalCenter }
            Column
            {
                spacing: 1
                Text { text: "Weight, kg" }
                CmpIndicator { id: id_indScaleWeight; m_mode: 3; width: 100;  }
            }
            Column
            {
                spacing: 1
                Text { text: "Speed, kg/h" }
                CmpIndicator { id: id_indScaleSpeed; m_mode: 3; width: 100;  }
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
                        CmpIndicator { id: id_indMeterVol; m_mode: 3; width: 100;  }
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
                        CmpIndicator { id: id_indMeterSpeed; m_mode: 3; width: 100;  }
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
                Text { anchors.horizontalCenter: parent.horizontalCenter; font.bold: true; text: "Result" }
//                Row
//                {
//                    spacing: 20
//                    Text { text: "Scale" }
//                    CmpIndicator { id: id_indResultScale; m_mode: 3; width: 100; m_fontColor: "lime"  }
//                }

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

                            property alias valValue: id_indVal.m_value
                            property alias indValue: id_indResult.m_value

                            Column
                            {
                                spacing: 2
                                Text { text: _testMode === 0 ? "Weight, kg" : "M" + (index + 1) + " :: Volume, L" }
                                CmpIndicator { id: id_indVal; m_mode: 3; width: 100; m_fontColor: "lime"  }
                                Text { text: "Ch" + (index + 1) + " :: Volume, L" }
                                CmpIndicator { id: id_indResult; m_mode: 3; width: 100; m_fontColor: "lime"  }
                            }
                        }
                    }
                }   // row
            }   // column
        }   // item result

    }   // column
}

