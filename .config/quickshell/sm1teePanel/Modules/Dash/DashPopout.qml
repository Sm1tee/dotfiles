import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Dash

Popout {
    id: root

    property bool dashVisible: false
    property var triggerScreen: null
    property int currentTabIndex: 0

    function setTriggerPosition(x, y, width, section, screen) {
        triggerSection = section
        triggerScreen = screen
        triggerY = y

        if (section === "center" && (SettingsData.barPosition === SettingsData.Position.Top || SettingsData.barPosition === SettingsData.Position.Bottom)) {
            const screenWidth = screen ? screen.width : Screen.width
            triggerX = (screenWidth - popupWidth) / 2
            triggerWidth = popupWidth
        } else if (section === "center" && (SettingsData.barPosition === SettingsData.Position.Left || SettingsData.barPosition === SettingsData.Position.Right)) {
            const screenHeight = screen ? screen.height : Screen.height
            triggerX = (screenHeight - popupHeight) / 2
            triggerWidth = popupHeight
        } else {
            triggerX = x
            triggerWidth = width
        }
    }

    popupWidth: Math.max(700, Math.min(950, 700 * SettingsData.fontScale))
    popupHeight: contentLoader.item ? contentLoader.item.implicitHeight : Math.max(500, Math.min(700, 500 * SettingsData.fontScale))
    triggerX: Screen.width - 620 - Theme.spacingL
    triggerY: Math.max(26 + SettingsData.barInnerPadding + 4, Theme.barHeight - 4 - (8 - SettingsData.barInnerPadding)) + SettingsData.barSpacing + SettingsData.barBottomGap - 2
    triggerWidth: 80
    shouldBeVisible: dashVisible
    visible: shouldBeVisible


    onDashVisibleChanged: {
        if (dashVisible) {
            open()
        } else {
            close()
        }
    }

    onBackgroundClicked: {
        dashVisible = false
    }

    content: Component {
        Rectangle {
            id: mainContainer

            implicitHeight: contentColumn.height + Theme.spacingM * 2
            color: Theme.surfaceContainer
            radius: Theme.cornerRadius
            focus: true

            Component.onCompleted: {
                if (root.shouldBeVisible) {
                    forceActiveFocus()
                }
            }

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    root.dashVisible = false
                    event.accepted = true
                    return
                }

                // Tab/Shift+Tab для переключения вкладок
                if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) {
                    let nextIndex = root.currentTabIndex + 1
                    while (nextIndex < tabBar.model.length && tabBar.model[nextIndex] && tabBar.model[nextIndex].isAction) {
                        nextIndex++
                    }
                    if (nextIndex >= tabBar.model.length) {
                        nextIndex = 0
                    }
                    root.currentTabIndex = nextIndex
                    event.accepted = true
                    return
                }

                if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                    let prevIndex = root.currentTabIndex - 1
                    while (prevIndex >= 0 && tabBar.model[prevIndex] && tabBar.model[prevIndex].isAction) {
                        prevIndex--
                    }
                    if (prevIndex < 0) {
                        prevIndex = tabBar.model.length - 1
                        while (prevIndex >= 0 && tabBar.model[prevIndex] && tabBar.model[prevIndex].isAction) {
                            prevIndex--
                        }
                    }
                    if (prevIndex >= 0) {
                        root.currentTabIndex = prevIndex
                    }
                    event.accepted = true
                    return
                }

                // Передаём клавиши в WallpaperTab когда он активен
                if (root.currentTabIndex === 2 && wallpaperTabLoader.item?.handleKeyEvent) {
                    if (wallpaperTabLoader.item.handleKeyEvent(event)) {
                        event.accepted = true
                        return
                    }
                }
            }

            Connections {
                function onShouldBeVisibleChanged() {
                    if (root.shouldBeVisible) {
                        Qt.callLater(function() {
                            mainContainer.forceActiveFocus()
                        })
                    }
                }
                target: root
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(Theme.surfaceTint.r, Theme.surfaceTint.g, Theme.surfaceTint.b, 0.04)
                radius: parent.radius

                SequentialAnimation on opacity {
                    running: root.shouldBeVisible
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.08
                        duration: Theme.extraLongDuration
                        easing.type: Theme.standardEasing
                    }

                    NumberAnimation {
                        to: 0.02
                        duration: Theme.extraLongDuration
                        easing.type: Theme.standardEasing
                    }
                }
            }

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS

                TabBar {
                    id: tabBar

                    width: parent.width
                    currentIndex: root.currentTabIndex
                    spacing: Theme.spacingS
                    equalWidthTabs: true

                    model: {
                        let tabs = [
                            { icon: "dashboard", text: "Обзор" },
                            { icon: "music_note", text: "Медиа" },
                            { icon: "wallpaper", text: "Обои" }
                        ]
                        
                        if (SettingsData.weatherEnabled) {
                            tabs.push({ icon: "wb_sunny", text: "Погода" })
                        }
                        
                        tabs.push({ icon: "settings", text: "Настройки", isAction: true })
                        return tabs
                    }

                    onTabClicked: function(index) {
                        root.currentTabIndex = index
                    }

                    onActionTriggered: function(index) {
                        let settingsIndex = SettingsData.weatherEnabled ? 4 : 3
                        if (index === settingsIndex) {
                            dashVisible = false
                            PopoutService.openSettings()
                        }
                    }

                }

                Item {
                    width: parent.width
                    height: Theme.spacingXS
                }

                StackLayout {
                    id: pages
                    width: parent.width
                    implicitHeight: {
                        if (currentIndex === 0) return overviewTabLoader.item?.implicitHeight ?? 410
                        if (currentIndex === 1) return mediaTabLoader.item?.implicitHeight ?? 410
                        if (currentIndex === 2) return wallpaperTabLoader.item?.implicitHeight ?? 410
                        if (SettingsData.weatherEnabled && currentIndex === 3) return weatherTabLoader.item?.implicitHeight ?? 410
                        return 410
                    }
                    currentIndex: root.currentTabIndex

                    Loader {
                        id: overviewTabLoader
                        active: root.currentTabIndex === 0 || root.dashVisible
                        sourceComponent: OverviewTab {
                            onSwitchToWeatherTab: {
                                if (SettingsData.weatherEnabled) {
                                    tabBar.currentIndex = 3
                                    tabBar.tabClicked(3)
                                }
                            }

                            onSwitchToMediaTab: {
                                tabBar.currentIndex = 1
                                tabBar.tabClicked(1)
                            }
                        }
                    }

                    Loader {
                        id: mediaTabLoader
                        active: root.currentTabIndex === 1
                        sourceComponent: MediaPlayerTab {}
                    }

                    Loader {
                        id: wallpaperTabLoader
                        active: root.currentTabIndex === 2
                        sourceComponent: WallpaperTab {
                            targetScreen: root.triggerScreen
                        }
                    }

                    Loader {
                        id: weatherTabLoader
                        active: SettingsData.weatherEnabled && root.currentTabIndex === 3
                        sourceComponent: WeatherTab {}
                    }
                }
            }
        }
    }
}