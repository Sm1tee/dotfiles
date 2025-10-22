import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: dankBarTab

    property var parentModal: null

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
        }, {
            "id": "focusedWindow",
            "enabled": true
        }]
    property var defaultCenterWidgets: [{
            "id": "music",
            "enabled": true
        }, {
            "id": "clock",
            "enabled": true
        }, {
            "id": "weather",
            "enabled": true
        }]
    property var defaultRightWidgets: [{
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
            widgets = SettingsData.dankBarLeftWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setDankBarLeftWidgets(widgets)
        } else if (targetSection === "center") {
            widgets = SettingsData.dankBarCenterWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setDankBarCenterWidgets(widgets)
        } else if (targetSection === "right") {
            widgets = SettingsData.dankBarRightWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setDankBarRightWidgets(widgets)
        }
    }

    function removeWidgetFromSection(sectionId, widgetIndex) {
        var widgets = []
        if (sectionId === "left") {
            widgets = SettingsData.dankBarLeftWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
            }
            SettingsData.setDankBarLeftWidgets(widgets)
        } else if (sectionId === "center") {
            widgets = SettingsData.dankBarCenterWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
            }
            SettingsData.setDankBarCenterWidgets(widgets)
        } else if (sectionId === "right") {
            widgets = SettingsData.dankBarRightWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
            }
            SettingsData.setDankBarRightWidgets(widgets)
        }
    }

    function handleItemEnabledChanged(sectionId, itemId, enabled) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.dankBarLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.dankBarCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.dankBarRightWidgets.slice()
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
            SettingsData.setDankBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setDankBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setDankBarRightWidgets(widgets)
    }

    function handleItemOrderChanged(sectionId, newOrder) {
        if (sectionId === "left")
            SettingsData.setDankBarLeftWidgets(newOrder)
        else if (sectionId === "center")
            SettingsData.setDankBarCenterWidgets(newOrder)
        else if (sectionId === "right")
            SettingsData.setDankBarRightWidgets(newOrder)
    }

    function handleSpacerSizeChanged(sectionId, widgetIndex, newSize) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.dankBarLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.dankBarCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.dankBarRightWidgets.slice()
        
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
            SettingsData.setDankBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setDankBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setDankBarRightWidgets(widgets)
    }

    function handleGpuSelectionChanged(sectionId, widgetIndex, selectedGpuIndex) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.dankBarLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.dankBarCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.dankBarRightWidgets.slice()

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
            SettingsData.setDankBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setDankBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setDankBarRightWidgets(widgets)
    }

    function handleDiskMountSelectionChanged(sectionId, widgetIndex, mountPath) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.dankBarLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.dankBarCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.dankBarRightWidgets.slice()

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
            SettingsData.setDankBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setDankBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setDankBarRightWidgets(widgets)
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
            widgets = SettingsData.dankBarLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.dankBarCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.dankBarRightWidgets.slice()

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
            SettingsData.setDankBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setDankBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setDankBarRightWidgets(widgets)
    }

    function getItemsForSection(sectionId) {
        var widgets = []
        var widgetData = []
        if (sectionId === "left")
            widgetData = SettingsData.dankBarLeftWidgets || []
        else if (sectionId === "center")
            widgetData = SettingsData.dankBarCenterWidgets || []
        else if (sectionId === "right")
            widgetData = SettingsData.dankBarRightWidgets || []
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
        if (!SettingsData.dankBarLeftWidgets)
            SettingsData.setDankBarLeftWidgets(defaultLeftWidgets)

        if (!SettingsData.dankBarCenterWidgets)
            SettingsData.setDankBarCenterWidgets(defaultCenterWidgets)

        if (!SettingsData.dankBarRightWidgets)
            SettingsData.setDankBarRightWidgets(defaultRightWidgets)
        const sections = ["left", "center", "right"]
        sections.forEach(sectionId => {
                             var widgets = []
                             if (sectionId === "left")
                             widgets = SettingsData.dankBarLeftWidgets.slice()
                             else if (sectionId === "center")
                             widgets = SettingsData.dankBarCenterWidgets.slice()
                             else if (sectionId === "right")
                             widgets = SettingsData.dankBarRightWidgets.slice()
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
                                 SettingsData.setDankBarLeftWidgets(widgets)
                                 else if (sectionId === "center")
                                 SettingsData.setDankBarCenterWidgets(widgets)
                                 else if (sectionId === "right")
                                 SettingsData.setDankBarRightWidgets(widgets)
                             }
                         })
    }

    DankFlickable {
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

                        DankIcon {
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

                    Item {
                        width: parent.width
                        height: childrenRect.height

                        DankButtonGroup {
                            id: positionButtonGroup
                            x: (parent.width - width) / 2
                            minButtonWidth: Math.floor((parent.width - spacing * 3) / 4)
                            model: ["Сверху", "Снизу", "Слева", "Справа"]
                            currentIndex: {
                                switch (SettingsData.dankBarPosition) {
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
                                        case 0: SettingsData.setDankBarPosition(SettingsData.Position.Top); break
                                        case 1: SettingsData.setDankBarPosition(SettingsData.Position.Bottom); break
                                        case 2: SettingsData.setDankBarPosition(SettingsData.Position.Left); break
                                        case 3: SettingsData.setDankBarPosition(SettingsData.Position.Right); break
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // DankBar Auto-hide Section
            StyledRect {
                width: parent.width
                height: dankBarAutoHideSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: dankBarAutoHideSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
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
                                text: "Автоматически скрывать панель для расширения рабочего пространства"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: autoHideToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.dankBarAutoHide
                            onToggled: toggled => {
                                           return SettingsData.setDankBarAutoHide(
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

                        DankIcon {
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

                        DankToggle {
                            id: overviewToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.dankBarOpenOnOverview
                            onToggled: toggled => {
                                           return SettingsData.setDankBarOpenOnOverview(
                                               toggled)
                                       }
                        }
                    }
                }
            }


            // Spacing
            StyledRect {
                width: parent.width
                height: dankBarSpacingSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: dankBarSpacingSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
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

                            DankActionButton {
                                id: resetEdgeSpacingBtn
                                buttonSize: 20
                                iconName: "refresh"
                                iconSize: 12
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    edgeSpacingSlider.value = 0
                                    SettingsData.setDankBarSpacing(0)
                                }
                            }

                            Item {
                                width: Theme.spacingS
                                height: 1
                            }
                        }

                        DankSlider {
                            id: edgeSpacingSlider
                            width: parent.width
                            height: 24
                            value: SettingsData.dankBarSpacing
                            minimum: 0
                            maximum: 32
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDankBarSpacing(
                                                          newValue)
                                                  }

                            Binding {
                                target: edgeSpacingSlider
                                property: "value"
                                value: SettingsData.dankBarSpacing
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

                            DankActionButton {
                                id: resetExclusiveZoneBtn
                                buttonSize: 20
                                iconName: "refresh"
                                iconSize: 12
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    exclusiveZoneSlider.value = 0
                                    SettingsData.setDankBarBottomGap(0)
                                }
                            }

                            Item {
                                width: Theme.spacingS
                                height: 1
                            }
                        }
                        


                        DankSlider {
                            id: exclusiveZoneSlider
                            width: parent.width
                            height: 24
                            value: SettingsData.dankBarBottomGap
                            minimum: -50
                            maximum: 50
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDankBarBottomGap(
                                                          newValue)
                                                  }

                            Binding {
                                target: exclusiveZoneSlider
                                property: "value"
                                value: SettingsData.dankBarBottomGap
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

                            DankActionButton {
                                id: resetSizeBtn
                                buttonSize: 20
                                iconName: "refresh"
                                iconSize: 12
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    SettingsData.setDankBarInnerPadding(4)
                                }
                            }

                            Item {
                                width: Theme.spacingS
                                height: 1
                            }
                        }

                        DankSlider {
                            id: sizeSlider
                            width: parent.width
                            height: 24
                            value: SettingsData.dankBarInnerPadding
                            minimum: 0
                            maximum: 24
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setDankBarInnerPadding(
                                                          newValue)
                                                  }

                            Binding {
                                target: sizeSlider
                                property: "value"
                                value: SettingsData.dankBarInnerPadding
                                restoreMode: Binding.RestoreBinding
                            }
                        }
                    }


                    DankToggle {
                        width: parent.width
                        text: "Квадратные углы"
                        description: "Убирает закругленные углы у контейнера панели."
                        checked: SettingsData.dankBarSquareCorners
                        onToggled: checked => {
                                       SettingsData.setDankBarSquareCorners(
                                           checked)
                                   }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Без фона"
                        description: "Убирает фон виджетов для минималистичного вида с меньшими отступами."
                        checked: SettingsData.dankBarNoBackground
                        onToggled: checked => {
                                       SettingsData.setDankBarNoBackground(
                                           checked)
                                   }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Готические углы"
                        description: "Добавляет изогнутые кончики внизу панели."
                        checked: SettingsData.dankBarGothCornersEnabled
                        onToggled: checked => {
                                       SettingsData.setDankBarGothCornersEnabled(
                                           checked)
                                   }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankToggle {
                            width: parent.width
                            text: "Граница"
                            description: "Добавляет границу 1px к панели. Умное определение краев показывает границу только на открытых сторонах."
                            checked: SettingsData.dankBarBorderEnabled
                            onToggled: checked => {
                                           SettingsData.setDankBarBorderEnabled(checked)
                                       }
                        }

                        Column {
                            width: parent.width
                            leftPadding: Theme.spacingM
                            spacing: Theme.spacingM
                            visible: SettingsData.dankBarBorderEnabled

                            Rectangle {
                                width: parent.width - parent.leftPadding
                                height: 1
                                color: Theme.outline
                                opacity: 0.2
                            }

                            Column {
                                width: parent.width - parent.leftPadding
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Цвет границы"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                StyledText {
                                    text: "Выберите акцентный цвет границы"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                }

                                Item {
                                    width: parent.width
                                    height: borderColorGroup.height
                                    
                                    DankButtonGroup {
                                        id: borderColorGroup
                                        x: (parent.width - width) / 2
                                        minButtonWidth: Math.floor((parent.width - spacing * 2) / 3)
                                        model: ["Текст", "Вторичный", "Основной"]
                                        currentIndex: {
                                            const colorOption = SettingsData.dankBarBorderColor || "surfaceText"
                                            switch (colorOption) {
                                                case "surfaceText": return 0
                                                case "secondary": return 1
                                                case "primary": return 2
                                                default: return 0
                                            }
                                        }
                                        onSelectionChanged: (index, selected) => {
                                            if (selected) {
                                                let newColor = "surfaceText"
                                                switch (index) {
                                                    case 0: newColor = "surfaceText"; break
                                                    case 1: newColor = "secondary"; break
                                                    case 2: newColor = "primary"; break
                                                }
                                                if (SettingsData.dankBarBorderColor !== newColor) {
                                                    SettingsData.dankBarBorderColor = newColor
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Column {
                                width: parent.width - parent.leftPadding
                                spacing: Theme.spacingS

                                Row {
                                    width: parent.width
                                    spacing: Theme.spacingS

                                    StyledText {
                                        text: "Прозрачность границы"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        font.weight: Font.Medium
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Item {
                                        width: parent.width - borderOpacityText.implicitWidth - resetBorderOpacityBtn.width - Theme.spacingS - Theme.spacingM
                                        height: 1

                                        StyledText {
                                            id: borderOpacityText
                                            visible: false
                                            text: "Прозрачность границы"
                                            font.pixelSize: Theme.fontSizeSmall
                                        }
                                    }

                                    DankActionButton {
                                        id: resetBorderOpacityBtn
                                        buttonSize: 20
                                        iconName: "refresh"
                                        iconSize: 12
                                        backgroundColor: Theme.surfaceContainerHigh
                                        iconColor: Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: {
                                            SettingsData.dankBarBorderOpacity = 1.0
                                        }
                                    }

                                    Item {
                                        width: Theme.spacingS
                                        height: 1
                                    }
                                }

                                DankSlider {
                                    id: borderOpacitySlider
                                    width: parent.width
                                    height: 24
                                    value: (SettingsData.dankBarBorderOpacity ?? 1.0) * 100
                                    minimum: 0
                                    maximum: 100
                                    unit: "%"
                                    showValue: true
                                    wheelEnabled: false
                                    thumbOutlineColor: Theme.surfaceContainerHigh
                                    onSliderValueChanged: newValue => {
                                        SettingsData.dankBarBorderOpacity = newValue / 100
                                    }

                                    Binding {
                                        target: borderOpacitySlider
                                        property: "value"
                                        value: (SettingsData.dankBarBorderOpacity ?? 1.0) * 100
                                        restoreMode: Binding.RestoreBinding
                                    }
                                }
                            }

                            Column {
                                width: parent.width - parent.leftPadding
                                spacing: Theme.spacingS

                                Row {
                                    width: parent.width
                                    spacing: Theme.spacingS

                                    StyledText {
                                        text: "Толщина границы"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        font.weight: Font.Medium
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Item {
                                        width: parent.width - borderThicknessText.implicitWidth - resetBorderThicknessBtn.width - Theme.spacingS - Theme.spacingM
                                        height: 1

                                        StyledText {
                                            id: borderThicknessText
                                            visible: false
                                            text: "Толщина границы"
                                            font.pixelSize: Theme.fontSizeSmall
                                        }
                                    }

                                    DankActionButton {
                                        id: resetBorderThicknessBtn
                                        buttonSize: 20
                                        iconName: "refresh"
                                        iconSize: 12
                                        backgroundColor: Theme.surfaceContainerHigh
                                        iconColor: Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: {
                                            SettingsData.dankBarBorderThickness = 1
                                        }
                                    }

                                    Item {
                                        width: Theme.spacingS
                                        height: 1
                                    }
                                }

                                DankSlider {
                                    id: borderThicknessSlider
                                    width: parent.width
                                    height: 24
                                    value: SettingsData.dankBarBorderThickness ?? 1
                                    minimum: 1
                                    maximum: 10
                                    unit: "px"
                                    showValue: true
                                    wheelEnabled: false
                                    thumbOutlineColor: Theme.surfaceContainerHigh
                                    onSliderValueChanged: newValue => {
                                        SettingsData.dankBarBorderThickness = newValue
                                    }

                                    Binding {
                                        target: borderThicknessSlider
                                        property: "value"
                                        value: SettingsData.dankBarBorderThickness ?? 1
                                        restoreMode: Binding.RestoreBinding
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

                    Rectangle {
                        width: parent.width
                        height: 60
                        radius: Theme.cornerRadius
                        color: "transparent"

                        Column {
                            anchors.left: parent.left
                            anchors.right: dankBarFontScaleControls.left
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
                            id: dankBarFontScaleControls

                            width: 180
                            height: 36
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            DankActionButton {
                                buttonSize: 32
                                iconName: "remove"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.dankBarFontScale > 0.5
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.max(0.5, SettingsData.dankBarFontScale - 0.05)
                                    SettingsData.setDankBarFontScale(newScale)
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
                                    text: (SettingsData.dankBarFontScale * 100).toFixed(0) + "%"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }
                            }

                            DankActionButton {
                                buttonSize: 32
                                iconName: "add"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.dankBarFontScale < 2.0
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.min(2.0, SettingsData.dankBarFontScale + 0.05)
                                    SettingsData.setDankBarFontScale(newScale)
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 60
                        radius: Theme.cornerRadius
                        color: "transparent"

                        Column {
                            anchors.left: parent.left
                            anchors.right: dankBarIconScaleControls.left
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
                            id: dankBarIconScaleControls

                            width: 180
                            height: 36
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            DankActionButton {
                                buttonSize: 32
                                iconName: "remove"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.dankBarIconScale > 0.5
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.max(0.5, SettingsData.dankBarIconScale - 0.05)
                                    SettingsData.setDankBarIconScale(newScale)
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
                                    text: (SettingsData.dankBarIconScale * 100).toFixed(0) + "%"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }
                            }

                            DankActionButton {
                                buttonSize: 32
                                iconName: "add"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.dankBarIconScale < 2.0
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.min(2.0, SettingsData.dankBarIconScale + 0.05)
                                    SettingsData.setDankBarIconScale(newScale)
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

                        DankIcon {
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

                        Rectangle {
                            id: resetButton
                            width: 80
                            height: 28
                            radius: Theme.cornerRadius
                            color: resetArea.containsMouse ? Theme.surfacePressed : Theme.surfaceVariant
                            Layout.alignment: Qt.AlignVCenter
                            border.width: 0
                            border.color: resetArea.containsMouse ? Theme.outline : Qt.rgba(
                                                                        Theme.outline.r,
                                                                        Theme.outline.g,
                                                                        Theme.outline.b,
                                                                        0.5)

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DankIcon {
                                    name: "refresh"
                                    size: 14
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Сброс"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: resetArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SettingsData.setDankBarLeftWidgets(
                                                defaultLeftWidgets)
                                    SettingsData.setDankBarCenterWidgets(
                                                defaultCenterWidgets)
                                    SettingsData.setDankBarRightWidgets(
                                                defaultRightWidgets)
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }
                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }
                            }
                        }
                    }

                    StyledText {
                        width: parent.width
                        text: "Перетаскивайте виджеты для изменения порядка в секциях. Используйте иконку глаза чтобы скрыть/показать виджеты (сохраняет отступы), или X чтобы удалить их полностью."
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
                        title: SettingsData.dankBarIsVertical ? "Верхняя секция" : "Левая секция"
                        titleIcon: "format_align_left"
                        sectionId: "left"
                        allWidgets: dankBarTab.baseWidgetDefinitions
                        items: dankBarTab.getItemsForSection("left")
                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  dankBarTab.handleItemEnabledChanged(
                                                      sectionId,
                                                      itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                dankBarTab.handleItemOrderChanged(
                                                    "left", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets
                                         = dankBarTab.getWidgetsForPopup()
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.show()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            dankBarTab.removeWidgetFromSection(
                                                sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 dankBarTab.handleSpacerSizeChanged(
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
                                                   dankBarTab.handleGpuSelectionChanged(
                                                       sectionId, widgetIndex,
                                                       selectedIndex)
                                               }
                        onDiskMountSelectionChanged: (sectionId, widgetIndex, mountPath) => {
                                                         dankBarTab.handleDiskMountSelectionChanged(
                                                             sectionId, widgetIndex, mountPath)
                                                     }
                        onMinimumWidthChanged: (sectionId, widgetIndex, enabled) => {
                                                   dankBarTab.handleMinimumWidthChanged(
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
                        allWidgets: dankBarTab.baseWidgetDefinitions
                        items: dankBarTab.getItemsForSection("center")
                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  dankBarTab.handleItemEnabledChanged(
                                                      sectionId,
                                                      itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                dankBarTab.handleItemOrderChanged(
                                                    "center", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets
                                         = dankBarTab.getWidgetsForPopup()
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.show()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            dankBarTab.removeWidgetFromSection(
                                                sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 dankBarTab.handleSpacerSizeChanged(
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
                                                   dankBarTab.handleGpuSelectionChanged(
                                                       sectionId, widgetIndex,
                                                       selectedIndex)
                                               }
                        onDiskMountSelectionChanged: (sectionId, widgetIndex, mountPath) => {
                                                         dankBarTab.handleDiskMountSelectionChanged(
                                                             sectionId, widgetIndex, mountPath)
                                                     }
                        onMinimumWidthChanged: (sectionId, widgetIndex, enabled) => {
                                                   dankBarTab.handleMinimumWidthChanged(
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
                        title: SettingsData.dankBarIsVertical ? "Нижняя секция" : "Правая секция"
                        titleIcon: "format_align_right"
                        sectionId: "right"
                        allWidgets: dankBarTab.baseWidgetDefinitions
                        items: dankBarTab.getItemsForSection("right")
                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  dankBarTab.handleItemEnabledChanged(
                                                      sectionId,
                                                      itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                dankBarTab.handleItemOrderChanged(
                                                    "right", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets
                                         = dankBarTab.getWidgetsForPopup()
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.show()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            dankBarTab.removeWidgetFromSection(
                                                sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 dankBarTab.handleSpacerSizeChanged(
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
                                                   dankBarTab.handleGpuSelectionChanged(
                                                       sectionId, widgetIndex,
                                                       selectedIndex)
                                               }
                        onDiskMountSelectionChanged: (sectionId, widgetIndex, mountPath) => {
                                                         dankBarTab.handleDiskMountSelectionChanged(
                                                             sectionId, widgetIndex, mountPath)
                                                     }
                        onMinimumWidthChanged: (sectionId, widgetIndex, enabled) => {
                                                   dankBarTab.handleMinimumWidthChanged(
                                                       sectionId, widgetIndex, enabled)
                                               }
                    }
                }
            }
        }
    }

    WidgetSelectionPopup {
        id: widgetSelectionPopup

        parentModal: dankBarTab.parentModal
        onWidgetSelected: (widgetId, targetSection) => {
                              dankBarTab.addWidgetToSection(widgetId,
                                                           targetSection)
                          }
    }
}
