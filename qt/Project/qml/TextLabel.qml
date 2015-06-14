import QtQuick 2.4
import QtGraphicalEffects 1.0

Text {
    font.family: "Avenir Next"
    color: "#ffffff"
    font.pixelSize: 32

    layer.enabled: true
    layer.effect: DropShadow {
        radius: 6
        spread: 6
        verticalOffset: 3
        horizontalOffset: 3
        color: "#000000"
    }
}

