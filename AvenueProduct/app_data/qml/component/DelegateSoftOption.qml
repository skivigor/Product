import QtQuick 2.0
import QtQuick.Controls 2.5

Item
{
    id: root
//    width: 300
    height: id_rowContent.height

    property var _fid
    property var _grfid
    property string _name
    property string _descr
    property bool _chkVisibled: true
    property alias _checked: id_box.checked


    Row
    {
        id: id_rowContent
        spacing: 20
        CheckBox { id: id_box; visible: _chkVisibled; checked: true }
        Text
        {
            width: 80
            anchors.verticalCenter: parent.verticalCenter
            color: "darkgreen"
            font.bold: true
            text: _name
        }
        Text
        {
            width: 350
            wrapMode: Text.WordWrap
            anchors.verticalCenter: parent.verticalCenter
            text: _descr
        }
    }
}

