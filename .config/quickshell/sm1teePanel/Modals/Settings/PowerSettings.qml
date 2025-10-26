import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: powerTab

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingXL

            StyledText {
                text: "Батарея не обнаружена - доступны только настройки питания от сети"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceVariantText
                visible: !BatteryService.batteryAvailable
            }

            StyledRect {
                width: parent.width
                height: lockScreenSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: lockScreenSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "lock"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Экран блокировки"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Показывать действия питания"
                        description: "Показывать кнопки выключения, перезагрузки и выхода на экране блокировки"
                        checked: SettingsData.lockScreenShowPowerActions
                        onToggled: checked => SettingsData.setLockScreenShowPowerActions(checked)
                    }

                    StyledText {
                        text: "Требуется DMS сервер для интеграции с системой. Блокировка работает и без него."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.warning
                        visible: !SessionService.loginctlAvailable
                        width: parent.width
                        wrapMode: Text.Wrap
                    }

                    DankToggle {
                        width: parent.width
                        text: "Интеграция с системой (loginctl)"
                        description: "Автоблокировка при засыпании и статус 'Отошёл' в приложениях."
                        checked: SessionService.loginctlAvailable && SessionData.loginctlLockIntegration
                        enabled: SessionService.loginctlAvailable
                        onToggled: checked => {
                            if (SessionService.loginctlAvailable) {
                                SessionData.setLoginctlLockIntegration(checked)
                            }
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Блокировать перед приостановкой"
                        description: "Автоматически блокировать экран когда система готовится к приостановке"
                        checked: SessionData.lockBeforeSuspend
                        visible: SessionService.loginctlAvailable && SessionData.loginctlLockIntegration
                        onToggled: checked => SessionData.setLockBeforeSuspend(checked)
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: timeoutSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: timeoutSection
                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "schedule"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Настройки простоя"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: Math.max(0, parent.width - parent.children[0].width - parent.children[1].width - powerCategory.width - Theme.spacingM * 3)
                            height: parent.height
                        }

                        DankButtonGroup {
                            id: powerCategory
                            anchors.verticalCenter: parent.verticalCenter
                            visible: BatteryService.batteryAvailable
                            model: ["От сети", "От батареи"]
                            currentIndex: 0
                            selectionMode: "single"
                            checkEnabled: false
                        }
                    }

                    DankDropdown {
                        id: lockDropdown
                        property var timeoutOptions: ["Никогда", "1 минута", "2 минуты", "3 минуты", "5 минут", "10 минут", "15 минут", "20 минут", "30 минут", "1 час", "1 час 30 минут", "2 часа", "3 часа"]
                        property var timeoutValues: [0, 60, 120, 180, 300, 600, 900, 1200, 1800, 3600, 5400, 7200, 10800]

                        text: "Автоматически блокировать"
                        options: timeoutOptions

                        Connections {
                            target: powerCategory
                            function onCurrentIndexChanged() {
                                const currentTimeout = powerCategory.currentIndex === 0 ? SessionData.acLockTimeout : SessionData.batteryLockTimeout
                                const index = lockDropdown.timeoutValues.indexOf(currentTimeout)
                                lockDropdown.currentValue = index >= 0 ? lockDropdown.timeoutOptions[index] : "Never"
                            }
                        }

                        Component.onCompleted: {
                            const currentTimeout = powerCategory.currentIndex === 0 ? SessionData.acLockTimeout : SessionData.batteryLockTimeout
                            const index = timeoutValues.indexOf(currentTimeout)
                            currentValue = index >= 0 ? timeoutOptions[index] : "Never"
                        }

                        onValueChanged: value => {
                            const index = timeoutOptions.indexOf(value)
                            if (index >= 0) {
                                const timeout = timeoutValues[index]
                                if (powerCategory.currentIndex === 0) {
                                    SessionData.setAcLockTimeout(timeout)
                                } else {
                                    SessionData.setBatteryLockTimeout(timeout)
                                }
                            }
                        }
                    }

                    DankDropdown {
                        id: monitorDropdown
                        property var timeoutOptions: ["Никогда", "1 минута", "2 минуты", "3 минуты", "5 минут", "10 минут", "15 минут", "20 минут", "30 минут", "1 час", "1 час 30 минут", "2 часа", "3 часа"]
                        property var timeoutValues: [0, 60, 120, 180, 300, 600, 900, 1200, 1800, 3600, 5400, 7200, 10800]

                        text: "Выключить мониторы"
                        options: timeoutOptions

                        Connections {
                            target: powerCategory
                            function onCurrentIndexChanged() {
                                const currentTimeout = powerCategory.currentIndex === 0 ? SessionData.acMonitorTimeout : SessionData.batteryMonitorTimeout
                                const index = monitorDropdown.timeoutValues.indexOf(currentTimeout)
                                monitorDropdown.currentValue = index >= 0 ? monitorDropdown.timeoutOptions[index] : "Never"
                            }
                        }

                        Component.onCompleted: {
                            const currentTimeout = powerCategory.currentIndex === 0 ? SessionData.acMonitorTimeout : SessionData.batteryMonitorTimeout
                            const index = timeoutValues.indexOf(currentTimeout)
                            currentValue = index >= 0 ? timeoutOptions[index] : "Never"
                        }

                        onValueChanged: value => {
                            const index = timeoutOptions.indexOf(value)
                            if (index >= 0) {
                                const timeout = timeoutValues[index]
                                if (powerCategory.currentIndex === 0) {
                                    SessionData.setAcMonitorTimeout(timeout)
                                } else {
                                    SessionData.setBatteryMonitorTimeout(timeout)
                                }
                            }
                        }
                    }

                    DankDropdown {
                        id: suspendDropdown
                        property var timeoutOptions: ["Никогда", "1 минута", "2 минуты", "3 минуты", "5 минут", "10 минут", "15 минут", "20 минут", "30 минут", "1 час", "1 час 30 минут", "2 часа", "3 часа"]
                        property var timeoutValues: [0, 60, 120, 180, 300, 600, 900, 1200, 1800, 3600, 5400, 7200, 10800]

                        text: "Приостановить систему"
                        options: timeoutOptions

                        Connections {
                            target: powerCategory
                            function onCurrentIndexChanged() {
                                const currentTimeout = powerCategory.currentIndex === 0 ? SessionData.acSuspendTimeout : SessionData.batterySuspendTimeout
                                const index = suspendDropdown.timeoutValues.indexOf(currentTimeout)
                                suspendDropdown.currentValue = index >= 0 ? suspendDropdown.timeoutOptions[index] : "Never"
                            }
                        }

                        Component.onCompleted: {
                            const currentTimeout = powerCategory.currentIndex === 0 ? SessionData.acSuspendTimeout : SessionData.batterySuspendTimeout
                            const index = timeoutValues.indexOf(currentTimeout)
                            currentValue = index >= 0 ? timeoutOptions[index] : "Never"
                        }

                        onValueChanged: value => {
                            const index = timeoutOptions.indexOf(value)
                            if (index >= 0) {
                                const timeout = timeoutValues[index]
                                if (powerCategory.currentIndex === 0) {
                                    SessionData.setAcSuspendTimeout(timeout)
                                } else {
                                    SessionData.setBatterySuspendTimeout(timeout)
                                }
                            }
                        }
                    }

                    DankDropdown {
                        id: hibernateDropdown
                        property var timeoutOptions: ["Никогда", "1 минута", "2 минуты", "3 минуты", "5 минут", "10 минут", "15 минут", "20 минут", "30 минут", "1 час", "1 час 30 минут", "2 часа", "3 часа"]
                        property var timeoutValues: [0, 60, 120, 180, 300, 600, 900, 1200, 1800, 3600, 5400, 7200, 10800]

                        text: "Гибернировать систему"
                        options: timeoutOptions
                        visible: SessionService.hibernateSupported

                        Connections {
                            target: powerCategory
                            function onCurrentIndexChanged() {
                                const currentTimeout = powerCategory.currentIndex === 0 ? SessionData.acHibernateTimeout : SessionData.batteryHibernateTimeout
                                const index = hibernateDropdown.timeoutValues.indexOf(currentTimeout)
                                hibernateDropdown.currentValue = index >= 0 ? hibernateDropdown.timeoutOptions[index] : "Never"
                            }
                        }

                        Component.onCompleted: {
                            const currentTimeout = powerCategory.currentIndex === 0 ? SessionData.acHibernateTimeout : SessionData.batteryHibernateTimeout
                            const index = timeoutValues.indexOf(currentTimeout)
                            currentValue = index >= 0 ? timeoutOptions[index] : "Never"
                        }

                        onValueChanged: value => {
                            const index = timeoutOptions.indexOf(value)
                            if (index >= 0) {
                                const timeout = timeoutValues[index]
                                if (powerCategory.currentIndex === 0) {
                                    SessionData.setAcHibernateTimeout(timeout)
                                } else {
                                    SessionData.setBatteryHibernateTimeout(timeout)
                                }
                            }
                        }
                    }

                    StyledText {
                        text: "Мониторинг простоя не поддерживается - требуется новая версия Quickshell"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.error
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: !IdleService.idleMonitorAvailable
                    }
                }
            }

        }
    }
}