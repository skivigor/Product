import QtQuick 2.11

QtObject
{
    id: root

    property var _args

    function execute(str)
    {
        console.log("Execute NonGui 1: " + str)
        _args.test()
    }

    Component.onCompleted: console.log("NonGui 1 completed")
    Component.onDestruction: console.log("NonGui 1 destruction")
}


















