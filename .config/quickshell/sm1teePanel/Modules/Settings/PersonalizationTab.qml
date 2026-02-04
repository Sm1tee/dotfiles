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
import "Personalization"

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

            var rootName = fontName.replace(/ (Thin|Extra Light|Light|Regular|Medium|Semi Bold|Demi Bold|Bold|Extra Bold|Black|Heavy)$/i, "").replace(/ (Italic|Oblique|Condensed|Extended|Narrow|Wide)$/i, "").replace(/ (UI|Display|Text|Mono|Sans|Serif)$/i, function (match, suffix) {
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

            // 1. Обои
            WallpaperSection {
                id: wallpaperSectionItem
                width: parent.width
                selectedMonitorName: personalizationTab.selectedMonitorName
                onOpenWallpaperBrowser: wallpaperBrowserLoader.active = true
            }

            // 2. Цвет темы
            ThemeColorSection {
                id: themeColorSectionItem
                width: parent.width
                onOpenCustomThemeBrowser: customThemeFileBrowserLoader.active = true
            }

            // 3. Стилизация виджетов
            WidgetStylingSection {
                id: widgetStylingSection
                width: parent.width
            }

            // 4. Скорость анимации
            AnimationSection {
                id: animationSection
                width: parent.width
            }

            // 5. Масштаб интерфейса
            ScaleSection {
                id: scaleSection
                width: parent.width
            }

            // 6. Шрифты
            FontSettingsSection {
                id: fontSettingsSection
                width: parent.width
                cachedFontFamilies: personalizationTab.cachedFontFamilies
            }

            // 7. Светлая тема
            LightModeSection {
                id: lightModeSection
                width: parent.width
            }
        }
    }

    Loader {
        id: wallpaperBrowserLoader
        active: false
        sourceComponent: FileBrowserModal {
            id: wallpaperBrowserModal
            browserTitle: "Выбор обоев"
            browserIcon: "wallpaper"
            browserType: "wallpaper"
            fileExtensions: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif", "*.bmp"]
            showHiddenFiles: false
            onFileSelected: path => {
                if (SettingsData.perMonitorWallpaper) {
                    SessionData.setMonitorWallpaper(personalizationTab.selectedMonitorName, path)
                } else {
                    SessionData.setWallpaper(path)
                }
            }
        }
    }

    Loader {
        id: customThemeFileBrowserLoader
        active: false
        sourceComponent: FileBrowserModal {
            browserTitle: "Выбрать файл темы"
            browserIcon: "palette"
            browserType: "custom-theme"
            fileExtensions: ["*.json"]
            onFileSelected: path => {
                SettingsData.setCustomThemeFile(path)
            }
        }
    }
}
