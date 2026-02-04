import QtQuick
import qs.Common
import qs.Widgets

StyledRect {
    id: root
    
    property var cachedFontFamilies: []
    
    width: parent.width
    height: fontSettingsColumn.implicitHeight + Theme.spacingL * 2
    radius: Theme.cornerRadius
    color: Theme.surfaceContainerHigh
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
    border.width: 0

    Column {
        id: fontSettingsColumn

        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM

        Row {
            width: parent.width
            spacing: Theme.spacingM

            Icon {
                name: "font_download"
                size: Theme.iconSize
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: "Настройки шрифтов"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Medium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Dropdown {
            text: "Семейство шрифтов"
            description: "Выберите системное семейство шрифтов"
            currentValue: {
                if (SettingsData.fontFamily === SettingsData.defaultFontFamily)
                    return "Default"
                else
                    return SettingsData.fontFamily || "Default"
            }
            enableFuzzySearch: true
            popupWidthOffset: 100
            maxPopupHeight: 400
            options: root.cachedFontFamilies
            onValueChanged: value => {
                if (value.startsWith("Default"))
                    SettingsData.setFontFamily(SettingsData.defaultFontFamily)
                else
                    SettingsData.setFontFamily(value)
            }
        }

        Dropdown {
            text: "Насыщенность шрифта"
            description: "Выберите насыщенность шрифта"
            currentValue: {
                switch (SettingsData.fontWeight) {
                case Font.Thin: return "Тонкий"
                case Font.ExtraLight: return "Сверхлегкий"
                case Font.Light: return "Легкий"
                case Font.Normal: return "Обычный"
                case Font.Medium: return "Средний"
                case Font.DemiBold: return "Полужирный"
                case Font.Bold: return "Жирный"
                case Font.ExtraBold: return "Сверхжирный"
                case Font.Black: return "Черный"
                default: return "Обычный"
                }
            }
            options: ["Тонкий", "Сверхлегкий", "Легкий", "Обычный", "Средний", "Полужирный", "Жирный", "Сверхжирный", "Черный"]
            onValueChanged: value => {
                var weight
                switch (value) {
                    case "Тонкий": weight = Font.Thin; break
                    case "Сверхлегкий": weight = Font.ExtraLight; break
                    case "Легкий": weight = Font.Light; break
                    case "Обычный": weight = Font.Normal; break
                    case "Средний": weight = Font.Medium; break
                    case "Полужирный": weight = Font.DemiBold; break
                    case "Жирный": weight = Font.Bold; break
                    case "Сверхжирный": weight = Font.ExtraBold; break
                    case "Черный": weight = Font.Black; break
                    default: weight = Font.Normal; break
                }
                SettingsData.setFontWeight(weight)
            }
        }

        Dropdown {
            text: "Моноширинный шрифт"
            description: "Выберите моноширинный шрифт для списка процессов"
            currentValue: {
                if (SettingsData.monoFontFamily === SettingsData.defaultMonoFontFamily)
                    return "Default"
                return SettingsData.monoFontFamily || "Default"
            }
            enableFuzzySearch: true
            popupWidthOffset: 100
            maxPopupHeight: 400
            options: root.cachedFontFamilies
            onValueChanged: value => {
                if (value === "Default")
                    SettingsData.setMonoFontFamily(SettingsData.defaultMonoFontFamily)
                else
                    SettingsData.setMonoFontFamily(value)
            }
        }
    }
}
