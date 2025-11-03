import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    property bool expanded: false
    readonly property real contentHeight: contentColumn.height + Theme.spacingL * 2

    width: parent.width
    height: expanded ? contentHeight : 0
    visible: expanded
    clip: true
    radius: Theme.cornerRadius
    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.3)
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
    border.width: 1

    Behavior on height {
        NumberAnimation {
            duration: Anims.durShort
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Anims.emphasized
        }
    }

    opacity: expanded ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: Anims.durShort
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Anims.emphasized
        }
    }

    readonly property var timeoutOptions: [{
            "text": "Никогда",
            "value": 0
        }, {
            "text": "1 секунда",
            "value": 1000
        }, {
            "text": "3 секунды",
            "value": 3000
        }, {
            "text": "5 секунд",
            "value": 5000
        }, {
            "text": "8 секунд",
            "value": 8000
        }, {
            "text": "10 секунд",
            "value": 10000
        }, {
            "text": "15 секунд",
            "value": 15000
        }, {
            "text": "30 секунд",
            "value": 30000
        }, {
            "text": "1 минута",
            "value": 60000
        }, {
            "text": "2 минуты",
            "value": 120000
        }, {
            "text": "5 минут",
            "value": 300000
        }, {
            "text": "10 минут",
            "value": 600000
        }]

    function getTimeoutText(value) {
        if (value === undefined || value === null || isNaN(value)) {
            return "5 секунд"
        }

        for (let i = 0; i < timeoutOptions.length; i++) {
            if (timeoutOptions[i].value === value) {
                return timeoutOptions[i].text
            }
        }
        if (value === 0) {
            return "Никогда"
        }
        if (value < 1000) {
            return value + "мс"
        }
        if (value < 60000) {
            const seconds = Math.round(value / 1000)
            if (seconds === 1) return "1 секунда"
            if (seconds < 5) return seconds + " секунды"
            return seconds + " секунд"
        }
        const minutes = Math.round(value / 60000)
        if (minutes === 1) return "1 минута"
        if (minutes < 5) return minutes + " минуты"
        return minutes + " минут"
    }

    Column {
        id: contentColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        StyledText {
            text: "Настройки уведомлений"
            font.pixelSize: Math.round(Theme.fontSizeMedium * 1.15) + 1
            font.weight: Font.Bold
            color: Theme.surfaceText
        }

        Item {
            width: parent.width
            height: 36

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingM

                Icon {
                    name: SessionData.doNotDisturb ? "notifications_off" : "notifications"
                    size: Math.round(Theme.fontSizeMedium * 1.15 * 1.3)
                    color: SessionData.doNotDisturb ? Theme.error : Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: "Не беспокоить"
                    font.pixelSize: Math.round(Theme.fontSizeMedium * 1.15)
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Toggle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: SessionData.doNotDisturb
                onToggled: SessionData.setDoNotDisturb(!SessionData.doNotDisturb)
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
        }

        StyledText {
            text: "Время показа уведомлений"
            font.pixelSize: Math.round(Theme.fontSizeMedium * 1.15)
            font.weight: Font.Medium
            color: Theme.surfaceVariantText
        }

        Dropdown {
            text: "Низкий приоритет"
            description: ""
            currentValue: getTimeoutText(SettingsData.notificationTimeoutLow)
            options: timeoutOptions.map(opt => opt.text)
            onValueChanged: value => {
                                for (let i = 0; i < timeoutOptions.length; i++) {
                                    if (timeoutOptions[i].text === value) {
                                        SettingsData.setNotificationTimeoutLow(timeoutOptions[i].value)
                                        break
                                    }
                                }
                            }
        }

        Dropdown {
            text: "Обычный приоритет"
            description: ""
            currentValue: getTimeoutText(SettingsData.notificationTimeoutNormal)
            options: timeoutOptions.map(opt => opt.text)
            onValueChanged: value => {
                                for (let i = 0; i < timeoutOptions.length; i++) {
                                    if (timeoutOptions[i].text === value) {
                                        SettingsData.setNotificationTimeoutNormal(timeoutOptions[i].value)
                                        break
                                    }
                                }
                            }
        }

        Dropdown {
            text: "Критический приоритет"
            description: ""
            currentValue: getTimeoutText(SettingsData.notificationTimeoutCritical)
            options: timeoutOptions.map(opt => opt.text)
            onValueChanged: value => {
                                for (let i = 0; i < timeoutOptions.length; i++) {
                                    if (timeoutOptions[i].text === value) {
                                        SettingsData.setNotificationTimeoutCritical(timeoutOptions[i].value)
                                        break
                                    }
                                }
                            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
        }

        Item {
            width: parent.width
            height: 36

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingM

                Icon {
                    name: "notifications_active"
                    size: Math.round(Theme.fontSizeMedium * 1.15 * 1.3)
                    color: SettingsData.notificationOverlayEnabled ? Theme.primary : Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: "Поверх полноэкранных приложений"
                    font.pixelSize: Math.round(Theme.fontSizeMedium * 1.15)
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Toggle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: SettingsData.notificationOverlayEnabled
                onToggled: toggled => SettingsData.setNotificationOverlayEnabled(toggled)
            }
        }
    }
}
