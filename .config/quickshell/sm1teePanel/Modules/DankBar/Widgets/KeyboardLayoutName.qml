import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.ProcessList
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    property bool isVertical: axis?.isVertical ?? false
    property var axis: null
    property real widgetThickness: 30
    property real barThickness: 48
    readonly property real horizontalPadding: SettingsData.dankBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetThickness / 30))
    property string currentLayout: ""
    property string hyprlandKeyboard: ""

    width: isVertical ? widgetThickness : (contentRow.implicitWidth + horizontalPadding * 2)
    height: isVertical ? (contentColumn.implicitHeight + horizontalPadding * 2) : widgetThickness
    radius: SettingsData.dankBarNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.dankBarNoBackground) {
            return "transparent";
        }

        const baseColor = mouseArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (CompositorService.isNiri) {
                NiriService.cycleKeyboardLayout()
            } else if (CompositorService.isHyprland) {
                Quickshell.execDetached([
                    "hyprctl",
                    "switchxkblayout",
                    root.hyprlandKeyboard,
                    "next"
                ])
            }
        }
    }

    Column {
        id: contentColumn

        anchors.centerIn: parent
        spacing: 1
        visible: root.isVertical

        DankIcon {
            name: "keyboard"
            size: Theme.barIconSize(barThickness)
            color: Theme.surfaceText
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !SettingsData.keyboardLayoutShowFlag
        }

        StyledText {
            text: {
                if (!currentLayout) return ""
                
                if (SettingsData.keyboardLayoutShowFlag) {
                    // Показываем флаг (эмодзи)
                    const layoutLower = currentLayout.toLowerCase()
                    if (layoutLower.includes("russian")) return "🇷🇺"
                    if (layoutLower.includes("english") || layoutLower.includes("us")) return "🇺🇸"
                    if (layoutLower.includes("german")) return "🇩🇪"
                    if (layoutLower.includes("french")) return "🇫🇷"
                    if (layoutLower.includes("spanish")) return "🇪🇸"
                    if (layoutLower.includes("italian")) return "🇮🇹"
                    if (layoutLower.includes("chinese")) return "🇨🇳"
                    if (layoutLower.includes("japanese")) return "🇯🇵"
                    if (layoutLower.includes("korean")) return "🇰🇷"
                }
                
                // Показываем первые 2 буквы
                const parts = currentLayout.split(" ")
                if (parts.length > 0) {
                    return parts[0].substring(0, 2).toUpperCase()
                }
                return currentLayout.substring(0, 2).toUpperCase()
            }
            font.pixelSize: SettingsData.keyboardLayoutShowFlag ? Theme.barTextSize(barThickness) + 2 : Theme.barTextSize(barThickness)
            font.weight: Font.Medium
            color: Theme.surfaceText
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: Theme.spacingS
        visible: !root.isVertical

        StyledText {
            text: {
                if (SettingsData.keyboardLayoutShowFlag) {
                    // Показываем флаг (эмодзи)
                    const layoutLower = currentLayout.toLowerCase()
                    if (layoutLower.includes("russian")) return "🇷🇺"
                    if (layoutLower.includes("english") || layoutLower.includes("us")) return "🇺🇸"
                    if (layoutLower.includes("german")) return "🇩🇪"
                    if (layoutLower.includes("french")) return "🇫🇷"
                    if (layoutLower.includes("spanish")) return "🇪🇸"
                    if (layoutLower.includes("italian")) return "🇮🇹"
                    if (layoutLower.includes("chinese")) return "🇨🇳"
                    if (layoutLower.includes("japanese")) return "🇯🇵"
                    if (layoutLower.includes("korean")) return "🇰🇷"
                    // Если не нашли - показываем первые 2 буквы
                    return currentLayout.substring(0, 2).toUpperCase()
                } else {
                    // Показываем название раскладки
                    return currentLayout
                }
            }
            font.pixelSize: SettingsData.keyboardLayoutShowFlag ? Theme.barTextSize(barThickness) + 2 : Theme.barTextSize(barThickness)
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
        }

    }


    Process {
        id: hyprlandLayoutProcess
        running: false
        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    // Find the main keyboard and get its active keymap
                    const mainKeyboard = data.keyboards.find(kb => kb.main === true)
                    root.hyprlandKeyboard = mainKeyboard.name
                    if (mainKeyboard && mainKeyboard.active_keymap) {
                        root.currentLayout = mainKeyboard.active_keymap
                    } else {
                        root.currentLayout = "Unknown"
                    }
                } catch (e) {
                    root.currentLayout = "Unknown"
                }
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            updateLayout()
        }
    }

    Component.onCompleted: {
        updateLayout()
    }

    function updateLayout() {
        if (CompositorService.isNiri) {
            root.currentLayout = NiriService.getCurrentKeyboardLayoutName()
        } else if (CompositorService.isHyprland) {
            hyprlandLayoutProcess.running = true
        }
    }
}
