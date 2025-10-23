import QtQuick
import qs.Common
import qs.Modals.Common
import qs.Services
import qs.Widgets

DankModal {
    id: root

    property string networkSSID: ""
    property string networkPassword: ""

    function show() {
        networkSSID = ""
        networkPassword = ""
        open()
        Qt.callLater(() => {
            if (contentLoader.item && contentLoader.item.ssidInput) {
                contentLoader.item.ssidInput.forceActiveFocus()
            }
        })
    }

    shouldBeVisible: false
    width: Math.max(420, Math.min(600, 420 * SettingsData.fontScale))
    height: Math.max(280, Math.min(380, 280 * SettingsData.fontScale))
    
    onShouldBeVisibleChanged: () => {
        if (!shouldBeVisible) {
            networkSSID = ""
            networkPassword = ""
        }
    }
    
    onOpened: {
        Qt.callLater(() => {
            if (contentLoader.item && contentLoader.item.ssidInput) {
                contentLoader.item.ssidInput.forceActiveFocus()
            }
        })
    }
    
    onBackgroundClicked: () => {
        close()
        networkSSID = ""
        networkPassword = ""
    }

    content: Component {
        FocusScope {
            id: hiddenNetworkContent

            property alias ssidInput: ssidInput
            property alias passwordInput: passwordInput

            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: event => {
                close()
                networkSSID = ""
                networkPassword = ""
                event.accepted = true
            }

            Column {
                anchors.centerIn: parent
                width: parent.width - Theme.spacingM * 2
                spacing: Theme.spacingM

                Row {
                    width: parent.width

                    Column {
                        width: parent.width - 40
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Добавить скрытую сеть"
                            font.pixelSize: Theme.fontSizeLarge
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        StyledText {
                            text: "Введите имя сети (SSID) и пароль"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceTextMedium
                        }
                    }

                    DankActionButton {
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: () => {
                            close()
                            networkSSID = ""
                            networkPassword = ""
                        }
                    }
                }

                // SSID Input
                Rectangle {
                    width: parent.width
                    height: 50
                    radius: Theme.cornerRadius
                    color: Theme.surfaceHover
                    border.color: ssidInput.activeFocus ? Theme.primary : Theme.outlineStrong
                    border.width: ssidInput.activeFocus ? 2 : 1

                    MouseArea {
                        anchors.fill: parent
                        onClicked: () => {
                            ssidInput.forceActiveFocus()
                        }
                    }

                    DankTextField {
                        id: ssidInput

                        anchors.fill: parent
                        font.pixelSize: Theme.fontSizeMedium
                        textColor: Theme.surfaceText
                        text: networkSSID
                        placeholderText: "Имя сети (SSID)"
                        backgroundColor: "transparent"
                        enabled: root.shouldBeVisible
                        onTextEdited: () => {
                            networkSSID = text
                        }
                        onAccepted: () => {
                            if (passwordInput) {
                                passwordInput.forceActiveFocus()
                            }
                        }
                    }
                }

                // Password Input
                Rectangle {
                    width: parent.width
                    height: 50
                    radius: Theme.cornerRadius
                    color: Theme.surfaceHover
                    border.color: passwordInput.activeFocus ? Theme.primary : Theme.outlineStrong
                    border.width: passwordInput.activeFocus ? 2 : 1

                    MouseArea {
                        anchors.fill: parent
                        onClicked: () => {
                            passwordInput.forceActiveFocus()
                        }
                    }

                    DankTextField {
                        id: passwordInput

                        anchors.fill: parent
                        font.pixelSize: Theme.fontSizeMedium
                        textColor: Theme.surfaceText
                        text: networkPassword
                        echoMode: showPasswordCheckbox.checked ? TextInput.Normal : TextInput.Password
                        placeholderText: "Пароль (оставьте пустым для открытой сети)"
                        backgroundColor: "transparent"
                        enabled: root.shouldBeVisible
                        onTextEdited: () => {
                            networkPassword = text
                        }
                        onAccepted: () => {
                            if (ssidInput.text.length > 0) {
                                NetworkService.connectToHiddenWifi(ssidInput.text, passwordInput.text)
                                close()
                                networkSSID = ""
                                networkPassword = ""
                                ssidInput.text = ""
                                passwordInput.text = ""
                            }
                        }
                    }
                }

                // Show Password Checkbox
                Row {
                    spacing: Theme.spacingS

                    Rectangle {
                        id: showPasswordCheckbox

                        property bool checked: false

                        width: 20
                        height: 20
                        radius: 4
                        color: checked ? Theme.primary : "transparent"
                        border.color: checked ? Theme.primary : Theme.outlineButton
                        border.width: 2

                        DankIcon {
                            anchors.centerIn: parent
                            name: "check"
                            size: 12
                            color: Theme.background
                            visible: parent.checked
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                showPasswordCheckbox.checked = !showPasswordCheckbox.checked
                            }
                        }
                    }

                    StyledText {
                        text: "Показать пароль"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Buttons
                Item {
                    width: parent.width
                    height: 40

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingM

                        Rectangle {
                            width: Math.max(70, cancelText.contentWidth + Theme.spacingM * 2)
                            height: 36
                            radius: Theme.cornerRadius
                            color: cancelArea.containsMouse ? Theme.surfaceTextHover : "transparent"
                            border.color: Theme.surfaceVariantAlpha
                            border.width: 1

                            StyledText {
                                id: cancelText

                                anchors.centerIn: parent
                                text: "Отмена"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: cancelArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: () => {
                                    close()
                                    networkSSID = ""
                                    networkPassword = ""
                                }
                            }
                        }

                        Rectangle {
                            width: Math.max(80, connectText.contentWidth + Theme.spacingM * 2)
                            height: 36
                            radius: Theme.cornerRadius
                            color: connectArea.containsMouse ? Qt.darker(Theme.primary, 1.1) : Theme.primary
                            enabled: ssidInput.text.length > 0
                            opacity: enabled ? 1 : 0.5

                            StyledText {
                                id: connectText

                                anchors.centerIn: parent
                                text: "Подключить"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.background
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: connectArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: parent.enabled
                                onClicked: () => {
                                    NetworkService.connectToHiddenWifi(ssidInput.text, passwordInput.text)
                                    close()
                                    networkSSID = ""
                                    networkPassword = ""
                                    ssidInput.text = ""
                                    passwordInput.text = ""
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
