import QtQuick 2.3

Item
{
    id: root
    width: 110 //128
    height: 35
    opacity: 0.7

    property string m_label: "Button"
    property bool m_checked: false

    onM_checkedChanged:
    {
        if (m_checked)
        {
            root.opacity = 1
        } else
        {
            root.opacity = 0.7
        }
//        console.log("Opacity: " + root.opacity)
    }

    signal butClicked(string label)

    Image
    {
        anchors.fill: parent
        source: "../images/button.png"

        Text
        {
            id: id_txtButLabel
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            minimumPixelSize: 8
            font.pixelSize: 16
//            font.bold: true
            color: "white"
            style: Text.Raised
            styleColor: "#909090"
            text: m_label
        }
    }

    Rectangle
    {
        id: id_rcButInd
        width: parent.width - 20
        height: 3
        radius: 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        //color: "#3393CD"
        color: "dimGrey"
        visible: m_checked ? true : false
    }

    MouseArea
    {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: m_checked ? 1 : root.opacity = 0.85
        onExited: m_checked ? 1 : root.opacity = 0.7
        onPressed: m_checked ? 1 : root.opacity = 1
        onReleased: m_checked ? 1 : root.opacity = 0.85
        onClicked: if (!m_checked) butClicked(m_label)
    }
}
