import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Widgets

CompoundPill {
    id: root

    property string mountPath: "/"
    property string instanceId: ""
    property var diskMounts: []

    iconName: "storage"

    property var selectedMount: {
        if (!diskMounts || diskMounts.length === 0) {
            return null
        }

        // Читаем текущий mountPath из SessionData или используем сохраненный
        const currentPath = SessionData.diskWidgetMountPaths[instanceId] || mountPath
        const targetMount = diskMounts.find(mount => mount.mount === currentPath)
        return targetMount || diskMounts.find(mount => mount.mount === "/") || diskMounts[0]
    }

    property real usagePercent: {
        if (!selectedMount || !selectedMount.percent) {
            return 0
        }
        const percentStr = selectedMount.percent.replace("%", "")
        return parseFloat(percentStr) || 0
    }

    isActive: selectedMount !== null

    primaryText: {
        if (!selectedMount) {
            return "Использование диска"
        }
        return selectedMount.mount
    }

    secondaryText: {
        if (!selectedMount) {
            return "Загрузка..."
        }
        return `${selectedMount.used} / ${selectedMount.size} (${usagePercent.toFixed(0)}%)`
    }

    iconColor: {
        if (!selectedMount) {
            return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
        }
        if (usagePercent > 90) {
            return Theme.error
        }
        if (usagePercent > 75) {
            return Theme.warning
        }
        return Theme.surfaceText
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: dfProcess.running = true
    }

    Process {
        id: dfProcess
        command: ["df", "-h", "--output=source,size,used,avail,pcent,target", "-x", "tmpfs", "-x", "devtmpfs"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: line => {
                if (line.trim().startsWith("Filesystem")) return
                
                const parts = line.trim().split(/\s+/)
                if (parts.length >= 6) {
                    const mount = {
                        device: parts[0],
                        size: parts[1],
                        used: parts[2],
                        avail: parts[3],
                        percent: parts[4],
                        mount: parts[5]
                    }
                    
                    let mounts = root.diskMounts.slice()
                    const existingIndex = mounts.findIndex(m => m.mount === mount.mount)
                    if (existingIndex >= 0) {
                        mounts[existingIndex] = mount
                    } else {
                        mounts.push(mount)
                    }
                    root.diskMounts = mounts
                }
            }
        }
    }

    onToggled: {
        expandClicked()
    }
}