import QtQuick 2.0

Item
{
    id: root
    anchors.fill: parent

    property string _orderDescr: "Undefined"
    property int _orderNum: 0
    property int _orderCount: 0
    property string _eui
    property string _board

    Column
    {
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.leftMargin: 10
        spacing: 10

        Text
        {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 16
            text: "Order"
        }

        Row
        {
            width: parent.width
            spacing: 10
            Text { anchors.verticalCenter: parent.verticalCenter; width: parent.width * 0.3; text: "Order:" }
            Text { font.pixelSize: 14; color: "darkblue"; text: _orderDescr }
        }

        Row
        {
            width: parent.width
            spacing: 10
            Text { anchors.verticalCenter: parent.verticalCenter; width: parent.width * 0.3; text: "Item num:" }
            Text { font.pixelSize: 14; text: _orderNum }
        }

        Row
        {
            width: parent.width
            spacing: 10
            Text { anchors.verticalCenter: parent.verticalCenter; width: parent.width * 0.3; text: "Item count:" }
            Text { font.pixelSize: 14; text: _orderCount }
        }

        Row
        {
            width: parent.width
            spacing: 10
            Text { /*anchors.verticalCenter: parent.verticalCenter;*/ width: parent.width * 0.3; text: "Cover EUI:" }
            Text { /*font.pixelSize: 14;*/ color: "darkblue"; text: _eui }
        }

        Row
        {
            width: parent.width
            spacing: 10
            Text { /*anchors.verticalCenter: parent.verticalCenter; */width: parent.width * 0.3; text: "Board ID:" }
            Text { /*font.pixelSize: 14;*/ color: "darkblue"; text: _board }
        }
    }
}

