import QtQuick 2.4
import QtGraphicalEffects 1.0

Text {
    font.family: "Avenir Next"
    color: "#ffffff"
    font.pixelSize: 32

    layer.enabled: true
    layer.effect: DropShadow {
        radius: 2
        samples: 6
        verticalOffset: 2
        horizontalOffset: 2
        color: "#000000"
    }
}

