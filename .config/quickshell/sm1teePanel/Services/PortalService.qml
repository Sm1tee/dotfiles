pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool accountsServiceAvailable: false
    property string systemProfileImage: ""
    property string profileImage: ""
    property bool settingsPortalAvailable: false
    property int systemColorScheme: 0

    property bool freedeskAvailable: false

    readonly property string socketPath: Quickshell.env("SM1TEE_SOCKET")
    property string watchedIconPath: ""
    
    signal profileImageUpdateCompleted()

    function init() {
        startWatchingProfileImage()
    }
    
    function startWatchingProfileImage() {
        const username = Quickshell.env("USER")
        if (!username) return
        
        watchedIconPath = `/var/lib/AccountsService/icons/${username}`
        profileImageWatcher.path = watchedIconPath
    }

    function getSystemProfileImage() {
        if (!freedeskAvailable) return

        const username = Quickshell.env("USER")
        if (!username) return

        PluginManagerService.sendRequest("freedesktop.accounts.getUserIconFile", { username: username }, response => {
            if (response.result && response.result.success) {
                const iconFile = response.result.value || ""
                if (iconFile && iconFile !== "" && iconFile !== "/var/lib/AccountsService/icons/") {
                    systemProfileImage = iconFile
                    if (!profileImage || profileImage === "") {
                        profileImage = iconFile
                    }
                } else {
                    // Если системная аватарка не найдена, пробуем загрузить из ~/.face
                    loadFromFaceIcon()
                }
            } else {
                // Если запрос не удался, пробуем загрузить из ~/.face
                loadFromFaceIcon()
            }
        })
    }
    
    function loadFromFaceIcon() {
        const homeDir = StandardPaths.writableLocation(StandardPaths.HomeLocation)
        const facePath = homeDir + "/.face"
        const faceIconPath = homeDir + "/.face.icon"
        
        // Проверяем существование файлов
        checkFaceFile.command = ["bash", "-c", `if [ -f "${facePath}" ]; then echo "${facePath}"; elif [ -f "${faceIconPath}" ]; then echo "${faceIconPath}"; fi`]
        checkFaceFile.running = true
    }
    
    Process {
        id: checkFaceFile
        command: []
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                const trimmed = text.trim()
                if (trimmed && trimmed !== "") {
                    if (!root.profileImage || root.profileImage === "") {
                        root.profileImage = trimmed
                        root.systemProfileImage = trimmed
                    }
                }
            }
        }
    }

    function getUserProfileImage(username) {
        if (!username) {
            profileImage = ""
            return
        }
        if (Quickshell.env("SM1TEE_RUN_GREETER") === "1" || Quickshell.env("SM1TEE_RUN_GREETER") === "true") {
            profileImage = ""
            return
        }

        if (!freedeskAvailable) {
            profileImage = ""
            return
        }

        PluginManagerService.sendRequest("freedesktop.accounts.getUserIconFile", { username: username }, response => {
            if (response.result && response.result.success) {
                const icon = response.result.value || ""
                if (icon && icon !== "" && icon !== "/var/lib/AccountsService/icons/") {
                    profileImage = icon
                } else {
                    profileImage = ""
                }
            } else {
                profileImage = ""
            }
        })
    }

    function setProfileImage(imagePath) {
        profileImage = imagePath
        
        // Всегда пытаемся установить системную аватарку, не только если accountsServiceAvailable
        if (imagePath) {
            setSystemProfileImage(imagePath)
        } else {
            setSystemProfileImage("")
        }
    }

    function getSystemColorScheme() {
        if (!freedeskAvailable) return

        PluginManagerService.sendRequest("freedesktop.settings.getColorScheme", null, response => {
            if (response.result) {
                systemColorScheme = response.result.value || 0

                if (typeof Theme !== "undefined") {
                    const shouldBeLightMode = (systemColorScheme === 2)
                    if (Theme.isLightMode !== shouldBeLightMode) {
                        Theme.isLightMode = shouldBeLightMode
                        if (typeof SessionData !== "undefined") {
                            SessionData.setLightMode(shouldBeLightMode)
                        }
                    }
                }
            }
        })
    }

    function setLightMode(isLightMode) {
        if (settingsPortalAvailable) {
            setSystemColorScheme(isLightMode)
        }
    }

    function setSystemColorScheme(isLightMode) {
        if (!settingsPortalAvailable || !freedeskAvailable) return

        PluginManagerService.sendRequest("freedesktop.settings.setColorScheme", { preferDark: !isLightMode }, response => {
            if (!response.error) {
                Qt.callLater(() => getSystemColorScheme())
            }
        })
    }

    function setSystemProfileImage(imagePath) {
        const username = Quickshell.env("USER")
        if (!username) return
        
        if (imagePath && imagePath !== "") {
            const systemIconPath = `/var/lib/AccountsService/icons/${username}`
            
            // Копируем в ~/.face для SDDM
            copyToFaceIcon.command = ["bash", "-c", `cp "${imagePath}" ~/.face && cp "${imagePath}" ~/.face.icon`]
            copyToFaceIcon.running = true
            
            // Копируем в системную папку с сохранением имени
            // Пробуем несколько методов в порядке приоритета
            if (accountsServiceAvailable && freedeskAvailable) {
                // Метод 1: Через PluginManagerService (если доступен)
                PluginManagerService.sendRequest("freedesktop.accounts.setIconFile", { path: imagePath }, response => {
                    if (response.error) {
                        console.warn("PortalService: PluginManagerService failed, trying direct copy:", response.error)
                        copyToSystemIconDirect(imagePath, systemIconPath)
                    } else {
                        Qt.callLater(() => root.getSystemProfileImage())
                        root.profileImageUpdateCompleted()
                    }
                })
            } else {
                // Метод 2: Прямое копирование
                copyToSystemIconDirect(imagePath, systemIconPath)
            }
        }
    }
    
    function copyToSystemIconDirect(imagePath, systemIconPath) {
        // Пробуем копировать напрямую (может сработать если есть права)
        copyToSystemIcon.command = ["bash", "-c", `cp "${imagePath}" "${systemIconPath}" 2>/dev/null || pkexec cp "${imagePath}" "${systemIconPath}"`]
        copyToSystemIcon.running = true
    }
    
    FileView {
        id: profileImageWatcher
        path: ""
        
        onLoaded: {
            // Файл изменился - обновляем аватарку в интерфейсе
            if (path && path !== "") {
                root.profileImage = path
                root.systemProfileImage = path
            }
        }
    }
    
    Process {
        id: copyToSystemIcon
        command: []
        running: false
        
        onExited: exitCode => {
            if (exitCode === 0) {
                Qt.callLater(() => root.getSystemProfileImage())
            } else {
                console.warn("PortalService: Failed to copy profile image to system location")
            }
            root.profileImageUpdateCompleted()
        }
    }
    
    Process {
        id: copyToFaceIcon
        command: []
        running: false
        
        onExited: exitCode => {
            if (exitCode === 0) {
            } else {
                console.warn("PortalService: Failed to copy profile image to ~/.face")
            }
        }
    }

    Component.onCompleted: {
        init()
        if (socketPath && socketPath.length > 0) {
            checkServerCapabilities()
        }
    }

    Connections {
        target: PluginManagerService

        function onConnectionStateChanged() {
            if (PluginManagerService.isConnected) {
                checkServerCapabilities()
            }
        }
    }

    Connections {
        target: PluginManagerService
        enabled: PluginManagerService.isConnected

        function onCapabilitiesChanged() {
            checkServerCapabilities()
        }
    }

    function checkServerCapabilities() {
        if (!PluginManagerService.isConnected) {
            return
        }

        if (PluginManagerService.capabilities.length === 0) {
            return
        }

        freedeskAvailable = PluginManagerService.capabilities.includes("freedesktop")
        if (freedeskAvailable) {
            checkAccountsService()
            checkSettingsPortal()
        }
    }

    function checkAccountsService() {
        if (!freedeskAvailable) return

        PluginManagerService.sendRequest("freedesktop.getState", null, response => {
            if (response.result && response.result.accounts) {
                accountsServiceAvailable = response.result.accounts.available || false
                if (accountsServiceAvailable) {
                    getSystemProfileImage()
                }
            }
        })
    }

    function checkSettingsPortal() {
        if (!freedeskAvailable) return

        PluginManagerService.sendRequest("freedesktop.getState", null, response => {
            if (response.result && response.result.settings) {
                settingsPortalAvailable = response.result.settings.available || false
                if (settingsPortalAvailable) {
                    getSystemColorScheme()
                }
            }
        })
    }

    function getGreeterUserProfileImage(username) {
        if (!username) {
            profileImage = ""
            return
        }
        userProfileCheckProcess.command = [
            "bash", "-c",
            `uid=$(id -u ${username} 2>/dev/null) && [ -n "$uid" ] && dbus-send --system --print-reply --dest=org.freedesktop.Accounts /org/freedesktop/Accounts/User$uid org.freedesktop.DBus.Properties.Get string:org.freedesktop.Accounts.User string:IconFile 2>/dev/null | grep -oP 'string "\\K[^"]+' || echo ""`
        ]
        userProfileCheckProcess.running = true
    }

    Process {
        id: userProfileCheckProcess
        command: []
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const trimmed = text.trim()
                if (trimmed && trimmed !== "" && !trimmed.includes("Error") && trimmed !== "/var/lib/AccountsService/icons/") {
                    root.profileImage = trimmed
                } else {
                    root.profileImage = ""
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.profileImage = ""
            }
        }
    }

    IpcHandler {
        target: "profile"

        function getImage(): string {
            return root.profileImage
        }

        function setImage(path: string): string {
            if (!path) {
                return "ERROR: No path provided"
            }

            const absolutePath = path.startsWith("/") ? path : `${StandardPaths.writableLocation(StandardPaths.HomeLocation)}/${path}`

            try {
                root.setProfileImage(absolutePath)
                return "SUCCESS: Profile image set to " + absolutePath
            } catch (e) {
                return "ERROR: Failed to set profile image: " + e.toString()
            }
        }

        function clearImage(): string {
            root.setProfileImage("")
            return "SUCCESS: Profile image cleared"
        }
    }
}
