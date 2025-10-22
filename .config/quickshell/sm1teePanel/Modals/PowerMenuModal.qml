import QtQuick
import qs.Common
import qs.Modals.Common
import qs.Services
import qs.Widgets

DankModal {
    id: root

    property int selectedIndex: 0
    property int optionCount: 3
    property rect parentBounds: Qt.rect(0, 0, 0, 0)
    property var parentScreen: null

    signal powerActionRequested(string action, string title, string message)

    function openCentered() {
        parentBounds = Qt.rect(0, 0, 0, 0)
        parentScreen = null
        backgroundOpacity = 0.5
        open()
    }

    function openFromControlCenter(bounds, targetScreen) {
        parentBounds = bounds
        parentScreen = targetScreen
        backgroundOpacity = 0
        open()
    }

    function selectOption(action) {
        close();
        const actions = {
            "logout": {
                "title": "Выход",
                "message": "Вы уверены, что хотите выйти из системы?"
            },
            "reboot": {
                "title": "Перезагрузка",
                "message": "Вы уверены, что хотите перезагрузить систему?"
            },
            "poweroff": {
                "title": "Выключение",
                "message": "Вы уверены, что хотите выключить систему?"
            }
        }
        const selected = actions[action]
        if (selected) {
            root.powerActionRequested(action, selected.title, selected.message);
        }

    }

    shouldBeVisible: false
    width: Math.max(320, Math.min(450, 320 * SettingsData.fontScale))
    height: contentLoader.item ? contentLoader.item.implicitHeight : Math.max(300, Math.min(400, 300 * SettingsData.fontScale))
    enableShadow: true
    screen: parentScreen
    positioning: parentBounds.width > 0 ? "custom" : "center"
    customPosition: {
        if (parentBounds.width > 0) {
            // Правый верхний угол меню касается кнопки питания
            // x: правый край меню совпадает с правым краем кнопки
            const x = parentBounds.x + parentBounds.width - width
            // y: верхний край меню совпадает с верхним краем кнопки
            const y = parentBounds.y
            
            return Qt.point(x, y)
        }
        return Qt.point(0, 0)
    }
    onBackgroundClicked: () => {
        return close();
    }
    onOpened: () => {
        selectedIndex = 0;
        Qt.callLater(() => modalFocusScope.forceActiveFocus());
    }
    modalFocusScope.Keys.onPressed: (event) => {
        switch (event.key) {
        case Qt.Key_Up:
        case Qt.Key_Backtab:
            selectedIndex = (selectedIndex - 1 + optionCount) % optionCount;
            event.accepted = true;
            break;
        case Qt.Key_Down:
        case Qt.Key_Tab:
            selectedIndex = (selectedIndex + 1) % optionCount;
            event.accepted = true;
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            const actions = ["logout", "reboot", "poweroff"];
            if (selectedIndex < actions.length) {
                selectOption(actions[selectedIndex]);
            }
            event.accepted = true;
            break;
        case Qt.Key_N:
            if (event.modifiers & Qt.ControlModifier) {
                selectedIndex = (selectedIndex + 1) % optionCount;
                event.accepted = true;
            }
            break;
        case Qt.Key_P:
            if (event.modifiers & Qt.ControlModifier) {
                selectedIndex = (selectedIndex - 1 + optionCount) % optionCount;
                event.accepted = true;
            }
            break;
        case Qt.Key_J:
            if (event.modifiers & Qt.ControlModifier) {
                selectedIndex = (selectedIndex + 1) % optionCount;
                event.accepted = true;
            }
            break;
        case Qt.Key_K:
            if (event.modifiers & Qt.ControlModifier) {
                selectedIndex = (selectedIndex - 1 + optionCount) % optionCount;
                event.accepted = true;
            }
            break;
        }
    }

    content: Component {
        Item {
            anchors.fill: parent
            implicitHeight: mainColumn.implicitHeight + Theme.spacingL * 2

            Column {
                id: mainColumn
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                Row {
                    width: parent.width

                    StyledText {
                        text: "Параметры питания"
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item {
                        width: parent.width - 150
                        height: 1
                    }

                    DankActionButton {
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: () => {
                            return close();
                        }
                    }

                }

                Column {
                    width: parent.width
                    spacing: Theme.spacingS

                    Rectangle {
                        width: parent.width
                        height: 50
                        radius: Theme.cornerRadius
                        color: {
                            if (selectedIndex === 0) {
                                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12);
                            } else if (logoutArea.containsMouse) {
                                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08);
                            } else {
                                return Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.08);
                            }
                        }
                        border.color: selectedIndex === 0 ? Theme.primary : "transparent"
                        border.width: selectedIndex === 0 ? 1 : 0

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingM

                            DankIcon {
                                name: "logout"
                                size: Theme.iconSize
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: "Выход"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                        MouseArea {
                            id: logoutArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                selectedIndex = 0;
                                selectOption("logout");
                            }
                        }

                    }

                    Rectangle {
                        width: parent.width
                        height: 50
                        radius: Theme.cornerRadius
                        color: {
                            if (selectedIndex === 1) {
                                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12);
                            } else if (rebootArea.containsMouse) {
                                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08);
                            } else {
                                return Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.08);
                            }
                        }
                        border.color: selectedIndex === 1 ? Theme.primary : "transparent"
                        border.width: selectedIndex === 1 ? 1 : 0

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingM

                            DankIcon {
                                name: "restart_alt"
                                size: Theme.iconSize
                                color: rebootArea.containsMouse ? Theme.warning : Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: "Перезагрузка"
                                font.pixelSize: Theme.fontSizeMedium
                                color: rebootArea.containsMouse ? Theme.warning : Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                        MouseArea {
                            id: rebootArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                selectedIndex = 1;
                                selectOption("reboot");
                            }
                        }

                    }

                    Rectangle {
                        width: parent.width
                        height: 50
                        radius: Theme.cornerRadius
                        color: {
                            if (selectedIndex === 2) {
                                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12);
                            } else if (powerOffArea.containsMouse) {
                                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08);
                            } else {
                                return Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.08);
                            }
                        }
                        border.color: selectedIndex === 2 ? Theme.primary : "transparent"
                        border.width: selectedIndex === 2 ? 1 : 0

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingM

                            DankIcon {
                                name: "power_settings_new"
                                size: Theme.iconSize
                                color: powerOffArea.containsMouse ? Theme.error : Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: "Выключение"
                                font.pixelSize: Theme.fontSizeMedium
                                color: powerOffArea.containsMouse ? Theme.error : Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                        MouseArea {
                            id: powerOffArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: () => {
                                selectedIndex = 2;
                                selectOption("poweroff");
                            }
                        }

                    }

                }

                Item {
                    height: Theme.spacingS
                }

            }

        }

    }

}
