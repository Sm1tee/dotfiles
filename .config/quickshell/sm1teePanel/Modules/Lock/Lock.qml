import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Common
import qs.Services

Item {
    id: root

    property string sharedPasswordBuffer: ""
    property bool shouldLock: false

    Component.onCompleted: {
        IdleService.lockComponent = root
    }

    function activate() {
        shouldLock = true
    }

    Connections {
        target: SessionService

        function onSessionLocked() {
            shouldLock = true
        }

        function onSessionUnlocked() {
            shouldLock = false
        }
    }

    Connections {
        target: IdleService

        function onLockRequested() {
            shouldLock = true
        }
    }

    WlSessionLock {
        id: sessionLock

        locked: root.shouldLock

        WlSessionLockSurface {
            color: "transparent"

            LockSurface {
                anchors.fill: parent
                lock: sessionLock
                sharedPasswordBuffer: root.sharedPasswordBuffer
                onUnlockRequested: {
                    root.shouldLock = false
                }
                onPasswordChanged: newPassword => {
                                       root.sharedPasswordBuffer = newPassword
                                   }
            }
        }
    }

    LockScreenDemo {
        id: demoWindow
    }

    IpcHandler {
        target: "lock"

        function lock() {
            shouldLock = true
        }

        function demo() {
            demoWindow.showDemo()
        }

        function isLocked(): bool {
            return sessionLock.locked
        }
    }
}
