import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: root

    property var modelData
    property bool shouldBeVisible: false
    property int displayBatteryLevel: BatteryService.batteryAvailable ? BatteryService.batteryLevel : 8

    screen: modelData
    visible: shouldBeVisible
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    function show() {
        shouldBeVisible = true
        visible = true
    }

    function hide() {
        shouldBeVisible = false
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: Theme.mediumDuration + 50
        onTriggered: {
            if (!shouldBeVisible) {
                visible = false
            }
        }
    }

    // Полупрозрачный фон
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        opacity: shouldBeVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.hide()
        }
    }

    // Главное модальное окно
    Rectangle {
        id: modalBox
        anchors.centerIn: parent
        width: 480
        height: 320
        radius: Theme.cornerRadius * 3
        opacity: shouldBeVisible ? 1 : 0
        scale: shouldBeVisible ? 1 : 0.85

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#E85D4A" }
            GradientStop { position: 1.0; color: "#F08A7A" }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 12
            shadowBlur: 1.2
            shadowColor: Qt.rgba(0, 0, 0, 0.6)
            shadowOpacity: 0.6
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacingL

            // Иконка батареи
            Rectangle {
                width: 120
                height: 120
                radius: 60
                color: Qt.rgba(1, 1, 1, 0.15)
                anchors.horizontalCenter: parent.horizontalCenter

                Icon {
                    name: "battery_alert"
                    size: 80
                    color: "#FFFFFF"
                    anchors.centerIn: parent

                    SequentialAnimation on opacity {
                        running: root.shouldBeVisible
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.4; duration: 800 }
                        NumberAnimation { from: 0.4; to: 1.0; duration: 800 }
                    }
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingS

                Text {
                    text: "⚠️ НИЗКИЙ ЗАРЯД БАТАРЕИ"
                    font.pixelSize: 24
                    font.weight: Font.Black
                    color: "#FFFFFF"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: `${root.displayBatteryLevel}%`
                    font.pixelSize: 72
                    font.weight: Font.Black
                    color: "#FFFFFF"
                    anchors.horizontalCenter: parent.horizontalCenter
                    style: Text.Outline
                    styleColor: Qt.rgba(0, 0, 0, 0.2)
                }

                Text {
                    text: "Подключите зарядное устройство"
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.9)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.hide()
        }
    }

    mask: Region {
        item: modalBox
    }
}
