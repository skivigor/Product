import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "component/CmpStyle.js" as Style
import "component"
import "widget"

Window
{
    id: root
    visible: true
    width: 1000
    height: 800
    minimumWidth: 800
    minimumHeight: 800
    title: qsTr("AvDrvTest")

    property var    _uart: new SerialClient("flag")
    property bool   _connected: _uart.state
    property string _time: Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss")
    property var _onoffModel: ["OFF", "ON"]

    property var _standApiObj

    //-----------------------------------------------------------------

    on_ConnectedChanged:
    {
        if (_connected)
        {
            showMessage("darkgreen", "Port openned!")
//            getConfig()
        } else
        {
            showMessage("darkgreen", "Port closed!")
        }
    }

    function getAdcValue(id)
    {
        if (_connected === false) return

        var val = _standApiObj.getAdcValue(id)
        if (val === false)
        {
            showMessage("red", "Get ADC value ERROR!")
            return
        }
        if (id === 1)
        {
            id_indAdc1_1.m_value = val.ch1
            id_indAdc1_2.m_value = val.ch2
        }
        if (id === 2)
        {
            id_indAdc2_1.m_value = val.ch1
            id_indAdc2_2.m_value = val.ch2
        }
//        if (id === 3)
//        {
//            id_indAdc3_1.m_value = val.ch1
//            id_indAdc3_2.m_value = val.ch2
//        }
    }


    //-----------------------------------------------------------------

    function setPioValue(id, val)
    {
        if (_connected === false) return

        var ret = _standApiObj.setPioValue(id, val)
        if (ret === false)
        {
            showMessage("red", "Set PIO value ERROR!")
            return
        }
        showMessage("green", "Set PIO value OK!")
    }

    //-----------------------------------------------------------------

    function setPwmLevel(lvl)
    {
        if (_connected === false) return

        var ret = _standApiObj.setPwmLevel(lvl)
        if (ret === false)
        {
            showMessage("red", "Set PWM level ERROR!")
            return
        }
        showMessage("green", "Set PWM level OK!")
    }

    //-----------------------------------------------------------------

    function getDateTime() { _time = Qt.formatDateTime(new Date(), "ddd,  dd.MM.yy  hh:mm:ss") }

    //-----------------------------------------------------------------

    function sortByKey(array, key)
    {
        return array.sort(function(a, b) {
            var x = a[key]; var y = b[key];
            return ((x < y) ? -1 : ((x > y) ? 1 : 0));
        });
    }

    //-----------------------------------------------------------------

    function showMessage(color, mes)
    {
        id_txtMessage.color = color
        id_txtMessage.text = _time + " :: " + mes
    }

    //-----------------------------------------------------------------

    Timer { interval: 1000; repeat: true; running: true; onTriggered: getDateTime() }
    BorderImage { anchors.fill: parent; source: "../images/wave_theme5.jpg" }
    Image { anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 5; source: "../images/logo.png" }

    Rectangle
    {
        width: parent.width
        height: 50
        anchors.bottom: parent.bottom
        color: "#99ffffff"
        Text { id: id_txtMessage; anchors.centerIn: parent; font.pixelSize: 16 }
    }

    Column
    {
        id: id_clmTop
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        Text { color: "darkgreen"; font.pixelSize: 16; text: _time }
        Row
        {
            anchors.right: parent.right
            spacing: 40
            Image { source: _connected ? "../images/online_32.png" : "../images/offline_32.png" }
            Button
            {
                width: 80
                anchors.verticalCenter: parent.verticalCenter
                text: _connected ? "Close" : "Open"
                onClicked:
                {
                    if (!_connected)
                    {
                        _uart.connectSerial(settings.uart.port, settings.uart.speed )
                    } else
                    {
                        _uart.disconnectSerial()
                    }
                }
            }
        }
    }


    Flickable
    {
        anchors.fill: parent
        anchors.topMargin: 100
        anchors.bottomMargin: 60
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

            // Driver stand
            CmpBoard
            {
                Layout.fillWidth: true
                height: 300
                Column
                {
                    anchors.centerIn: parent
                    spacing: 10
                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Style.txtHeaderSize
                        text: "Driver stand"
                    }
                    Row
                    {
                        spacing: 10
                        Text { width: 50; text: "       Rel1" }
                        ComboBox { id: id_boxRel1; width: 50; model: _onoffModel }
                        Button { width: 60; text: "Set"; onClicked: setPioValue(1, id_boxRel1.currentIndex) }
                        Text { width: 50; text: "       Rel2" }
                        ComboBox { id: id_boxRel2; width: 50; model: _onoffModel }
                        Button { width: 60; text: "Set"; onClicked: setPioValue(2, id_boxRel2.currentIndex) }
                        Text { width: 50; text: "       Rel3" }
                        ComboBox { id: id_boxRel3; width: 50; model: _onoffModel }
                        Button { width: 60; text: "Set"; onClicked: setPioValue(3, id_boxRel3.currentIndex) }
                    }
                    Row
                    {
                        spacing: 10
                        Text { width: 50; text: "       Dob" }
                        ComboBox { id: id_boxDob; width: 50; model: _onoffModel }
                        Button { width: 60; text: "Set"; onClicked: setPioValue(4, id_boxDob.currentIndex) }
                        Text { width: 50; text: "       Moc" }
                        ComboBox { id: id_boxMoc; width: 50; model: _onoffModel }
                        Button { width: 60; text: "Set"; onClicked: setPioValue(5, id_boxMoc.currentIndex) }
                    }
                    Row
                    {
                        spacing: 20
                        Text { text: "PWM" }
                        TextField { id: id_fldPwm; width: 80; validator: IntValidator{ bottom: 0; top: 100 } selectByMouse: true; text: "0" }
                        Button { width: 60; text: "Set"; onClicked: setPwmLevel(parseInt(id_fldPwm.text)) }
                    }
                    Row
                    {
                        spacing: 20
                        Text { text: "ADC1" }
                        CmpIndicator { id: id_indAdc1_1; m_mode: 3; m_toFix: 3; width: 100;  }
                        CmpIndicator { id: id_indAdc1_2; m_mode: 3; m_toFix: 3; width: 100 }
                        Button { width: 60; text: "Get"; onClicked: getAdcValue(1) }
                    }
                    Row
                    {
                        spacing: 20
                        Text { text: "ADC2" }
                        CmpIndicator { id: id_indAdc2_1; m_mode: 3; m_toFix: 3; width: 100 }
                        CmpIndicator { id: id_indAdc2_2; m_mode: 3; m_toFix: 3; width: 100 }
                        Button { width: 60; text: "Get"; onClicked: getAdcValue(2) }
                    }
//                    Row
//                    {
//                        spacing: 20
//                        Text { text: "ADC2" }
//                        CmpIndicator { id: id_indAdc3_1; m_mode: 3; m_toFix: 3; width: 100 }
//                        CmpIndicator { id: id_indAdc3_2; m_mode: 3; m_toFix: 3; width: 100 }
//                        Button { width: 60; text: "Get"; onClicked: getAdcValue(3) }
//                    }
                }
            }   // CmpBoard

            CmpBoard
            {
                Layout.fillWidth: true
                height: 300

                WidgetStandDebug
                {
                    id: id_wStandDebug
                    anchors.fill: parent
                    anchors.margins: 20
                    visible: true
                    standObj: _uart
//                    anchors.bottom: parent.bottom
//                    anchors.bottomMargin: 30
                }
            }
        }    // ColumnLayout
    }    // Flickable

    Component.onCompleted:
    {
        var path = "../product/stand_drv/StandApi.qml"
        _standApiObj = Qt.createComponent(path).createObject(root, { "_iface" : _uart })

        if (_standApiObj === null)
        {
            showMessage("red", "Can not load Stand API object")
        } else
        {
            showMessage("green", "Stand API object load OK")
        }
    }
}
