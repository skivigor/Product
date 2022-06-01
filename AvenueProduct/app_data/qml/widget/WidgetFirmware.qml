import QtQuick 2.0
import QtQuick.Controls 1.2
//import QtQuick.Dialogs 1.2
import "../component"

ListView
{
    width: 450
    height: contentHeight

    property var _model

    model: _model
    delegate: DelegateFirmware {
        m_descr: descr
        m_binname: binname
        m_binsize: binsize
        m_checkStatus: checkStatus
        m_loadStatus: loadStatus
        m_checkState: checkState
        m_loadState: loadState
    }
}

