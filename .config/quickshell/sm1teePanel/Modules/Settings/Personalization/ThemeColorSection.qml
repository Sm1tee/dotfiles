import QtQuick
import Quickshell
import qs.Common
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

StyledRect {
    id: root
    
    signal openCustomThemeBrowser()
    
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

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.outline
            opacity: 0.2
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
                        name: "border_color"
                        size: Theme.iconSize
                        color: SettingsData.hyprlandBorderSync ? Theme.primary : Theme.surfaceVariantText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        width: parent.width - Theme.iconSize - Theme.spacingM - hyprlandBorderToggle.width - Theme.spacingM
                        spacing: Theme.spacingXS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Использовать для рамки Hyprland"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        StyledText {
                            text: "Автоматически менять цвет рамок окон в Hyprland"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            width: parent.width
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                    Toggle {
                        id: hyprlandBorderToggle

                        anchors.verticalCenter: parent.verticalCenter
                        checked: SettingsData.hyprlandBorderSync
                        enabled: Theme.matugenAvailable
                        onToggleCompleted: checked => {
                            SettingsData.setHyprlandBorderSync(checked)
                            
                            if (checked) {
                                // Создаем файл с текущими цветами сразу
                                const primary = Theme.primary.toString().replace("#", "")
                                const outline = Theme.outline.toString().replace("#", "")
                                const content = `# Автоматически сгенерировано matugen\n# Цвета синхронизированы с темой Quickshell\n\ngeneral {\n    col.active_border = rgba(${primary}ee)\n    col.inactive_border = rgba(${outline}aa)\n}\n`
                                
                                Quickshell.execDetached(["sh", "-c", `mkdir -p ~/.config/hypr && cat > ~/.config/hypr/sm1tee-colors.conf << 'EOF'\n${content}EOF`])
                                
                                // Добавляем source в конец hyprland.conf если его там нет
                                Quickshell.execDetached(["sh", "-c", `grep -q 'source.*sm1tee-colors.conf' ~/.config/hypr/hyprland.conf || echo '\n# Цвета из Quickshell\nsource = ~/.config/hypr/sm1tee-colors.conf' >> ~/.config/hypr/hyprland.conf`])
                                
                                // Перезагружаем Hyprland
                                Quickshell.execDetached(["hyprctl", "reload"])
                                
                                ToastService.showSuccess("Синхронизация рамок Hyprland включена")
                            } else {
                                // Удаляем строки с source из hyprland.conf
                                Quickshell.execDetached(["sh", "-c", `sed -i '/# Цвета из Quickshell/d; /source.*sm1tee-colors.conf/d' ~/.config/hypr/hyprland.conf`])
                                
                                // Удаляем файл с цветами
                                Quickshell.execDetached(["rm", "-f", `${Theme.homeDir}/.config/hypr/sm1tee-colors.conf`])
                                
                                // Перезагружаем Hyprland
                                Quickshell.execDetached(["hyprctl", "reload"])
                                
                                ToastService.showInfo("Синхронизация рамок Hyprland отключена")
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
                            text: "Пользовательские шаблоны matugen"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        StyledText {
                            text: "Применять цвета из ~/.config/matugen/config.toml"
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
                        onClicked: root.openCustomThemeBrowser()
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

