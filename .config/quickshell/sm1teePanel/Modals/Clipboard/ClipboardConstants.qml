pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    readonly property int previewLength: 100
    readonly property int longTextThreshold: 200
    readonly property int modalWidth: {
        if (typeof SettingsData !== "undefined") {
            return Math.max(650, Math.min(900, 650 * SettingsData.fontScale))
        }
        return 650
    }
    readonly property int modalHeight: {
        if (typeof SettingsData !== "undefined") {
            return Math.max(550, Math.min(750, 550 * SettingsData.fontScale))
        }
        return 550
    }
    readonly property int itemHeight: {
        if (typeof SettingsData !== "undefined") {
            return Math.max(72, Math.min(100, 72 * SettingsData.fontScale))
        }
        return 72
    }
    readonly property int thumbnailSize: 48
    readonly property int retryInterval: 50
    readonly property int viewportBuffer: 100
    readonly property int extendedBuffer: 200
    readonly property int keyboardHintsHeight: 80
    readonly property int headerHeight: 40
}
