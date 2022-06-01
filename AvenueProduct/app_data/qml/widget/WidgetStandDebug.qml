import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.2

import "../../tools/stand_service.js" as JStand

Item
{
    id: root
    width: parent.width
    height: parent.height * 0.2

    property var standObj   // must support 'sendData()' & property 'resp'
    property int    _cmdIdx: 0

    function sendData()
    {
        standObj.sendData(id_txtPayload.displayText)
        id_cmdModel.append({ "text" : id_txtPayload.text })
        _cmdIdx = id_cmdModel.count - 1
    }

    ListModel { id: id_cmdModel }

    Column
    {
        id: id_clmDebug
        anchors.fill: parent
        spacing: 10

        Row
        {
            id: id_rowCmd
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Text
            {
                font.pixelSize: 16
                font.bold: true
                text: qsTr("Debug")
            }

            TextField
            {
                id: id_txtPayload
                width: 290
                validator: id_regExpHex
                selectByMouse: true
                onAccepted: sendData()
                Keys.onDownPressed:
                {
                    if (_cmdIdx < id_cmdModel.count - 1) _cmdIdx++
                    text = id_cmdModel.get(_cmdIdx).text
                }
                Keys.onUpPressed:
                {
                    if (_cmdIdx > 0) _cmdIdx--
                    text = id_cmdModel.get(_cmdIdx).text
                }
            }

            Button
            {
                width: 80
                text: qsTr("Send")
                onClicked: sendData()
                Keys.onReturnPressed: sendData()
            }
        }

        Rectangle
        {
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            height: id_clmDebug.height - id_rowCmd.height - 10
            color: "#ccffffff"

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
                text: standObj.log //Qt.formatDateTime(new Date(), "dd.MM.yy  hh:mm:ss:zzz") + " <=> " + "SYSTEM" + ": " + "Run application"
            }
        }
    }

    RegExpValidator
    {
        id: id_regExpHex
        regExp: /[0-9A-Fa-f/\s]+/
    }

    Component.onCompleted: standObj.logEnabled = settings.conf.debug
}
