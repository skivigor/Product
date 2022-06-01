import QtQuick 2.12
import QtQuick.Controls 2.5
import "../component/CmpStyle.js" as Style

Item
{
    id: root
    anchors.fill: parent

    BorderImage { anchors.fill: parent; source: Style.bgPageTheme }

    Item
    {
        id: id_itmTopBar
        width: parent.width
        height: 45
        Rectangle { anchors.fill: parent; color: "#e0e0e0" }
        Text
        {
            anchors.centerIn: parent
            font.pixelSize: 22
            font.bold: true
            color: "darkgreen"
            text: "Jooby Control Panel"
        }
        Image
        {
            height: parent.height - 5
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.margins: 5
            fillMode: Image.PreserveAspectFit
            source: "../../images/logo.png"
        }
    }

    Row
    {
        anchors.left: parent.left
        anchors.leftMargin: 10
        spacing: 10
        ToolButton
        {
            id: toolButton
            text: "\u2630"
            font.pixelSize: Qt.application.font.pixelSize * 2
            onClicked: drawer.open()
        }
        Label
        {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Style.txtHeaderSize
            text: stackView.currentItem.title
        }
    }

    ListModel
    {
        id: id_model
        ListElement
        {
            name: qsTr("  Order")
            path: "PageCtrlOrder.qml"
        }
        ListElement
        {
            name: qsTr("  Status")
            path: "PageCtrlStatus.qml"
        }
        ListElement
        {
            name: qsTr("  Device info")
            path: "PageCtrlDevInfo.qml"
        }
    }

    Drawer
    {
        id: drawer
        width: root.width * 0.2
        height: root.height

        ListView
        {
            anchors.fill: parent
            clip: true
            model: id_model
            delegate: ItemDelegate {
                text: name
                font.pixelSize: Style.txtHeaderSize
                width: parent.width
                onClicked:
                {
                    if (stackView.depth > 1) stackView.pop()
                    stackView.push(path)
                    drawer.close()
                }
            }
        }
    }

    StackView
    {
        id: stackView
        initialItem: "PageCtrl0.qml"
        anchors.top: id_itmTopBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    Component.onCompleted:
    {
        stackView.push("PageCtrlOrder.qml")
        id_mainWindow.width = 1024
        id_mainWindow.height = 800
        id_mainWindow.minimumWidth = 1024
        id_mainWindow.minimumHeight = 300
    }
}
