import QtQuick 2.11
import QtQuick.Controls 2.5
import "../component/CmpStyle.js" as Style

Item
{
    id: root
    anchors.fill: parent

    property var  _modelTests
    property var  _testObj: null

    property int _countComplete: 0
    property int _countError: 0
    property int _countTotal: 0

    function onExecuted(ret)
    {
        if (ret === true) _countComplete++
        else _countError++
        _countTotal = _countComplete + _countError

        _waiting = false
        _testObj.destroy()
        _testObj = null
    }

    //-----------------------------------------------------------------

    function onStop()
    {
        _waiting = false
        _testObj.destroy()
        _testObj = null
        avlog.show("red", "Work stopped!!!")
    }

    //-----------------------------------------------------------------

    function startTest(name)
    {
        console.log("Start test: " + name)
        var path = _standTestsPath + name
        _testObj = Qt.createComponent(path).createObject(root, { /*"_args" : stage.args*/ })

        if (_testObj === null)
        {
            console.log("Work stopped: " + name)
            avlog.show("red", "ERROR!!! Can not load " + name, false, true)
            avlog.show("red", "Work stopped!!!")
            return
        }

        _testObj.executed.connect(onExecuted)
        _testObj.stop.connect(onStop)
        _waiting = true
        id_tim.start()
    }

    function process()
    {
        if (_testObj === null) return
        _testObj.execute()
    }

    Timer
    {
        id: id_tim
        running: false
        repeat: false
        interval: 100
        onTriggered: process()
    }

    //-----------------------------------------------------------------

    Column
    {
        anchors.centerIn: parent
        spacing: 10

        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Select profile" }
        Row
        {
            spacing: 20
            ComboBox { id: id_boxProfile; width: 200; enabled: !_waiting; model: _modelTests}
            Button
            {
                width: 100
                text: "Start"
                enabled: !_waiting
                onClicked: startTest(id_boxProfile.currentText)
                Keys.onReturnPressed: startTest(id_boxProfile.currentText)
            }
            Text { font.pixelSize: 14; text: "[Ctrl + S]" }
        }
        Row
        {
            spacing: 5
            Text { /*width: 80;*/ text: "Completed: " }
            Text { width: 30; text: _countComplete }
            Text { /*width: 50;*/ text: " Error: " }
            Text { width: 30; text: _countError }
            Text { /*width: 50;*/ text: " Total: " }
            Text { width: 30; text: _countTotal }
        }
    }

    Shortcut { sequences: ["Ctrl+S"]; onActivated: { if (!_waiting) startTest(id_boxProfile.currentText) }  }

    Component.onCompleted:
    {
        var filter = ["*.qml"]
        _modelTests = file.getFilesNameList(_standTestsPath, filter)
    }

}

