import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import qs.Common
import qs.Modals
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

Item {
    id: personalizationTab

    property var wallpaperBrowser: wallpaperBrowserLoader.item
    property var parentModal: null
    property var cachedFontFamilies: []
    property bool fontsEnumerated: false
    property string selectedMonitorName: {
        var screens = Quickshell.screens
        return screens.length > 0 ? screens[0].name : ""
    }

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
    }

    Timer {
        id: fontEnumerationTimer
        interval: 50
        running: false
        onTriggered: {
            if (!fontsEnumerated) {
                enumerateFonts()
                fontsEnumerated = true
            }
        }
    }

    Component.onCompleted: {
        WallpaperCyclingService.cyclingActive
        fontEnumerationTimer.start()
    }

    Flickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL

            // Interface Scale
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

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "zoom_in"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Масштаб интерфейса"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
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

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Масштаб интерфейса"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item {
                                width: parent.width - scaleText.implicitWidth - resetScaleBtn.width - Theme.spacingS - Theme.spacingM
                                height: 1

                                StyledText {
                                    id: scaleText
                                    visible: false
                                    text: "Масштаб интерфейса"
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }

                            ActionButton {
                                id: resetScaleBtn
                                buttonSize: 20
                                iconName: "refresh"
                                iconSize: Theme.fontSizeSmall
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    scaleSlider.value = 100
                                    SettingsData.setFontScale(1.0)
                                }
                            }

                            Item {
                                width: Theme.spacingS
                                height: 1
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

            // Animation Settings
            StyledRect {
                width: parent.width
                height: animationSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: animationSection

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
                                // Маппинг старых значений на новые
                                if (SettingsData.animationSpeed === 0) return 0 // Нет
                                if (SettingsData.animationSpeed === 1) return 1 // Макс -> Быстро
                                if (SettingsData.animationSpeed === 2) return 1 // Быстро
                                if (SettingsData.animationSpeed === 3) return 2 // Средне
                                return 3 // Медленно
                            }
                            onSelectionChanged: (index, selected) => {
                                if (selected) {
                                    // Маппинг новых значений на индексы длительностей
                                    const speedMap = [0, 2, 3, 4] // Нет, Быстро, Средне, Медленно
                                    SettingsData.setAnimationSpeed(speedMap[index])
                                }
                            }
                        }
                    }
                }

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



            // Theme Color Section
            StyledRect {
                width: parent.width
                height: themeColorSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: themeColorSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "palette"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Цвет темы"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: parent.width - parent.children[0].width - parent.children[1].width - surfaceBaseGroup.width - Theme.spacingM * 3
                            height: 1
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            ButtonGroup {
                                id: surfaceBaseGroup
                                property int currentSurfaceIndex: {
                                    switch (SettingsData.surfaceBase) {
                                        case "sc": return 0
                                        case "s": return 1
                                        default: return 0
                                    }
                                }

                                model: ["Стандартный", "Темнее"]
                                currentIndex: currentSurfaceIndex
                                selectionMode: "single"
                                checkEnabled: false

                                buttonHeight: 32
                                buttonPadding: Theme.spacingM
                                textSize: Theme.fontSizeSmall
                                spacing: 2

                                onSelectionChanged: (index, selected) => {
                                    if (!selected) return
                                    const surfaceOptions = ["sc", "s"]
                                    SettingsData.setSurfaceBase(surfaceOptions[index])
                                }
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: Theme.spacingM
                    }

                    Item {
                        width: parent.width
                        height: childrenRect.height

                        ButtonGroup {
                            id: themeButtonGroup
                            checkEnabled: false
                            
                            property int currentThemeIndex: {
                                if (Theme.currentTheme === Theme.dynamic) return 2
                                if (Theme.currentThemeName === "custom") return 3
                                if (Theme.currentThemeCategory === "catppuccin") return 1
                                return 0
                            }
                            property int pendingThemeIndex: -1
                            property int selectedThemeIndex: {
                                if (Theme.currentTheme === Theme.dynamic) return 2
                                if (Theme.currentThemeName === "custom") return 3
                                if (Theme.currentThemeCategory === "catppuccin") return 1
                                return 0
                            }
                            
                            Component.onCompleted: {
                                selectedThemeIndex = currentThemeIndex
                            }
                            
                            onCurrentThemeIndexChanged: {
                                if (pendingThemeIndex === -1) {
                                    selectedThemeIndex = currentThemeIndex
                                }
                            }

                            width: parent.width
                            model: ["Готовые", "Catppuccin", "Из обоев", "Своя"]
                            currentIndex: currentThemeIndex
                            selectionMode: "single"
                            fillWidth: true
                            buttonPadding: Theme.spacingXS
                            spacing: 2
                            onSelectionChanged: (index, selected) => {
                                if (!selected) return
                                pendingThemeIndex = index
                                selectedThemeIndex = index
                            }
                            onAnimationCompleted: {
                                if (pendingThemeIndex === -1) return
                                switch (pendingThemeIndex) {
                                    case 0: Theme.switchThemeCategory("generic", "blue"); break
                                    case 1: Theme.switchThemeCategory("catppuccin", "cat-mauve"); break
                                    case 2:
                                        if (ToastService.wallpaperErrorStatus === "matugen_missing")
                                            ToastService.showError("matugen not found - install matugen package for dynamic theming")
                                        else if (ToastService.wallpaperErrorStatus === "error")
                                            ToastService.showError("Wallpaper processing failed - check wallpaper path")
                                        else
                                            Theme.switchTheme(Theme.dynamic, true, true)
                                        break
                                    case 3:
                                        if (Theme.currentThemeName !== "custom") {
                                            Theme.switchTheme("custom", true, true)
                                        }
                                        break
                                }
                                pendingThemeIndex = -1
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingM
                        anchors.horizontalCenter: parent.horizontalCenter

                        Column {
                            spacing: Theme.spacingS
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: Theme.currentThemeCategory === "generic" && Theme.currentTheme !== Theme.dynamic && Theme.currentThemeName !== "custom"

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: ["blue", "purple", "green", "orange", "red"]

                                    Rectangle {
                                        property string themeName: modelData
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Theme.getThemeColors(themeName).primary
                                        border.color: Theme.outline
                                        border.width: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 2 : 1
                                        scale: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 1.1 : 1

                                        Rectangle {
                                            width: nameText.contentWidth + Theme.spacingS * 2
                                            height: nameText.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 0
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseArea.containsMouse

                                            StyledText {
                                                id: nameText
                                                text: Theme.getThemeColors(themeName).name
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.switchTheme(themeName)
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: ["cyan", "pink", "amber", "coral", "monochrome"]

                                    Rectangle {
                                        property string themeName: modelData
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Theme.getThemeColors(themeName).primary
                                        border.color: Theme.outline
                                        border.width: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 2 : 1
                                        scale: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 1.1 : 1

                                        Rectangle {
                                            width: nameText2.contentWidth + Theme.spacingS * 2
                                            height: nameText2.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 0
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseArea2.containsMouse

                                            StyledText {
                                                id: nameText2
                                                text: Theme.getThemeColors(themeName).name
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseArea2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.switchTheme(themeName)
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            spacing: Theme.spacingS
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: Theme.currentThemeCategory === "catppuccin" && Theme.currentTheme !== Theme.dynamic && Theme.currentThemeName !== "custom"

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: ["cat-rosewater", "cat-flamingo", "cat-pink", "cat-mauve", "cat-red", "cat-maroon", "cat-peach"]

                                    Rectangle {
                                        property string themeName: modelData
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Theme.getCatppuccinColor(themeName)
                                        border.color: Theme.outline
                                        border.width: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 2 : 1
                                        scale: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 1.1 : 1

                                        Rectangle {
                                            width: nameTextCat.contentWidth + Theme.spacingS * 2
                                            height: nameTextCat.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 0
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseAreaCat.containsMouse

                                            StyledText {
                                                id: nameTextCat
                                                text: Theme.getCatppuccinVariantName(themeName)
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseAreaCat
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.switchTheme(themeName)
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }

                            Row {
                                spacing: Theme.spacingM
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: ["cat-yellow", "cat-green", "cat-teal", "cat-sky", "cat-sapphire", "cat-blue", "cat-lavender"]

                                    Rectangle {
                                        property string themeName: modelData
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Theme.getCatppuccinColor(themeName)
                                        border.color: Theme.outline
                                        border.width: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 2 : 1
                                        scale: (Theme.currentThemeName === themeName && Theme.currentTheme !== Theme.dynamic) ? 1.1 : 1

                                        Rectangle {
                                            width: nameTextCat2.contentWidth + Theme.spacingS * 2
                                            height: nameTextCat2.contentHeight + Theme.spacingXS * 2
                                            color: Theme.surfaceContainer
                                            border.color: Theme.outline
                                            border.width: 0
                                            radius: Theme.cornerRadius
                                            anchors.bottom: parent.top
                                            anchors.bottomMargin: Theme.spacingXS
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            visible: mouseAreaCat2.containsMouse

                                            StyledText {
                                                id: nameTextCat2
                                                text: Theme.getCatppuccinVariantName(themeName)
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceText
                                                anchors.centerIn: parent
                                            }
                                        }

                                        MouseArea {
                                            id: mouseAreaCat2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.switchTheme(themeName)
                                            }
                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }

                                        Behavior on border.width {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.emphasizedEasing
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            id: dynamicThemeSettings
                            width: parent.width
                            spacing: Theme.spacingM
                            visible: themeButtonGroup.selectedThemeIndex === 2

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                Row {
                                    width: parent.width
                                    spacing: Theme.spacingXS

                                    Dropdown {
                                        id: matugenPaletteDropdown
                                        text: "Палитра"
                                        description: ""
                                        width: parent.width - infoButton.width - parent.spacing
                                        options: ["Тональная", "Контентная", "Выразительная", "Монохромная", "Нейтральная", "Многоцветная", "Радужная", "Точная"]
                                        currentValue: Theme.getMatugenScheme(SettingsData.matugenScheme).label
                                        enabled: Theme.matugenAvailable
                                        onValueChanged: value => {
                                            const schemeMap = {
                                                "Тональная": "scheme-tonal-spot",
                                                "Контентная": "scheme-content",
                                                "Выразительная": "scheme-expressive",
                                                "Монохромная": "scheme-monochrome",
                                                "Нейтральная": "scheme-neutral",
                                                "Многоцветная": "scheme-fruit-salad",
                                                "Радужная": "scheme-rainbow",
                                                "Точная": "scheme-fidelity"
                                            }
                                            SettingsData.setMatugenScheme(schemeMap[value])
                                        }
                                    }

                                    ActionButton {
                                        id: infoButton
                                        iconName: showSchemeInfo ? "expand_less" : "info"
                                        iconColor: showSchemeInfo ? Theme.primary : Theme.surfaceText
                                        buttonSize: 32
                                        anchors.verticalCenter: matugenPaletteDropdown.verticalCenter
                                        enabled: Theme.matugenAvailable

                                        property bool showSchemeInfo: false

                                        onClicked: {
                                            showSchemeInfo = !showSchemeInfo
                                        }
                                    }
                                }

                                StyledRect {
                                    width: parent.width
                                    height: infoButton.showSchemeInfo ? (schemeInfoContent.height + Theme.spacingM * 2) : 0
                                    radius: Theme.cornerRadius
                                    color: Theme.surfaceContainerHigh
                                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
                                    border.width: 1
                                    visible: height > 0
                                    clip: true

                                    Behavior on height {
                                        NumberAnimation {
                                            duration: Theme.mediumDuration
                                            easing.type: Theme.emphasizedEasing
                                        }
                                    }

                                    Column {
                                        id: schemeInfoContent
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.margins: Theme.spacingM
                                        spacing: Theme.spacingS
                                        opacity: infoButton.showSchemeInfo ? 1 : 0

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: Theme.shortDuration
                                                easing.type: Theme.standardEasing
                                            }
                                        }

                                        StyledText {
                                            text: "Все доступные схемы:"
                                            font.pixelSize: Theme.fontSizeSmall
                                            font.weight: Font.Medium
                                            color: Theme.surfaceText
                                        }

                                        Repeater {
                                            model: Theme.availableMatugenSchemes

                                            Column {
                                                width: parent.width
                                                spacing: 2

                                                Row {
                                                    spacing: Theme.spacingXS
                                                    width: parent.width

                                                    StyledText {
                                                        text: SettingsData.matugenScheme === modelData.value ? "▸" : "•"
                                                        font.pixelSize: Theme.fontSizeMedium
                                                        color: SettingsData.matugenScheme === modelData.value ? Theme.primary : Theme.surfaceVariantText
                                                        font.weight: Font.Bold
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }

                                                    StyledText {
                                                        text: modelData.label
                                                        font.pixelSize: Theme.fontSizeMedium
                                                        font.weight: SettingsData.matugenScheme === modelData.value ? Font.Medium : Font.Normal
                                                        color: SettingsData.matugenScheme === modelData.value ? Theme.primary : Theme.surfaceText
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }

                                                StyledText {
                                                    text: modelData.description
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    color: Theme.surfaceVariantText
                                                    wrapMode: Text.WordWrap
                                                    width: parent.width
                                                    leftPadding: Theme.spacingM
                                                }

                                                Item { width: 1; height: Theme.spacingXS }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.outline
                                opacity: 0.2
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                Icon {
                                    name: "code"
                                    size: Theme.iconSize
                                    color: SettingsData.runUserMatugenTemplates ? Theme.primary : Theme.surfaceVariantText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width - Theme.iconSize - Theme.spacingM - runUserTemplatesToggle.width - Theme.spacingM
                                    spacing: Theme.spacingXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        text: "Запускать пользовательские шаблоны"
                                        font.pixelSize: Theme.fontSizeMedium
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: "Выполнять шаблоны из ~/.config/matugen/config.toml"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }
                                }

                                Toggle {
                                    id: runUserTemplatesToggle

                                    anchors.verticalCenter: parent.verticalCenter
                                    checked: SettingsData.runUserMatugenTemplates
                                    enabled: Theme.matugenAvailable
                                    onToggled: checked => {
                                        SettingsData.setRunUserMatugenTemplates(checked)
                                    }
                                }
                            }

                            StyledText {
                                text: "matugen не обнаружен - динамическая тема недоступна"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.error
                                visible: ToastService.wallpaperErrorStatus === "matugen_missing"
                                width: parent.width
                            }
                        }

                        Column {
                            id: customThemeSettings
                            width: parent.width
                            spacing: Theme.spacingM
                            visible: themeButtonGroup.selectedThemeIndex === 3

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                ActionButton {
                                    buttonSize: 48
                                    iconName: "folder_open"
                                    iconSize: Theme.iconSize
                                    backgroundColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                                    iconColor: Theme.primary
                                    onClicked: customThemeFileBrowserModal.open()
                                }

                                Column {
                                    width: parent.width - 48 - Theme.spacingM
                                    spacing: Theme.spacingXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        text: SettingsData.customThemeFile ? SettingsData.customThemeFile.split('/').pop() : "Нет файла пользовательской темы"
                                        font.pixelSize: Theme.fontSizeLarge
                                        color: Theme.surfaceText
                                        elide: Text.ElideMiddle
                                        maximumLineCount: 1
                                        width: parent.width
                                    }

                                    StyledText {
                                        text: SettingsData.customThemeFile || "Нажмите, чтобы выбрать JSON файл пользовательской темы"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        elide: Text.ElideMiddle
                                        maximumLineCount: 1
                                        width: parent.width
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Wallpaper Section
            StyledRect {
                width: parent.width
                height: wallpaperSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: wallpaperSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "wallpaper"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Обои"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingL

                        StyledRect {
                            width: 160
                            height: 90
                            radius: Theme.cornerRadius
                            color: Theme.surfaceVariant
                            border.color: Theme.outline
                            border.width: 0

                            CachingImage {
                                anchors.fill: parent
                                anchors.margins: 1
                                property var weExtensions: [".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp", ".tga"]
                                property int weExtIndex: 0
                                source: {
                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                    if (currentWallpaper && currentWallpaper.startsWith("we:")) {
                                        var sceneId = currentWallpaper.substring(3)
                                        return StandardPaths.writableLocation(StandardPaths.HomeLocation)
                                            + "/.local/share/Steam/steamapps/workshop/content/431960/"
                                            + sceneId + "/preview" + weExtensions[weExtIndex]
                                    }
                                    return (currentWallpaper !== "" && !currentWallpaper.startsWith("#")) ? "file://" + currentWallpaper : ""
                                }
                                onStatusChanged: {
                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                    if (currentWallpaper && currentWallpaper.startsWith("we:") && status === Image.Error) {
                                        if (weExtIndex < weExtensions.length - 1) {
                                            weExtIndex++
                                            source = StandardPaths.writableLocation(StandardPaths.HomeLocation)
                                                + "/.local/share/Steam/steamapps/workshop/content/431960/"
                                                + currentWallpaper.substring(3)
                                                + "/preview" + weExtensions[weExtIndex]
                                        } else {
                                            visible = false
                                        }
                                    }
                                }
                                fillMode: Image.PreserveAspectCrop
                                visible: {
                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                    return currentWallpaper !== "" && !currentWallpaper.startsWith("#")
                                }
                                maxCacheSize: 160
                                layer.enabled: true

                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: wallpaperMask
                                    maskThresholdMin: 0.5
                                    maskSpreadAtMin: 1
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: Theme.cornerRadius - 1
                                color: {
                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                    return currentWallpaper.startsWith("#") ? currentWallpaper : "transparent"
                                }
                                visible: {
                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                    return currentWallpaper !== "" && currentWallpaper.startsWith("#")
                                }
                            }

                            Rectangle {
                                id: wallpaperMask

                                anchors.fill: parent
                                anchors.margins: 1
                                radius: Theme.cornerRadius - 1
                                color: "black"
                                visible: false
                                layer.enabled: true
                            }

                            Icon {
                                anchors.centerIn: parent
                                name: "image"
                                size: Theme.iconSizeLarge + 8
                                color: Theme.surfaceVariantText
                                visible: {
                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                    return currentWallpaper === ""
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: Theme.cornerRadius - 1
                                color: Qt.rgba(0, 0, 0, 0.7)
                                visible: wallpaperMouseArea.containsMouse

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Qt.rgba(255, 255, 255, 0.9)

                                        Icon {
                                            anchors.centerIn: parent
                                            name: "folder_open"
                                            size: 18
                                            color: "black"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                wallpaperBrowserLoader.active = true
                                            }
                                        }
                                    }


                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Qt.rgba(255, 255, 255, 0.9)

                                        Icon {
                                            anchors.centerIn: parent
                                            name: "palette"
                                            size: 18
                                            color: "black"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (PopoutService.colorPickerModal) {
                                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                                    PopoutService.colorPickerModal.selectedColor = currentWallpaper.startsWith("#") ? currentWallpaper : Theme.primary
                                                    PopoutService.colorPickerModal.pickerTitle = "Choose Wallpaper Color"
                                                    PopoutService.colorPickerModal.onColorSelectedCallback = function(selectedColor) {
                                                        if (SessionData.perMonitorWallpaper) {
                                                            SessionData.setMonitorWallpaper(selectedMonitorName, selectedColor)
                                                        } else {
                                                            SessionData.setWallpaperColor(selectedColor)
                                                        }
                                                    }
                                                    PopoutService.colorPickerModal.show()
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Qt.rgba(255, 255, 255, 0.9)
                                        visible: {
                                            var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                            return currentWallpaper !== ""
                                        }

                                        Icon {
                                            anchors.centerIn: parent
                                            name: "clear"
                                            size: 18
                                            color: "black"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (SessionData.perMonitorWallpaper) {
                                                    SessionData.setMonitorWallpaper(selectedMonitorName, "")
                                                } else {
                                                    if (Theme.currentTheme === Theme.dynamic)
                                                        Theme.switchTheme("blue")
                                                    SessionData.clearWallpaper()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: wallpaperMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                propagateComposedEvents: true
                                acceptedButtons: Qt.NoButton
                            }
                        }

                        Column {
                            width: parent.width - 160 - Theme.spacingL
                            spacing: Theme.spacingS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: {
                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                    return currentWallpaper ? currentWallpaper.split('/').pop() : "No wallpaper selected"
                                }
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                elide: Text.ElideMiddle
                                maximumLineCount: 1
                                width: parent.width
                            }

                            StyledText {
                                text: {
                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                    return currentWallpaper ? currentWallpaper : ""
                                }
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                elide: Text.ElideMiddle
                                maximumLineCount: 1
                                width: parent.width
                                visible: {
                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                    return currentWallpaper !== ""
                                }
                            }

                            Row {
                                spacing: Theme.spacingS
                                visible: {
                                    var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                    return currentWallpaper !== ""
                                }

                                ActionButton {
                                    buttonSize: 32
                                    iconName: "skip_previous"
                                    iconSize: Theme.iconSizeSmall
                                    enabled: {
                                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                        return currentWallpaper && !currentWallpaper.startsWith("#") && !currentWallpaper.startsWith("we")
                                    }
                                    opacity: {
                                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                        return (currentWallpaper && !currentWallpaper.startsWith("#") && !currentWallpaper.startsWith("we")) ? 1 : 0.5
                                    }
                                    backgroundColor: Theme.surfaceContainerHigh
                                    iconColor: Theme.surfaceText
                                    onClicked: {
                                        if (SessionData.perMonitorWallpaper) {
                                            WallpaperCyclingService.cyclePrevForMonitor(selectedMonitorName)
                                        } else {
                                            WallpaperCyclingService.cyclePrevManually()
                                        }
                                    }
                                }

                                ActionButton {
                                    buttonSize: 32
                                    iconName: "skip_next"
                                    iconSize: Theme.iconSizeSmall
                                    enabled: {
                                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                        return currentWallpaper && !currentWallpaper.startsWith("#") && !currentWallpaper.startsWith("we")
                                    }
                                    opacity: {
                                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(selectedMonitorName) : SessionData.wallpaperPath
                                        return (currentWallpaper && !currentWallpaper.startsWith("#") && !currentWallpaper.startsWith("we")) ? 1 : 0.5
                                    }
                                    backgroundColor: Theme.surfaceContainerHigh
                                    iconColor: Theme.surfaceText
                                    onClicked: {
                                        if (SessionData.perMonitorWallpaper) {
                                            WallpaperCyclingService.cycleNextForMonitor(selectedMonitorName)
                                        } else {
                                            WallpaperCyclingService.cycleNextManually()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Per-Mode Wallpaper Section - Full Width
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                        visible: SessionData.wallpaperPath !== ""
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingM
                        visible: SessionData.wallpaperPath !== ""

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            Icon {
                                name: "brightness_6"
                                size: Theme.iconSize
                                color: SessionData.perModeWallpaper ? Theme.primary : Theme.surfaceVariantText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                width: parent.width - Theme.iconSize - Theme.spacingM - perModeToggle.width - Theme.spacingM
                                spacing: Theme.spacingXS
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    text: "Менять обои под тему"
                                    font.pixelSize: Theme.fontSizeLarge
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                StyledText {
                                    text: "Разные обои для светлой и темной темы"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                }
                            }

                            Toggle {
                                id: perModeToggle

                                anchors.verticalCenter: parent.verticalCenter
                                checked: SessionData.perModeWallpaper
                                onToggled: toggled => {
                                               return SessionData.setPerModeWallpaper(toggled)
                                           }
                            }
                        }
                    }

                    // Per-Monitor Wallpaper Section - Full Width
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                        visible: SessionData.wallpaperPath !== ""
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingM
                        visible: SessionData.wallpaperPath !== ""

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            Icon {
                                name: "monitor"
                                size: Theme.iconSize
                                color: SessionData.perMonitorWallpaper ? Theme.primary : Theme.surfaceVariantText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                width: parent.width - Theme.iconSize - Theme.spacingM - perMonitorToggle.width - Theme.spacingM
                                spacing: Theme.spacingXS
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    text: "Обои для разных мониторов"
                                    font.pixelSize: Theme.fontSizeLarge
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                StyledText {
                                    text: "Разные обои для каждого подключенного монитора"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                }
                            }

                            Toggle {
                                id: perMonitorToggle

                                anchors.verticalCenter: parent.verticalCenter
                                checked: SessionData.perMonitorWallpaper
                                onToggled: toggled => {
                                               return SessionData.setPerMonitorWallpaper(toggled)
                                           }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS
                            visible: SessionData.perMonitorWallpaper
                            leftPadding: Theme.iconSize + Theme.spacingM
                            rightPadding: Theme.spacingM

                            StyledText {
                                text: "Выбор монитора:"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            Dropdown {
                                id: monitorDropdown

                                width: parent.width - parent.leftPadding - parent.rightPadding
                                text: "Монитор"
                                description: "Выберите монитор для настройки обоев"
                                currentValue: selectedMonitorName || "No monitors"
                                dropdownWidth: 150
                                options: {
                                    var screenNames = []
                                    var screens = Quickshell.screens
                                    for (var i = 0; i < screens.length; i++) {
                                        screenNames.push(screens[i].name)
                                    }
                                    return screenNames
                                }
                                onValueChanged: value => {
                                                    selectedMonitorName = value
                                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                        visible: (SessionData.wallpaperPath !== "" || SessionData.perMonitorWallpaper) && !SessionData.perModeWallpaper
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingM
                        visible: (SessionData.wallpaperPath !== "" || SessionData.perMonitorWallpaper) && !SessionData.perModeWallpaper

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            Icon {
                                name: "schedule"
                                size: Theme.iconSize
                                color: SessionData.wallpaperCyclingEnabled ? Theme.primary : Theme.surfaceVariantText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                width: parent.width - Theme.iconSize - Theme.spacingM - cyclingToggle.width - Theme.spacingM
                                spacing: Theme.spacingXS
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    text: "Автосмена обоев"
                                    font.pixelSize: Theme.fontSizeLarge
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                StyledText {
                                    text: "Автоматически менять обои из одной папки"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                }
                            }

                            Toggle {
                                id: cyclingToggle

                                anchors.verticalCenter: parent.verticalCenter
                                checked: SessionData.perMonitorWallpaper ? SessionData.getMonitorCyclingSettings(selectedMonitorName).enabled : SessionData.wallpaperCyclingEnabled
                                onToggled: toggled => {
                                               if (SessionData.perMonitorWallpaper) {
                                                   return SessionData.setMonitorCyclingEnabled(selectedMonitorName, toggled)
                                               } else {
                                                   return SessionData.setWallpaperCyclingEnabled(toggled)
                                               }
                                           }

                                Connections {
                                    target: personalizationTab
                                    function onSelectedMonitorNameChanged() {
                                        cyclingToggle.checked = Qt.binding(() => {
                                            return SessionData.perMonitorWallpaper ? SessionData.getMonitorCyclingSettings(selectedMonitorName).enabled : SessionData.wallpaperCyclingEnabled
                                        })
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS
                            visible: SessionData.perMonitorWallpaper ? SessionData.getMonitorCyclingSettings(selectedMonitorName).enabled : SessionData.wallpaperCyclingEnabled
                            leftPadding: Theme.iconSize + Theme.spacingM

                            Row {
                                spacing: Theme.spacingL
                                width: parent.width - parent.leftPadding

                                StyledText {
                                    text: "Режим:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Item {
                                    width: 200
                                    height: 45 + Theme.spacingM
                                    
                                    ButtonGroup {
                                        id: modeTabBar

                                        width: 200
                                        fillWidth: true
                                        buttonPadding: Theme.spacingXS
                                        spacing: 2
                                        checkEnabled: false
                                        model: ["Интервал", "Время"]
                                        currentIndex: {
                                            if (SessionData.perMonitorWallpaper) {
                                                return SessionData.getMonitorCyclingSettings(selectedMonitorName).mode === "time" ? 1 : 0
                                            } else {
                                                return SessionData.wallpaperCyclingMode === "time" ? 1 : 0
                                            }
                                        }
                                        onSelectionChanged: (index, selected) => {
                                            if (!selected) return
                                            if (SessionData.perMonitorWallpaper) {
                                                SessionData.setMonitorCyclingMode(selectedMonitorName, index === 1 ? "time" : "interval")
                                            } else {
                                                SessionData.setWallpaperCyclingMode(index === 1 ? "time" : "interval")
                                            }
                                        }

                                        Connections {
                                            target: personalizationTab
                                            function onSelectedMonitorNameChanged() {
                                                modeTabBar.currentIndex = Qt.binding(() => {
                                                    if (SessionData.perMonitorWallpaper) {
                                                        return SessionData.getMonitorCyclingSettings(selectedMonitorName).mode === "time" ? 1 : 0
                                                    } else {
                                                        return SessionData.wallpaperCyclingMode === "time" ? 1 : 0
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                            }

                            // Interval settings
                            Dropdown {
                                id: intervalDropdown
                                width: parent.width - parent.leftPadding
                                property var intervalOptions: ["1 минута", "5 минут", "15 минут", "30 минут", "1 час", "1.5 часа", "2 часа", "3 часа", "4 часа", "6 часов", "8 часов", "12 часов"]
                                property var intervalValues: [60, 300, 900, 1800, 3600, 5400, 7200, 10800, 14400, 21600, 28800, 43200]

                                visible: {
                                    if (SessionData.perMonitorWallpaper) {
                                        return SessionData.getMonitorCyclingSettings(selectedMonitorName).mode === "interval"
                                    } else {
                                        return SessionData.wallpaperCyclingMode === "interval"
                                    }
                                }
                                text: "Интервал"
                                description: "Как часто менять обои"
                                dropdownWidth: 120
                                options: intervalOptions
                                currentValue: {
                                    var currentSeconds
                                    if (SessionData.perMonitorWallpaper) {
                                        currentSeconds = SessionData.getMonitorCyclingSettings(selectedMonitorName).interval
                                    } else {
                                        currentSeconds = SessionData.wallpaperCyclingInterval
                                    }
                                    const index = intervalValues.indexOf(currentSeconds)
                                    return index >= 0 ? intervalOptions[index] : "5 minutes"
                                }
                                onValueChanged: value => {
                                                    const index = intervalOptions.indexOf(value)
                                                    if (index >= 0) {
                                                        if (SessionData.perMonitorWallpaper) {
                                                            SessionData.setMonitorCyclingInterval(selectedMonitorName, intervalValues[index])
                                                        } else {
                                                            SessionData.setWallpaperCyclingInterval(intervalValues[index])
                                                        }
                                                    }
                                                }

                                Connections {
                                    target: personalizationTab
                                    function onSelectedMonitorNameChanged() {
                                        // Force dropdown to refresh its currentValue
                                        Qt.callLater(() => {
                                            var currentSeconds
                                            if (SessionData.perMonitorWallpaper) {
                                                currentSeconds = SessionData.getMonitorCyclingSettings(selectedMonitorName).interval
                                            } else {
                                                currentSeconds = SessionData.wallpaperCyclingInterval
                                            }
                                            const index = intervalDropdown.intervalValues.indexOf(currentSeconds)
                                            intervalDropdown.currentValue = index >= 0 ? intervalDropdown.intervalOptions[index] : "5 minutes"
                                        })
                                    }
                                }
                            }

                            // Time settings
                            Row {
                                spacing: Theme.spacingM
                                visible: {
                                    if (SessionData.perMonitorWallpaper) {
                                        return SessionData.getMonitorCyclingSettings(selectedMonitorName).mode === "time"
                                    } else {
                                        return SessionData.wallpaperCyclingMode === "time"
                                    }
                                }
                                width: parent.width - parent.leftPadding

                                StyledText {
                                    text: "Ежедневно в:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                TextField {
                                    id: timeTextField
                                    width: 100
                                    height: 40
                                    text: {
                                        if (SessionData.perMonitorWallpaper) {
                                            return SessionData.getMonitorCyclingSettings(selectedMonitorName).time
                                        } else {
                                            return SessionData.wallpaperCyclingTime
                                        }
                                    }
                                    placeholderText: "00:00"
                                    maximumLength: 5
                                    topPadding: Theme.spacingS
                                    bottomPadding: Theme.spacingS
                                    onAccepted: {
                                        var isValid = /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/.test(text)
                                        if (isValid) {
                                            if (SessionData.perMonitorWallpaper) {
                                                SessionData.setMonitorCyclingTime(selectedMonitorName, text)
                                            } else {
                                                SessionData.setWallpaperCyclingTime(text)
                                            }
                                        } else {
                                            if (SessionData.perMonitorWallpaper) {
                                                text = SessionData.getMonitorCyclingSettings(selectedMonitorName).time
                                            } else {
                                                text = SessionData.wallpaperCyclingTime
                                            }
                                        }
                                    }
                                    onEditingFinished: {
                                        var isValid = /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/.test(text)
                                        if (isValid) {
                                            if (SessionData.perMonitorWallpaper) {
                                                SessionData.setMonitorCyclingTime(selectedMonitorName, text)
                                            } else {
                                                SessionData.setWallpaperCyclingTime(text)
                                            }
                                        } else {
                                            if (SessionData.perMonitorWallpaper) {
                                                text = SessionData.getMonitorCyclingSettings(selectedMonitorName).time
                                            } else {
                                                text = SessionData.wallpaperCyclingTime
                                            }
                                        }
                                    }
                                    anchors.verticalCenter: parent.verticalCenter

                                    validator: RegularExpressionValidator {
                                        regularExpression: /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/
                                    }

                                    Connections {
                                        target: personalizationTab
                                        function onSelectedMonitorNameChanged() {
                                            // Force text field to refresh its value
                                            Qt.callLater(() => {
                                                if (SessionData.perMonitorWallpaper) {
                                                    timeTextField.text = SessionData.getMonitorCyclingSettings(selectedMonitorName).time
                                                } else {
                                                    timeTextField.text = SessionData.wallpaperCyclingTime
                                                }
                                            })
                                        }
                                    }
                                }

                                StyledText {
                                    text: "24-часовой формат"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Dropdown {
                        text: "Эффект перехода"
                        description: "Визуальный эффект при смене обоев"
                        property var transitionNames: {
                            "random": "Случайный",
                            "fade": "Затухание",
                            "wipe": "Стирание",
                            "grow": "Рост",
                            "outer": "Внешний",
                            "wave": "Волна",
                            "center": "Центр",
                            "any": "Любой",
                            "simple": "Простой",
                            "none": "Нет",
                            "left": "Влево",
                            "right": "Вправо",
                            "top": "Вверх",
                            "bottom": "Вниз",
                            "tl": "Верх-лево",
                            "tr": "Верх-право",
                            "bl": "Низ-лево",
                            "br": "Низ-право",
                            "stripes": "Полосы",
                            "disc": "Круг",
                            "disk": "Круг",
                            "iris": "Диафрагма",
                            "bloom": "Расцвет",
                            "iris bloom": "Диафрагма",
                            "pixelate": "Пикселизация",
                            "portal": "Портал"
                        }
                        currentValue: {
                            var trans = SessionData.wallpaperTransition
                            return transitionNames[trans] || trans.charAt(0).toUpperCase() + trans.slice(1)
                        }
                        options: ["Случайный"].concat(SessionData.availableWallpaperTransitions.map(t => transitionNames[t] || t.charAt(0).toUpperCase() + t.slice(1)))
                        onValueChanged: value => {
                            // Специальная обработка для значений с несколькими ключами
                            if (value === "Круг") {
                                // Используем disc как основной вариант
                                SessionData.setWallpaperTransition("disc")
                                return
                            }
                            if (value === "Диафрагма") {
                                // iris bloom - составное название
                                SessionData.setWallpaperTransition("iris bloom")
                                return
                            }
                            
                            var reverseMap = {}
                            for (var key in transitionNames) {
                                // Пропускаем дубликаты
                                if (key === "disk" || key === "iris" || key === "bloom") continue
                                reverseMap[transitionNames[key]] = key
                            }
                            var transition = reverseMap[value] || value.toLowerCase()
                            SessionData.setWallpaperTransition(transition)
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: SessionData.wallpaperTransition === "random"

                        StyledText {
                            text: "Включить переходы"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        StyledText {
                            text: "Выберите какие переходы включить в рандомизацию"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        ButtonGroup {
                            id: transitionGroup
                            width: parent.width
                            selectionMode: "multi"
                            checkEnabled: false
                            model: SessionData.availableWallpaperTransitions.filter(t => t !== "none")
                            initialSelection: SessionData.includedTransitions
                            currentSelection: SessionData.includedTransitions

                            onSelectionChanged: (index, selected) => {
                                const transition = model[index]
                                let newIncluded = [...SessionData.includedTransitions]

                                if (selected && !newIncluded.includes(transition)) {
                                    newIncluded.push(transition)
                                } else if (!selected && newIncluded.includes(transition)) {
                                    newIncluded = newIncluded.filter(t => t !== transition)
                                }

                                SessionData.includedTransitions = newIncluded
                            }
                        }
                    }
                }
            }

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

            // Font Settings Section
            StyledRect {
                width: parent.width
                height: fontSettingsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: fontSettingsSection

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
                        options: cachedFontFamilies
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
                        description: "Выберите моноширинный шрифт для списка процессов и технических дисплеев"
                        currentValue: {
                            if (SettingsData.monoFontFamily === SettingsData.defaultMonoFontFamily)
                                return "Default"
                            return SettingsData.monoFontFamily || "Default"
                        }
                        enableFuzzySearch: true
                        popupWidthOffset: 100
                        maxPopupHeight: 400
                        options: cachedFontFamilies
                        onValueChanged: value => {
                            if (value === "Default")
                                SettingsData.setMonoFontFamily(SettingsData.defaultMonoFontFamily)
                            else
                                SettingsData.setMonoFontFamily(value)
                        }
                    }


                }
            }


        }
    }

    Loader {
        id: wallpaperBrowserLoader
        active: false
        asynchronous: true

        sourceComponent: FileBrowserModal {
            parentModal: personalizationTab.parentModal
            Component.onCompleted: {
                open()
            }
            browserTitle: "Select Wallpaper"
            browserIcon: "wallpaper"
            browserType: "wallpaper"
            fileExtensions: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
            onFileSelected: path => {
                                if (SessionData.perMonitorWallpaper) {
                                    SessionData.setMonitorWallpaper(selectedMonitorName, path)
                                } else {
                                    SessionData.setWallpaper(path)
                                }
                                close()
                            }
            onDialogClosed: {
                Qt.callLater(() => wallpaperBrowserLoader.active = false)
            }
        }
    }

    FileBrowserModal {
        id: customThemeFileBrowserModal
        parentModal: personalizationTab.parentModal
        browserTitle: "Выбрать файл пользовательской темы"
        browserIcon: "palette"
        browserType: "custom-theme"
        fileExtensions: ["*.json"]
        onFileSelected: path => {
            SettingsData.setCustomThemeFile(path)
            Theme.switchTheme("custom", true, true)
            close()
        }
    }
}
