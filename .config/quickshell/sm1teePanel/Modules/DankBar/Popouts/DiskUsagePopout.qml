import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

PanelWindow {
    id: root

    property var diskMount: null
    property real targetX: 0
    property real targetY: 0
    property var targetScreen: null
    property bool alignLeft: false
    property bool alignRight: false
    property bool alignAbove: false

    function show(mount, x, y, screen, leftAlign, rightAlign, above) {
        root.diskMount = mount
        if (screen) {
            targetScreen = screen
            const screenX = screen.x || 0
            targetX = x - screenX
        } else {
            targetScreen = null
            targetX = x
        }
        targetY = y
        alignLeft = leftAlign ?? false
        alignRight = rightAlign ?? false
        alignAbove = above ?? false
        visible = true
    }

    function hide() {
        visible = false
    }

    screen: targetScreen
    implicitWidth: contentColumn.implicitWidth + Theme.spacingM * 2
    implicitHeight: contentColumn.implicitHeight + Theme.spacingM * 2
    color: "transparent"
    visible: false
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1

    anchors {
        top: true
        left: true
    }

    margins {
        left: {
            if (alignLeft) return Math.round(targetX)
            if (alignRight) return Math.round(targetX - implicitWidth)
            return Math.round(targetX - implicitWidth / 2)
        }
        top: {
            if (alignLeft || alignRight) return Math.round(targetY - implicitHeight / 2)
            if (alignAbove) return Math.round(targetY - implicitHeight)
            return Math.round(targetY)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceContainerHigh
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Theme.outlineMedium

        Column {
            id: contentColumn
            anchors.centerIn: parent
            spacing: Theme.spacingXS

            Row {
                spacing: Theme.spacingS

                StyledText {
                    text: root.diskMount ? (root.diskMount.displayName || root.diskMount.mount) : ""
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }

                StyledText {
                    text: root.diskMount ? (root.diskMount.percent || "0%") : "0%"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: {
                        if (!root.diskMount) return Theme.surfaceText
                        const percentStr = root.diskMount.percent.replace("%", "")
                        const percent = parseFloat(percentStr) || 0
                        if (percent > 90) return Theme.tempDanger
                        if (percent > 75) return Theme.tempWarning
                        return Theme.surfaceText
                    }
                }
            }

            StyledText {
                text: {
                    if (!root.diskMount) return ""
                    const used = root.diskMount.used || "0"
                    const size = root.diskMount.size || "0"
                    return `${used} / ${size}`
                }
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceTextMedium
            }
        }
    }
}
