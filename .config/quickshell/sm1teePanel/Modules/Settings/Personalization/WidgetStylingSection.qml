import QtQuick
import qs.Common
import qs.Widgets

// Widget Styling Section
StyledRect {
    width: parent.width
    height: widgetStylingSection.implicitHeight + Theme.spacingL * 2
    radius: Theme.cornerRadius
    color: Theme.surfaceContainerHigh
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
    border.width: 0

    Column {
        id: widgetStylingSection

        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        Row {
            width: parent.width
            spacing: Theme.spacingM

            Icon {
                name: "opacity"
                size: Theme.iconSize
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: "Стилизация виджетов"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Medium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Column {
            width: parent.width
            spacing: Theme.spacingS

            Dropdown {
                id: widgetColorDropdown
                text: "Яркость фона виджетов"
                description: "Выберите оттенок из палитры темы"
                width: parent.width
                options: ["Темный", "Средний", "Светлый"]
                currentValue: {
                    switch (SettingsData.widgetBackgroundColor) {
                        case "s": return "Темный"
                        case "sc": return "Средний"
                        case "sch": return "Светлый"
                        case "sth": return "Средний"
                        default: return "Светлый"
                    }
                }
                onValueChanged: value => {
                    const colorMap = {
                        "Темный": "s",
                        "Средний": "sc",
                        "Светлый": "sch"
                    }
                    SettingsData.setWidgetBackgroundColor(colorMap[value])
                }
            }
        }

        Column {
            width: parent.width
            spacing: Theme.spacingS

            StyledText {
                text: "Прозрачность панели"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                font.weight: Font.Medium
            }

            Slider {
                width: parent.width
                height: 24
                value: Math.round(SettingsData.barTransparency * 100)
                minimum: 0
                maximum: 100
                unit: ""
                showValue: true
                wheelEnabled: false
                thumbOutlineColor: Theme.surfaceContainerHigh
                onSliderValueChanged: newValue => {
                    SettingsData.setBarTransparency(newValue / 100)
                }
            }
        }

        Column {
            width: parent.width
            spacing: Theme.spacingS

            StyledText {
                text: "Прозрачность фона виджетов"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                font.weight: Font.Medium
            }

            Slider {
                width: parent.width
                height: 24
                value: Math.round(SettingsData.barWidgetTransparency * 100)
                minimum: 0
                maximum: 100
                unit: ""
                showValue: true
                wheelEnabled: false
                thumbOutlineColor: Theme.surfaceContainerHigh
                onSliderValueChanged: newValue => {
                    SettingsData.setBarWidgetTransparency(newValue / 100)
                }
            }
        }

        Column {
            width: parent.width
            spacing: Theme.spacingS

            StyledText {
                text: "Прозрачность всплывающих окон"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                font.weight: Font.Medium
            }

            Slider {
                width: parent.width
                height: 24
                value: Math.round(SettingsData.popupTransparency * 100)
                minimum: 0
                maximum: 100
                unit: ""
                showValue: true
                wheelEnabled: false
                thumbOutlineColor: Theme.surfaceContainerHigh
                onSliderValueChanged: newValue => {
                    SettingsData.setPopupTransparency(newValue / 100)
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.outline
            opacity: 0.2
        }

        Column {
            width: parent.width
            spacing: Theme.spacingS

            StyledText {
                text: "Радиус углов (0 = квадратные углы)"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                font.weight: Font.Medium
            }

            Slider {
                width: parent.width
                height: 24
                value: SettingsData.cornerRadius
                minimum: 0
                maximum: 32
                unit: ""
                showValue: true
                wheelEnabled: false
                thumbOutlineColor: Theme.surfaceContainerHigh
                onSliderValueChanged: newValue => {
                    SettingsData.setCornerRadius(newValue)
                }
            }
        }
    }
}

