import QtQuick
import qs.Common
import qs.Services
import "../utils/widgets.js" as WidgetUtils

QtObject {
    id: root

    readonly property var coreWidgetDefinitions: [{
            "id": "nightMode",
            "text": "Ночной режим",
            "description": "Фильтр синего света",
            "icon": "nightlight",
            "type": "toggle",
            "enabled": DisplayService.automationAvailable,
            "warning": !DisplayService.automationAvailable ? "Требуется поддержка ночного режима" : undefined
        }, {
            "id": "darkMode",
            "text": "Темная тема",
            "description": "Переключение темы системы",
            "icon": "contrast",
            "type": "toggle",
            "enabled": true
        }, {
            "id": "doNotDisturb",
            "text": "Не беспокоить",
            "description": "Блокировка уведомлений",
            "icon": "do_not_disturb_on",
            "type": "toggle",
            "enabled": true
        }, {
            "id": "idleInhibitor",
            "text": "Не выключать экран",
            "description": "Предотвращение отключения экрана",
            "icon": "motion_sensor_active",
            "type": "toggle",
            "enabled": true
        }, {
            "id": "wifi",
            "text": "Сеть",
            "description": "Подключение Wi-Fi и Ethernet",
            "icon": "wifi",
            "type": "connection",
            "enabled": NetworkService.wifiAvailable,
            "warning": !NetworkService.wifiAvailable ? "Wi-Fi недоступен" : undefined
        }, {
            "id": "bluetooth",
            "text": "Bluetooth",
            "description": "Подключение устройств",
            "icon": "bluetooth",
            "type": "connection",
            "enabled": BluetoothService.available,
            "warning": !BluetoothService.available ? "Bluetooth недоступен" : undefined
        }, {
            "id": "audioOutput",
            "text": "Аудиовыход",
            "description": "Настройки динамиков",
            "icon": "volume_up",
            "type": "connection",
            "enabled": true
        }, {
            "id": "audioInput",
            "text": "Аудиовход",
            "description": "Настройки микрофона",
            "icon": "mic",
            "type": "connection",
            "enabled": true
        }, {
            "id": "volumeSlider",
            "text": "Громкость",
            "description": "Управление громкостью",
            "icon": "volume_up",
            "type": "slider",
            "enabled": true
        }, {
            "id": "brightnessSlider",
            "text": "Яркость",
            "description": "Управление яркостью экрана",
            "icon": "brightness_6",
            "type": "slider",
            "enabled": DisplayService.brightnessAvailable,
            "warning": !DisplayService.brightnessAvailable ? "Управление яркостью недоступно" : undefined
        }, {
            "id": "inputVolumeSlider",
            "text": "Громкость микрофона",
            "description": "Управление громкостью микрофона",
            "icon": "mic",
            "type": "slider",
            "enabled": true
        }, {
            "id": "battery",
            "text": "Батарея",
            "description": "Управление батареей и питанием",
            "icon": "battery_std",
            "type": "action",
            "enabled": true
        }, {
            "id": "diskUsage",
            "text": "Использование дисков",
            "description": "Мониторинг использования дисков",
            "icon": "storage",
            "type": "action",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Требуется утилита 'dgop'" : undefined,
            "allowMultiple": true
        }, {
            "id": "colorPicker",
            "text": "Выбор цвета",
            "description": "Выбор цвета из палитры",
            "icon": "palette",
            "type": "action",
            "enabled": true
        }]

    function getPluginWidgets() {
        const plugins = []
        const loadedPlugins = PluginService.getLoadedPlugins()

        for (var i = 0; i < loadedPlugins.length; i++) {
            const plugin = loadedPlugins[i]

            if (plugin.type === "daemon") {
                continue
            }

            const pluginComponent = PluginService.pluginWidgetComponents[plugin.id]
            if (!pluginComponent) {
                continue
            }

            const tempInstance = pluginComponent.createObject(null)
            if (!tempInstance) {
                continue
            }

            const hasCCWidget = tempInstance.ccWidgetIcon && tempInstance.ccWidgetIcon.length > 0
            tempInstance.destroy()

            if (!hasCCWidget) {
                continue
            }

            plugins.push({
                             "id": "plugin_" + plugin.id,
                             "pluginId": plugin.id,
                             "text": plugin.name || "Plugin",
                             "description": plugin.description || "",
                             "icon": plugin.icon || "extension",
                             "type": "plugin",
                             "enabled": true,
                             "isPlugin": true
                         })
        }

        return plugins
    }

    readonly property var baseWidgetDefinitions: coreWidgetDefinitions

    function getWidgetForId(widgetId) {
        return WidgetUtils.getWidgetForId(baseWidgetDefinitions, widgetId)
    }

    function addWidget(widgetId) {
        WidgetUtils.addWidget(widgetId)
    }

    function removeWidget(index) {
        WidgetUtils.removeWidget(index)
    }

    function toggleWidgetSize(index) {
        WidgetUtils.toggleWidgetSize(index)
    }

    function moveWidget(fromIndex, toIndex) {
        WidgetUtils.moveWidget(fromIndex, toIndex)
    }

    function resetToDefault() {
        WidgetUtils.resetToDefault()
    }

    function clearAll() {
        WidgetUtils.clearAll()
    }
}
