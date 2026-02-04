import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: barTab

    property var parentModal: null

    function getScreenPreferences(componentId) {
        return SettingsData.screenPreferences && SettingsData.screenPreferences[componentId] || ["all"];
    }

    function setScreenPreferences(componentId, screenNames) {
        var prefs = SettingsData.screenPreferences || {};
        prefs[componentId] = screenNames;
        SettingsData.setScreenPreferences(prefs);
    }

    function getWidgetsForPopup() {
        return baseWidgetDefinitions.filter(widget => {
            if (widget.warning && widget.warning.includes("Plugin is disabled")) {
                return false
            }
            return true
        })
    }

    property var baseWidgetDefinitions: {
        var coreWidgets = [{
            "id": "launcherButton",
            "text": "Лаунчер",
            "description": "Быстрый доступ к запуску приложений",
            "icon": "apps",
            "enabled": true
        }, {
            "id": "workspaceSwitcher",
            "text": "Рабочие столы",
            "description": "Показывает текущий рабочий стол и позволяет переключаться",
            "icon": "view_module",
            "enabled": true
        }, {
            "id": "focusedWindow",
            "text": "Активное окно",
            "description": "Отображает название активного приложения",
            "icon": "window",
            "enabled": true
        }, {
            "id": "runningApps",
            "text": "Запущенные приложения",
            "description": "Показывает все запущенные приложения с индикацией фокуса",
            "icon": "apps",
            "enabled": true
        }, {
            "id": "clock",
            "text": "Часы",
            "description": "Текущее время и дата",
            "icon": "schedule",
            "enabled": true
        }, {
            "id": "weather",
            "text": "Погода",
            "description": "Текущие погодные условия и температура",
            "icon": "wb_sunny",
            "enabled": true
        }, {
            "id": "music",
            "text": "Медиа",
            "description": "Управление воспроизведением медиа",
            "icon": "music_note",
            "enabled": true
        }, {
            "id": "clipboard",
            "text": "Буфер обмена",
            "description": "Доступ к истории буфера обмена",
            "icon": "content_paste",
            "enabled": true
        }, {
            "id": "cpuUsage",
            "text": "Загрузка CPU",
            "description": "Индикатор загрузки процессора",
            "icon": "memory",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Требуется утилита 'dgop'" : undefined
        }, {
            "id": "memUsage",
            "text": "Использование памяти",
            "description": "Индикатор использования оперативной памяти",
            "icon": "developer_board",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Требуется утилита 'dgop'" : undefined
        }, {
            "id": "diskUsage",
            "text": "Использование диска",
            "description": "Процент использования",
            "icon": "storage",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Требуется утилита 'dgop'" : undefined
        }, {
            "id": "cpuTemp",
            "text": "Температура CPU",
            "description": "Отображение температуры процессора",
            "icon": "device_thermostat",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Требуется утилита 'dgop'" : undefined
        }, {
            "id": "systemTray",
            "text": "Системный трей",
            "description": "Иконки системных уведомлений",
            "icon": "notifications",
            "enabled": true
        }, {
            "id": "privacyIndicator",
            "text": "Индикатор приватности",
            "description": "Показывает когда активны микрофон, камера или запись экрана",
            "icon": "privacy_tip",
            "enabled": true
        }, {
            "id": "controlCenterButton",
            "text": "Центр управления",
            "description": "Доступ к системным настройкам и управлению",
            "icon": "settings",
            "enabled": true
        }, {
            "id": "notificationButton",
            "text": "Центр уведомлений",
            "description": "Доступ к уведомлениям и режиму не беспокоить",
            "icon": "notifications",
            "enabled": true
        }, {
            "id": "battery",
            "text": "Батарея",
            "description": "Уровень заряда и управление питанием",
            "icon": "battery_std",
            "enabled": true
        }, {
            "id": "idleInhibitor",
            "text": "Блокировка простоя",
            "description": "Предотвращает отключение экрана",
            "icon": "motion_sensor_active",
            "enabled": true
        }, {
            "id": "spacer",
            "text": "Отступ",
            "description": "Настраиваемое пустое пространство",
            "icon": "more_horiz",
            "enabled": true
        }, {
            "id": "separator",
            "text": "Разделитель",
            "description": "Визуальный разделитель между виджетами",
            "icon": "remove",
            "enabled": true
        },
        {
            "id": "network_speed_monitor",
            "text": "Монитор скорости сети",
            "description": "Отображение скорости загрузки и выгрузки",
            "icon": "network_check",
            "warning": !DgopService.dgopAvailable ? "Требуется утилита 'dgop'" : undefined,
            "enabled": DgopService.dgopAvailable
        }, {
            "id": "keyboard_layout_name",
            "text": "Раскладка клавиатуры",
            "description": "Отображает активную раскладку и позволяет переключать",
            "icon": "keyboard",
        }, {
            "id": "notepadButton",
            "text": "Блокнот",
            "description": "Быстрый доступ к блокноту",
            "icon": "assignment",
            "enabled": true
        }, {
            "id": "colorPicker",
            "text": "Выбор цвета",
            "description": "Быстрый доступ к выбору цвета",
            "icon": "palette",
            "enabled": true
        }, {
            "id": "systemUpdate",
            "text": "Обновления системы",
            "description": "Проверка обновлений системы",
            "icon": "update",
            "enabled": SystemUpdateService.distributionSupported
        }]

        var allPluginVariants = PluginService.getAllPluginVariants()
        for (var i = 0; i < allPluginVariants.length; i++) {
            var variant = allPluginVariants[i]
            coreWidgets.push({
                "id": variant.fullId,
                "text": variant.name,
                "description": variant.description,
                "icon": variant.icon,
                "enabled": variant.loaded,
                "warning": !variant.loaded ? "Плагин отключен - включите в настройках плагинов для использования" : undefined
            })
        }

        return coreWidgets
    }
    property var defaultLeftWidgets: [{
            "id": "launcherButton",
            "enabled": true
        }, {
            "id": "workspaceSwitcher",
            "enabled": true
        }]
    property var defaultCenterWidgets: [{
            "id": "clock",
            "enabled": true
        }]
    property var defaultRightWidgets: [{
            "id": "keyboard_layout_name",
            "enabled": true
        }, {
            "id": "systemTray",
            "enabled": true
        }, {
            "id": "clipboard",
            "enabled": true
        }, {
            "id": "notificationButton",
            "enabled": true
        }, {
            "id": "battery",
            "enabled": true
        }, {
            "id": "controlCenterButton",
            "enabled": true
        }]

    function addWidgetToSection(widgetId, targetSection) {
        var widgetObj = {
            "id": widgetId,
            "enabled": true
        }
        if (widgetId === "spacer")
            widgetObj.size = 20

        if (widgetId === "controlCenterButton") {
            widgetObj.showNetworkIcon = true
            widgetObj.showBluetoothIcon = true
            widgetObj.showAudioIcon = true
        }
        if (widgetId === "diskUsage") {
            widgetObj.mountPath = "/"
        }
        if (widgetId === "cpuUsage" || widgetId === "memUsage" || widgetId === "cpuTemp") {
            widgetObj.minimumWidth = true
        }

        var widgets = []
        if (targetSection === "left") {
            widgets = SettingsData.barLeftWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setBarLeftWidgets(widgets)
        } else if (targetSection === "center") {
            widgets = SettingsData.barCenterWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setBarCenterWidgets(widgets)
        } else if (targetSection === "right") {
            widgets = SettingsData.barRightWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setBarRightWidgets(widgets)
        }
    }

    function removeWidgetFromSection(sectionId, widgetIndex) {
        var widgets = []
        if (sectionId === "left") {
            widgets = SettingsData.barLeftWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
            }
            SettingsData.setBarLeftWidgets(widgets)
        } else if (sectionId === "center") {
            widgets = SettingsData.barCenterWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
            }
            SettingsData.setBarCenterWidgets(widgets)
        } else if (sectionId === "right") {
            widgets = SettingsData.barRightWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
            }
            SettingsData.setBarRightWidgets(widgets)
        }
    }

    function handleItemEnabledChanged(sectionId, itemId, enabled) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.barLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.barCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.barRightWidgets.slice()
        for (var i = 0; i < widgets.length; i++) {
            var widget = widgets[i]
            var widgetId = typeof widget === "string" ? widget : widget.id
            if (widgetId === itemId) {
                if (typeof widget === "string") {
                    widgets[i] = {
                        "id": widget,
                        "enabled": enabled
                    }
                } else {
                    var newWidget = {
                        "id": widget.id,
                        "enabled": enabled
                    }
                    if (widget.size !== undefined)
                        newWidget.size = widget.size
                    if (widget.selectedGpuIndex !== undefined)
                        newWidget.selectedGpuIndex = widget.selectedGpuIndex
                    if (widget.pciId !== undefined)
                        newWidget.pciId = widget.pciId
                    if (widget.id === "controlCenterButton") {
                        newWidget.showNetworkIcon = widget.showNetworkIcon !== undefined ? widget.showNetworkIcon : true
                        newWidget.showBluetoothIcon = widget.showBluetoothIcon !== undefined ? widget.showBluetoothIcon : true
                        newWidget.showAudioIcon = widget.showAudioIcon !== undefined ? widget.showAudioIcon : true
                    }
                    widgets[i] = newWidget
                }
                break
            }
        }
        if (sectionId === "left")
            SettingsData.setBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setBarRightWidgets(widgets)
    }

    function handleItemOrderChanged(sectionId, newOrder) {
        if (sectionId === "left")
            SettingsData.setBarLeftWidgets(newOrder)
        else if (sectionId === "center")
            SettingsData.setBarCenterWidgets(newOrder)
        else if (sectionId === "right")
            SettingsData.setBarRightWidgets(newOrder)
    }

    function handleSpacerSizeChanged(sectionId, widgetIndex, newSize) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.barLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.barCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.barRightWidgets.slice()
        
        if (widgetIndex >= 0 && widgetIndex < widgets.length) {
            var widget = widgets[widgetIndex]
            var widgetId = typeof widget === "string" ? widget : widget.id
            if (widgetId === "spacer") {
                if (typeof widget === "string") {
                    widgets[widgetIndex] = {
                        "id": widget,
                        "enabled": true,
                        "size": newSize
                    }
                } else {
                    var newWidget = {
                        "id": widget.id,
                        "enabled": widget.enabled,
                        "size": newSize
                    }
                    if (widget.selectedGpuIndex !== undefined)
                        newWidget.selectedGpuIndex = widget.selectedGpuIndex
                    if (widget.pciId !== undefined)
                        newWidget.pciId = widget.pciId
                    if (widget.id === "controlCenterButton") {
                        newWidget.showNetworkIcon = widget.showNetworkIcon !== undefined ? widget.showNetworkIcon : true
                        newWidget.showBluetoothIcon = widget.showBluetoothIcon !== undefined ? widget.showBluetoothIcon : true
                        newWidget.showAudioIcon = widget.showAudioIcon !== undefined ? widget.showAudioIcon : true
                    }
                    widgets[widgetIndex] = newWidget
                }
            }
        }
        
        if (sectionId === "left")
            SettingsData.setBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setBarRightWidgets(widgets)
    }

    function handleGpuSelectionChanged(sectionId, widgetIndex, selectedGpuIndex) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.barLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.barCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.barRightWidgets.slice()

        if (widgetIndex >= 0 && widgetIndex < widgets.length) {
            var widget = widgets[widgetIndex]
            if (typeof widget === "string") {
                widgets[widgetIndex] = {
                    "id": widget,
                    "enabled": true,
                    "selectedGpuIndex": selectedGpuIndex,
                    "pciId": DgopService.availableGpus
                             && DgopService.availableGpus.length
                             > selectedGpuIndex ? DgopService.availableGpus[selectedGpuIndex].pciId : ""
                }
            } else {
                var newWidget = {
                    "id": widget.id,
                    "enabled": widget.enabled,
                    "selectedGpuIndex": selectedGpuIndex,
                    "pciId": DgopService.availableGpus
                             && DgopService.availableGpus.length
                             > selectedGpuIndex ? DgopService.availableGpus[selectedGpuIndex].pciId : ""
                }
                if (widget.size !== undefined)
                    newWidget.size = widget.size
                widgets[widgetIndex] = newWidget
            }
        }

        if (sectionId === "left")
            SettingsData.setBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setBarRightWidgets(widgets)
    }

    function handleDiskMountSelectionChanged(sectionId, widgetIndex, mountPath) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.barLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.barCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.barRightWidgets.slice()

        if (widgetIndex >= 0 && widgetIndex < widgets.length) {
            var widget = widgets[widgetIndex]
            if (typeof widget === "string") {
                widgets[widgetIndex] = {
                    "id": widget,
                    "enabled": true,
                    "mountPath": mountPath
                }
            } else {
                var newWidget = {
                    "id": widget.id,
                    "enabled": widget.enabled,
                    "mountPath": mountPath
                }
                if (widget.size !== undefined)
                    newWidget.size = widget.size
                if (widget.selectedGpuIndex !== undefined)
                    newWidget.selectedGpuIndex = widget.selectedGpuIndex
                if (widget.pciId !== undefined)
                    newWidget.pciId = widget.pciId
                if (widget.id === "controlCenterButton") {
                    newWidget.showNetworkIcon = widget.showNetworkIcon !== undefined ? widget.showNetworkIcon : true
                    newWidget.showBluetoothIcon = widget.showBluetoothIcon !== undefined ? widget.showBluetoothIcon : true
                    newWidget.showAudioIcon = widget.showAudioIcon !== undefined ? widget.showAudioIcon : true
                }
                widgets[widgetIndex] = newWidget
            }
        }

        if (sectionId === "left")
            SettingsData.setBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setBarRightWidgets(widgets)
    }

    function handleControlCenterSettingChanged(sectionId, widgetIndex, settingName, value) {
        // Control Center settings are global, not per-widget instance
        if (settingName === "showNetworkIcon") {
            SettingsData.setControlCenterShowNetworkIcon(value)
        } else if (settingName === "showBluetoothIcon") {
            SettingsData.setControlCenterShowBluetoothIcon(value)
        } else if (settingName === "showAudioIcon") {
            SettingsData.setControlCenterShowAudioIcon(value)
        }
    }

    function handleMinimumWidthChanged(sectionId, widgetIndex, enabled) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.barLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.barCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.barRightWidgets.slice()

        if (widgetIndex >= 0 && widgetIndex < widgets.length) {
            var widget = widgets[widgetIndex]
            if (typeof widget === "string") {
                widgets[widgetIndex] = {
                    "id": widget,
                    "enabled": true,
                    "minimumWidth": enabled
                }
            } else {
                var newWidget = {
                    "id": widget.id,
                    "enabled": widget.enabled,
                    "minimumWidth": enabled
                }
                if (widget.size !== undefined)
                    newWidget.size = widget.size
                if (widget.selectedGpuIndex !== undefined)
                    newWidget.selectedGpuIndex = widget.selectedGpuIndex
                if (widget.pciId !== undefined)
                    newWidget.pciId = widget.pciId
                if (widget.mountPath !== undefined)
                    newWidget.mountPath = widget.mountPath
                if (widget.id === "controlCenterButton") {
                    newWidget.showNetworkIcon = widget.showNetworkIcon !== undefined ? widget.showNetworkIcon : true
                    newWidget.showBluetoothIcon = widget.showBluetoothIcon !== undefined ? widget.showBluetoothIcon : true
                    newWidget.showAudioIcon = widget.showAudioIcon !== undefined ? widget.showAudioIcon : true
                }
                widgets[widgetIndex] = newWidget
            }
        }

        if (sectionId === "left")
            SettingsData.setBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setBarRightWidgets(widgets)
    }

    function getItemsForSection(sectionId) {
        var widgets = []
        var widgetData = []
        if (sectionId === "left")
            widgetData = SettingsData.barLeftWidgets || []
        else if (sectionId === "center")
            widgetData = SettingsData.barCenterWidgets || []
        else if (sectionId === "right")
            widgetData = SettingsData.barRightWidgets || []
        widgetData.forEach(widget => {
                               var widgetId = typeof widget === "string" ? widget : widget.id
                               var widgetEnabled = typeof widget
                               === "string" ? true : widget.enabled
                               var widgetSize = typeof widget === "string" ? undefined : widget.size
                               var widgetSelectedGpuIndex = typeof widget
                               === "string" ? undefined : widget.selectedGpuIndex
                               var widgetPciId = typeof widget
                               === "string" ? undefined : widget.pciId
                               var widgetMountPath = typeof widget
                               === "string" ? undefined : widget.mountPath
                               var widgetShowNetworkIcon = typeof widget === "string" ? undefined : widget.showNetworkIcon
                               var widgetShowBluetoothIcon = typeof widget === "string" ? undefined : widget.showBluetoothIcon
                               var widgetShowAudioIcon = typeof widget === "string" ? undefined : widget.showAudioIcon
                               var widgetMinimumWidth = typeof widget === "string" ? undefined : widget.minimumWidth
                               var widgetDef = baseWidgetDefinitions.find(w => {
                                                                              return w.id === widgetId
                                                                          })
                               if (widgetDef) {
                                   var item = Object.assign({}, widgetDef)
                                   item.enabled = widgetEnabled
                                   if (widgetSize !== undefined)
                                   item.size = widgetSize
                                   if (widgetSelectedGpuIndex !== undefined)
                                   item.selectedGpuIndex = widgetSelectedGpuIndex
                                   if (widgetPciId !== undefined)
                                   item.pciId = widgetPciId
                                   if (widgetMountPath !== undefined)
                                   item.mountPath = widgetMountPath
                                   if (widgetShowNetworkIcon !== undefined)
                                   item.showNetworkIcon = widgetShowNetworkIcon
                                   if (widgetShowBluetoothIcon !== undefined)
                                   item.showBluetoothIcon = widgetShowBluetoothIcon
                                   if (widgetShowAudioIcon !== undefined)
                                   item.showAudioIcon = widgetShowAudioIcon
                                   if (widgetMinimumWidth !== undefined)
                                   item.minimumWidth = widgetMinimumWidth

                                   widgets.push(item)
                               }
                           })
        return widgets
    }

    Component.onCompleted: {
        // Only set defaults if widgets have never been configured (null/undefined, not empty array)
        if (!SettingsData.barLeftWidgets)
            SettingsData.setBarLeftWidgets(defaultLeftWidgets)

        if (!SettingsData.barCenterWidgets)
            SettingsData.setBarCenterWidgets(defaultCenterWidgets)

        if (!SettingsData.barRightWidgets)
            SettingsData.setBarRightWidgets(defaultRightWidgets)
        const sections = ["left", "center", "right"]
        sections.forEach(sectionId => {
                             var widgets = []
                             if (sectionId === "left")
                             widgets = SettingsData.barLeftWidgets.slice()
                             else if (sectionId === "center")
                             widgets = SettingsData.barCenterWidgets.slice()
                             else if (sectionId === "right")
                             widgets = SettingsData.barRightWidgets.slice()
                             var updated = false
                             for (var i = 0; i < widgets.length; i++) {
                                 var widget = widgets[i]
                                 if (typeof widget === "object"
                                     && widget.id === "spacer"
                                     && !widget.size) {
                                     widgets[i] = Object.assign({}, widget, {
                                                                    "size": 20
                                                                })
                                     updated = true
                                 }
                             }
                             if (updated) {
                                 if (sectionId === "left")
                                 SettingsData.setBarLeftWidgets(widgets)
                                 else if (sectionId === "center")
                                 SettingsData.setBarCenterWidgets(widgets)
                                 else if (sectionId === "right")
                                 SettingsData.setBarRightWidgets(widgets)
                             }
                         })
    }

    Flickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        anchors.bottomMargin: Theme.spacingS
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingXL

            // Position Section
            StyledRect {
                width: parent.width
                height: positionSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: positionSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "vertical_align_center"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Позиция"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    ButtonGroup {
                        id: positionButtonGroup
                        width: parent.width
                        fillWidth: true
                        buttonPadding: Theme.spacingXS
                        spacing: 2
                        checkEnabled: false
                        model: ["Сверху", "Снизу", "Слева", "Справа"]
                            currentIndex: {
                                switch (SettingsData.barPosition) {
                                    case SettingsData.Position.Top: return 0
                                    case SettingsData.Position.Bottom: return 1
                                    case SettingsData.Position.Left: return 2
                                    case SettingsData.Position.Right: return 3
                                    default: return 0
                                }
                            }
                            onSelectionChanged: (index, selected) => {
                                if (selected) {
                                    switch (index) {
                                        case 0: SettingsData.setBarPosition(SettingsData.Position.Top); break
                                        case 1: SettingsData.setBarPosition(SettingsData.Position.Bottom); break
                                        case 2: SettingsData.setBarPosition(SettingsData.Position.Left); break
                                        case 3: SettingsData.setBarPosition(SettingsData.Position.Right); break
                                    }
                                }
                            }
                        }
                    }
                }

            // Bar Auto-hide Section
            StyledRect {
                width: parent.width
                height: barAutoHideSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: barAutoHideSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "monitor"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - barAllDisplaysToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Отображать на всех мониторах"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Показывать на всех подключенных дисплеях"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        Toggle {
                            id: barAllDisplaysToggle
                            anchors.verticalCenter: parent.verticalCenter
                            checked: barTab.getScreenPreferences("bar").includes("all")
                            onToggled: checked => {
                                if (checked)
                                    barTab.setScreenPreferences("bar", ["all"])
                                else
                                    barTab.setScreenPreferences("bar", [])
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
                            name: "visibility_off"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - autoHideToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Автоскрытие"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Автоматически скрывать панель"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        Toggle {
                            id: autoHideToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.barAutoHide
                            onToggled: toggled => {
                                           return SettingsData.setBarAutoHide(
                                               toggled)
                                       }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                        visible: CompositorService.isNiri
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM
                        visible: CompositorService.isNiri

                        Icon {
                            name: "fullscreen"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - overviewToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Показывать в обзоре"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Всегда показывать панель когда открыт обзор niri"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        Toggle {
                            id: overviewToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.barOpenOnOverview
                            onToggled: toggled => {
                                           return SettingsData.setBarOpenOnOverview(
                                               toggled)
                                       }
                        }
                    }
                }
            }


            // Spacing
            StyledRect {
                width: parent.width
                height: barSpacingSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: barSpacingSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "space_bar"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Отступы"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Отступ от края (0 = от края до края)"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item {
                                width: parent.width - edgeSpacingText.implicitWidth - resetEdgeSpacingBtn.width - Theme.spacingS - Theme.spacingM
                                height: 1

                                StyledText {
                                    id: edgeSpacingText
                                    visible: false
                                    text: "Отступ от края (0 = от края до края)"
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }

                            ActionButton {
                                id: resetEdgeSpacingBtn
                                buttonSize: Theme.iconSize
                                iconName: "refresh"
                                iconSize: Theme.iconSizeSmall
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    edgeSpacingSlider.value = 0
                                    SettingsData.setBarSpacing(0)
                                }
                            }

                            Item {
                                width: Theme.spacingS
                                height: 1
                            }
                        }

                        Slider {
                            id: edgeSpacingSlider
                            width: parent.width
                            height: 24
                            value: SettingsData.barSpacing
                            minimum: 0
                            maximum: 32
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setBarSpacing(
                                                          newValue)
                                                  }

                            Binding {
                                target: edgeSpacingSlider
                                property: "value"
                                value: SettingsData.barSpacing
                                restoreMode: Binding.RestoreBinding
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Зарезервированное пространство"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item {
                                width: parent.width - exclusiveZoneLabel.implicitWidth - resetExclusiveZoneBtn.width - Theme.spacingS - Theme.spacingM
                                height: 1

                                StyledText {
                                    id: exclusiveZoneLabel
                                    visible: false
                                    text: "Зарезервированное пространство"
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }

                            ActionButton {
                                id: resetExclusiveZoneBtn
                                buttonSize: Theme.iconSize
                                iconName: "refresh"
                                iconSize: Theme.iconSizeSmall
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    exclusiveZoneSlider.value = 0
                                    SettingsData.setBarBottomGap(0)
                                }
                            }

                            Item {
                                width: Theme.spacingS
                                height: 1
                            }
                        }
                        


                        Slider {
                            id: exclusiveZoneSlider
                            width: parent.width
                            height: 24
                            value: SettingsData.barBottomGap
                            minimum: -50
                            maximum: 50
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setBarBottomGap(
                                                          newValue)
                                                  }

                            Binding {
                                target: exclusiveZoneSlider
                                property: "value"
                                value: SettingsData.barBottomGap
                                restoreMode: Binding.RestoreBinding
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Размер"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item {
                                width: parent.width - sizeText.implicitWidth - resetSizeBtn.width - Theme.spacingS - Theme.spacingM
                                height: 1

                                StyledText {
                                    id: sizeText
                                    visible: false
                                    text: "Размер"
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }

                            ActionButton {
                                id: resetSizeBtn
                                buttonSize: Theme.iconSize
                                iconName: "refresh"
                                iconSize: Theme.iconSizeSmall
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    SettingsData.setBarInnerPadding(12)
                                }
                            }

                            Item {
                                width: Theme.spacingS
                                height: 1
                            }
                        }

                        Slider {
                            id: sizeSlider
                            width: parent.width
                            height: 24
                            value: SettingsData.barInnerPadding
                            minimum: 0
                            maximum: 24
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setBarInnerPadding(
                                                          newValue)
                                                  }

                            Binding {
                                target: sizeSlider
                                property: "value"
                                value: SettingsData.barInnerPadding
                                restoreMode: Binding.RestoreBinding
                            }
                        }
                    }


                    Toggle {
                        width: parent.width
                        text: "Острые углы"
                        description: "Панель с прямыми углами вместо скругленных."
                        checked: SettingsData.barSquareCorners
                        onToggled: checked => {
                                       SettingsData.setBarSquareCorners(
                                           checked)
                                   }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Toggle {
                        width: parent.width
                        text: "Прозрачные виджеты"
                        description: "Виджеты без фона и с минимальными отступами."
                        checked: SettingsData.barNoBackground
                        onToggled: checked => {
                                       SettingsData.setBarNoBackground(
                                           checked)
                                   }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Toggle {
                        width: parent.width
                        text: "Изогнутые края"
                        description: "Декоративные изогнутые выступы по краям панели."
                        checked: SettingsData.barGothCornersEnabled
                        onToggled: checked => {
                                       SettingsData.setBarGothCornersEnabled(
                                           checked)
                                   }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Rectangle {
                        width: parent.width
                        height: 60
                        radius: Theme.cornerRadius
                        color: "transparent"

                        Column {
                            anchors.left: parent.left
                            anchors.right: barFontScaleControls.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Масштаб шрифта панели"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Независимый масштаб шрифтов для панели"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: parent.width
                            }
                        }

                        Row {
                            id: barFontScaleControls

                            width: 180
                            height: 36
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            ActionButton {
                                buttonSize: 32
                                iconName: "remove"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.barFontScale > 0.5
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.round(Math.max(0.5, SettingsData.barFontScale - 0.1) * 100) / 100
                                    SettingsData.setBarFontScale(newScale)
                                }
                            }

                            StyledRect {
                                width: 60
                                height: 32
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                border.width: 0

                                StyledText {
                                    anchors.centerIn: parent
                                    text: (SettingsData.barFontScale * 100).toFixed(0) + "%"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }
                            }

                            ActionButton {
                                buttonSize: 32
                                iconName: "add"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.barFontScale < 2.0
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.round(Math.min(2.0, SettingsData.barFontScale + 0.1) * 100) / 100
                                    SettingsData.setBarFontScale(newScale)
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

                    Rectangle {
                        width: parent.width
                        height: 60
                        radius: Theme.cornerRadius
                        color: "transparent"

                        Column {
                            anchors.left: parent.left
                            anchors.right: barIconScaleControls.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Масштаб иконок панели"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Независимый масштаб иконок для панели"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: parent.width
                            }
                        }

                        Row {
                            id: barIconScaleControls

                            width: 180
                            height: 36
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            ActionButton {
                                buttonSize: 32
                                iconName: "remove"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.barIconScale > 0.5
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.round(Math.max(0.5, SettingsData.barIconScale - 0.1) * 100) / 100
                                    SettingsData.setBarIconScale(newScale)
                                }
                            }

                            StyledRect {
                                width: 60
                                height: 32
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                border.width: 0

                                StyledText {
                                    anchors.centerIn: parent
                                    text: (SettingsData.barIconScale * 100).toFixed(0) + "%"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }
                            }

                            ActionButton {
                                buttonSize: 32
                                iconName: "add"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.barIconScale < 2.0
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.round(Math.min(2.0, SettingsData.barIconScale + 0.1) * 100) / 100
                                    SettingsData.setBarIconScale(newScale)
                                }
                            }
                        }
                    }
                }
            }

            // Widget Management Section
            StyledRect {
                width: parent.width
                height: widgetManagementSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: widgetManagementSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            id: widgetIcon
                            name: "widgets"
                            size: Theme.iconSize
                            color: Theme.primary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        StyledText {
                            id: widgetTitle
                            text: "Управление виджетами"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item {
                            height: 1
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "Сбросить"
                            iconName: "refresh"
                            backgroundColor: Theme.surfaceContainerHigh
                            textColor: Theme.surfaceText
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: {
                                SettingsData.setBarLeftWidgets(defaultLeftWidgets)
                                SettingsData.setBarCenterWidgets(defaultCenterWidgets)
                                SettingsData.setBarRightWidgets(defaultRightWidgets)
                            }
                        }
                    }

                    StyledText {
                        width: parent.width
                        text: "Перетаскивайте виджеты для изменения порядка в секциях."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingL

                // Left/Top Section
                StyledRect {
                    width: parent.width
                    height: leftSection.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHigh
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                          Theme.outline.b, 0.2)
                    border.width: 0

                    WidgetsTabSection {
                        id: leftSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        title: SettingsData.barIsVertical ? "Верхняя секция" : "Левая секция"
                        titleIcon: "format_align_left"
                        sectionId: "left"
                        allWidgets: barTab.baseWidgetDefinitions
                        items: barTab.getItemsForSection("left")
                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  barTab.handleItemEnabledChanged(
                                                      sectionId,
                                                      itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                barTab.handleItemOrderChanged(
                                                    "left", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets
                                         = barTab.getWidgetsForPopup()
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.show()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            barTab.removeWidgetFromSection(
                                                sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 barTab.handleSpacerSizeChanged(
                                                     sectionId, widgetIndex, newSize)
                                             }
                        onCompactModeChanged: (widgetId, value) => {
                                                  if (widgetId === "clock") {
                                                      SettingsData.setClockCompactMode(
                                                          value)
                                                  } else if (widgetId === "music") {
                                                      SettingsData.setMediaSize(
                                                          value)
                                                  } else if (widgetId === "focusedWindow") {
                                                      SettingsData.setFocusedWindowCompactMode(
                                                          value)
                                                  } else if (widgetId === "runningApps") {
                                                      SettingsData.setRunningAppsCompactMode(
                                                          value)
                                                  }
                                              }
                        onControlCenterSettingChanged: (sectionId, widgetIndex, settingName, value) => {
                                                           handleControlCenterSettingChanged(sectionId, widgetIndex, settingName, value)
                                                       }
                        onGpuSelectionChanged: (sectionId, widgetIndex, selectedIndex) => {
                                                   barTab.handleGpuSelectionChanged(
                                                       sectionId, widgetIndex,
                                                       selectedIndex)
                                               }
                        onDiskMountSelectionChanged: (sectionId, widgetIndex, mountPath) => {
                                                         barTab.handleDiskMountSelectionChanged(
                                                             sectionId, widgetIndex, mountPath)
                                                     }
                        onMinimumWidthChanged: (sectionId, widgetIndex, enabled) => {
                                                   barTab.handleMinimumWidthChanged(
                                                       sectionId, widgetIndex, enabled)
                                               }
                    }
                }

                // Center Section
                StyledRect {
                    width: parent.width
                    height: centerSection.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHigh
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                          Theme.outline.b, 0.2)
                    border.width: 0

                    WidgetsTabSection {
                        id: centerSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        title: "Центральная секция"
                        titleIcon: "format_align_center"
                        sectionId: "center"
                        allWidgets: barTab.baseWidgetDefinitions
                        items: barTab.getItemsForSection("center")
                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  barTab.handleItemEnabledChanged(
                                                      sectionId,
                                                      itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                barTab.handleItemOrderChanged(
                                                    "center", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets
                                         = barTab.getWidgetsForPopup()
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.show()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            barTab.removeWidgetFromSection(
                                                sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 barTab.handleSpacerSizeChanged(
                                                     sectionId, widgetIndex, newSize)
                                             }
                        onCompactModeChanged: (widgetId, value) => {
                                                  if (widgetId === "clock") {
                                                      SettingsData.setClockCompactMode(
                                                          value)
                                                  } else if (widgetId === "music") {
                                                      SettingsData.setMediaSize(
                                                          value)
                                                  } else if (widgetId === "focusedWindow") {
                                                      SettingsData.setFocusedWindowCompactMode(
                                                          value)
                                                  } else if (widgetId === "runningApps") {
                                                      SettingsData.setRunningAppsCompactMode(
                                                          value)
                                                  }
                                              }
                        onControlCenterSettingChanged: (sectionId, widgetIndex, settingName, value) => {
                                                           handleControlCenterSettingChanged(sectionId, widgetIndex, settingName, value)
                                                       }
                        onGpuSelectionChanged: (sectionId, widgetIndex, selectedIndex) => {
                                                   barTab.handleGpuSelectionChanged(
                                                       sectionId, widgetIndex,
                                                       selectedIndex)
                                               }
                        onDiskMountSelectionChanged: (sectionId, widgetIndex, mountPath) => {
                                                         barTab.handleDiskMountSelectionChanged(
                                                             sectionId, widgetIndex, mountPath)
                                                     }
                        onMinimumWidthChanged: (sectionId, widgetIndex, enabled) => {
                                                   barTab.handleMinimumWidthChanged(
                                                       sectionId, widgetIndex, enabled)
                                               }
                    }
                }

                // Right/Bottom Section
                StyledRect {
                    width: parent.width
                    height: rightSection.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHigh
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                          Theme.outline.b, 0.2)
                    border.width: 0

                    WidgetsTabSection {
                        id: rightSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        title: SettingsData.barIsVertical ? "Нижняя секция" : "Правая секция"
                        titleIcon: "format_align_right"
                        sectionId: "right"
                        allWidgets: barTab.baseWidgetDefinitions
                        items: barTab.getItemsForSection("right")
                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  barTab.handleItemEnabledChanged(
                                                      sectionId,
                                                      itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                barTab.handleItemOrderChanged(
                                                    "right", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets
                                         = barTab.getWidgetsForPopup()
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.show()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            barTab.removeWidgetFromSection(
                                                sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 barTab.handleSpacerSizeChanged(
                                                     sectionId, widgetIndex, newSize)
                                             }
                        onCompactModeChanged: (widgetId, value) => {
                                                  if (widgetId === "clock") {
                                                      SettingsData.setClockCompactMode(
                                                          value)
                                                  } else if (widgetId === "music") {
                                                      SettingsData.setMediaSize(
                                                          value)
                                                  } else if (widgetId === "focusedWindow") {
                                                      SettingsData.setFocusedWindowCompactMode(
                                                          value)
                                                  } else if (widgetId === "runningApps") {
                                                      SettingsData.setRunningAppsCompactMode(
                                                          value)
                                                  }
                                              }
                        onControlCenterSettingChanged: (sectionId, widgetIndex, settingName, value) => {
                                                           handleControlCenterSettingChanged(sectionId, widgetIndex, settingName, value)
                                                       }
                        onGpuSelectionChanged: (sectionId, widgetIndex, selectedIndex) => {
                                                   barTab.handleGpuSelectionChanged(
                                                       sectionId, widgetIndex,
                                                       selectedIndex)
                                               }
                        onDiskMountSelectionChanged: (sectionId, widgetIndex, mountPath) => {
                                                         barTab.handleDiskMountSelectionChanged(
                                                             sectionId, widgetIndex, mountPath)
                                                     }
                        onMinimumWidthChanged: (sectionId, widgetIndex, enabled) => {
                                                   barTab.handleMinimumWidthChanged(
                                                       sectionId, widgetIndex, enabled)
                                               }
                    }
                }
            }
        }
    }

    WidgetSelectionPopup {
        id: widgetSelectionPopup

        parentModal: barTab.parentModal
        onWidgetSelected: (widgetId, targetSection) => {
                              barTab.addWidgetToSection(widgetId,
                                                           targetSection)
                          }
    }
}
