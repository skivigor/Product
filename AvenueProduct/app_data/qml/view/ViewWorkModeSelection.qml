import QtQuick 2.12
import QtQuick.Controls 2.5
import "../component/CmpStyle.js" as Style

Rectangle
{
    id: root
    anchors.fill: parent
    color: "#ddffffff"

//    signal selected(var index)

    PropertyAnimation { target: root; property: "opacity";
        duration: 400; from: 0; to: 1;
        easing.type: Easing.InOutQuad ; running: true }

//    MouseArea
//    {
//        anchors.fill: parent
//        onClicked:
//        {
//            console.log("Model size: " + id_modeModel.count)
//            //            _workMode = 2
//            //            root.destroy()
//            var mode = { "bla" : "val" }
//            selected(mode)
//        }
//    }

    ListModel
    {
        id: id_modeModel
    }

    Component
    {
        id: id_delegate

        Rectangle
        {
            id: id_rcDelegate
            width: 180
            height: 180
            border.width: 2
            border.color: "#b0b0b0"
            radius: 5

            Column
            {
                anchors.centerIn: parent
                Text { font.pixelSize: 14; text: '<b>' + name + '</b>' }
                Image
                {
                    width: 150
                    height: 150
                    source: "../../images/" + image
                }

                //Text { text: '<b>Image:</b> ' + image }
            }

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: id_rcDelegate.border.color = "#505050"
                onExited: id_rcDelegate.border.color = "#b0b0b0"
                onPressed: id_rcDelegate.border.color = "#000000"
                onClicked:
                {
                    id_view.currentIndex = index
                    console.log("Index: " + id_view.currentIndex)
                    //selected(id_view.currentIndex)
                    _selectedMode = index
                    root.destroy()
                }

            }
        }

//        Item
//        {
//            width: 180; height: 40
//            Column {
//                Text { text: '<b>Name:</b> ' + name }
//                Text { text: '<b>Image:</b> ' + image }
//            }
//        }
    }

    ListView
    {
        id: id_view
        anchors.fill: parent
        anchors.margins: 40
        orientation: ListView.Horizontal
        spacing: 10
        model: id_modeModel
        delegate: id_delegate
        currentIndex: -1
    }


    Component.onCompleted:
    {
        id_mainWindow.width = 800
        id_mainWindow.height = 300
        id_mainWindow.minimumWidth = 800
        id_mainWindow.minimumHeight = 300

        var list = settings.product.list

        for (var i = 0; i < list.length; ++i)
        {
            id_modeModel.append(list[i])
        }

    }
}
