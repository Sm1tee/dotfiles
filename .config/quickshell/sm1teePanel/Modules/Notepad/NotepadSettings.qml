import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets

pragma ComponentBehavior: Bound

Item {
    id: root

    property bool isVisible: false
    property var cachedFontFamilies: []
    property var cachedMonoFamilies: []
    property bool fontsEnumerated: false

    signal settingsRequested()
    signal findRequested()

    function enumerateFonts() {
        var fonts = ["Default"]
        var availableFonts = Qt.fontFamilies()
        var rootFamilies = []
        var seenFamilies = new Set()
        for (var i = 0; i < availableFonts.length; i++) {
            var fontName = availableFonts[i]
            if (fontName.startsWith("."))
                continue

            if (fontName === SettingsData.defaultFontFamily)
                continue

            var rootName = fontName.replace(/ (Thin|Extra Light|Light|Regular|Medium|Semi Bold|Demi Bold|Bold|Extra Bold|Black|Heavy)$/i, "").replace(/ (Italic|Oblique|Condensed|Extended|Narrow|Wide)$/i,
                                                                                                                                                  "").replace(/ (UI|Display|Text|Mono|Sans|Serif)$/i, function (match, suffix) {
                                                                                                                                                      return match
                                                                                                                                                  }).trim()
            if (!seenFamilies.has(rootName) && rootName !== "") {
                seenFamilies.add(rootName)
                rootFamilies.push(rootName)
            }
        }
        cachedFontFamilies = fonts.concat(rootFamilies.sort())
        var monoFonts = ["Default"]
        var monoFamilies = []
        var seenMonoFamilies = new Set()
        for (var j = 0; j < availableFonts.length; j++) {
            var fontName2 = availableFonts[j]
            if (fontName2.startsWith("."))
                continue

            if (fontName2 === SettingsData.defaultMonoFontFamily)
                continue

            var lowerName = fontName2.toLowerCase()
            if (lowerName.includes("mono") || lowerName.includes("code") || lowerName.includes("console") || lowerName.includes("terminal") || lowerName.includes("courier") || lowerName.includes("dejavu sans mono") || lowerName.includes(
                        "jetbrains") || lowerName.includes("fira") || lowerName.includes("hack") || lowerName.includes("source code") || lowerName.includes("ubuntu mono") || lowerName.includes("cascadia")) {
                var rootName2 = fontName2.replace(/ (Thin|Extra Light|Light|Regular|Medium|Semi Bold|Demi Bold|Bold|Extra Bold|Black|Heavy)$/i, "").replace(/ (Italic|Oblique|Condensed|Extended|Narrow|Wide)$/i, "").trim()
                if (!seenMonoFamilies.has(rootName2) && rootName2 !== "") {
                    seenMonoFamilies.add(rootName2)
                    monoFamilies.push(rootName2)
                }
            }
        }
        cachedMonoFamilies = monoFonts.concat(monoFamilies.sort())
        fontsEnumerated = true
    }

    Component.onCompleted: {
        if (!fontsEnumerated) {
            enumerateFonts()
        }
    }

    MouseArea {
        anchors.fill: parent
        visible: root.isVisible
        onClicked: root.settingsRequested()
        z: 50
    }

    Rectangle {
        id: settingsMenu
        visible: root.isVisible
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 360
        height: settingsColumn.implicitHeight + Theme.spacingXL * 2
        radius: Theme.cornerRadius
        color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, Theme.notepadTransparency)
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1
        z: 100

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 2
            anchors.rightMargin: -2
            anchors.bottomMargin: -4
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.15)
            z: parent.z - 1
        }

        Column {
            id: settingsColumn
            width: parent.width - Theme.spacingXL * 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.spacingXL
            spacing: Theme.spacingS

            Rectangle {
                width: parent.width
                height: 36
                color: "transparent"

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: -Theme.spacingXS
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Настройки шрифта блокнота"
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
            }

            Toggle {
                anchors.left: parent.left
                anchors.leftMargin: -Theme.spacingM
                width: parent.width + Theme.spacingM
                text: "Моноширинный шрифт"
                description: "Переключить шрифты"
                checked: SettingsData.notepadUseMonospace
                onToggled: checked => {
                    SettingsData.notepadUseMonospace = checked
                }
            }

            Toggle {
                anchors.left: parent.left
                anchors.leftMargin: -Theme.spacingM
                width: parent.width + Theme.spacingM
                text: "Показывать номера строк"
                description: "Отображать номера строк в редакторе"
                checked: SettingsData.notepadShowLineNumbers
                onToggled: checked => {
                    SettingsData.notepadShowLineNumbers = checked
                }
            }

            StyledRect {
                width: parent.width
                height: 60
                radius: Theme.cornerRadius
                color: "transparent"

                StateLayer {
                    anchors.fill: parent
                    anchors.leftMargin: -Theme.spacingM
                    width: parent.width + Theme.spacingM
                    stateColor: Theme.primary
                    cornerRadius: parent.radius
                    onClicked: root.findRequested()
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: -Theme.spacingM
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingM
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingM

                    Icon {
                        name: "search"
                        size: Theme.iconSize - 2
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Найти в тексте"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        StyledText {
                            text: "Открыть панель поиска"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: visible ? (fontDropdown.height + Theme.spacingS) : 0
                color: "transparent"
                visible: !SettingsData.notepadUseMonospace

                Dropdown {
                    id: fontDropdown
                    anchors.left: parent.left 
                    anchors.leftMargin: -Theme.spacingM
                    width: parent.width + Theme.spacingM
                    text: "Семейство шрифтов"
                    options: cachedFontFamilies
                    currentValue: {
                        if (!SettingsData.notepadFontFamily || SettingsData.notepadFontFamily === "")
                            return "Default (Global)"
                        else
                            return SettingsData.notepadFontFamily
                    }
                    enableFuzzySearch: true
                    onValueChanged: value => {
                        if (value && (value.startsWith("Default") || value === "Default (Global)")) {
                            SettingsData.notepadFontFamily = ""
                        } else {
                            SettingsData.notepadFontFamily = value
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: fontSizeRow.height + Theme.spacingS
                color: "transparent"

                Row {
                    id: fontSizeRow
                    width: parent.width
                    spacing: Theme.spacingS

                    Column {
                        width: parent.width - fontSizeControls.width - Theme.spacingM
                        spacing: Theme.spacingXS

                        StyledText {
                            text: "Размер шрифта"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        StyledText {
                            text: SettingsData.notepadFontSize + "px"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            width: parent.width
                        }
                    }

                    Row {
                        id: fontSizeControls
                        spacing: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        ActionButton {
                            buttonSize: 32
                            iconName: "remove"
                            iconSize: Theme.iconSizeSmall
                            enabled: SettingsData.notepadFontSize > 8
                            backgroundColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)
                            iconColor: Theme.surfaceText
                            onClicked: {
                                var newSize = Math.max(8, SettingsData.notepadFontSize - 1)
                                SettingsData.notepadFontSize = newSize
                            }
                        }

                        Rectangle {
                            width: 60
                            height: 32
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.3)
                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            border.width: 1

                            StyledText {
                                anchors.centerIn: parent
                                text: SettingsData.notepadFontSize + "px"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }
                        }

                        ActionButton {
                            buttonSize: 32
                            iconName: "add"
                            iconSize: Theme.iconSizeSmall
                            enabled: SettingsData.notepadFontSize < 48
                            backgroundColor: Qt.rgba(Theme.surfaceVariant.r, Theme.surfaceVariant.g, Theme.surfaceVariant.b, 0.5)
                            iconColor: Theme.surfaceText
                            onClicked: {
                                var newSize = Math.min(48, SettingsData.notepadFontSize + 1)
                                SettingsData.notepadFontSize = newSize
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: transparencySliderColumn.height + Theme.spacingS
                color: "transparent"

                Column {
                    id: transparencySliderColumn
                    width: parent.width
                    spacing: Theme.spacingS

                    Toggle {
                        anchors.left: parent.left
                        anchors.leftMargin: -Theme.spacingM
                        width: parent.width + Theme.spacingM
                        text: "Своя прозрачность"
                        description: "Переопределить глобальную прозрачность для блокнота"
                        checked: SettingsData.notepadTransparencyOverride >= 0
                        onToggled: checked => {
                            if (checked) {
                                SettingsData.notepadTransparencyOverride = SettingsData.notepadLastCustomTransparency
                            } else {
                                SettingsData.notepadTransparencyOverride = -1
                            }
                        }
                    }

                    Slider {
                        anchors.left: parent.left
                        anchors.leftMargin: -Theme.spacingM
                        width: parent.width + Theme.spacingM
                        height: 24
                        visible: SettingsData.notepadTransparencyOverride >= 0
                        value: Math.round((SettingsData.notepadTransparencyOverride >= 0 ? SettingsData.notepadTransparencyOverride : SettingsData.popupTransparency) * 100)
                        minimum: 0
                        maximum: 100
                        unit: ""
                        showValue: true
                        wheelEnabled: false
                        onSliderValueChanged: newValue => {
                            if (SettingsData.notepadTransparencyOverride >= 0) {
                                SettingsData.notepadTransparencyOverride = newValue / 100
                            }
                        }
                    }
                }
            }

            StyledText {
                width: parent.width
                text: SettingsData.notepadUseMonospace ?
                    "Используется глобальный моноширинный шрифт из Настройки → Персонализация" :
                    "Глобальные шрифты можно настроить в Настройки → Персонализация"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceTextMedium
                wrapMode: Text.WordWrap
                opacity: 0.8
            }
        }
    }
}