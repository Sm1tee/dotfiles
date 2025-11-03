pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Common

Singleton {
    id: root

    property bool hasUwsm: false
    property bool isElogind: false
    property bool hibernateSupported: false
    property bool inhibitorAvailable: true
    property bool idleInhibited: false
    property string inhibitReason: "Keep system awake"
    property bool hasPrimeRun: false

    readonly property bool nativeInhibitorAvailable: {
        try {
            return typeof IdleInhibitor !== "undefined"
        } catch (e) {
            return false
        }
    }

    property bool loginctlAvailable: false
    property string sessionId: ""
    property string sessionPath: ""
    property bool locked: false
    property bool active: false
    property bool idleHint: false
    property bool lockedHint: false
    property bool preparingForSleep: false
    property string sessionType: ""
    property string userName: ""
    property string seat: ""
    property string display: ""

    signal sessionLocked()
    signal sessionUnlocked()
    signal prepareForSleep(bool sleeping)
    signal loginctlStateChanged()

    property bool stateInitialized: false

    readonly property string socketPath: Quickshell.env("SM1TEE_SOCKET")

    Timer {
        id: sessionInitTimer
        interval: 200
        running: true
        repeat: false
        onTriggered: {
            detectElogindProcess.running = true
            detectHibernateProcess.running = true
            detectPrimeRunProcess.running = true
            sleepMonitor.running = true
            console.log("SessionService: Native inhibitor available:", nativeInhibitorAvailable)
            if (!SessionData.loginctlLockIntegration) {
                console.log("SessionService: loginctl lock integration disabled by user")
                return
            }
            if (socketPath && socketPath.length > 0) {
                checkServerCapabilities()
            }
        }
    }


    Process {
        id: detectUwsmProcess
        running: false
        command: ["which", "uwsm"]

        onExited: function (exitCode) {
            hasUwsm = (exitCode === 0)
        }
    }

    Process {
        id: detectElogindProcess
        running: false
        command: ["sh", "-c", "ps -eo comm= | grep -E '^(elogind|elogind-daemon)$'"]

        onExited: function (exitCode) {
            isElogind = (exitCode === 0)
        }
    }

    Process {
        id: detectHibernateProcess
        running: false
        command: ["grep", "-q", "disk", "/sys/power/state"]

        onExited: function (exitCode) {
            hibernateSupported = (exitCode === 0)
        }
    }

    Process {
        id: detectPrimeRunProcess
        running: false
        command: ["which", "prime-run"]

        onExited: function (exitCode) {
            hasPrimeRun = (exitCode === 0)
        }
    }

    // Монитор пробуждения системы
    Process {
        id: sleepMonitor
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.login1"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                // PrepareForSleep(true) - готовится ко сну, PrepareForSleep(false) - проснулась
                if (line.includes("PrepareForSleep")) {
                    const sleeping = line.includes("true")
                    if (!sleeping) {
                        console.log("SessionService: System woke up")
                    }
                    prepareForSleep(sleeping)
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0 && !sleepRestartTimer.running) {
                console.warn("SessionService: Sleep monitor failed, restarting in 5s")
                sleepRestartTimer.start()
            }
        }
    }

    Timer {
        id: sleepRestartTimer
        interval: 5000
        running: false
        onTriggered: sleepMonitor.running = true
    }

    Process {
        id: uwsmLogout
        command: ["uwsm", "stop"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (data.trim().toLowerCase().includes("not running")) {
                    _logout()
                }
            }
        }

        onExited: function (exitCode) {
            if (exitCode === 0) {
                return
            }
            _logout()
        }
    }

    // * Apps
    function launchDesktopEntry(desktopEntry, usePrimeRun) {
        let cmd = desktopEntry.command
        if (usePrimeRun && hasPrimeRun) {
            cmd = ["prime-run"].concat(cmd)
        }
        if (SessionData.launchPrefix && SessionData.launchPrefix.length > 0) {
            const launchPrefix = SessionData.launchPrefix.trim().split(" ")
            cmd = launchPrefix.concat(cmd)
        }

        Quickshell.execDetached({
            command: cmd,
            workingDirectory: desktopEntry.workingDirectory || Quickshell.env("HOME"),
        });
    }

    function launchDesktopAction(desktopEntry, action, usePrimeRun) {
        let cmd = action.command
        if (usePrimeRun && hasPrimeRun) {
            cmd = ["prime-run"].concat(cmd)
        }
        if (SessionData.launchPrefix && SessionData.launchPrefix.length > 0) {
            const launchPrefix = SessionData.launchPrefix.trim().split(" ")
            cmd = launchPrefix.concat(cmd)
        }

        Quickshell.execDetached({
            command: cmd,
            workingDirectory: desktopEntry.workingDirectory || Quickshell.env("HOME"),
        });
    }

    // * Session management
    function logout() {
        if (hasUwsm) {
            uwsmLogout.running = true
        }
        _logout()
    }

    function _logout() {
        if (CompositorService.isNiri) {
            NiriService.quit()
            return
        }

        // Hyprland fallback
        Hyprland.dispatch("exit")
    }

    function suspend() {
        Quickshell.execDetached([isElogind ? "loginctl" : "systemctl", "suspend"])
    }

    function hibernate() {
        Quickshell.execDetached([isElogind ? "loginctl" : "systemctl", "hibernate"])
    }

    function reboot() {
        Quickshell.execDetached([isElogind ? "loginctl" : "systemctl", "reboot"])
    }

    function poweroff() {
        Quickshell.execDetached([isElogind ? "loginctl" : "systemctl", "poweroff"])
    }

    // * Idle Inhibitor
    signal inhibitorChanged

    function enableIdleInhibit() {
        if (idleInhibited) {
            return
        }
        idleInhibited = true
        inhibitorChanged()
    }

    function disableIdleInhibit() {
        if (!idleInhibited) {
            return
        }
        idleInhibited = false
        inhibitorChanged()
    }

    function toggleIdleInhibit() {
        if (idleInhibited) {
            disableIdleInhibit()
        } else {
            enableIdleInhibit()
        }
    }

    function setInhibitReason(reason) {
        inhibitReason = reason

        if (idleInhibited && !nativeInhibitorAvailable) {
            const wasActive = idleInhibited
            idleInhibited = false

            Qt.callLater(() => {
                             if (wasActive) {
                                 idleInhibited = true
                             }
                         })
        }
    }

    Process {
        id: idleInhibitProcess

        command: {
            if (!idleInhibited || nativeInhibitorAvailable) {
                return ["true"]
            }

            return [isElogind ? "elogind-inhibit" : "systemd-inhibit", "--what=idle", "--who=quickshell", `--why=${inhibitReason}`, "--mode=block", "sleep", "infinity"]
        }

        running: idleInhibited && !nativeInhibitorAvailable

        onRunningChanged: {
        }

        onExited: function (exitCode) {
            if (idleInhibited && exitCode !== 0 && !nativeInhibitorAvailable) {
                console.warn("SessionService: Inhibitor process crashed with exit code:", exitCode)
                idleInhibited = false
                ToastService.showWarning("Idle inhibitor failed")
            }
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

    Connections {
        target: SessionData

        function onLoginctlLockIntegrationChanged() {
            if (SessionData.loginctlLockIntegration) {
                if (socketPath && socketPath.length > 0 && loginctlAvailable) {
                    if (!stateInitialized) {
                        stateInitialized = true
                        getLoginctlState()
                        syncLockBeforeSuspend()
                    }
                }
            } else {
                stateInitialized = false
            }
        }

        function onLockBeforeSuspendChanged() {
            if (SessionData.loginctlLockIntegration) {
                syncLockBeforeSuspend()
            }
        }
    }

    Connections {
        target: PluginManagerService
        enabled: SessionData.loginctlLockIntegration

        function onLoginctlStateUpdate(data) {
            updateLoginctlState(data)
        }

        function onLoginctlEvent(event) {
            handleLoginctlEvent(event)
        }
    }

    function checkServerCapabilities() {
        if (!PluginManagerService.isConnected) {
            return
        }

        if (PluginManagerService.capabilities.length === 0) {
            return
        }

        if (PluginManagerService.capabilities.includes("loginctl")) {
            loginctlAvailable = true
            if (SessionData.loginctlLockIntegration && !stateInitialized) {
                stateInitialized = true
                getLoginctlState()
                syncLockBeforeSuspend()
            }
        } else {
            loginctlAvailable = false
        }
    }

    function getLoginctlState() {
        if (!loginctlAvailable) return

        PluginManagerService.sendRequest("loginctl.getState", null, response => {
            if (response.result) {
                updateLoginctlState(response.result)
            }
        })
    }

    function syncLockBeforeSuspend() {
        if (!loginctlAvailable) return

        PluginManagerService.sendRequest("loginctl.setLockBeforeSuspend", {
            enabled: SessionData.lockBeforeSuspend
        }, response => {
            if (response.error) {
                console.warn("SessionService: Failed to sync lock before suspend:", response.error)
            }
        })
    }

    function updateLoginctlState(state) {
        const wasLocked = locked

        sessionId = state.sessionId || ""
        sessionPath = state.sessionPath || ""
        locked = state.locked || false
        active = state.active || false
        idleHint = state.idleHint || false
        lockedHint = state.lockedHint || false
        sessionType = state.sessionType || ""
        userName = state.userName || ""
        seat = state.seat || ""
        display = state.display || ""

        if (locked && !wasLocked) {
            sessionLocked()
        } else if (!locked && wasLocked) {
            sessionUnlocked()
        }

        loginctlStateChanged()
    }

    function handleLoginctlEvent(event) {
        if (event.event === "Lock") {
            locked = true
            lockedHint = true
            sessionLocked()
        } else if (event.event === "Unlock") {
            locked = false
            lockedHint = false
            sessionUnlocked()
        }
    }

}
