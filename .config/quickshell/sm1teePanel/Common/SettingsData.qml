pragma Singleton

pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

Singleton {
    id: root

    readonly property bool isGreeterMode: Quickshell.env("SM1TEE_RUN_GREETER") === "1" || Quickshell.env("SM1TEE_RUN_GREETER") === "true"

    enum Position {
        Top,
        Bottom,
        Left,
        Right
    }

    enum AnimationSpeed {
        None,
        Shortest,
        Short,
        Medium,
        Long
    }

    // Theme settings
    property string currentThemeName: "blue"
    property string customThemeFile: ""
    property string matugenScheme: "scheme-tonal-spot"
    property bool runUserMatugenTemplates: true
    property real barTransparency: 1.0
    property real barWidgetTransparency: 1.0
    property real popupTransparency: 1.0
    property real dockTransparency: 1
    property bool use24HourClock: true
    property bool useFahrenheit: false
    property bool nightModeEnabled: false
    property string weatherLocation: "New York, NY"
    property string weatherCoordinates: "40.7128,-74.0060"
    property bool useAutoLocation: false
    property bool showLauncherButton: true
    property bool showWorkspaceSwitcher: true
    property bool showFocusedWindow: true
    property bool showWeather: true
    property bool showMusic: true
    property bool showClipboard: true
    property bool showCpuUsage: true
    property bool showMemUsage: true
    property bool showCpuTemp: true
    property int selectedGpuIndex: 0
    property var enabledGpuPciIds: []
    property bool showSystemTray: true
    property bool showClock: true
    property bool showNotificationButton: true
    property bool showBattery: true
    property bool showControlCenterButton: true
    property bool controlCenterShowNetworkIcon: true
    property bool controlCenterShowBluetoothIcon: true
    property bool controlCenterShowAudioIcon: true
    property var controlCenterWidgets: [
        {"id": "volumeSlider", "enabled": true, "width": 50},
        {"id": "brightnessSlider", "enabled": true, "width": 50},
        {"id": "wifi", "enabled": true, "width": 50},
        {"id": "bluetooth", "enabled": true, "width": 50},
        {"id": "audioOutput", "enabled": true, "width": 50},
        {"id": "audioInput", "enabled": true, "width": 50},
        {"id": "nightMode", "enabled": true, "width": 50},
        {"id": "darkMode", "enabled": true, "width": 50}
    ]
    property bool showWorkspaceIndex: false
    property int workspacePaddingCount: 0
    property bool showWorkspaceApps: false
    property int maxWorkspaceIcons: 3
    property bool workspacesPerMonitor: true
    property var workspaceNameIcons: ({})
    property bool waveProgressEnabled: true
    property bool clockCompactMode: false
    property bool clockDateFirst: false
    property bool keyboardLayoutShowFlag: true
    property bool focusedWindowCompactMode: false
    property bool runningAppsCompactMode: true
    property bool runningAppsCurrentWorkspace: false
    property string clockDateFormat: ""
    property string lockDateFormat: ""
    property int mediaSize: 1
    property var barLeftWidgets: ["launcherButton", "workspaceSwitcher", "focusedWindow"]
    property var barCenterWidgets: ["music", "clock", "weather"]
    property var barRightWidgets: ["systemTray", "clipboard", "cpuUsage", "memUsage", "notificationButton", "battery", "controlCenterButton"]
    property var barWidgetOrder: []
    property alias barLeftWidgetsModel: leftWidgetsModel
    property alias barCenterWidgetsModel: centerWidgetsModel
    property alias barRightWidgetsModel: rightWidgetsModel
    property string appLauncherViewMode: "list"
    property string spotlightModalViewMode: "list"
    property string networkPreference: "auto"
    property string launcherLogoMode: "apps"
    property string launcherLogoCustomPath: ""
    property string launcherLogoColorOverride: ""
    property bool launcherLogoColorInvertOnMode: false
    property real launcherLogoBrightness: 0.5
    property real launcherLogoContrast: 1
    property int launcherLogoSizeOffset: 0
    property bool weatherEnabled: false
    property string fontFamily: "Inter Variable"
    property string monoFontFamily: "Fira Code"
    property int fontWeight: Font.Normal
    property real fontScale: 1.0
    property real barFontScale: 1.0
    property real barIconScale: 1.0
    property bool notepadUseMonospace: true
    property string notepadFontFamily: ""
    property real notepadFontSize: 14
    property bool notepadShowLineNumbers: false
    property real notepadTransparencyOverride: -1
    property real notepadLastCustomTransparency: 0.7

    onNotepadUseMonospaceChanged: saveSettings()
    onNotepadFontFamilyChanged: saveSettings()
    onNotepadFontSizeChanged: saveSettings()
    onNotepadShowLineNumbersChanged: saveSettings()
    onNotepadTransparencyOverrideChanged: {
        if (notepadTransparencyOverride > 0) {
            notepadLastCustomTransparency = notepadTransparencyOverride
        }
        saveSettings()
    }
    onNotepadLastCustomTransparencyChanged: saveSettings()
    property bool showDock: false
    property bool dockAutoHide: false
    property bool dockGroupByApp: false
    property bool dockOpenOnOverview: false
    property int dockPosition: SettingsData.Position.Bottom
    property real dockSpacing: 4
    property real dockBottomGap: 0
    property real cornerRadius: 12
    property bool notificationOverlayEnabled: false
    property bool barAutoHide: false
    property bool barOpenOnOverview: false
    property bool barVisible: true
    property real barSpacing: 4
    property real barBottomGap: 0
    property real barInnerPadding: 4
    property bool barSquareCorners: false
    property bool barNoBackground: false
    property bool barGothCornersEnabled: false

    property int barPosition: SettingsData.Position.Top
    property bool barIsVertical: barPosition === SettingsData.Position.Left || barPosition === SettingsData.Position.Right
    property bool lockScreenShowPowerActions: true
    property bool hideBrightnessSlider: false
    property string widgetBackgroundColor: "sch"
    property string surfaceBase: "s"
    property int notificationTimeoutLow: 5000
    property int notificationTimeoutNormal: 5000
    property int notificationTimeoutCritical: 0
    property int notificationPopupPosition: SettingsData.Position.Top
    property bool osdAlwaysShowValue: false
    property var screenPreferences: ({})
    property int animationSpeed: SettingsData.AnimationSpeed.Short
    readonly property string defaultFontFamily: "Inter Variable"
    readonly property string defaultMonoFontFamily: "Fira Code"
    readonly property string _homeUrl: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    readonly property string _configUrl: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
    readonly property string _configDir: Paths.strip(_configUrl)
    readonly property string pluginSettingsPath: _configDir + "/sm1teePanel/plugin_settings.json"

    signal forceBarLayoutRefresh
    signal forceDockLayoutRefresh
    signal widgetDataChanged
    signal workspaceIconsUpdated

    property bool _loading: false
    property bool _pluginSettingsLoading: false

    property var pluginSettings: ({})

    function getEffectiveTimeFormat() {
        if (use24HourClock) {
            return Locale.ShortFormat
        } else {
            return "h:mm AP"
        }
    }

    function getEffectiveClockDateFormat() {
        return clockDateFormat && clockDateFormat.length > 0 ? clockDateFormat : "ddd d"
    }

    function getEffectiveLockDateFormat() {
        return lockDateFormat && lockDateFormat.length > 0 ? lockDateFormat : Locale.LongFormat
    }

    function initializeListModels() {
        // ! Hack-ish to add all properties to the listmodel once
        // ! allows the properties to be bound on new widget addtions
        var dummyItem = {
            "widgetId": "dummy",
            "enabled": true,
            "size": 20,
            "selectedGpuIndex": 0,
            "pciId": "",
            "mountPath": "/",
            "minimumWidth": true
        }
        leftWidgetsModel.append(dummyItem)
        centerWidgetsModel.append(dummyItem)
        rightWidgetsModel.append(dummyItem)

        updateListModel(leftWidgetsModel, barLeftWidgets)
        updateListModel(centerWidgetsModel, barCenterWidgets)
        updateListModel(rightWidgetsModel, barRightWidgets)
    }

    function loadSettings() {
        _loading = true
        parseSettings(settingsFile.text())
        _loading = false
        loadPluginSettings()
    }

    function loadPluginSettings() {
        _pluginSettingsLoading = true
        parsePluginSettings(pluginSettingsFile.text())
        _pluginSettingsLoading = false
    }

    function parsePluginSettings(content) {
        _pluginSettingsLoading = true
        try {
            if (content && content.trim()) {
                pluginSettings = JSON.parse(content)
            } else {
                pluginSettings = {}
            }
        } catch (e) {
            console.warn("SettingsData: Failed to parse plugin settings:", e.message)
            pluginSettings = {}
        } finally {
            _pluginSettingsLoading = false
        }
    }

    function parseSettings(content) {
        _loading = true
        var shouldMigrate = false
        try {
            if (content && content.trim()) {
                var settings = JSON.parse(content)
                if (settings.pluginSettings !== undefined) {
                    pluginSettings = settings.pluginSettings
                    shouldMigrate = true
                }
                // Auto-migrate from old theme system
                if (settings.themeIndex !== undefined || settings.themeIsDynamic !== undefined) {
                    const themeNames = ["blue", "deepBlue", "purple", "green", "orange", "red", "cyan", "pink", "amber", "coral"]
                    if (settings.themeIsDynamic) {
                        currentThemeName = "dynamic"
                    } else if (settings.themeIndex >= 0 && settings.themeIndex < themeNames.length) {
                        currentThemeName = themeNames[settings.themeIndex]
                    }

                } else {
                    currentThemeName = settings.currentThemeName !== undefined ? settings.currentThemeName : "blue"
                }
                customThemeFile = settings.customThemeFile !== undefined ? settings.customThemeFile : ""
                matugenScheme = settings.matugenScheme !== undefined ? settings.matugenScheme : "scheme-tonal-spot"
                runUserMatugenTemplates = settings.runUserMatugenTemplates !== undefined ? settings.runUserMatugenTemplates : true
                barTransparency = settings.barTransparency !== undefined ? (settings.barTransparency > 1 ? settings.barTransparency / 100 : settings.barTransparency) : (settings.topBarTransparency !== undefined ? (settings.topBarTransparency > 1 ? settings.topBarTransparency / 100 : settings.topBarTransparency) : 1.0)
                barWidgetTransparency = settings.barWidgetTransparency !== undefined ? (settings.barWidgetTransparency > 1 ? settings.barWidgetTransparency / 100 : settings.barWidgetTransparency) : (settings.topBarWidgetTransparency !== undefined ? (settings.topBarWidgetTransparency > 1 ? settings.topBarWidgetTransparency / 100 : settings.topBarWidgetTransparency) : 1.0)
                popupTransparency = settings.popupTransparency !== undefined ? (settings.popupTransparency > 1 ? settings.popupTransparency / 100 : settings.popupTransparency) : 1.0
                dockTransparency = settings.dockTransparency !== undefined ? (settings.dockTransparency > 1 ? settings.dockTransparency / 100 : settings.dockTransparency) : 1
                use24HourClock = settings.use24HourClock !== undefined ? settings.use24HourClock : true
                useFahrenheit = settings.useFahrenheit !== undefined ? settings.useFahrenheit : false
                nightModeEnabled = settings.nightModeEnabled !== undefined ? settings.nightModeEnabled : false
                weatherLocation = settings.weatherLocation !== undefined ? settings.weatherLocation : "New York, NY"
                weatherCoordinates = settings.weatherCoordinates !== undefined ? settings.weatherCoordinates : "40.7128,-74.0060"
                useAutoLocation = settings.useAutoLocation !== undefined ? settings.useAutoLocation : false
                weatherEnabled = settings.weatherEnabled !== undefined ? settings.weatherEnabled : true
                showLauncherButton = settings.showLauncherButton !== undefined ? settings.showLauncherButton : true
                showWorkspaceSwitcher = settings.showWorkspaceSwitcher !== undefined ? settings.showWorkspaceSwitcher : true
                showFocusedWindow = settings.showFocusedWindow !== undefined ? settings.showFocusedWindow : true
                showWeather = settings.showWeather !== undefined ? settings.showWeather : true
                showMusic = settings.showMusic !== undefined ? settings.showMusic : true
                showClipboard = settings.showClipboard !== undefined ? settings.showClipboard : true
                showCpuUsage = settings.showCpuUsage !== undefined ? settings.showCpuUsage : true
                showMemUsage = settings.showMemUsage !== undefined ? settings.showMemUsage : true
                showCpuTemp = settings.showCpuTemp !== undefined ? settings.showCpuTemp : true
                selectedGpuIndex = settings.selectedGpuIndex !== undefined ? settings.selectedGpuIndex : 0
                enabledGpuPciIds = settings.enabledGpuPciIds !== undefined ? settings.enabledGpuPciIds : []
                showSystemTray = settings.showSystemTray !== undefined ? settings.showSystemTray : true
                showClock = settings.showClock !== undefined ? settings.showClock : true
                showNotificationButton = settings.showNotificationButton !== undefined ? settings.showNotificationButton : true
                showBattery = settings.showBattery !== undefined ? settings.showBattery : true
                showControlCenterButton = settings.showControlCenterButton !== undefined ? settings.showControlCenterButton : true
                controlCenterShowNetworkIcon = settings.controlCenterShowNetworkIcon !== undefined ? settings.controlCenterShowNetworkIcon : true
                controlCenterShowBluetoothIcon = settings.controlCenterShowBluetoothIcon !== undefined ? settings.controlCenterShowBluetoothIcon : true
                controlCenterShowAudioIcon = settings.controlCenterShowAudioIcon !== undefined ? settings.controlCenterShowAudioIcon : true
                controlCenterWidgets = settings.controlCenterWidgets !== undefined ? settings.controlCenterWidgets : [
                    {"id": "volumeSlider", "enabled": true, "width": 50},
                    {"id": "brightnessSlider", "enabled": true, "width": 50},
                    {"id": "wifi", "enabled": true, "width": 50},
                    {"id": "bluetooth", "enabled": true, "width": 50},
                    {"id": "audioOutput", "enabled": true, "width": 50},
                    {"id": "audioInput", "enabled": true, "width": 50},
                    {"id": "nightMode", "enabled": true, "width": 50},
                    {"id": "darkMode", "enabled": true, "width": 50}
                ]
                showWorkspaceIndex = settings.showWorkspaceIndex !== undefined ? settings.showWorkspaceIndex : false
                // Миграция: если старая настройка showWorkspacePadding была true, устанавливаем 3
                if (settings.showWorkspacePadding !== undefined && typeof settings.showWorkspacePadding === "boolean") {
                    workspacePaddingCount = settings.showWorkspacePadding ? 3 : 0
                } else {
                    workspacePaddingCount = settings.workspacePaddingCount !== undefined ? settings.workspacePaddingCount : 0
                }
                showWorkspaceApps = settings.showWorkspaceApps !== undefined ? settings.showWorkspaceApps : false
                maxWorkspaceIcons = settings.maxWorkspaceIcons !== undefined ? settings.maxWorkspaceIcons : 3
                workspaceNameIcons = settings.workspaceNameIcons !== undefined ? settings.workspaceNameIcons : ({})
                workspacesPerMonitor = settings.workspacesPerMonitor !== undefined ? settings.workspacesPerMonitor : true
                waveProgressEnabled = settings.waveProgressEnabled !== undefined ? settings.waveProgressEnabled : true
                clockCompactMode = settings.clockCompactMode !== undefined ? settings.clockCompactMode : false
                keyboardLayoutShowFlag = settings.keyboardLayoutShowFlag !== undefined ? settings.keyboardLayoutShowFlag : false
                focusedWindowCompactMode = settings.focusedWindowCompactMode !== undefined ? settings.focusedWindowCompactMode : false
                runningAppsCompactMode = settings.runningAppsCompactMode !== undefined ? settings.runningAppsCompactMode : true
                runningAppsCurrentWorkspace = settings.runningAppsCurrentWorkspace !== undefined ? settings.runningAppsCurrentWorkspace : false
                clockDateFormat = settings.clockDateFormat !== undefined ? settings.clockDateFormat : ""
                lockDateFormat = settings.lockDateFormat !== undefined ? settings.lockDateFormat : ""
                mediaSize = settings.mediaSize !== undefined ? settings.mediaSize : (settings.mediaCompactMode !== undefined ? (settings.mediaCompactMode ? 0 : 1) : 1)
                if (settings.barWidgetOrder || settings.topBarWidgetOrder) {
                    var widgetOrder = settings.barWidgetOrder || settings.topBarWidgetOrder
                    barLeftWidgets = widgetOrder.filter(w => {
                                                                              return ["launcherButton", "workspaceSwitcher", "focusedWindow"].includes(w)
                                                                          })
                    barCenterWidgets = widgetOrder.filter(w => {
                                                                                return ["clock", "music", "weather"].includes(w)
                                                                            })
                    barRightWidgets = widgetOrder.filter(w => {
                                                                               return ["systemTray", "clipboard", "systemResources", "notificationButton", "battery", "controlCenterButton"].includes(w)
                                                                           })
                } else {
                    var leftWidgets = settings.barLeftWidgets !== undefined ? settings.barLeftWidgets : (settings.topBarLeftWidgets !== undefined ? settings.topBarLeftWidgets : ["launcherButton", "workspaceSwitcher", "focusedWindow"])
                    var centerWidgets = settings.barCenterWidgets !== undefined ? settings.barCenterWidgets : (settings.topBarCenterWidgets !== undefined ? settings.topBarCenterWidgets : ["music", "clock", "weather"])
                    var rightWidgets = settings.barRightWidgets !== undefined ? settings.barRightWidgets : (settings.topBarRightWidgets !== undefined ? settings.topBarRightWidgets : ["systemTray", "clipboard", "cpuUsage", "memUsage", "notificationButton", "battery", "controlCenterButton"])
                    barLeftWidgets = leftWidgets
                    barCenterWidgets = centerWidgets
                    barRightWidgets = rightWidgets
                    updateListModel(leftWidgetsModel, leftWidgets)
                    updateListModel(centerWidgetsModel, centerWidgets)
                    updateListModel(rightWidgetsModel, rightWidgets)
                }
                appLauncherViewMode = settings.appLauncherViewMode !== undefined ? settings.appLauncherViewMode : "list"
                spotlightModalViewMode = settings.spotlightModalViewMode !== undefined ? settings.spotlightModalViewMode : "list"
                networkPreference = settings.networkPreference !== undefined ? settings.networkPreference : "auto"
                if (settings.useOSLogo !== undefined) {
                    launcherLogoMode = settings.useOSLogo ? "os" : "apps"
                    launcherLogoColorOverride = settings.osLogoColorOverride !== undefined ? settings.osLogoColorOverride : ""
                    launcherLogoBrightness = settings.osLogoBrightness !== undefined ? settings.osLogoBrightness : 0.5
                    launcherLogoContrast = settings.osLogoContrast !== undefined ? settings.osLogoContrast : 1
                } else {
                    launcherLogoMode = settings.launcherLogoMode !== undefined ? settings.launcherLogoMode : "apps"
                    launcherLogoCustomPath = settings.launcherLogoCustomPath !== undefined ? settings.launcherLogoCustomPath : ""
                    launcherLogoColorOverride = settings.launcherLogoColorOverride !== undefined ? settings.launcherLogoColorOverride : ""
                    launcherLogoColorInvertOnMode = settings.launcherLogoColorInvertOnMode !== undefined ? settings.launcherLogoColorInvertOnMode : false
                    launcherLogoBrightness = settings.launcherLogoBrightness !== undefined ? settings.launcherLogoBrightness : 0.5
                    launcherLogoContrast = settings.launcherLogoContrast !== undefined ? settings.launcherLogoContrast : 1
                    launcherLogoSizeOffset = settings.launcherLogoSizeOffset !== undefined ? settings.launcherLogoSizeOffset : 0
                }
                fontFamily = settings.fontFamily !== undefined ? settings.fontFamily : defaultFontFamily
                monoFontFamily = settings.monoFontFamily !== undefined ? settings.monoFontFamily : defaultMonoFontFamily
                fontWeight = settings.fontWeight !== undefined ? settings.fontWeight : Font.Normal
                fontScale = settings.fontScale !== undefined ? settings.fontScale : 1.0
                barFontScale = settings.barFontScale !== undefined ? settings.barFontScale : 1.0
                barIconScale = settings.barIconScale !== undefined ? settings.barIconScale : 1.0
                notepadUseMonospace = settings.notepadUseMonospace !== undefined ? settings.notepadUseMonospace : true
                notepadFontFamily = settings.notepadFontFamily !== undefined ? settings.notepadFontFamily : ""
                notepadFontSize = settings.notepadFontSize !== undefined ? settings.notepadFontSize : 14
                notepadShowLineNumbers = settings.notepadShowLineNumbers !== undefined ? settings.notepadShowLineNumbers : false
                notepadTransparencyOverride = settings.notepadTransparencyOverride !== undefined ? settings.notepadTransparencyOverride : -1
                notepadLastCustomTransparency = settings.notepadLastCustomTransparency !== undefined ? settings.notepadLastCustomTransparency : 0.95
                showDock = settings.showDock !== undefined ? settings.showDock : false
                dockAutoHide = settings.dockAutoHide !== undefined ? settings.dockAutoHide : false
                dockGroupByApp = settings.dockGroupByApp !== undefined ? settings.dockGroupByApp : false
                dockPosition = settings.dockPosition !== undefined ? settings.dockPosition : SettingsData.Position.Bottom
                dockSpacing = settings.dockSpacing !== undefined ? settings.dockSpacing : 4
                dockBottomGap = settings.dockBottomGap !== undefined ? settings.dockBottomGap : 0
                cornerRadius = settings.cornerRadius !== undefined ? settings.cornerRadius : 12
                notificationOverlayEnabled = settings.notificationOverlayEnabled !== undefined ? settings.notificationOverlayEnabled : false
                barAutoHide = settings.barAutoHide !== undefined ? settings.barAutoHide : (settings.topBarAutoHide !== undefined ? settings.topBarAutoHide : false)
                barOpenOnOverview = settings.barOpenOnOverview !== undefined ? settings.barOpenOnOverview : (settings.topBarOpenOnOverview !== undefined ? settings.topBarOpenOnOverview : false)
                barVisible = settings.barVisible !== undefined ? settings.barVisible : (settings.topBarVisible !== undefined ? settings.topBarVisible : true)
                dockOpenOnOverview = settings.dockOpenOnOverview !== undefined ? settings.dockOpenOnOverview : false
                notificationTimeoutLow = settings.notificationTimeoutLow !== undefined ? settings.notificationTimeoutLow : 5000
                notificationTimeoutNormal = settings.notificationTimeoutNormal !== undefined ? settings.notificationTimeoutNormal : 5000
                notificationTimeoutCritical = settings.notificationTimeoutCritical !== undefined ? settings.notificationTimeoutCritical : 0
                notificationPopupPosition = settings.notificationPopupPosition !== undefined ? settings.notificationPopupPosition : SettingsData.Position.Top
                osdAlwaysShowValue = settings.osdAlwaysShowValue !== undefined ? settings.osdAlwaysShowValue : false
                barSpacing = settings.barSpacing !== undefined ? settings.barSpacing : (settings.topBarSpacing !== undefined ? settings.topBarSpacing : 4)
                barBottomGap = settings.barBottomGap !== undefined ? settings.barBottomGap : (settings.topBarBottomGap !== undefined ? settings.topBarBottomGap : 0)
                barInnerPadding = settings.barInnerPadding !== undefined ? settings.barInnerPadding : (settings.topBarInnerPadding !== undefined ? settings.topBarInnerPadding : 4)
                barSquareCorners = settings.barSquareCorners !== undefined ? settings.barSquareCorners : (settings.topBarSquareCorners !== undefined ? settings.topBarSquareCorners : false)
                barNoBackground = settings.barNoBackground !== undefined ? settings.barNoBackground : (settings.topBarNoBackground !== undefined ? settings.topBarNoBackground : false)
                barGothCornersEnabled = settings.barGothCornersEnabled !== undefined ? settings.barGothCornersEnabled : (settings.topBarGothCornersEnabled !== undefined ? settings.topBarGothCornersEnabled : false)
                barPosition = settings.barPosition !== undefined ? settings.barPosition : (settings.barAtBottom !== undefined ? (settings.barAtBottom ? SettingsData.Position.Bottom : SettingsData.Position.Top) : (settings.topBarAtBottom !== undefined ? (settings.topBarAtBottom ? SettingsData.Position.Bottom : SettingsData.Position.Top) : SettingsData.Position.Top))
                lockScreenShowPowerActions = settings.lockScreenShowPowerActions !== undefined ? settings.lockScreenShowPowerActions : true
                hideBrightnessSlider = settings.hideBrightnessSlider !== undefined ? settings.hideBrightnessSlider : false
                widgetBackgroundColor = settings.widgetBackgroundColor !== undefined ? settings.widgetBackgroundColor : "sch"
                surfaceBase = settings.surfaceBase !== undefined ? settings.surfaceBase : "s"
                screenPreferences = settings.screenPreferences !== undefined ? settings.screenPreferences : ({})
                animationSpeed = settings.animationSpeed !== undefined ? settings.animationSpeed : SettingsData.AnimationSpeed.Short
                applyStoredTheme()
                detectQtTools()
            } else {
                applyStoredTheme()
            }
        } catch (e) {
            applyStoredTheme()
        } finally {
            _loading = false
        }

        if (shouldMigrate) {
            savePluginSettings()
            saveSettings()
        }
    }

    function saveSettings() {
        if (_loading)
            return
        settingsFile.setText(JSON.stringify({
                                                "currentThemeName": currentThemeName,
                                                "customThemeFile": customThemeFile,
                                                "matugenScheme": matugenScheme,
                                                "runUserMatugenTemplates": runUserMatugenTemplates,
                                                "barTransparency": barTransparency,
                                                "barWidgetTransparency": barWidgetTransparency,
                                                "popupTransparency": popupTransparency,
                                                "dockTransparency": dockTransparency,
                                                "use24HourClock": use24HourClock,
                                                "useFahrenheit": useFahrenheit,
                                                "nightModeEnabled": nightModeEnabled,
                                                "weatherLocation": weatherLocation,
                                                "weatherCoordinates": weatherCoordinates,
                                                "useAutoLocation": useAutoLocation,
                                                "weatherEnabled": weatherEnabled,
                                                "showLauncherButton": showLauncherButton,
                                                "showWorkspaceSwitcher": showWorkspaceSwitcher,
                                                "showFocusedWindow": showFocusedWindow,
                                                "showWeather": showWeather,
                                                "showMusic": showMusic,
                                                "showClipboard": showClipboard,
                                                "showCpuUsage": showCpuUsage,
                                                "showMemUsage": showMemUsage,
                                                "showCpuTemp": showCpuTemp,
                                                "selectedGpuIndex": selectedGpuIndex,
                                                "enabledGpuPciIds": enabledGpuPciIds,
                                                "showSystemTray": showSystemTray,
                                                "showClock": showClock,
                                                "showNotificationButton": showNotificationButton,
                                                "showBattery": showBattery,
                                                "showControlCenterButton": showControlCenterButton,
                                                "controlCenterShowNetworkIcon": controlCenterShowNetworkIcon,
                                                "controlCenterShowBluetoothIcon": controlCenterShowBluetoothIcon,
                                                "controlCenterShowAudioIcon": controlCenterShowAudioIcon,
                                                "controlCenterWidgets": controlCenterWidgets,
                                                "showWorkspaceIndex": showWorkspaceIndex,
                                                "workspacePaddingCount": workspacePaddingCount,
                                                "showWorkspaceApps": showWorkspaceApps,
                                                "maxWorkspaceIcons": maxWorkspaceIcons,
                                                "workspacesPerMonitor": workspacesPerMonitor,
                                                "workspaceNameIcons": workspaceNameIcons,
                                                "waveProgressEnabled": waveProgressEnabled,
                                                "clockCompactMode": clockCompactMode,
                                                "keyboardLayoutShowFlag": keyboardLayoutShowFlag,
                                                "focusedWindowCompactMode": focusedWindowCompactMode,
                                                "runningAppsCompactMode": runningAppsCompactMode,
                                                "runningAppsCurrentWorkspace": runningAppsCurrentWorkspace,
                                                "clockDateFormat": clockDateFormat,
                                                "lockDateFormat": lockDateFormat,
                                                "mediaSize": mediaSize,
                                                "barLeftWidgets": barLeftWidgets,
                                                "barCenterWidgets": barCenterWidgets,
                                                "barRightWidgets": barRightWidgets,
                                                "appLauncherViewMode": appLauncherViewMode,
                                                "spotlightModalViewMode": spotlightModalViewMode,
                                                "networkPreference": networkPreference,
                                                "launcherLogoMode": launcherLogoMode,
                                                "launcherLogoCustomPath": launcherLogoCustomPath,
                                                "launcherLogoColorOverride": launcherLogoColorOverride,
                                                "launcherLogoColorInvertOnMode": launcherLogoColorInvertOnMode,
                                                "launcherLogoBrightness": launcherLogoBrightness,
                                                "launcherLogoContrast": launcherLogoContrast,
                                                "launcherLogoSizeOffset": launcherLogoSizeOffset,
                                                "fontFamily": fontFamily,
                                                "monoFontFamily": monoFontFamily,
                                                "fontWeight": fontWeight,
                                                "fontScale": fontScale,
                                                "barFontScale": barFontScale,
                                                "barIconScale": barIconScale,
                                                "notepadUseMonospace": notepadUseMonospace,
                                                "notepadFontFamily": notepadFontFamily,
                                                "notepadFontSize": notepadFontSize,
                                                "notepadShowLineNumbers": notepadShowLineNumbers,
                                                "notepadTransparencyOverride": notepadTransparencyOverride,
                                                "notepadLastCustomTransparency": notepadLastCustomTransparency,
                                                "showDock": showDock,
                                                "dockAutoHide": dockAutoHide,
                                                "dockGroupByApp": dockGroupByApp,
                                                "dockOpenOnOverview": dockOpenOnOverview,
                                                "dockPosition": dockPosition,
                                                "dockSpacing": dockSpacing,
                                                "dockBottomGap": dockBottomGap,
                                                "cornerRadius": cornerRadius,
                                                "notificationOverlayEnabled": notificationOverlayEnabled,
                                                "barAutoHide": barAutoHide,
                                                "barOpenOnOverview": barOpenOnOverview,
                                                "barVisible": barVisible,
                                                "barSpacing": barSpacing,
                                                "barBottomGap": barBottomGap,
                                                "barInnerPadding": barInnerPadding,
                                                "barSquareCorners": barSquareCorners,
                                                "barNoBackground": barNoBackground,
                                                "barGothCornersEnabled": barGothCornersEnabled,
                                                "barPosition": barPosition,
                                                "lockScreenShowPowerActions": lockScreenShowPowerActions,
                                                "hideBrightnessSlider": hideBrightnessSlider,
                                                "widgetBackgroundColor": widgetBackgroundColor,
                                                "surfaceBase": surfaceBase,
                                                "notificationTimeoutLow": notificationTimeoutLow,
                                                "notificationTimeoutNormal": notificationTimeoutNormal,
                                                "notificationTimeoutCritical": notificationTimeoutCritical,
                                                "notificationPopupPosition": notificationPopupPosition,
                                                "osdAlwaysShowValue": osdAlwaysShowValue,
                                                "screenPreferences": screenPreferences,
                                                "animationSpeed": animationSpeed
                                            }, null, 2))
    }

    function savePluginSettings() {
        if (_pluginSettingsLoading)
            return
        pluginSettingsFile.setText(JSON.stringify(pluginSettings, null, 2))
    }

    function setShowWorkspaceIndex(enabled) {
        showWorkspaceIndex = enabled
        saveSettings()
    }

    function setWorkspacePaddingCount(count) {
        workspacePaddingCount = count
        saveSettings()
    }

    function setShowWorkspaceApps(enabled) {
        showWorkspaceApps = enabled
        saveSettings()
    }

    function setMaxWorkspaceIcons(maxIcons) {
        maxWorkspaceIcons = maxIcons
        saveSettings()
    }

    function setWorkspacesPerMonitor(enabled) {
        workspacesPerMonitor = enabled
        saveSettings()
    }

    function setWaveProgressEnabled(enabled) {
        waveProgressEnabled = enabled
        saveSettings()
    }

    function setWorkspaceNameIcon(workspaceName, iconData) {
        var iconMap = JSON.parse(JSON.stringify(workspaceNameIcons))
        iconMap[workspaceName] = iconData
        workspaceNameIcons = iconMap
        saveSettings()
        workspaceIconsUpdated()
    }

    function removeWorkspaceNameIcon(workspaceName) {
        var iconMap = JSON.parse(JSON.stringify(workspaceNameIcons))
        delete iconMap[workspaceName]
        workspaceNameIcons = iconMap
        saveSettings()
        workspaceIconsUpdated()
    }

    function getWorkspaceNameIcon(workspaceName) {
        return workspaceNameIcons[workspaceName] || null
    }

    function hasNamedWorkspaces() {
        if (typeof NiriService === "undefined" || !CompositorService.isNiri)
            return false

        for (var i = 0; i < NiriService.allWorkspaces.length; i++) {
            var ws = NiriService.allWorkspaces[i]
            if (ws.name && ws.name.trim() !== "")
                return true
        }
        return false
    }

    function getNamedWorkspaces() {
        var namedWorkspaces = []
        if (typeof NiriService === "undefined" || !CompositorService.isNiri)
            return namedWorkspaces

        for (const ws of NiriService.allWorkspaces) {
            if (ws.name && ws.name.trim() !== "") {
                namedWorkspaces.push(ws.name)
            }
        }
        return namedWorkspaces
    }

    function setClockCompactMode(enabled) {
        clockCompactMode = enabled
        saveSettings()
    }

    function setKeyboardLayoutShowFlag(enabled) {
        keyboardLayoutShowFlag = enabled
        saveSettings()
    }

    function setFocusedWindowCompactMode(enabled) {
        focusedWindowCompactMode = enabled
        saveSettings()
    }

    function setRunningAppsCompactMode(enabled) {
        runningAppsCompactMode = enabled
        saveSettings()
    }

    function setRunningAppsCurrentWorkspace(enabled) {
        runningAppsCurrentWorkspace = enabled
        saveSettings()
    }

    function setClockDateFormat(format) {
        clockDateFormat = format || ""
        saveSettings()
    }

    function setLockDateFormat(format) {
        lockDateFormat = format || ""
        saveSettings()
    }

    function setMediaSize(size) {
        mediaSize = size
        saveSettings()
    }

    function applyStoredTheme() {
        if (typeof Theme !== "undefined")
            Theme.switchTheme(currentThemeName, false, false)
        else
            Qt.callLater(() => {
                             if (typeof Theme !== "undefined")
                             Theme.switchTheme(currentThemeName, false, false)
                         })
    }

    function setTheme(themeName) {
        currentThemeName = themeName
        saveSettings()
    }

    function setCustomThemeFile(filePath) {
        customThemeFile = filePath
        saveSettings()
    }

    function setMatugenScheme(scheme) {
        var normalized = scheme || "scheme-tonal-spot"
        if (matugenScheme === normalized)
            return

        matugenScheme = normalized
        saveSettings()

        if (typeof Theme !== "undefined") {
            Theme.generateSystemThemesFromCurrentTheme()
        }
    }

    function setRunUserMatugenTemplates(enabled) {
        if (runUserMatugenTemplates === enabled)
            return

        runUserMatugenTemplates = enabled
        saveSettings()

        if (typeof Theme !== "undefined") {
            Theme.generateSystemThemesFromCurrentTheme()
        }
    }

    function setBarTransparency(transparency) {
        barTransparency = transparency
        saveSettings()
    }

    function setBarWidgetTransparency(transparency) {
        barWidgetTransparency = transparency
        saveSettings()
    }

    function setPopupTransparency(transparency) {
        popupTransparency = transparency
        saveSettings()
    }

    function setDockTransparency(transparency) {
        dockTransparency = transparency
        saveSettings()
    }

    // New preference setters
    function setClockFormat(use24Hour) {
        use24HourClock = use24Hour
        saveSettings()
    }

    function setTemperatureUnit(fahrenheit) {
        useFahrenheit = fahrenheit
        saveSettings()
    }

    function setNightModeEnabled(enabled) {
        nightModeEnabled = enabled
        saveSettings()
    }

    // Widget visibility setters
    function setShowLauncherButton(enabled) {
        showLauncherButton = enabled
        saveSettings()
    }

    function setShowWorkspaceSwitcher(enabled) {
        showWorkspaceSwitcher = enabled
        saveSettings()
    }

    function setShowFocusedWindow(enabled) {
        showFocusedWindow = enabled
        saveSettings()
    }

    function setShowWeather(enabled) {
        showWeather = enabled
        saveSettings()
    }

    function setShowMusic(enabled) {
        showMusic = enabled
        saveSettings()
    }

    function setShowClipboard(enabled) {
        showClipboard = enabled
        saveSettings()
    }

    function setShowCpuUsage(enabled) {
        showCpuUsage = enabled
        saveSettings()
    }

    function setShowMemUsage(enabled) {
        showMemUsage = enabled
        saveSettings()
    }

    function setShowCpuTemp(enabled) {
        showCpuTemp = enabled
        saveSettings()
    }



    function setSelectedGpuIndex(index) {
        selectedGpuIndex = index
        saveSettings()
    }

    function setEnabledGpuPciIds(pciIds) {
        enabledGpuPciIds = pciIds
        saveSettings()
    }

    function setShowSystemTray(enabled) {
        showSystemTray = enabled
        saveSettings()
    }

    function setShowClock(enabled) {
        showClock = enabled
        saveSettings()
    }

    function setShowNotificationButton(enabled) {
        showNotificationButton = enabled
        saveSettings()
    }

    function setShowBattery(enabled) {
        showBattery = enabled
        saveSettings()
    }

    function setShowControlCenterButton(enabled) {
        showControlCenterButton = enabled
        saveSettings()
    }

    function setControlCenterShowNetworkIcon(enabled) {
        controlCenterShowNetworkIcon = enabled
        saveSettings()
    }

    function setControlCenterShowBluetoothIcon(enabled) {
        controlCenterShowBluetoothIcon = enabled
        saveSettings()
    }

    function setControlCenterShowAudioIcon(enabled) {
        controlCenterShowAudioIcon = enabled
        saveSettings()
    }
    function setControlCenterWidgets(widgets) {
        controlCenterWidgets = widgets
        saveSettings()
    }

    function setBarWidgetOrder(order) {
        barWidgetOrder = order
        saveSettings()
    }

    function setBarLeftWidgets(order) {
        barLeftWidgets = order
        updateListModel(leftWidgetsModel, order)
        saveSettings()
    }

    function setBarCenterWidgets(order) {
        barCenterWidgets = order
        updateListModel(centerWidgetsModel, order)
        saveSettings()
    }

    function setBarRightWidgets(order) {
        barRightWidgets = order
        updateListModel(rightWidgetsModel, order)
        saveSettings()
    }

    function updateListModel(listModel, order) {
        listModel.clear()
        for (var i = 0; i < order.length; i++) {
            var widgetId = typeof order[i] === "string" ? order[i] : order[i].id
            var enabled = typeof order[i] === "string" ? true : order[i].enabled
            var size = typeof order[i] === "string" ? undefined : order[i].size
            var selectedGpuIndex = typeof order[i] === "string" ? undefined : order[i].selectedGpuIndex
            var pciId = typeof order[i] === "string" ? undefined : order[i].pciId
            var mountPath = typeof order[i] === "string" ? undefined : order[i].mountPath
            var minimumWidth = typeof order[i] === "string" ? undefined : order[i].minimumWidth
            var item = {
                "widgetId": widgetId,
                "enabled": enabled
            }
            if (size !== undefined)
                item.size = size
            if (selectedGpuIndex !== undefined)
                item.selectedGpuIndex = selectedGpuIndex
            if (pciId !== undefined)
                item.pciId = pciId
            if (mountPath !== undefined)
                item.mountPath = mountPath
            if (minimumWidth !== undefined)
                item.minimumWidth = minimumWidth

            listModel.append(item)
        }
        // Emit signal to notify widgets that data has changed
        widgetDataChanged()
    }

    function resetBarWidgetsToDefault() {
        var defaultLeft = ["launcherButton", "workspaceSwitcher", "focusedWindow"]
        var defaultCenter = ["music", "clock", "weather"]
        var defaultRight = ["systemTray", "clipboard", "notificationButton", "battery", "controlCenterButton"]
        barLeftWidgets = defaultLeft
        barCenterWidgets = defaultCenter
        barRightWidgets = defaultRight
        updateListModel(leftWidgetsModel, defaultLeft)
        updateListModel(centerWidgetsModel, defaultCenter)
        updateListModel(rightWidgetsModel, defaultRight)
        showLauncherButton = true
        showWorkspaceSwitcher = true
        showFocusedWindow = true
        showWeather = true
        showMusic = true
        showClipboard = true
        showCpuUsage = true
        showMemUsage = true
        showCpuTemp = true
        showSystemTray = true
        showClock = true
        showNotificationButton = true
        showBattery = true
        showControlCenterButton = true
        saveSettings()
    }

    // View mode setters
    function setAppLauncherViewMode(mode) {
        appLauncherViewMode = mode
        saveSettings()
    }

    function setSpotlightModalViewMode(mode) {
        spotlightModalViewMode = mode
        saveSettings()
    }

    // Weather location setter
    function setWeatherLocation(displayName, coordinates) {
        weatherLocation = displayName
        weatherCoordinates = coordinates
        saveSettings()
    }

    function setAutoLocation(enabled) {
        useAutoLocation = enabled
        saveSettings()
    }

    function setWeatherEnabled(enabled) {
        weatherEnabled = enabled
        saveSettings()
    }

    // Network preference setter
    function setNetworkPreference(preference) {
        networkPreference = preference
        saveSettings()
    }



    function setLauncherLogoMode(mode) {
        launcherLogoMode = mode
        saveSettings()
    }

    function setLauncherLogoCustomPath(path) {
        launcherLogoCustomPath = path
        saveSettings()
    }

    function setLauncherLogoColorOverride(color) {
        launcherLogoColorOverride = color
        saveSettings()
    }

    function setLauncherLogoColorInvertOnMode(invert) {
        launcherLogoColorInvertOnMode = invert
        saveSettings()
    }

    function setLauncherLogoBrightness(brightness) {
        launcherLogoBrightness = brightness
        saveSettings()
    }

    function setLauncherLogoContrast(contrast) {
        launcherLogoContrast = contrast
        saveSettings()
    }

    function setLauncherLogoSizeOffset(offset) {
        launcherLogoSizeOffset = offset
        saveSettings()
    }

    function setFontFamily(family) {
        fontFamily = family
        saveSettings()
    }

    function setFontWeight(weight) {
        fontWeight = weight
        saveSettings()
    }

    function setMonoFontFamily(family) {
        monoFontFamily = family
        saveSettings()
    }

    function setFontScale(scale) {
        fontScale = scale
        saveSettings()
    }

    function setBarFontScale(scale) {
        barFontScale = scale
        saveSettings()
    }

    function setBarIconScale(scale) {
        barIconScale = scale
        saveSettings()
    }

    function setShowDock(enabled) {
        showDock = enabled
        if (enabled && dockPosition === barPosition) {
            if (barPosition === SettingsData.Position.Top) {
                setDockPosition(SettingsData.Position.Bottom)
                return
            }
            if (barPosition === SettingsData.Position.Bottom) {
                setDockPosition(SettingsData.Position.Top)
                return
            }
            if (barPosition === SettingsData.Position.Left) {
                setDockPosition(SettingsData.Position.Right)
                return
            }
            if (barPosition === SettingsData.Position.Right) {
                setDockPosition(SettingsData.Position.Left)
                return
            }
        }
        saveSettings()
    }

    function setDockAutoHide(enabled) {
        dockAutoHide = enabled
        saveSettings()
    }

    function setDockGroupByApp(enabled) {
        dockGroupByApp = enabled
        saveSettings()
    }

    function setdockOpenOnOverview(enabled) {
        dockOpenOnOverview = enabled
        saveSettings()
    }

    function setCornerRadius(radius) {
        cornerRadius = radius
        saveSettings()
    }

    function setNotificationOverlayEnabled(enabled) {
        notificationOverlayEnabled = enabled
        saveSettings()
    }

    function setBarAutoHide(enabled) {
        barAutoHide = enabled
        saveSettings()
    }

    function setBarOpenOnOverview(enabled) {
        barOpenOnOverview = enabled
        saveSettings()
    }

    function setBarVisible(visible) {
        // Панель всегда должна быть видимой, игнорируем false
        if (visible === false) {
            console.warn("Попытка скрыть панель игнорирована - панель всегда видима")
            return
        }
        barVisible = true
        saveSettings()
    }

    function toggleBarVisible() {
        barVisible = !barVisible
        saveSettings()
    }

    function setNotificationTimeoutLow(timeout) {
        notificationTimeoutLow = timeout
        saveSettings()
    }

    function setNotificationTimeoutNormal(timeout) {
        notificationTimeoutNormal = timeout
        saveSettings()
    }

    function setNotificationTimeoutCritical(timeout) {
        notificationTimeoutCritical = timeout
        saveSettings()
    }

    function setNotificationPopupPosition(position) {
        notificationPopupPosition = position
        saveSettings()
    }

    function setOsdAlwaysShowValue(enabled) {
        osdAlwaysShowValue = enabled
        saveSettings()
    }

    function sendTestNotifications() {
        sendTestNotification(0)
        testNotifTimer1.start()
        testNotifTimer2.start()
    }

    function sendTestNotification(index) {
        const notifications = [
            ["Notification Position Test", "Test notification 1 of 3 ~ Hi there!", "preferences-system"],
            ["Second Test", "Notification 2 of 3 ~ Check it out!", "applications-graphics"],
            ["Third Test", "Notification 3 of 3 ~ Enjoy!", "face-smile"]
        ]

        if (index < 0 || index >= notifications.length) {
            return
        }

        const notif = notifications[index]
        testNotificationProcess.command = ["notify-send", "-h", "int:transient:1", "-a", "sm1tee", "-i", notif[2], notif[0], notif[1]]
        testNotificationProcess.running = true
    }

    property Process testNotificationProcess

    testNotificationProcess: Process {
        command: []
        running: false
    }

    property Timer testNotifTimer1

    testNotifTimer1: Timer {
        interval: 400
        repeat: false
        onTriggered: sendTestNotification(1)
    }

    property Timer testNotifTimer2

    testNotifTimer2: Timer {
        interval: 800
        repeat: false
        onTriggered: sendTestNotification(2)
    }

    function setBarSpacing(spacing) {
        barSpacing = spacing
        saveSettings()
    }

    function setBarBottomGap(gap) {
        barBottomGap = gap
        saveSettings()
    }

    function setBarInnerPadding(padding) {
        barInnerPadding = padding
        saveSettings()
    }

    function setBarSquareCorners(enabled) {
        barSquareCorners = enabled
        saveSettings()
    }

    function setBarNoBackground(enabled) {
        barNoBackground = enabled
        saveSettings()
    }

    function setBarGothCornersEnabled(enabled) {
        barGothCornersEnabled = enabled
        saveSettings()
    }

    function setBarPosition(position) {
        barPosition = position
        if (position === SettingsData.Position.Bottom && dockPosition === SettingsData.Position.Bottom && showDock) {
            setDockPosition(SettingsData.Position.Top)
            return
        }
        if (position === SettingsData.Position.Top && dockPosition === SettingsData.Position.Top && showDock) {
            setDockPosition(SettingsData.Position.Bottom)
            return
        }
        if (position === SettingsData.Position.Left && dockPosition === SettingsData.Position.Left && showDock) {
            setDockPosition(SettingsData.Position.Right)
            return
        }
        if (position === SettingsData.Position.Right && dockPosition === SettingsData.Position.Right && showDock) {
            setDockPosition(SettingsData.Position.Left)
            return
        }
        saveSettings()
    }

    function setDockPosition(position) {
        dockPosition = position
        if (position === SettingsData.Position.Bottom && barPosition === SettingsData.Position.Bottom && showDock) {
            setBarPosition(SettingsData.Position.Top)
        }
        if (position === SettingsData.Position.Top && barPosition === SettingsData.Position.Top && showDock) {
            setBarPosition(SettingsData.Position.Bottom)
        }
        if (position === SettingsData.Position.Left && barPosition === SettingsData.Position.Left && showDock) {
            setBarPosition(SettingsData.Position.Right)
        }
        if (position === SettingsData.Position.Right && barPosition === SettingsData.Position.Right && showDock) {
            setBarPosition(SettingsData.Position.Left)
        }
        saveSettings()
        Qt.callLater(() => forceDockLayoutRefresh())
    }
    function setDockSpacing(spacing) {
        dockSpacing = spacing
        saveSettings()
    }
    function setDockBottomGap(gap) {
        dockBottomGap = gap
        saveSettings()
    }
    function setDockOpenOnOverview(enabled) {
        dockOpenOnOverview = enabled
        saveSettings()
    }

    function getPopupYPosition(barHeight) {
        const gothOffset = barGothCornersEnabled ? Theme.cornerRadius : 0
        return barHeight + barSpacing + barBottomGap - gothOffset + Theme.popupDistance
    }

    function getPopupTriggerPosition(globalPos, screen, barThickness, widgetWidth) {
        const screenX = screen ? screen.x : 0
        const screenY = screen ? screen.y : 0
        const relativeX = globalPos.x - screenX
        const relativeY = globalPos.y - screenY

        if (barPosition === SettingsData.Position.Left || barPosition === SettingsData.Position.Right) {
            return {
                x: relativeY,
                y: barThickness + barSpacing + Theme.popupDistance,
                width: widgetWidth
            }
        }
        return {
            x: relativeX,
            y: barThickness + barSpacing + barBottomGap + Theme.popupDistance,
            width: widgetWidth
        }
    }

    function setLockScreenShowPowerActions(enabled) {
        lockScreenShowPowerActions = enabled
        saveSettings()
    }

    function setHideBrightnessSlider(enabled) {
        hideBrightnessSlider = enabled
        saveSettings()
    }

    function setWidgetBackgroundColor(color) {
        widgetBackgroundColor = color
        saveSettings()
    }

    function setSurfaceBase(base) {
        surfaceBase = base
        saveSettings()
        if (typeof Theme !== "undefined") {
            Theme.generateSystemThemesFromCurrentTheme()
        }
    }

    function setScreenPreferences(prefs) {
        screenPreferences = prefs
        saveSettings()
    }

    function getFilteredScreens(componentId) {
        var prefs = screenPreferences && screenPreferences[componentId] || ["all"]
        if (prefs.includes("all")) {
            return Quickshell.screens
        }
        return Quickshell.screens.filter(screen => prefs.includes(screen.name))
    }

    // Plugin settings functions
    function getPluginSetting(pluginId, key, defaultValue) {
        if (!pluginSettings[pluginId]) {
            return defaultValue
        }
        return pluginSettings[pluginId][key] !== undefined ? pluginSettings[pluginId][key] : defaultValue
    }

    function setPluginSetting(pluginId, key, value) {
        if (!pluginSettings[pluginId]) {
            pluginSettings[pluginId] = {}
        }
        pluginSettings[pluginId][key] = value
        savePluginSettings()
    }

    function removePluginSettings(pluginId) {
        if (pluginSettings[pluginId]) {
            delete pluginSettings[pluginId]
            savePluginSettings()
        }
    }

    function getPluginSettingsForPlugin(pluginId) {
        return pluginSettings[pluginId] || {}
    }

    function setAnimationSpeed(speed) {
        animationSpeed = speed
        saveSettings()
    }

    function _shq(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    Component.onCompleted: {
        if (!isGreeterMode) {
            loadSettings()
            fontCheckTimer.start()
            initializeListModels()
        }
    }

    ListModel {
        id: leftWidgetsModel
    }

    ListModel {
        id: centerWidgetsModel
    }

    ListModel {
        id: rightWidgetsModel
    }

    Timer {
        id: fontCheckTimer

        interval: 3000
        repeat: false
        onTriggered: {
            var availableFonts = Qt.fontFamilies()
            var missingFonts = []
            if (fontFamily === defaultFontFamily && !availableFonts.includes(defaultFontFamily))
            missingFonts.push(defaultFontFamily)

            if (monoFontFamily === defaultMonoFontFamily && !availableFonts.includes(defaultMonoFontFamily))
            missingFonts.push(defaultMonoFontFamily)

            if (missingFonts.length > 0) {
                var message = "Missing fonts: " + missingFonts.join(", ") + ". Using system defaults."
                ToastService.showWarning(message)
            }
        }
    }

    property bool hasTriedDefaultSettings: false

    FileView {
        id: settingsFile

        path: isGreeterMode ? "" : StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/sm1teePanel/settings.json"
        blockLoading: true
        blockWrites: true
        atomicWrites: true
        watchChanges: !isGreeterMode
        onLoaded: {
            if (!isGreeterMode) {
                parseSettings(settingsFile.text())
                hasTriedDefaultSettings = false
            }
        }
        onLoadFailed: error => {
            if (!isGreeterMode && !hasTriedDefaultSettings) {
                hasTriedDefaultSettings = true
                defaultSettingsCheckProcess.running = true
            } else if (!isGreeterMode) {
                applyStoredTheme()
            }
        }
    }

    FileView {
        id: pluginSettingsFile

        path: isGreeterMode ? "" : pluginSettingsPath
        blockLoading: true
        blockWrites: true
        atomicWrites: true
        watchChanges: !isGreeterMode
        onLoaded: {
            if (!isGreeterMode) {
                parsePluginSettings(pluginSettingsFile.text())
            }
        }
        onLoadFailed: error => {
            if (!isGreeterMode) {
                pluginSettings = {}
            }
        }
    }



    Process {
        id: defaultSettingsCheckProcess

        command: ["sh", "-c", "CONFIG_DIR=\"" + _configDir
            + "/sm1teePanel\"; if [ -f \"$CONFIG_DIR/default-settings.json\" ] && [ ! -f \"$CONFIG_DIR/settings.json\" ]; then cp --no-preserve=mode \"$CONFIG_DIR/default-settings.json\" \"$CONFIG_DIR/settings.json\" && echo 'copied'; else echo 'not_found'; fi"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0) {
                settingsFile.reload()
            } else {
                // No default settings file found, just apply stored theme
                applyStoredTheme()
            }
        }
    }

    IpcHandler {
        function reveal(): string {
            root.setBarAutoHide(false)
            return "BAR_SHOW_SUCCESS"
        }

        function hide(): string {
            root.setBarAutoHide(true)
            return "BAR_AUTOHIDE_ENABLED"
        }

        function toggle(): string {
            root.setBarAutoHide(!root.barAutoHide)
            return root.barAutoHide ? "BAR_AUTOHIDE_ENABLED" : "BAR_SHOW_SUCCESS"
        }

        function status(): string {
            return root.barVisible ? "visible" : "hidden"
        }

        target: "bar"
    }
}
