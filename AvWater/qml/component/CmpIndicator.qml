import QtQuick 2.11

Item
{
    id: root
    width: 80
    height: 25

    property int m_mode: 1   // 1 - real, 2 - string, 3 - real fixed, 4 - int
    property real m_value: 0.00
    property int m_int: 0
    property int m_toFix: 3
    property string m_str
    property color m_fontColor: "orange"
    property int m_fontSize: 16

    Image
    {
        anchors.fill: parent
        source: "../../images/lcd2.jpg" //"qrc:/images/lcd2.jpg"
    }

    Text
    {
        anchors.centerIn: parent
        font.pixelSize: m_fontSize
        color: m_fontColor
        text:
        {
            if (m_mode == 1)
            {
                return m_value
            } else if (m_mode == 2)
            {
                return m_str
            } else if (m_mode == 3)
            {
                return m_value.toFixed(m_toFix)
            } else
            {
                return m_int
            }
        }
    }
}

