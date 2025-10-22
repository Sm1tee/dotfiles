import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common

PanelWindow {
    id: root

    property bool demoActive: false

    visible: demoActive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"

    function showDemo(): void {
        demoActive = true
    }

    function hideDemo(): void {
        demoActive = false
    }

    Loader {
        anchors.fill: parent
        active: demoActive
        sourceComponent: LockScreenContent {
            demoMode: true
            screenName: root.screen?.name ?? ""
            onUnlockRequested: root.hideDemo()
        }
    }
}
