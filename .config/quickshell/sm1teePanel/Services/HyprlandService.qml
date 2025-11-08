pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    property string currentKeyboardLayout: ""
    property string mainKeyboardName: ""

    signal keyboardLayoutChanged(string layout)

    // Получаем начальную раскладку
    Process {
        id: initialLayoutProcess
        running: CompositorService.isHyprland
        command: ["hyprctl", "-j", "devices"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    const mainKeyboard = data.keyboards.find(kb => kb.main === true)
                    if (mainKeyboard) {
                        root.mainKeyboardName = mainKeyboard.name
                        if (mainKeyboard.active_keymap) {
                            root.currentKeyboardLayout = mainKeyboard.active_keymap
                        }
                    }
                } catch (e) {
                    console.warn("HyprlandService: Failed to parse initial layout:", e)
                }
            }
        }
    }

    // Слушаем события Hyprland через socat
    Process {
        id: eventListener
        running: CompositorService.isHyprland
        command: ["sh", "-c", "socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"]
        
        stdout: SplitParser {
            onRead: line => {
                try {
                    // Формат: EVENT>>DATA
                    const parts = line.split('>>')
                    if (parts.length >= 2) {
                        const eventType = parts[0]
                        const eventData = parts[1]
                        
                        if (eventType === 'activelayout') {
                            // activelayout>>keyboard_name,layout_name
                            const layoutParts = eventData.split(',')
                            if (layoutParts.length >= 2) {
                                const newLayout = layoutParts[1].trim()
                                if (newLayout !== root.currentKeyboardLayout) {
                                    root.currentKeyboardLayout = newLayout
                                    root.keyboardLayoutChanged(newLayout)
                                }
                            }
                        }
                    }
                } catch (e) {
                    console.warn("HyprlandService: Failed to parse event:", line, e)
                }
            }
        }
    }
}
