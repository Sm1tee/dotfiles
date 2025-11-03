import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import "../Popouts"

Rectangle {
    id: root

    property bool isVertical: axis?.isVertical ?? false
    property var axis: null
    property var widgetData: null
    property var parentScreen: null
    property real widgetThickness: 30
    property real barThickness: 48
    property string mountPath: (widgetData && widgetData.mountPath !== undefined) ? widgetData.mountPath : "/"
    readonly property real horizontalPadding: SettingsData.barNoBackground ? 0 : Math.max(Theme.baseSpacingXS, Theme.baseSpacingS * (widgetThickness / 30))

    property var selectedMount: {
        if (!DgopService.diskMounts || DgopService.diskMounts.length === 0) {
            return null
        }

        // Force re-evaluation when mountPath changes
        const currentMountPath = root.mountPath || "/"

        // First try to find exact match
        for (let i = 0; i < DgopService.diskMounts.length; i++) {
            if (DgopService.diskMounts[i].mount === currentMountPath) {
                return DgopService.diskMounts[i]
            }
        }

        // Fallback to root
        for (let i = 0; i < DgopService.diskMounts.length; i++) {
            if (DgopService.diskMounts[i].mount === "/") {
                return DgopService.diskMounts[i]
            }
        }

        // Last resort - first mount
        return DgopService.diskMounts[0] || null
    }

    property real diskUsagePercent: {
        if (!selectedMount || !selectedMount.percent) {
            return 0
        }
        const percentStr = selectedMount.percent.replace("%", "")
        return parseFloat(percentStr) || 0
    }

    width: isVertical ? widgetThickness : (diskContent.implicitWidth + horizontalPadding * 2)
    height: isVertical ? (diskContent.implicitHeight + horizontalPadding * 2) : widgetThickness
    radius: SettingsData.barNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.barNoBackground) {
            return "transparent"
        }

        const baseColor = diskArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency)
    }
    Component.onCompleted: {
        DgopService.addRef(["diskmounts"])
    }
    Component.onDestruction: {
        DgopService.removeRef(["diskmounts"])
    }

    Connections {
        function onWidgetDataChanged() {
            // Force property re-evaluation by triggering change detection
            root.mountPath = Qt.binding(() => {
                return (root.widgetData && root.widgetData.mountPath !== undefined) ? root.widgetData.mountPath : "/"
            })

            root.selectedMount = Qt.binding(() => {
                if (!DgopService.diskMounts || DgopService.diskMounts.length === 0) {
                    return null
                }

                const currentMountPath = root.mountPath || "/"

                // First try to find exact match
                for (let i = 0; i < DgopService.diskMounts.length; i++) {
                    if (DgopService.diskMounts[i].mount === currentMountPath) {
                        return DgopService.diskMounts[i]
                    }
                }

                // Fallback to root
                for (let i = 0; i < DgopService.diskMounts.length; i++) {
                    if (DgopService.diskMounts[i].mount === "/") {
                        return DgopService.diskMounts[i]
                    }
                }

                // Last resort - first mount
                return DgopService.diskMounts[0] || null
            })
        }

        target: SettingsData
    }

    Loader {
        id: popoutLoader
        active: false
        sourceComponent: DiskUsagePopout {}
    }

    MouseArea {
        id: diskArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            popoutLoader.active = true
            if (popoutLoader.item && root.selectedMount) {
                if (root.isVertical) {
                    const globalPos = mapToGlobal(width / 2, height / 2)
                    const screenX = root.parentScreen ? root.parentScreen.x : 0
                    const screenY = root.parentScreen ? root.parentScreen.y : 0
                    const relativeY = globalPos.y - screenY
                    const tooltipX = root.axis?.edge === "left" ? (Theme.barHeight + SettingsData.barSpacing + Theme.baseSpacingXS) : (root.parentScreen.width - Theme.barHeight - SettingsData.barSpacing - Theme.baseSpacingXS)
                    const isLeft = root.axis?.edge === "left"
                    popoutLoader.item.show(root.selectedMount, screenX + tooltipX, relativeY, root.parentScreen, isLeft, !isLeft)
                } else {
                    const globalPosX = mapToGlobal(width / 2, 0).x
                    const screenHeight = root.parentScreen ? root.parentScreen.height : 1080
                    
                    // Используем axis.edge напрямую
                    if (root.axis?.edge === "bottom") {
                        // Панель внизу - tooltip над панелью
                        const tooltipY = screenHeight - Theme.barHeight - SettingsData.barSpacing - Theme.baseSpacingXS
                        popoutLoader.item.show(root.selectedMount, globalPosX, tooltipY, root.parentScreen, false, false, true)
                    } else {
                        // Панель сверху - tooltip под панелью
                        const tooltipY = Theme.barHeight + SettingsData.barSpacing + Theme.baseSpacingXS
                        popoutLoader.item.show(root.selectedMount, globalPosX, tooltipY, root.parentScreen, false, false, false)
                    }
                }
            }
        }
        onExited: {
            if (popoutLoader.item) {
                popoutLoader.item.hide()
            }
            popoutLoader.active = false
        }
    }

    Row {
        id: diskContent
        anchors.centerIn: parent
        spacing: 3

        Icon {
            name: "storage"
            size: Theme.barIconSize(barThickness)
            color: {
                if (diskArea.containsMouse) {
                    return Theme.primary
                }
                if (root.diskUsagePercent > 90) {
                    return Theme.tempDanger
                }
                if (root.diskUsagePercent > 75) {
                    return Theme.tempWarning
                }
                return Theme.surfaceText
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: {
                if (root.diskUsagePercent === undefined || root.diskUsagePercent === null || root.diskUsagePercent === 0) {
                    return "--%"
                }
                return root.diskUsagePercent.toFixed(0) + "%"
            }
            font.pixelSize: Theme.barTextSize(barThickness)
            font.weight: Font.Medium
            color: diskArea.containsMouse ? Theme.primary : Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideNone

            StyledTextMetrics {
                id: diskBaseline
                font.pixelSize: Theme.barTextSize(barThickness)
                font.weight: Font.Medium
                text: "100%"
            }

            width: Math.max(diskBaseline.width, paintedWidth)

            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}