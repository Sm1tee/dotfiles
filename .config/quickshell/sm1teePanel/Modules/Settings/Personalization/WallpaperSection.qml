import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import qs.Common
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

StyledRect {
    id: root
    
    property string selectedMonitorName: ""
    signal openWallpaperBrowser()
    
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
                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
                        if (currentWallpaper && currentWallpaper.startsWith("we:")) {
                            var sceneId = currentWallpaper.substring(3)
                            return StandardPaths.writableLocation(StandardPaths.HomeLocation)
                                + "/.local/share/Steam/steamapps/workshop/content/431960/"
                                + sceneId + "/preview" + weExtensions[weExtIndex]
                        }
                        return (currentWallpaper !== "" && !currentWallpaper.startsWith("#")) ? "file://" + currentWallpaper : ""
                    }
                    onStatusChanged: {
                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
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
                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
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
                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
                        return currentWallpaper.startsWith("#") ? currentWallpaper : "transparent"
                    }
                    visible: {
                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
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
                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
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
                                    root.openWallpaperBrowser()
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
                                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
                                        PopoutService.colorPickerModal.selectedColor = currentWallpaper.startsWith("#") ? currentWallpaper : Theme.primary
                                        PopoutService.colorPickerModal.pickerTitle = "Choose Wallpaper Color"
                                        PopoutService.colorPickerModal.onColorSelectedCallback = function(selectedColor) {
                                            if (SessionData.perMonitorWallpaper) {
                                                SessionData.setMonitorWallpaper(root.selectedMonitorName, selectedColor)
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
                                var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
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
                                        SessionData.setMonitorWallpaper(root.selectedMonitorName, "")
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
                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
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
                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
                        return currentWallpaper ? currentWallpaper : ""
                    }
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    elide: Text.ElideMiddle
                    maximumLineCount: 1
                    width: parent.width
                    visible: {
                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
                        return currentWallpaper !== ""
                    }
                }

                Row {
                    spacing: Theme.spacingS
                    visible: {
                        var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
                        return currentWallpaper !== ""
                    }

                    ActionButton {
                        buttonSize: 40
                        iconName: "skip_previous"
                        iconSize: Theme.iconSize
                        enabled: {
                            var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
                            return currentWallpaper && !currentWallpaper.startsWith("#") && !currentWallpaper.startsWith("we")
                        }
                        opacity: {
                            var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
                            return (currentWallpaper && !currentWallpaper.startsWith("#") && !currentWallpaper.startsWith("we")) ? 1 : 0.5
                        }
                        backgroundColor: Theme.surfaceContainerHigh
                        iconColor: Theme.surfaceText
                        onClicked: {
                            if (SessionData.perMonitorWallpaper) {
                                WallpaperCyclingService.cyclePrevForMonitor(root.selectedMonitorName)
                            } else {
                                WallpaperCyclingService.cyclePrevManually()
                            }
                        }
                    }

                    ActionButton {
                        buttonSize: 40
                        iconName: "skip_next"
                        iconSize: Theme.iconSize
                        enabled: {
                            var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
                            return currentWallpaper && !currentWallpaper.startsWith("#") && !currentWallpaper.startsWith("we")
                        }
                        opacity: {
                            var currentWallpaper = SessionData.perMonitorWallpaper ? SessionData.getMonitorWallpaper(root.selectedMonitorName) : SessionData.wallpaperPath
                            return (currentWallpaper && !currentWallpaper.startsWith("#") && !currentWallpaper.startsWith("we")) ? 1 : 0.5
                        }
                        backgroundColor: Theme.surfaceContainerHigh
                        iconColor: Theme.surfaceText
                        onClicked: {
                            if (SessionData.perMonitorWallpaper) {
                                WallpaperCyclingService.cycleNextForMonitor(root.selectedMonitorName)
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
                    currentValue: root.selectedMonitorName || "No monitors"
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
                                        root.selectedMonitorName = value
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
                    checked: SessionData.perMonitorWallpaper ? SessionData.getMonitorCyclingSettings(root.selectedMonitorName).enabled : SessionData.wallpaperCyclingEnabled
                    onToggled: toggled => {
                                   if (SessionData.perMonitorWallpaper) {
                                       return SessionData.setMonitorCyclingEnabled(root.selectedMonitorName, toggled)
                                   } else {
                                       return SessionData.setWallpaperCyclingEnabled(toggled)
                                   }
                               }

                    Connections {
                        target: personalizationTab
                        function onSelectedMonitorNameChanged() {
                            cyclingToggle.checked = Qt.binding(() => {
                                return SessionData.perMonitorWallpaper ? SessionData.getMonitorCyclingSettings(root.selectedMonitorName).enabled : SessionData.wallpaperCyclingEnabled
                            })
                        }
                    }
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingS
                visible: SessionData.perMonitorWallpaper ? SessionData.getMonitorCyclingSettings(root.selectedMonitorName).enabled : SessionData.wallpaperCyclingEnabled
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
                                    return SessionData.getMonitorCyclingSettings(root.selectedMonitorName).mode === "time" ? 1 : 0
                                } else {
                                    return SessionData.wallpaperCyclingMode === "time" ? 1 : 0
                                }
                            }
                            onSelectionChanged: (index, selected) => {
                                if (!selected) return
                                if (SessionData.perMonitorWallpaper) {
                                    SessionData.setMonitorCyclingMode(root.selectedMonitorName, index === 1 ? "time" : "interval")
                                } else {
                                    SessionData.setWallpaperCyclingMode(index === 1 ? "time" : "interval")
                                }
                            }

                            Connections {
                                target: personalizationTab
                                function onSelectedMonitorNameChanged() {
                                    modeTabBar.currentIndex = Qt.binding(() => {
                                        if (SessionData.perMonitorWallpaper) {
                                            return SessionData.getMonitorCyclingSettings(root.selectedMonitorName).mode === "time" ? 1 : 0
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
                            return SessionData.getMonitorCyclingSettings(root.selectedMonitorName).mode === "interval"
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
                            currentSeconds = SessionData.getMonitorCyclingSettings(root.selectedMonitorName).interval
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
                                                SessionData.setMonitorCyclingInterval(root.selectedMonitorName, intervalValues[index])
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
                                    currentSeconds = SessionData.getMonitorCyclingSettings(root.selectedMonitorName).interval
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
                            return SessionData.getMonitorCyclingSettings(root.selectedMonitorName).mode === "time"
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
                                return SessionData.getMonitorCyclingSettings(root.selectedMonitorName).time
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
                                    SessionData.setMonitorCyclingTime(root.selectedMonitorName, text)
                                } else {
                                    SessionData.setWallpaperCyclingTime(text)
                                }
                            } else {
                                if (SessionData.perMonitorWallpaper) {
                                    text = SessionData.getMonitorCyclingSettings(root.selectedMonitorName).time
                                } else {
                                    text = SessionData.wallpaperCyclingTime
                                }
                            }
                        }
                        onEditingFinished: {
                            var isValid = /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/.test(text)
                            if (isValid) {
                                if (SessionData.perMonitorWallpaper) {
                                    SessionData.setMonitorCyclingTime(root.selectedMonitorName, text)
                                } else {
                                    SessionData.setWallpaperCyclingTime(text)
                                }
                            } else {
                                if (SessionData.perMonitorWallpaper) {
                                    text = SessionData.getMonitorCyclingSettings(root.selectedMonitorName).time
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
                                        timeTextField.text = SessionData.getMonitorCyclingSettings(root.selectedMonitorName).time
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

