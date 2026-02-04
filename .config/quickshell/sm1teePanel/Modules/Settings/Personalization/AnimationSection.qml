import QtQuick
import qs.Common
import qs.Widgets

StyledRect {
    width: parent.width
    height: animationColumn.implicitHeight + Theme.spacingL * 2
    radius: Theme.cornerRadius
    color: Theme.surfaceContainerHigh
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
    border.width: 0

    Column {
        id: animationColumn

        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        Row {
            width: parent.width
            spacing: Theme.spacingM

            Icon {
                name: "animation"
                size: Theme.iconSize
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: "Скорость анимации"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Medium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ButtonGroup {
            id: animationSpeedGroup
            width: parent.width
            model: ["Нет", "Быстро", "Средне", "Медленно"]
            selectionMode: "single"
            fillWidth: true
            buttonPadding: Theme.spacingXS
            spacing: 2
            checkEnabled: false
            currentIndex: {
                if (SettingsData.animationSpeed === 0) return 0
                if (SettingsData.animationSpeed === 1) return 1
                if (SettingsData.animationSpeed === 2) return 1
                if (SettingsData.animationSpeed === 3) return 2
                return 3
            }
            onSelectionChanged: (index, selected) => {
                if (selected) {
                    const speedMap = [0, 2, 3, 4]
                    SettingsData.setAnimationSpeed(speedMap[index])
                }
            }
        }
    }
}
