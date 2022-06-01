import QtQuick 2.3
//import QtQuick.Controls 1.2

Item
{
    id: root
    width: parent.width
    height: 35

    function onButClicked(label)
    {
        if (label === "Info") { state = "Info"; return; }
        if (label === "Warning") { state = "Warning"; return; }
        if (label === "Debug") { state = "Debug"; return; }
    }

    Row
    {
        spacing: 5

        CmpMenu { id: id_cmpMenuInfo; m_label: "Info"; }
        CmpMenu { id: id_cmpMenuWarn; m_label: "Warning"; }
        CmpMenu { id: id_cmpMenuDebug; m_label: "Debug"; }
    }

    states: [
        State
        {
            name: "Info"
            PropertyChanges { target: id_cmpMenuInfo; m_checked: true }
            PropertyChanges { target: id_cmpMenuWarn; m_checked: false }
            PropertyChanges { target: id_cmpMenuDebug; m_checked: false }
            PropertyChanges { target: id_wInfoLog; visible: true }
            PropertyChanges { target: id_wWarnLog; visible: false }
            PropertyChanges { target: id_wDebugLog; visible: false }
        },
        State
        {
            name: "Warning"
            PropertyChanges { target: id_cmpMenuInfo; m_checked: false }
            PropertyChanges { target: id_cmpMenuWarn; m_checked: true }
            PropertyChanges { target: id_cmpMenuDebug; m_checked: false }
            PropertyChanges { target: id_wInfoLog; visible: false }
            PropertyChanges { target: id_wWarnLog; visible: true }
            PropertyChanges { target: id_wDebugLog; visible: false }
        },
        State
        {
            name: "Debug"
            PropertyChanges { target: id_cmpMenuInfo; m_checked: false }
            PropertyChanges { target: id_cmpMenuWarn; m_checked: false }
            PropertyChanges { target: id_cmpMenuDebug; m_checked: true }
            PropertyChanges { target: id_wInfoLog; visible: false }
            PropertyChanges { target: id_wWarnLog; visible: false }
            PropertyChanges { target: id_wDebugLog; visible: true }
        }
    ]
    state: "Debug"

    Component.onCompleted:
    {
        id_cmpMenuInfo.butClicked.connect(onButClicked)
        id_cmpMenuWarn.butClicked.connect(onButClicked)
        id_cmpMenuDebug.butClicked.connect(onButClicked)
    }

}
