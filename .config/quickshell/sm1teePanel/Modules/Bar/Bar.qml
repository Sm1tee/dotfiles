import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Modules
import qs.Modules.Bar.Widgets
import qs.Modules.Bar.Popouts
import qs.Services
import qs.Widgets

Item {
    id: root

    signal colorPickerRequested()

    Variants {
        model: SettingsData.getFilteredScreens("bar")

        delegate: PanelWindow {
            id: barWindow

            WlrLayershell.namespace: "quickshell:bar"

            property var modelData: item

            signal colorPickerRequested()

            onColorPickerRequested: root.colorPickerRequested()


            AxisContext {
                id: axis
                edge: {
                    switch (SettingsData.barPosition) {
                        case SettingsData.Position.Top:
                            return "top";
                        case SettingsData.Position.Bottom:
                            return "bottom";
                        case SettingsData.Position.Left:
                            return "left";
                        case SettingsData.Position.Right:
                            return "right";
                        default:
                            return "top";
                    }
                }
            }

            readonly property bool isVertical: axis.isVertical


            property bool gothCornersEnabled: SettingsData.barGothCornersEnabled
            property real wingtipsRadius: Theme.cornerRadius
            readonly property real _wingR: Math.max(0, wingtipsRadius)
            readonly property color _bgColor: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, topBarCore?.backgroundTransparency ?? SettingsData.barTransparency)
            readonly property real _dpr: {
                if (CompositorService.isNiri && barWindow.screen) {
                    const niriScale = NiriService.displayScales[barWindow.screen.name]
                    if (niriScale !== undefined) return niriScale
                }
                if (CompositorService.isHyprland && barWindow.screen) {
                    const hyprlandMonitor = Hyprland.monitors.values.find(m => m.name === barWindow.screen.name)
                    if (hyprlandMonitor?.scale !== undefined) return hyprlandMonitor.scale
                }
                return (barWindow.screen?.devicePixelRatio) || 1
            }

            property string screenName: modelData.name
            readonly property int notificationCount: NotificationService.notifications.length
            readonly property real effectiveBarThickness: Math.max(barWindow.widgetThickness + SettingsData.barInnerPadding + 4, Theme.barHeight - 4 - (8 - SettingsData.barInnerPadding))
            readonly property real widgetThickness: Math.max(20, 26 + SettingsData.barInnerPadding * 0.6)

            screen: modelData
            implicitHeight: !isVertical ? Theme.px(effectiveBarThickness + SettingsData.barSpacing + (SettingsData.barGothCornersEnabled ? _wingR : 0), _dpr) : 0
            implicitWidth: isVertical ? Theme.px(effectiveBarThickness + SettingsData.barSpacing + (SettingsData.barGothCornersEnabled ? _wingR : 0), _dpr) : 0
            color: "transparent"

            property var nativeInhibitor: null

            Component.onCompleted: {
                const fonts = Qt.fontFamilies()
                if (fonts.indexOf("Material Symbols Rounded") === -1) {
                    ToastService.showError("Please install Material Symbols Rounded and Restart your Shell. See README.md for instructions")
                }

                if (SettingsData.forceStatusBarLayoutRefresh) {
                    SettingsData.forceStatusBarLayoutRefresh.connect(() => {
                        Qt.callLater(() => {
                            stackLoader.visible = false
                            Qt.callLater(() => {
                                stackLoader.visible = true
                            })
                        })
                    })
                }

                inhibitorInitTimer.start()
            }

            Timer {
                id: inhibitorInitTimer
                interval: 300
                repeat: false
                onTriggered: {
                    if (SessionService.nativeInhibitorAvailable) {
                        createNativeInhibitor()
                    }
                }
            }

            Connections {
                target: PluginService
                function onPluginLoaded(pluginId) {
                    SettingsData.widgetDataChanged()
                }
                function onPluginUnloaded(pluginId) {
                    SettingsData.widgetDataChanged()
                }
            }

            function createNativeInhibitor() {
                if (!SessionService.nativeInhibitorAvailable) {
                    return
                }

                try {
                    const qmlString = `
                        import QtQuick
                        import Quickshell.Wayland

                        IdleInhibitor {
                            enabled: false
                        }
                    `

                    nativeInhibitor = Qt.createQmlObject(qmlString, barWindow, "Bar.NativeInhibitor")
                    nativeInhibitor.window = barWindow
                    nativeInhibitor.enabled = Qt.binding(() => SessionService.idleInhibited)
                    nativeInhibitor.enabledChanged.connect(function() {
                        if (SessionService.idleInhibited !== nativeInhibitor.enabled) {
                            SessionService.idleInhibited = nativeInhibitor.enabled
                            SessionService.inhibitorChanged()
                        }
                    })
                } catch (e) {
                    console.warn("Bar: Failed to create native IdleInhibitor:", e)
                    nativeInhibitor = null
                }
            }





            Connections {
                target: axis
                function onChanged() {
                    Qt.application.active
                    refreshTimer.restart()
                }
            }

            anchors.top: !isVertical ? (SettingsData.barPosition === SettingsData.Position.Top) : true
            anchors.bottom: !isVertical ? (SettingsData.barPosition === SettingsData.Position.Bottom) : true
            anchors.left: !isVertical ? true : (SettingsData.barPosition === SettingsData.Position.Left)
            anchors.right: !isVertical ? true : (SettingsData.barPosition === SettingsData.Position.Right)

            exclusiveZone: (!SettingsData.barVisible || topBarCore.autoHide) ? -1 : (barWindow.effectiveBarThickness + SettingsData.barSpacing + SettingsData.barBottomGap)

            Item {
                id: inputMask

                readonly property int barThickness: Theme.px(barWindow.effectiveBarThickness + SettingsData.barSpacing, barWindow._dpr)

                readonly property bool inOverviewWithShow: CompositorService.isNiri && NiriService.inOverview && SettingsData.barOpenOnOverview
                readonly property bool effectiveVisible: SettingsData.barVisible || inOverviewWithShow
                readonly property bool showing: effectiveVisible && (topBarCore.reveal
                                         || inOverviewWithShow
                                         || !topBarCore.autoHide)

                readonly property int maskThickness: showing ? barThickness : 1

                x: {
                    if (!axis.isVertical) {
                        return 0
                    } else {
                        switch (SettingsData.barPosition) {
                        case SettingsData.Position.Left:  return 0
                        case SettingsData.Position.Right: return parent.width - maskThickness
                        default: return 0
                        }
                    }
                }
                y: {
                    if (axis.isVertical) {
                        return 0
                    } else {
                        switch (SettingsData.barPosition) {
                        case SettingsData.Position.Top:    return 0
                        case SettingsData.Position.Bottom: return parent.height - maskThickness
                        default: return 0
                        }
                    }
                }
                width: axis.isVertical ? maskThickness : parent.width
                height: axis.isVertical ? parent.height : maskThickness
            }

            mask: Region {
                item: inputMask
            }

            Item {
                id: topBarCore
                anchors.fill: parent
                layer.enabled: true

                property real backgroundTransparency: SettingsData.barTransparency
                property bool autoHide: SettingsData.barAutoHide
                property bool revealSticky: false

        Timer {
            id: revealHold
            interval: 250
            repeat: false
            onTriggered: topBarCore.revealSticky = false
        }

        property bool reveal: {
            if (CompositorService.isNiri && NiriService.inOverview) {
                return SettingsData.barOpenOnOverview
            }
            return SettingsData.barVisible && (!autoHide || topBarMouseArea.containsMouse || hasActivePopout || revealSticky)
        }

        readonly property bool hasActivePopout: {
            const loaders = [{
                                 "loader": appDrawerLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": dashPopoutLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": processListPopoutLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": notificationCenterLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": batteryPopoutLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": controlCenterLoader,
                                 "prop": "shouldBeVisible"
                             }, {
                                 "loader": clipboardHistoryModalPopup,
                                 "prop": "visible"
                             }, {
                                 "loader": systemUpdateLoader,
                                 "prop": "shouldBeVisible"
                             }]
            return loaders.some(item => {
                if (item.loader) {
                    return item.loader?.item?.[item.prop]
                }
                return false
            })
        }

        Connections {
            function onBarTransparencyChanged() {
                topBarCore.backgroundTransparency = SettingsData.barTransparency
            }

            target: SettingsData
        }

        Connections {
            target: topBarMouseArea
            function onContainsMouseChanged() {
                if (topBarMouseArea.containsMouse) {
                    topBarCore.revealSticky = true
                    revealHold.stop()
                } else {
                    if (topBarCore.autoHide && !topBarCore.hasActivePopout) {
                        revealHold.restart()
                    }
                }
            }
        }

        onHasActivePopoutChanged: {
            if (!hasActivePopout && autoHide && !topBarMouseArea.containsMouse) {
                revealSticky = true
                revealHold.restart()
            }
        }

        MouseArea {
            id: topBarMouseArea
            y: !barWindow.isVertical ? (SettingsData.barPosition === SettingsData.Position.Bottom ? parent.height - height : 0) : 0
            x: barWindow.isVertical ? (SettingsData.barPosition === SettingsData.Position.Right ? parent.width - width : 0) : 0
            height: !barWindow.isVertical ? Theme.px(barWindow.effectiveBarThickness + SettingsData.barSpacing, barWindow._dpr) : undefined
            width: barWindow.isVertical ? Theme.px(barWindow.effectiveBarThickness + SettingsData.barSpacing, barWindow._dpr) : undefined
            anchors {
                left: !barWindow.isVertical ? parent.left : (SettingsData.barPosition === SettingsData.Position.Left ? parent.left : undefined)
                right: !barWindow.isVertical ? parent.right : (SettingsData.barPosition === SettingsData.Position.Right ? parent.right : undefined)
                top: barWindow.isVertical ? parent.top : undefined
                bottom: barWindow.isVertical ? parent.bottom : undefined
            }
            // Only enable mouse handling while hidden (for reveal-on-edge logic).
            readonly property bool inOverview: CompositorService.isNiri && NiriService.inOverview && SettingsData.barOpenOnOverview
            hoverEnabled: SettingsData.barAutoHide && !topBarCore.reveal && !inOverview
            acceptedButtons: Qt.NoButton
            enabled: SettingsData.barAutoHide && !topBarCore.reveal && !inOverview

            Item {
                id: topBarContainer
                anchors.fill: parent

                transform: Translate {
                    id: topBarSlide
                    x: barWindow.isVertical ? Theme.snap(topBarCore.reveal ? 0 : (SettingsData.barPosition === SettingsData.Position.Right ? barWindow.implicitWidth : -barWindow.implicitWidth), barWindow._dpr) : 0
                    y: !barWindow.isVertical ? Theme.snap(topBarCore.reveal ? 0 : (SettingsData.barPosition === SettingsData.Position.Bottom ? barWindow.implicitHeight : -barWindow.implicitHeight), barWindow._dpr) : 0

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Item {
                    id: barUnitInset
                    anchors.fill: parent
                    anchors.leftMargin: !barWindow.isVertical ? Theme.px(SettingsData.barSpacing, barWindow._dpr) : (axis.edge === "left" ? Theme.px(SettingsData.barSpacing, barWindow._dpr) : 0)
                    anchors.rightMargin: !barWindow.isVertical ? Theme.px(SettingsData.barSpacing, barWindow._dpr) : (axis.edge === "right" ? Theme.px(SettingsData.barSpacing, barWindow._dpr) : 0)
                    anchors.topMargin: barWindow.isVertical ? Theme.px(SettingsData.barSpacing, barWindow._dpr) : (axis.outerVisualEdge() === "bottom" ? 0 : Theme.px(SettingsData.barSpacing, barWindow._dpr))
                    anchors.bottomMargin: barWindow.isVertical ? Theme.px(SettingsData.barSpacing, barWindow._dpr) : (axis.outerVisualEdge() === "bottom" ? Theme.px(SettingsData.barSpacing, barWindow._dpr) : 0)

                    BarCanvas {
                        id: barBackground
                        barWindow: barWindow
                        axis: axis
                    }

                    Item {
                        id: topBarContent
                        anchors.fill: parent
                        anchors.leftMargin: !barWindow.isVertical ? Math.max(Theme.baseSpacingXS, SettingsData.barInnerPadding * 0.8) : SettingsData.barInnerPadding / 2
                        anchors.rightMargin: !barWindow.isVertical ? Math.max(Theme.baseSpacingXS, SettingsData.barInnerPadding * 0.8) : SettingsData.barInnerPadding / 2
                        anchors.topMargin: !barWindow.isVertical ? SettingsData.barInnerPadding / 2 : Math.max(Theme.baseSpacingXS, SettingsData.barInnerPadding * 0.8)
                        anchors.bottomMargin: !barWindow.isVertical ? SettingsData.barInnerPadding / 2 : Math.max(Theme.baseSpacingXS, SettingsData.barInnerPadding * 0.8)
                        clip: true

                        property int componentMapRevision: 0

                        function updateComponentMap() {
                            componentMapRevision++
                        }

                        readonly property int availableWidth: width
                        readonly property int launcherButtonWidth: 40
                        readonly property int workspaceSwitcherWidth: 120
                        readonly property int focusedAppMaxWidth: 456
                        readonly property int estimatedLeftSectionWidth: launcherButtonWidth + workspaceSwitcherWidth + focusedAppMaxWidth + (Theme.baseSpacingXS * 2)
                        readonly property int rightSectionWidth: 200
                        readonly property int clockWidth: 120
                        readonly property int mediaMaxWidth: 280
                        readonly property int weatherWidth: 80
                        readonly property bool validLayout: availableWidth > 100 && estimatedLeftSectionWidth > 0 && rightSectionWidth > 0
                        readonly property int clockLeftEdge: (availableWidth - clockWidth) / 2
                        readonly property int clockRightEdge: clockLeftEdge + clockWidth
                        readonly property int leftSectionRightEdge: estimatedLeftSectionWidth
                        readonly property int mediaLeftEdge: clockLeftEdge - mediaMaxWidth - Theme.baseSpacingS
                        readonly property int rightSectionLeftEdge: availableWidth - rightSectionWidth
                        readonly property int leftToClockGap: Math.max(0, clockLeftEdge - leftSectionRightEdge)
                        readonly property int leftToMediaGap: mediaMaxWidth > 0 ? Math.max(0, mediaLeftEdge - leftSectionRightEdge) : leftToClockGap
                        readonly property int mediaToClockGap: mediaMaxWidth > 0 ? Theme.baseSpacingS : 0
                        readonly property int clockToRightGap: validLayout ? Math.max(0, rightSectionLeftEdge - clockRightEdge) : 1000
                        readonly property bool spacingTight: !barWindow.isVertical && validLayout && (leftToMediaGap < 150 || clockToRightGap < 100)
                        readonly property bool overlapping: !barWindow.isVertical && validLayout && (leftToMediaGap < 100 || clockToRightGap < 50)

                        function getWidgetEnabled(enabled) {
                            return enabled !== false
                        }

                        function getWidgetSection(parentItem) {
                            let current = parentItem
                            while (current) {
                                if (current.objectName === "leftSection" || current === hLeftSection || current === vLeftSection) {
                                    return "left"
                                }
                                if (current.objectName === "centerSection" || current === hCenterSection || current === vCenterSection) {
                                    return "center"
                                }
                                if (current.objectName === "rightSection" || current === hRightSection || current === vRightSection) {
                                    return "right"
                                }
                                current = current.parent
                            }
                            return "left" // fallback
                        }

                        readonly property var widgetVisibility: ({
                                                                     "cpuUsage": DgopService.dgopAvailable,
                                                                     "memUsage": DgopService.dgopAvailable,
                                                                     "cpuTemp": DgopService.dgopAvailable,
                                                                     "network_speed_monitor": DgopService.dgopAvailable
                                                                 })

                        function getWidgetVisible(widgetId) {
                            return widgetVisibility[widgetId] ?? true
                        }

                        readonly property var componentMap: {
                            // This property depends on componentMapRevision to ensure it updates when plugins change
                            componentMapRevision;

                            let baseMap = {
                                "launcherButton": launcherButtonComponent,
                                "workspaceSwitcher": workspaceSwitcherComponent,
                                "focusedWindow": focusedWindowComponent,
                                "runningApps": runningAppsComponent,
                                "clock": clockComponent,
                                "music": mediaComponent,
                                "weather": weatherComponent,
                                "systemTray": systemTrayComponent,
                                "privacyIndicator": privacyIndicatorComponent,
                                "clipboard": clipboardComponent,
                                "cpuUsage": cpuUsageComponent,
                                "memUsage": memUsageComponent,
                                "diskUsage": diskUsageComponent,
                                "cpuTemp": cpuTempComponent,
                                "notificationButton": notificationButtonComponent,
                                "battery": batteryComponent,
                                "controlCenterButton": controlCenterButtonComponent,
                                "idleInhibitor": idleInhibitorComponent,
                                "spacer": spacerComponent,
                                "separator": separatorComponent,
                                "network_speed_monitor": networkComponent,
                                "keyboard_layout_name": keyboardLayoutNameComponent,
                                "notepadButton": notepadButtonComponent,
                                "colorPicker": colorPickerComponent,
                                "systemUpdate": systemUpdateComponent
                            }

                            // Merge with plugin widgets
                            let pluginMap = PluginService.getWidgetComponents()
                            return Object.assign(baseMap, pluginMap)
                        }

                        function getWidgetComponent(widgetId) {
                            return componentMap[widgetId] || null
                        }

                        readonly property var allComponents: ({
                            launcherButtonComponent: launcherButtonComponent,
                            workspaceSwitcherComponent: workspaceSwitcherComponent,
                            focusedWindowComponent: focusedWindowComponent,
                            runningAppsComponent: runningAppsComponent,
                            clockComponent: clockComponent,
                            mediaComponent: mediaComponent,
                            weatherComponent: weatherComponent,
                            systemTrayComponent: systemTrayComponent,
                            privacyIndicatorComponent: privacyIndicatorComponent,
                            clipboardComponent: clipboardComponent,
                            cpuUsageComponent: cpuUsageComponent,
                            memUsageComponent: memUsageComponent,
                            diskUsageComponent: diskUsageComponent,
                            cpuTempComponent: cpuTempComponent,
                            notificationButtonComponent: notificationButtonComponent,
                            batteryComponent: batteryComponent,
                            controlCenterButtonComponent: controlCenterButtonComponent,
                            idleInhibitorComponent: idleInhibitorComponent,
                            spacerComponent: spacerComponent,
                            separatorComponent: separatorComponent,
                            networkComponent: networkComponent,
                            keyboardLayoutNameComponent: keyboardLayoutNameComponent,
                            notepadButtonComponent: notepadButtonComponent,
                            colorPickerComponent: colorPickerComponent,
                            systemUpdateComponent: systemUpdateComponent
                        })

                        Item {
                            id: stackContainer
                            anchors.fill: parent

                            Item {
                                id: horizontalStack
                                anchors.fill: parent
                                visible: !axis.isVertical

                                LeftSection {
                                    id: hLeftSection
                                    anchors {
                                        left: parent.left
                                        verticalCenter: parent.verticalCenter
                                    }
                                    axis: axis
                                    widgetsModel: SettingsData.barLeftWidgetsModel
                                    components: topBarContent.allComponents
                                    noBackground: SettingsData.barNoBackground
                                    parentScreen: barWindow.screen
                                    widgetThickness: barWindow.widgetThickness
                                    barThickness: barWindow.effectiveBarThickness
                                }

                                RightSection {
                                    id: hRightSection
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    axis: axis
                                    widgetsModel: SettingsData.barRightWidgetsModel
                                    components: topBarContent.allComponents
                                    noBackground: SettingsData.barNoBackground
                                    parentScreen: barWindow.screen
                                    widgetThickness: barWindow.widgetThickness
                                    barThickness: barWindow.effectiveBarThickness
                                }

                                CenterSection {
                                    id: hCenterSection
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    axis: axis
                                    widgetsModel: SettingsData.barCenterWidgetsModel
                                    components: topBarContent.allComponents
                                    noBackground: SettingsData.barNoBackground
                                    parentScreen: barWindow.screen
                                    widgetThickness: barWindow.widgetThickness
                                    barThickness: barWindow.effectiveBarThickness
                                }
                            }

                            Item {
                                id: verticalStack
                                anchors.fill: parent
                                visible: axis.isVertical

                                LeftSection {
                                    id: vLeftSection
                                    width: parent.width
                                    anchors {
                                        top: parent.top
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    axis: axis
                                    widgetsModel: SettingsData.barLeftWidgetsModel
                                    components: topBarContent.allComponents
                                    noBackground: SettingsData.barNoBackground
                                    parentScreen: barWindow.screen
                                    widgetThickness: barWindow.widgetThickness
                                    barThickness: barWindow.effectiveBarThickness
                                }

                                CenterSection {
                                    id: vCenterSection
                                    width: parent.width
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    axis: axis
                                    widgetsModel: SettingsData.barCenterWidgetsModel
                                    components: topBarContent.allComponents
                                    noBackground: SettingsData.barNoBackground
                                    parentScreen: barWindow.screen
                                    widgetThickness: barWindow.widgetThickness
                                    barThickness: barWindow.effectiveBarThickness
                                }

                                RightSection {
                                    id: vRightSection
                                    width: parent.width
                                    height: implicitHeight
                                    anchors {
                                        bottom: parent.bottom
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    axis: axis
                                    widgetsModel: SettingsData.barRightWidgetsModel
                                    components: topBarContent.allComponents
                                    noBackground: SettingsData.barNoBackground
                                    parentScreen: barWindow.screen
                                    widgetThickness: barWindow.widgetThickness
                                    barThickness: barWindow.effectiveBarThickness
                                }
                            }
                        }



                        Component {
                            id: clipboardComponent

                            ClipboardButton {
                                widgetThickness: barWindow.widgetThickness
                                barThickness: barWindow.effectiveBarThickness
                                section: topBarContent.getWidgetSection(parent)
                                parentScreen: barWindow.screen
                                onClicked: {
                                    clipboardHistoryModalPopup.toggle()
                                }
                            }
                        }

                        Component {
                            id: launcherButtonComponent

                            LauncherButton {
                                isActive: false
                                widgetThickness: barWindow.widgetThickness
                                barThickness: barWindow.effectiveBarThickness
                                section: topBarContent.getWidgetSection(parent)
                                popupTarget: appDrawerLoader.item
                                parentScreen: barWindow.screen
                                onClicked: {
                                    appDrawerLoader.active = true
                                    appDrawerLoader.item?.toggle()
                                }
                            }
                        }

                        Component {
                            id: workspaceSwitcherComponent

                            WorkspaceSwitcher {
                                screenName: barWindow.screenName
                                widgetHeight: barWindow.widgetThickness
                            }
                        }

                        Component {
                            id: focusedWindowComponent

                            FocusedApp {
                                availableWidth: topBarContent.leftToMediaGap
                                widgetThickness: barWindow.widgetThickness
                                parentScreen: barWindow.screen
                            }
                        }

                        Component {
                            id: runningAppsComponent

                            RunningApps {
                                widgetThickness: barWindow.widgetThickness
                                section: topBarContent.getWidgetSection(parent)
                                parentScreen: barWindow.screen
                                topBar: topBarContent
                            }
                        }

                        Component {
                            id: clockComponent

                            Clock {
                                compactMode: topBarContent.overlapping
                                barThickness: barWindow.effectiveBarThickness
                                widgetThickness: barWindow.widgetThickness
                                section: topBarContent.getWidgetSection(parent) || "center"
                                popupTarget: {
                                    dashPopoutLoader.active = true
                                    return dashPopoutLoader.item
                                }
                                parentScreen: barWindow.screen
                                onClockClicked: {
                                    dashPopoutLoader.active = true
                                    if (dashPopoutLoader.item) {
                                        dashPopoutLoader.item.dashVisible = !dashPopoutLoader.item.dashVisible
                                        dashPopoutLoader.item.currentTabIndex = 0
                                    }
                                }
                            }
                        }

                        Component {
                            id: mediaComponent

                            Media {
                                compactMode: topBarContent.spacingTight || topBarContent.overlapping
                                barThickness: barWindow.effectiveBarThickness
                                widgetThickness: barWindow.widgetThickness
                                section: topBarContent.getWidgetSection(parent) || "center"
                                popupTarget: {
                                    dashPopoutLoader.active = true
                                    return dashPopoutLoader.item
                                }
                                parentScreen: barWindow.screen
                                onClicked: {
                                    dashPopoutLoader.active = true
                                    if (dashPopoutLoader.item) {
                                        dashPopoutLoader.item.dashVisible = !dashPopoutLoader.item.dashVisible
                                        dashPopoutLoader.item.currentTabIndex = 1
                                    }
                                }
                            }
                        }

                        Component {
                            id: weatherComponent

                            Weather {
                                barThickness: barWindow.effectiveBarThickness
                                widgetThickness: barWindow.widgetThickness
                                section: topBarContent.getWidgetSection(parent) || "center"
                                popupTarget: {
                                    dashPopoutLoader.active = true
                                    return dashPopoutLoader.item
                                }
                                parentScreen: barWindow.screen
                                onClicked: {
                                    dashPopoutLoader.active = true
                                    if (dashPopoutLoader.item) {
                                        dashPopoutLoader.item.dashVisible = !dashPopoutLoader.item.dashVisible
                                        dashPopoutLoader.item.currentTabIndex = 2
                                    }
                                }
                            }
                        }

                        Component {
                            id: systemTrayComponent

                            SystemTrayBar {
                                parentWindow: root
                                parentScreen: barWindow.screen
                                widgetThickness: barWindow.widgetThickness
                                isAtBottom: SettingsData.barPosition === SettingsData.Position.Bottom
                                visible: SettingsData.getFilteredScreens("systemTray").includes(barWindow.screen)
                            }
                        }

                        Component {
                            id: privacyIndicatorComponent

                            PrivacyIndicator {
                                widgetThickness: barWindow.widgetThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                parentScreen: barWindow.screen
                            }
                        }

                        Component {
                            id: cpuUsageComponent

                            CpuMonitor {
                                barThickness: barWindow.effectiveBarThickness
                                widgetThickness: barWindow.widgetThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    processListPopoutLoader.active = true
                                    return processListPopoutLoader.item
                                }
                                parentScreen: barWindow.screen
                                widgetData: parent.widgetData
                                toggleProcessList: () => {
                                                       processListPopoutLoader.active = true
                                                       return processListPopoutLoader.item?.toggle()
                                                   }
                            }
                        }

                        Component {
                            id: memUsageComponent

                            RamMonitor {
                                barThickness: barWindow.effectiveBarThickness
                                widgetThickness: barWindow.widgetThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    processListPopoutLoader.active = true
                                    return processListPopoutLoader.item
                                }
                                parentScreen: barWindow.screen
                                widgetData: parent.widgetData
                                toggleProcessList: () => {
                                                       processListPopoutLoader.active = true
                                                       return processListPopoutLoader.item?.toggle()
                                                   }
                            }
                        }

                        Component {
                            id: diskUsageComponent

                            DiskUsage {
                                widgetThickness: barWindow.widgetThickness
                                widgetData: parent.widgetData
                                parentScreen: barWindow.screen
                            }
                        }

                        Component {
                            id: cpuTempComponent

                            CpuTemperature {
                                barThickness: barWindow.effectiveBarThickness
                                widgetThickness: barWindow.widgetThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    processListPopoutLoader.active = true
                                    return processListPopoutLoader.item
                                }
                                parentScreen: barWindow.screen
                                widgetData: parent.widgetData
                                toggleProcessList: () => {
                                                       processListPopoutLoader.active = true
                                                       return processListPopoutLoader.item?.toggle()
                                                   }
                            }
                        }



                        Component {
                            id: networkComponent

                            NetworkMonitor {}
                        }

                        Component {
                            id: notificationButtonComponent

                            NotificationCenterButton {
                                hasUnread: barWindow.notificationCount > 0
                                isActive: notificationCenterLoader.item ? notificationCenterLoader.item.shouldBeVisible : false
                                widgetThickness: barWindow.widgetThickness
                                barThickness: barWindow.effectiveBarThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    notificationCenterLoader.active = true
                                    return notificationCenterLoader.item
                                }
                                parentScreen: barWindow.screen
                                onClicked: {
                                    notificationCenterLoader.active = true
                                    notificationCenterLoader.item?.toggle()
                                }
                            }
                        }

                        Component {
                            id: batteryComponent

                            Battery {
                                batteryPopupVisible: batteryPopoutLoader.item ? batteryPopoutLoader.item.shouldBeVisible : false
                                widgetThickness: barWindow.widgetThickness
                                barThickness: barWindow.effectiveBarThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    batteryPopoutLoader.active = true
                                    return batteryPopoutLoader.item
                                }
                                parentScreen: barWindow.screen
                                onToggleBatteryPopup: {
                                    batteryPopoutLoader.active = true
                                    batteryPopoutLoader.item?.toggle()
                                }
                            }
                        }

                        Component {
                            id: controlCenterButtonComponent

                            ControlCenterButton {
                                isActive: controlCenterLoader.item ? controlCenterLoader.item.shouldBeVisible : false
                                widgetThickness: barWindow.widgetThickness
                                barThickness: barWindow.effectiveBarThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    controlCenterLoader.active = true
                                    return controlCenterLoader.item
                                }
                                parentScreen: barWindow.screen
                                widgetData: parent.widgetData
                                onClicked: {
                                    controlCenterLoader.active = true
                                    if (!controlCenterLoader.item) {
                                        return
                                    }
                                    controlCenterLoader.item.triggerScreen = barWindow.screen
                                    controlCenterLoader.item.toggle()
                                }
                            }
                        }

                        Component {
                            id: idleInhibitorComponent

                            IdleInhibitor {
                                widgetThickness: barWindow.widgetThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                parentScreen: barWindow.screen
                            }
                        }

                        Component {
                            id: spacerComponent

                            Item {
                                width: barWindow.isVertical ? barWindow.widgetThickness : (parent.spacerSize || 20)
                                height: barWindow.isVertical ? (parent.spacerSize || 20) : barWindow.widgetThickness
                                implicitWidth: width
                                implicitHeight: height

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                                    border.width: 1
                                    radius: 2
                                    visible: false

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.NoButton      // do not consume clicks
                                        propagateComposedEvents: true     // let events pass through
                                        cursorShape: Qt.ArrowCursor       // don't override widget cursors
                                        onEntered: parent.visible = true
                                        onExited: parent.visible = false
                                    }
                                }
                            }
                        }

                        Component {
                            id: separatorComponent

                            Rectangle {
                                width: barWindow.isVertical ? barWindow.widgetThickness * 0.67 : 1
                                height: barWindow.isVertical ? 1 : barWindow.widgetThickness * 0.67
                                implicitWidth: width
                                implicitHeight: height
                                color: Theme.outline
                                opacity: 0.3
                            }
                        }

                        Component {
                            id: keyboardLayoutNameComponent

                            KeyboardLayoutName {}
                        }

                        Component {
                            id: notepadButtonComponent

                            NotepadButton {
                                isVertical: barWindow.isVertical
                                widgetThickness: barWindow.widgetThickness
                                barThickness: barWindow.effectiveBarThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                parentScreen: barWindow.screen
                            }
                        }

                        Component {
                            id: colorPickerComponent

                            ColorPicker {
                                widgetThickness: barWindow.widgetThickness
                                barThickness: barWindow.effectiveBarThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                parentScreen: barWindow.screen
                                onColorPickerRequested: {
                                    barWindow.colorPickerRequested()
                                }
                            }
                        }

                        Component {
                            id: systemUpdateComponent

                            SystemUpdate {
                                isActive: systemUpdateLoader.item ? systemUpdateLoader.item.shouldBeVisible : false
                                widgetThickness: barWindow.widgetThickness
                                barThickness: barWindow.effectiveBarThickness
                                section: topBarContent.getWidgetSection(parent) || "right"
                                popupTarget: {
                                    systemUpdateLoader.active = true
                                    return systemUpdateLoader.item
                                }
                                parentScreen: barWindow.screen
                                onClicked: {
                                    systemUpdateLoader.active = true
                                    systemUpdateLoader.item?.toggle()
                                }
                            }
                        }

                    }
                }
            }
        }
        }
        }
    }
}
