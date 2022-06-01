import QtQuick 2.12
import QtQuick.Controls 2.5
//import "CmpStyle.js" as Style

Item
{
    id: root
    anchors.fill: parent
    property var _args   // color: _args[0]; text: _args[1]; path: _args[2]; fileName: _args[3]; content: _args[4]; lastResult: _args[5]; testDescr: _args[6]

    function saveFile()
    {
        var ret = file.appendFile(_args[2] + _args[3], _args[4])
        if (ret === true) avlog.show("green", "File  " + _args[3] + " saved ... OK", false, false)
        else avlog.show("red", "File  " + _args[3] + " save ... Error!", false, false)
        root.destroy()
    }

    Rectangle
    {
        id: id_rcOrder
        anchors.fill: parent
        color: "#ddffffff"
        onVisibleChanged: animation.running = true

        PropertyAnimation { id: animation;
            target: id_rcOrder; property: "opacity";
            duration: 400; from: 0; to: 1;
            easing.type: Easing.InOutQuad ; running: true }

        CmpBoard
        {
            anchors.centerIn: parent
            width: parent.width - 200
            height: 300

            Item
            {
                anchors.fill: parent
                anchors.margins: 10

                Column
                {
                    anchors.centerIn: parent
                    spacing: 20
                    Text
                    {
                        font.pixelSize: 14
                        color: "black"
                        textFormat: Text.RichText
                        text: "<b>Test mode:  </b><font color='darkgreen'>" + _args[6] + "</font><br>
                               <b>Scale speed: </b><font color='darkgreen'>" + _args[5].scale + " kg/h</font>"
                    }
                    Text { id: id_txtResult; font.pixelSize: 14; color: "black"; textFormat: Text.RichText; }
                    Text { font.pixelSize: 16; color: _args[0]; text: _args[1]; anchors.horizontalCenter: parent.horizontalCenter }
                    Row
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20

                        Button
                        {
                            width: 80
                            text: "Save"
                            onClicked: saveFile()
                        }
                        Button
                        {
                            width: 80
                            text: "Cancel"
                            onClicked: root.destroy()
                        }
                    }


                }
            }
        }   // CmpBoard
    }
//    Shortcut { sequences: ["Return"]; onActivated: saveFile() }
//    Shortcut { sequences: ["Esc"]; onActivated: root.destroy() }

    Component.onCompleted:
    {
        console.log("!!!!!!! Result popup window ctor")

        var name = _testMode === 0 ? "Weight, kg" : "Volume, L"

        id_txtResult.text = "<table cellspacing='10'>
        <tr>
            <th>&nbsp;</th>
            <th align='right'>Ch1</th>
            <th align='right'>Ch2</th>
            <th align='right'>Ch3</th>
            <th align='right'>Ch4</th>
        </tr>
        <tr>
            <td align='right'><b>" + name + "</b></td>
            <td align='right'><font color='darkgreen'>" + _args[5].v1 + "</font></td>
            <td align='right'><font color='darkgreen'>" + _args[5].v2 + "</font></td>
            <td align='right'><font color='darkgreen'>" + _args[5].v3 + "</font></td>
            <td align='right'><font color='darkgreen'>" + _args[5].v4 + "</font></td>
        </tr>
        <tr>
            <td align='right'><b>Meter, L</b></td>
            <td align='right'><font color='darkgreen'>" + _args[5].m1 + "</font></td>
            <td align='right'><font color='darkgreen'>" + _args[5].m2 + "</font></td>
            <td align='right'><font color='darkgreen'>" + _args[5].m3 + "</font></td>
            <td align='right'><font color='darkgreen'>" + _args[5].m4 + "</font></td>
        </tr>
        <tr>
            <td align='right'><b>%</b></td>
            <td align='right'><font color='grey'>" + _args[5].p1 + "</font></td>
            <td align='right'><font color='grey'>" + _args[5].p2 + "</font></td>
            <td align='right'><font color='grey'>" + _args[5].p3 + "</font></td>
            <td align='right'><font color='grey'>" + _args[5].p4 + "</font></td>
        </tr>
        </table>"
    }
}
