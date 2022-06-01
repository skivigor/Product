import QtQuick 2.11
import QtQuick.Controls 1.4

Item
{
    id: root
    anchors.fill: parent

    signal select(int mode)

    ListModel
    {
        id: cbItems
        ListElement { text: "Jooby ASC"; file: "app_data/qml/view/ViewAsc.qml" }
        ListElement { text: "Jooby Nema"; file: "app_data/qml/view/ViewNema.qml" }
//        ListElement { text: "Jooby Driver"; file: "app_data/qml/view/ViewDriver.qml" }
    }

    Column
    {
        anchors.centerIn: parent
        spacing: 10

        Text { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 16; /*font.bold: true;*/ text: "Select operating mode" }
        Row
        {
            spacing: 20
            ComboBox { id: id_boxMode; model: cbItems; width: 150; focus: true }
            Button
            {
                width: 80
                text: "Select"
                onClicked: select(id_boxMode.currentIndex)
                Keys.onEnterPressed: select(id_boxMode.currentIndex)
                Keys.onReturnPressed: select(id_boxMode.currentIndex)
//                onClicked: select(cbItems.get(id_boxMode.currentIndex).file)
//                Keys.onEnterPressed: select(cbItems.get(id_boxMode.currentIndex).file)
//                Keys.onReturnPressed: select(cbItems.get(id_boxMode.currentIndex).file)
            }
        }
    }
}
