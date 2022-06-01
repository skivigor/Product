import QtQuick 2.11

QtObject
{
    id: root

    property var _args

    function execute(str)
    {
        console.log("Execute NonGui 2: " + str)
        console.log("Args: " + _args[0] + " " + _args[1])
    }

    Component.onCompleted: console.log("NonGui 2 completed")
    Component.onDestruction: console.log("NonGui 2 destruction")
}
