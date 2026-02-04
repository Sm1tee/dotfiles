import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Row {
    id: root

    property var availableWidgets: []
    property Item popoutContent: null

    signal addWidget(string widgetId)
    signal resetToDefault()
    signal clearAll()

    height: 48
    spacing: Theme.spacingS

    onAddWidget: addWidgetPopup.close()

    Popup {
        id: addWidgetPopup
        parent: popoutContent
        x: parent ? Math.round((parent.width - width) / 2) : 0
        y: parent ? parent.height + Theme.spacingM : 0
        width: 400
        height: Math.min(450, root.availableWidgets.length * 80 + 80)
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Theme.surfaceContainer
            border.color: Theme.primarySelected
            border.width: 0
            radius: Theme.cornerRadius
        }

        contentItem: Item {
            anchors.fill: parent
            anchors.margins: Theme.spacingL

            Row {
                id: headerRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Theme.spacingM

                Icon {
                    name: "add_circle"
                    size: Theme.iconSize
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Typography {
                    text: "Добавить виджет"
                    style: Typography.Style.Subtitle
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ListView {
                anchors.top: headerRow.bottom
                anchors.topMargin: Theme.spacingM
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: Theme.spacingS
                clip: true
                model: root.availableWidgets

                delegate: Rectangle {
                    width: 400 - Theme.spacingL * 2
                    height: Math.max(60, contentColumn.implicitHeight + Theme.spacingM * 2)
                    radius: Theme.cornerRadius
                    color: widgetMouseArea.containsMouse ? Theme.primaryHover : Theme.surfaceContainerHigh
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                    border.width: 0

                    Row {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingM

                        Icon {
                            name: modelData.icon
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            id: contentColumn
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - Theme.iconSize * 2 - Theme.spacingM * 2

                            Typography {
                                text: modelData.text
                                style: Typography.Style.Body
                                color: Theme.surfaceText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                            Typography {
                                text: modelData.description
                                style: Typography.Style.Caption
                                color: Theme.outline
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        Icon {
                            name: "add"
                            size: Theme.iconSize - 4
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: widgetMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.addWidget(modelData.id)
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        width: (parent.width - Theme.spacingS * 2) / 3
        height: 48
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
        border.color: Theme.primary
        border.width: 0

        Row {
            anchors.centerIn: parent
            spacing: Theme.spacingS

            Icon {
                name: "add"
                size: Theme.iconSize - 2
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            Typography {
                text: "Добавить виджет"
                style: Typography.Style.Button
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: addWidgetPopup.open()
        }
    }

    Rectangle {
        width: (parent.width - Theme.spacingS * 2) / 3
        height: 48
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.12)
        border.color: Theme.warning
        border.width: 0

        Row {
            anchors.centerIn: parent
            spacing: Theme.spacingS

            Icon {
                name: "settings_backup_restore"
                size: Theme.iconSize - 2
                color: Theme.warning
                anchors.verticalCenter: parent.verticalCenter
            }

            Typography {
                text: "По умолчанию"
                style: Typography.Style.Button
                color: Theme.warning
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.resetToDefault()
        }
    }

    Rectangle {
        width: (parent.width - Theme.spacingS * 2) / 3
        height: 48
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12)
        border.color: Theme.error
        border.width: 0

        Row {
            anchors.centerIn: parent
            spacing: Theme.spacingS

            Icon {
                name: "clear_all"
                size: Theme.iconSize - 2
                color: Theme.error
                anchors.verticalCenter: parent.verticalCenter
            }

            Typography {
                text: "Очистить"
                style: Typography.Style.Button
                color: Theme.error
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clearAll()
        }
    }
}