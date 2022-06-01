import QtQuick 2.12
import QtQuick.Controls 2.5
//import "./CmpStyle.js" as Style

Page
{
    title: qsTr("Page0")

//    BorderImage
//    {
//        anchors.fill: parent
//        source: Style.bgPageTheme
//    }

    Label {
        text: qsTr("You are on the Page0.")
        anchors.centerIn: parent
    }

    Component.onCompleted: console.log("Page 0 completed")
    Component.onDestruction: console.log("Page 0 destruction")
}

