pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property int levelInfo: 0
    readonly property int levelWarn: 1
    readonly property int levelError: 2
    property string currentMessage: ""
    property int currentLevel: levelInfo
    property bool toastVisible: false
    property var toastQueue: []
    property string currentDetails: ""
    property string currentCommand: ""
    property bool hasDetails: false
    property string wallpaperErrorStatus: ""

    function showToast(message, level = levelInfo, details = "", command = "") {
        toastQueue.push({
                            "message": message,
                            "level": level,
                            "details": details,
                            "command": command
                        })
        if (!toastVisible) {
            processQueue()
        }
    }

    function showInfo(message, details = "", command = "") {
        showToast(message, levelInfo, details, command)
    }

    function showWarning(message, details = "", command = "") {
        showToast(message, levelWarn, details, command)
    }

    function showError(message, details = "", command = "") {
        showToast(message, levelError, details, command)
    }

    function hideToast() {
        toastVisible = false
        currentMessage = ""
        currentDetails = ""
        currentCommand = ""
        hasDetails = false
        currentLevel = levelInfo
        toastTimer.stop()
        resetToastState()
        if (toastQueue.length > 0) {
            processQueue()
        }
    }

    function processQueue() {
        if (toastQueue.length === 0) {
            return
        }

        const toast = toastQueue.shift()
        currentMessage = toast.message
        currentLevel = toast.level
        currentDetails = toast.details || ""
        currentCommand = toast.command || ""
        hasDetails = currentDetails.length > 0 || currentCommand.length > 0
        toastVisible = true
        resetToastState()

        if (toast.level === levelError && hasDetails) {
            toastTimer.interval = 8000
            toastTimer.start()
        } else {
            toastTimer.interval = toast.level === levelError ? 5000 : toast.level === levelWarn ? 3000 : 1500
            toastTimer.start()
        }
    }

    signal resetToastState

    function stopTimer() {
        toastTimer.stop()
    }

    function restartTimer() {
        if (hasDetails && currentLevel === levelError) {
            toastTimer.interval = 8000
            toastTimer.restart()
        }
    }

    function clearWallpaperError() {
        wallpaperErrorStatus = ""
    }

    Timer {
        id: toastTimer

        interval: 5000
        running: false
        repeat: false
        onTriggered: hideToast()
    }
}
