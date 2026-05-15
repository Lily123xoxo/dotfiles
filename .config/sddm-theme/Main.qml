import QtQuick
import QtQuick.Controls

Item {
    width: Screen.width
    height: Screen.height

    Connections {
        target: sddm
        function onLoginSucceeded() {}
        function onLoginFailed() {}
    }
}
