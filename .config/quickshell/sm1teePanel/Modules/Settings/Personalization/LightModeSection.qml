import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

StyledRect {
    width: parent.width
    height: lightModeRow.implicitHeight + Theme.spacingL * 2
    radius: Theme.cornerRadius
    color: Theme.surfaceContainerHigh
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
    border.width: 0

    Row {
        id: lightModeRow

        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        Icon {
            name: "contrast"
            size: Theme.iconSize
            color: Theme.primary
            rotation: SessionData.isLightMode ? 180 : 0
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: parent.width - Theme.iconSize - Theme.spacingM - lightModeToggle.width - Theme.spacingM
            spacing: Theme.spacingXS
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                text: "Светлая тема"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            StyledText {
                text: "Использовать светлую тему вместо темной"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }

        Toggle {
            id: lightModeToggle

            anchors.verticalCenter: parent.verticalCenter
            checked: SessionData.isLightMode
            onToggleCompleted: checked => {
                Theme.screenTransition()
                Theme.setLightMode(checked)
            }
        }
    }
}
