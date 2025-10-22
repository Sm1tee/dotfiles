import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    required property string pluginId
    property var pluginService: null
    default property list<QtObject> content

    signal settingChanged()

    property var variants: []
    property alias variantsModel: variantsListModel

    implicitHeight: hasPermission ? settingsColumn.implicitHeight : errorText.implicitHeight
    height: implicitHeight

    readonly property bool hasPermission: {
        if (!pluginService || !pluginId) return true
        const allPlugins = pluginService.availablePlugins
        const plugin = allPlugins[pluginId]
        if (!plugin) return true
        const permissions = Array.isArray(plugin.permissions) ? plugin.permissions : []
        return permissions.indexOf("settings_write") !== -1
    }

    Component.onCompleted: {
        loadVariants()
    }

    onPluginServiceChanged: {
        if (pluginService) {
            loadVariants()
            for (let i = 0; i < content.length; i++) {
                const child = content[i]
                if (child.loadValue) {
                    child.loadValue()
                }
            }
        }
    }

    onContentChanged: {
        for (let i = 0; i < content.length; i++) {
            const item = content[i]
            if (item instanceof Item) {
                item.parent = settingsColumn
            }
        }
    }

    Connections {
        target: pluginService
        function onPluginDataChanged(changedPluginId) {
            if (changedPluginId === pluginId) {
                loadVariants()
            }
        }
    }

    function loadVariants() {
        if (!pluginService || !pluginId) {
            variants = []
            return
        }
        variants = pluginService.getPluginVariants(pluginId)
        syncVariantsToModel()
    }

    function syncVariantsToModel() {
        variantsListModel.clear()
        for (let i = 0; i < variants.length; i++) {
            variantsListModel.append(variants[i])
        }
    }

    onVariantsChanged: {
        syncVariantsToModel()
    }

    ListModel {
        id: variantsListModel
    }

    function createVariant(variantName, variantConfig) {
        if (!pluginService || !pluginId) {
            return null
        }
        return pluginService.createPluginVariant(pluginId, variantName, variantConfig)
    }

    function removeVariant(variantId) {
        if (!pluginService || !pluginId) {
            return
        }
        pluginService.removePluginVariant(pluginId, variantId)
    }

    function updateVariant(variantId, variantConfig) {
        if (!pluginService || !pluginId) {
            return
        }
        pluginService.updatePluginVariant(pluginId, variantId, variantConfig)
    }

    function saveValue(key, value) {
        if (!pluginService) {
            return
        }
        if (!hasPermission) {
            console.warn("PluginSettings: Plugin", pluginId, "does not have settings_write permission")
            return
        }
        if (pluginService.savePluginData) {
            pluginService.savePluginData(pluginId, key, value)
            settingChanged()
        }
    }

    function loadValue(key, defaultValue) {
        if (pluginService && pluginService.loadPluginData) {
            return pluginService.loadPluginData(pluginId, key, defaultValue)
        }
        return defaultValue
    }

    function findFlickable(item) {
        var current = item?.parent
        while (current) {
            if (current.contentY !== undefined && current.contentHeight !== undefined) {
                return current
            }
            current = current.parent
        }
        return null
    }

    function ensureItemVisible(item) {
        if (!item) return

        var flickable = findFlickable(root)
        if (!flickable) return

        var itemGlobalY = item.mapToItem(null, 0, 0).y
        var itemHeight = item.height
        var flickableGlobalY = flickable.mapToItem(null, 0, 0).y
        var viewportHeight = flickable.height

        var itemRelativeY = itemGlobalY - flickableGlobalY
        var viewportTop = 0
        var viewportBottom = viewportHeight

        if (itemRelativeY < viewportTop) {
            flickable.contentY = Math.max(0, flickable.contentY - (viewportTop - itemRelativeY) - Theme.spacingL)
        } else if (itemRelativeY + itemHeight > viewportBottom) {
            flickable.contentY = Math.min(
                flickable.contentHeight - viewportHeight,
                flickable.contentY + (itemRelativeY + itemHeight - viewportBottom) + Theme.spacingL
            )
        }
    }

    StyledText {
        id: errorText
        visible: pluginService && !root.hasPermission
        anchors.fill: parent
        text: "У этого плагина нет разрешения 'settings_write'.\n\nДобавьте \"permissions\": [\"settings_read\", \"settings_write\"] в plugin.json"
        color: Theme.error
        font.pixelSize: Theme.fontSizeMedium
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Column {
        id: settingsColumn
        visible: root.hasPermission
        width: parent.width
        spacing: Theme.spacingM
    }
}
