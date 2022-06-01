import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Rectangle
{
    id: root
    width: parent.width
    height: 200
    color: "#ccffffff"

    property string _log

    TextArea
    {
        id: id_txtOutput

        style: TextAreaStyle {
            textColor: "#333"
            selectionColor: "steelblue"
            selectedTextColor: "#eee"
            //backgroundColor: "#77ffffff"
        }

        anchors.fill: parent
        anchors.margins: 5
        readOnly: true
        selectByMouse: true
        backgroundVisible: false
        textFormat: TextEdit.AutoText     // PlainText, AutoText, RichText
        font.pixelSize: 14
        wrapMode: TextEdit.WrapAnywhere
        cursorPosition: id_txtOutput.length
        text: _log
    }
}
