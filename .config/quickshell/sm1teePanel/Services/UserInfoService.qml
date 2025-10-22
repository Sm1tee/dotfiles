pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string username: ""
    property string fullName: ""
    property string profilePicture: ""
    property string uptime: ""
    property string shortUptime: ""
    property string hostname: ""
    property bool profileAvailable: false

    function getUserInfo() {
        userInfoProcess.running = true
    }

    function getUptime() {
        uptimeProcess.running = true
    }

    function refreshUserInfo() {
        getUserInfo()
        getUptime()
    }

    Component.onCompleted: {
        getUserInfo()
        getUptime()
    }

    Process {
        id: userInfoProcess

        command: ["bash", "-c", "echo \"$USER|$(getent passwd $USER | cut -d: -f5 | cut -d, -f1)|$(hostname)\""]
        running: false
        onExited: exitCode => {
            if (exitCode !== 0) {

                root.username = "User"
                root.fullName = "User"
                root.hostname = "System"
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")
                if (parts.length >= 3) {
                    root.username = parts[0] || ""
                    root.fullName = parts[1] || parts[0] || ""
                    root.hostname = parts[2] || ""
                }
            }
        }
    }

    Process {
        id: uptimeProcess

        command: ["cat", "/proc/uptime"]
        running: false

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.uptime = "Неизвестно"
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const seconds = parseInt(text.split(" ")[0])
                const days = Math.floor(seconds / 86400)
                const hours = Math.floor((seconds % 86400) / 3600)
                const minutes = Math.floor((seconds % 3600) / 60)

                const parts = []
                if (days > 0) {
                    const dayWord = days === 1 ? "день" : days < 5 ? "дня" : "дней"
                    parts.push(`${days} ${dayWord}`)
                }
                if (hours > 0) {
                    const hourWord = hours === 1 ? "час" : hours < 5 ? "часа" : "часов"
                    parts.push(`${hours} ${hourWord}`)
                }
                if (minutes > 0) {
                    const minuteWord = minutes === 1 ? "минута" : minutes < 5 ? "минуты" : "минут"
                    parts.push(`${minutes} ${minuteWord}`)
                }

                if (parts.length > 0) {
                    root.uptime = `работает ${parts.join(", ")}`
                } else {
                    root.uptime = `работает ${seconds} секунд`
                }

                // Create short uptime format
                let shortUptime = "работает"
                if (days > 0) {
                    shortUptime += ` ${days}д`
                }
                if (hours > 0) {
                    shortUptime += ` ${hours}ч`
                }
                if (minutes > 0) {
                    shortUptime += ` ${minutes}м`
                }
                root.shortUptime = shortUptime
            }
        }
    }
}
