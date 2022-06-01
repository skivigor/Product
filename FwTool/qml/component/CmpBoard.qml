import QtQuick 2.11
import QtGraphicalEffects 1.12

Rectangle
{
    width: 250
    height: 60
    radius: 4
    color: "#eeeeee"
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 2
        verticalOffset: 2
    }
}
