import QtQuick 2.0
//import QtQuick.Controls 1.2
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.12
import FwStateLib 1.0
import "."

Item
{
    id: root
    width: parent.width
    height: 65

    property string m_descr: "Description"
    property string m_binname: "Bin name"
    property int m_binsize: 0

    property string m_checkStatus: "Check status"
    property string m_loadStatus: "Load status"

    property int m_checkState: FwState.CHK_IDLE
    property int m_loadState: FwState.LDR_IDLE

    Item
    {
        id: id_itm
        anchors.fill: parent
        anchors.margins: 2

        CmpBoard { anchors.fill: parent }

        Image
        {
            id: id_imgFile
            height: parent.height - 10
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
            source: "../../images/bin_file_48.png"
        }

        Column
        {
            anchors.left: id_imgFile.right
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            Text  { font.pixelSize: 14; color: "darkblue"; text: m_descr }

            Row
            {
                spacing: 30
                Text { font.pixelSize: 12; color: "#505050"; text: m_binname }
                Text { font.pixelSize: 12; color: "#505050"; text: m_binsize + " bytes" }
            }

            Row
            {
                spacing: 30
                Text
                {
                    font.pixelSize: 14
                    color:
                    {
                        if (m_checkState == FwState.CHK_IDLE) return "darkred"
                        if (m_checkState == FwState.CHK_CHECKED) return "green"
                           else return "blue"
                    }

                    text: m_checkStatus
                }
                Image
                {
                    anchors.verticalCenter: parent.verticalCenter;
                    visible: (m_checkState == FwState.CHK_IDLE || m_checkState == FwState.CHK_CHECKED) ? true : false
                    source:
                    {
                        if (m_checkState == FwState.CHK_CHECKED) return "../../images/icon_ok_16.png"
                            else return "../../images/icon_error_16.png"
                    }
                }

                BusyIndicator
                {
                    width: 16
                    height: 16
                    running:  false //(m_checkState != FwState.CHK_IDLE || m_checkState != FwState.CHK_CHECKED) ? true : false
                }

                Text
                {
                    font.pixelSize: 14
                    color:
                    {
                        if (m_loadState == FwState.LDR_IDLE) return "darkred"
                        if (m_loadState == FwState.LDR_LOADED) return "green"
                            else return "blue"
                    }

                    text: m_loadStatus
                }
                Image
                {
                    anchors.verticalCenter: parent.verticalCenter;
                    source: if (m_loadState == FwState.LDR_LOADED) return "../../images/icon_ok_16.png"
                            else return "../../images/icon_error_16.png"
                }
            }
        }
    }
}

