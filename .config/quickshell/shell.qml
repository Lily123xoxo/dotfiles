import Quickshell
import Quickshell.Wayland
import QtQuick

/*
 * Registers services and wires dependencies into widgets. 
 * Widgets never reference services directly; all dependencies are injected via WidgetHost.
 */

ShellRoot {

    Component.onCompleted: {
        ServiceRegistry.register("theme", Theme)
        console.log("loafies has now started.")
    }

    // Transparent layer which every widget maps to for positioning
    PanelWindow {
        id: root
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "loafies"
        WlrLayershell.exclusiveZone: -1

        color: "transparent"

        // Run Clock widget
        WidgetHost {
            widgetSource: "ClockWidget.qml"
            dependencies: ({
                "theme": ["accentColor", "activeFont"]
            })
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: 450
            anchors.topMargin: 450
        }
    }
}