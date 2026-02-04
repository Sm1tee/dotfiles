import QtQuick
import qs.Common
import qs.Widgets

StyledRect {
    width: parent.width
    height: scaleSection.implicitHeight + Theme.spacingL * 2
    radius: Theme.cornerRadius
    color: Theme.surfaceContainerHigh
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
    border.width: 0

    Column {
        id: scaleSection

        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        Item {
            width: parent.width
            height: Theme.iconSize

            Row {
                spacing: Theme.spacingM
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Icon {
                    name: "zoom_in"
                    size: Theme.iconSize
                    color: Theme.primary
                }

                StyledText {
                    text: "Масштаб интерфейса"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
            }

            ActionButton {
                id: resetScaleBtn
                buttonSize: Theme.iconSize
                iconName: "refresh"
                iconSize: Theme.iconSizeSmall
                backgroundColor: Theme.surfaceContainerHigh
                iconColor: Theme.surfaceText
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    scaleSlider.value = 100
                    SettingsData.setFontScale(1.0)
                }
            }
        }

        Column {
            width: parent.width
            spacing: Theme.spacingS

            Timer {
                id: scaleApplyTimer
                interval: 300
                repeat: false
                onTriggered: {
                    SettingsData.setFontScale(scaleSlider.value / 100)
                }
            }

            Slider {
                id: scaleSlider
                width: parent.width
                height: 24
                value: Math.round((SettingsData.fontScale * 100) / 5) * 5
                minimum: 100
                maximum: 150
                unit: "%"
                showValue: true
                wheelEnabled: false
                thumbOutlineColor: Theme.surfaceContainerHigh
                onSliderValueChanged: newValue => {
                    const roundedValue = Math.round(newValue / 5) * 5
                    if (scaleSlider.value !== roundedValue) {
                        scaleSlider.value = roundedValue
                    }
                    scaleApplyTimer.restart()
                }

                Binding {
                    target: scaleSlider
                    property: "value"
                    value: Math.round((SettingsData.fontScale * 100) / 5) * 5
                    restoreMode: Binding.RestoreBinding
                }
            }
        }
    }
}

