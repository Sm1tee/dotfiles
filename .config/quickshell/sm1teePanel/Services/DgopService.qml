pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property int refCount: 0
    property int updateInterval: refCount > 0 ? 5000 : 30000  // Увеличено с 3 до 5 секунд
    property bool isUpdating: false
    property bool dgopAvailable: true // Always available with native commands

    property var moduleRefCounts: ({})
    property var enabledModules: []
    property var gpuPciIds: []
    property var gpuPciIdRefCounts: ({})
    property int processLimit: 20
    property string processSort: "cpu"
    property bool noCpu: false

    // CPU data
    property real cpuUsage: 0
    property real cpuFrequency: 0
    property real cpuTemperature: 0
    property int cpuCores: 1
    property string cpuModel: ""
    property var perCoreCpuUsage: []
    property var lastCpuStats: null

    // Memory data
    property real memoryUsage: 0
    property real totalMemoryMB: 0
    property real usedMemoryMB: 0
    property real freeMemoryMB: 0
    property real availableMemoryMB: 0
    property int totalMemoryKB: 0
    property int usedMemoryKB: 0
    property int totalSwapKB: 0
    property int usedSwapKB: 0

    // Network data
    property real networkRxRate: 0
    property real networkTxRate: 0
    property var lastNetworkStats: null
    property var networkInterfaces: []

    // Disk data
    property real diskReadRate: 0
    property real diskWriteRate: 0
    property var lastDiskStats: null
    property var diskMounts: []
    property var diskDevices: []

    // Process data
    property var processes: []
    property var allProcesses: []
    property string currentSort: "cpu"
    property bool sortDescending: true
    property var availableGpus: []

    // System info
    property string kernelVersion: ""
    property string distribution: ""
    property string hostname: ""
    property string architecture: ""
    property string loadAverage: ""
    property int processCount: 0
    property int threadCount: 0
    property string bootTime: ""
    property string motherboard: ""
    property string biosVersion: ""

    // History
    property int historySize: 60
    property var cpuHistory: []
    property var memoryHistory: []
    property var networkHistory: ({"rx": [], "tx": []})
    property var diskHistory: ({"read": [], "write": []})

    function addRef(modules = null) {
        refCount++
        let modulesChanged = false
        if (modules) {
            const modulesToAdd = Array.isArray(modules) ? modules : [modules]
            for (const module of modulesToAdd) {
                const currentCount = moduleRefCounts[module] || 0
                moduleRefCounts[module] = currentCount + 1
                if (enabledModules.indexOf(module) === -1) {
                    enabledModules.push(module)
                    modulesChanged = true
                }
            }
        }
        if (modulesChanged || refCount === 1) {
            enabledModules = enabledModules.slice()
            moduleRefCounts = Object.assign({}, moduleRefCounts)
            updateAllStats()
        }
    }

    function removeRef(modules = null) {
        refCount = Math.max(0, refCount - 1)
        let modulesChanged = false
        if (modules) {
            const modulesToRemove = Array.isArray(modules) ? modules : [modules]
            for (const module of modulesToRemove) {
                const currentCount = moduleRefCounts[module] || 0
                if (currentCount > 1) {
                    moduleRefCounts[module] = currentCount - 1
                } else if (currentCount === 1) {
                    delete moduleRefCounts[module]
                    const index = enabledModules.indexOf(module)
                    if (index > -1) {
                        enabledModules.splice(index, 1)
                        modulesChanged = true
                    }
                }
            }
        }
        if (modulesChanged) {
            enabledModules = enabledModules.slice()
            moduleRefCounts = Object.assign({}, moduleRefCounts)
        }
    }

    function setGpuPciIds(pciIds) { gpuPciIds = Array.isArray(pciIds) ? pciIds : [] }
    function addGpuPciId(pciId) {
        const currentCount = gpuPciIdRefCounts[pciId] || 0
        gpuPciIdRefCounts[pciId] = currentCount + 1
        if (!gpuPciIds.includes(pciId)) gpuPciIds = gpuPciIds.concat([pciId])
        gpuPciIdRefCounts = Object.assign({}, gpuPciIdRefCounts)
    }
    function removeGpuPciId(pciId) {
        const currentCount = gpuPciIdRefCounts[pciId] || 0
        if (currentCount > 1) {
            gpuPciIdRefCounts[pciId] = currentCount - 1
        } else if (currentCount === 1) {
            delete gpuPciIdRefCounts[pciId]
            const index = gpuPciIds.indexOf(pciId)
            if (index > -1) { gpuPciIds = gpuPciIds.slice(); gpuPciIds.splice(index, 1) }
        }
        gpuPciIdRefCounts = Object.assign({}, gpuPciIdRefCounts)
    }
    function setProcessOptions(limit = 20, sort = "cpu", disableCpu = false) {
        processLimit = limit; processSort = sort; noCpu = disableCpu
    }

    function updateAllStats() {
        if (refCount > 0 && enabledModules.length > 0) {
            isUpdating = true
            if (enabledModules.includes("cpu") || enabledModules.includes("all")) cpuProcess.running = true
            if (enabledModules.includes("memory") || enabledModules.includes("all")) memoryProcess.running = true
            if (enabledModules.includes("network") || enabledModules.includes("all")) networkProcess.running = true
            if (enabledModules.includes("processes") || enabledModules.includes("all")) processProcess.running = true
            if (enabledModules.includes("diskmounts") || enabledModules.includes("all")) diskMountsProcess.running = true
            // Update AMD GPU stats if system module is enabled
            if ((enabledModules.includes("system") || enabledModules.includes("all")) && availableGpus.length > 0) {
                amdGpuStatsProcess.running = true
            }
        } else { isUpdating = false }
    }

    function parseCpuStats(text) {
        const lines = text.trim().split('\n')
        if (lines.length === 0) return
        
        // Count CPU cores (lines starting with "cpu" followed by number)
        let coreCount = 0
        for (const line of lines) {
            if (line.match(/^cpu\d+/)) coreCount++
        }
        if (coreCount > 0) cpuCores = coreCount
        
        const parts = lines[0].split(/\s+/)
        if (parts.length < 5) return
        const user = parseInt(parts[1]) || 0, nice = parseInt(parts[2]) || 0
        const system = parseInt(parts[3]) || 0, idle = parseInt(parts[4]) || 0
        const iowait = parseInt(parts[5]) || 0, irq = parseInt(parts[6]) || 0, softirq = parseInt(parts[7]) || 0
        const steal = parseInt(parts[8]) || 0
        
        // Total = all time, Idle = idle + iowait
        const total = user + nice + system + idle + iowait + irq + softirq + steal
        const idleTime = idle + iowait
        const active = total - idleTime
        
        if (lastCpuStats) {
            const totalDiff = total - lastCpuStats.total
            const activeDiff = active - lastCpuStats.active
            if (totalDiff > 0) { 
                cpuUsage = (activeDiff / totalDiff) * 100
                addToHistory(cpuHistory, cpuUsage) 
            }
        }
        lastCpuStats = { total, active }
        
        // Try to read CPU temperature
        cpuTempProcess.running = true
    }
    
    function parseCpuTemp(text) {
        if (!text || text.trim().length === 0) {
            // No temperature sensor found, keep last value or set to 0
            if (cpuTemperature === 0) cpuTemperature = -1 // -1 means unavailable
            return
        }
        
        const lines = text.trim().split('\n')
        
        for (const line of lines) {
            const parts = line.split(':')
            if (parts.length !== 2) continue
            
            const temp = parseInt(parts[1].trim()) || 0
            
            // Valid temperature range: 0-150°C (in millidegrees: 0-150000)
            if (temp > 0 && temp < 150000) {
                cpuTemperature = temp / 1000
                return
            }
        }
        
        // If we get here, no valid temperature was found
        if (cpuTemperature === 0) cpuTemperature = -1
    }

    function parseMemoryStats(text) {
        const lines = text.trim().split('\n')
        let memTotal = 0, memAvailable = 0, memFree = 0, swapTotal = 0, swapFree = 0
        for (const line of lines) {
            const parts = line.split(/:\s+/)
            if (parts.length < 2) continue
            const key = parts[0], value = parseInt(parts[1]) || 0
            if (key === "MemTotal") memTotal = value
            else if (key === "MemAvailable") memAvailable = value
            else if (key === "MemFree") memFree = value
            else if (key === "SwapTotal") swapTotal = value
            else if (key === "SwapFree") swapFree = value
        }
        totalMemoryKB = memTotal
        availableMemoryMB = memAvailable / 1024
        freeMemoryMB = memFree / 1024
        usedMemoryKB = memTotal - memAvailable
        totalSwapKB = swapTotal
        usedSwapKB = swapTotal - swapFree
        totalMemoryMB = memTotal / 1024
        usedMemoryMB = usedMemoryKB / 1024
        memoryUsage = memTotal > 0 ? ((memTotal - memAvailable) / memTotal) * 100 : 0
        addToHistory(memoryHistory, memoryUsage)
    }

    function parseNetworkStats(text) {
        const lines = text.trim().split('\n')
        let totalRx = 0, totalTx = 0
        for (let i = 2; i < lines.length; i++) {
            const parts = lines[i].trim().split(/\s+/)
            if (parts.length < 10) continue
            const iface = parts[0].replace(':', '')
            if (iface === 'lo') continue
            totalRx += parseInt(parts[1]) || 0
            totalTx += parseInt(parts[9]) || 0
        }
        if (lastNetworkStats) {
            const timeDiff = updateInterval / 1000
            networkRxRate = Math.max(0, (totalRx - lastNetworkStats.rx) / timeDiff)
            networkTxRate = Math.max(0, (totalTx - lastNetworkStats.tx) / timeDiff)
            addToHistory(networkHistory.rx, networkRxRate / 1024)
            addToHistory(networkHistory.tx, networkTxRate / 1024)
        }
        lastNetworkStats = { rx: totalRx, tx: totalTx }
    }

    function addToHistory(array, value) { array.push(value); if (array.length > historySize) array.shift() }
    function getProcessIcon(command) {
        const cmd = command.toLowerCase()
        if (cmd.includes("firefox") || cmd.includes("chrome") || cmd.includes("browser") || cmd.includes("chromium")) return "web"
        if (cmd.includes("code") || cmd.includes("editor") || cmd.includes("vim")) return "code"
        if (cmd.includes("terminal") || cmd.includes("bash") || cmd.includes("zsh")) return "terminal"
        if (cmd.includes("music") || cmd.includes("audio") || cmd.includes("spotify")) return "music_note"
        if (cmd.includes("video") || cmd.includes("vlc") || cmd.includes("mpv")) return "play_circle"
        if (cmd.includes("systemd") || cmd.includes("elogind") || cmd.includes("kernel") || cmd.includes("kthread") || cmd.includes("kworker")) return "settings"
        return "memory"
    }
    function formatCpuUsage(cpu) { return (cpu || 0).toFixed(1) + "%" }
    function formatMemoryUsage(memoryKB) {
        const mem = memoryKB || 0
        if (mem < 1024) return mem.toFixed(0) + " KB"
        else if (mem < 1024 * 1024) return (mem / 1024).toFixed(1) + " MB"
        else return (mem / (1024 * 1024)).toFixed(1) + " GB"
    }
    function formatSystemMemory(memoryKB) {
        const mem = memoryKB || 0
        if (mem === 0) return "--"
        if (mem < 1024 * 1024) return (mem / 1024).toFixed(0) + " MB"
        else return (mem / (1024 * 1024)).toFixed(1) + " GB"
    }
    function killProcess(pid) { if (pid > 0) Quickshell.execDetached("kill", [pid.toString()]) }
    function setSortBy(newSortBy) { if (newSortBy !== currentSort) { currentSort = newSortBy; applySorting() } }
    function toggleSortOrder() { sortDescending = !sortDescending; applySorting() }
    function applySorting() {
        if (!allProcesses || allProcesses.length === 0) return
        const sorted = allProcesses.slice()
        sorted.sort((a, b) => {
            let valueA, valueB, result
            switch (currentSort) {
                case "cpu": 
                    valueA = a.cpu || 0
                    valueB = b.cpu || 0
                    result = valueB - valueA
                    break
                case "memory": 
                    valueA = a.memoryKB || 0
                    valueB = b.memoryKB || 0
                    result = valueB - valueA
                    break
                case "name": 
                    valueA = (a.command || "").toLowerCase()
                    valueB = (b.command || "").toLowerCase()
                    result = valueA.localeCompare(valueB)
                    break
                case "pid": 
                    valueA = a.pid || 0
                    valueB = b.pid || 0
                    result = valueA - valueB
                    break
                default: 
                    return 0
            }
            return sortDescending ? result : -result
        })
        processes = sorted.slice(0, processLimit)
    }

    function parseProcessStats(text) {
        const lines = text.trim().split('\n')
        const newProcesses = []
        for (const line of lines) {
            const parts = line.trim().split(/\s+/)
            if (parts.length < 5) continue
            const pid = parseInt(parts[0]) || 0
            const cpu = parseFloat(parts[1]) || 0
            const mem = parseFloat(parts[2]) || 0
            const memKB = parseInt(parts[3]) || 0
            const command = parts[4] || ""
            
            newProcesses.push({
                pid: pid,
                ppid: 0,
                cpu: cpu,
                memoryPercent: mem,
                memoryKB: memKB,
                command: command,
                fullCommand: command,
                displayName: command.length > 15 ? command.substring(0, 15) + "..." : command
            })
        }
        allProcesses = newProcesses
        applySorting()
    }

    function parseGpuDetect(text) {
        const lines = text.trim().split('\n')
        const gpus = []
        for (const line of lines) {
            if (line.includes('VGA') || line.includes('3D') || line.includes('Display')) {
                let vendor = "Unknown"
                let name = line
                if (line.includes('NVIDIA')) vendor = "NVIDIA"
                else if (line.includes('AMD') || line.includes('ATI')) vendor = "AMD"
                else if (line.includes('Intel')) vendor = "Intel"
                
                // Extract GPU name - everything after "VGA compatible controller: " or similar
                let match = line.match(/:\s+VGA compatible controller:\s+(.+)/)
                if (!match) match = line.match(/:\s+3D controller:\s+(.+)/)
                if (!match) match = line.match(/:\s+Display controller:\s+(.+)/)
                if (!match) match = line.match(/:\s+(.+)/)
                
                if (match) {
                    name = match[1]
                    // Remove vendor prefix
                    name = name.replace(/^Advanced Micro Devices,?\s*Inc\.?\s*\[AMD\/ATI\]\s*/gi, '')
                    name = name.replace(/^Advanced Micro Devices,?\s*Inc\.?\s*/gi, '')
                    name = name.replace(/^AMD\s*/gi, '')
                    name = name.replace(/^NVIDIA\s+Corporation\s*/gi, '')
                    name = name.replace(/^Intel\s+Corporation\s*/gi, '')
                    // Remove ALL brackets and parentheses content
                    name = name.replace(/\s*\[.*?\]/g, '')
                    name = name.replace(/\s*\(.*?\)/g, '')
                    // Remove codenames like "Navi 32", "Polaris 20", "Turing", etc
                    name = name.replace(/\s+(Navi|Polaris|Vega|Ellesmere|Baffin|Tonga|Fiji|Hawaii|Tahiti|Pitcairn|Cape Verde|Oland|Bonaire|Turks|Caicos|Cayman|Barts|Redwood|Cedar|Juniper|Cypress|RV\d+|R\d+)\s+\d+/gi, '')
                    name = name.replace(/\s+(Turing|Ampere|Ada|Pascal|Maxwell|Kepler|Fermi|Tesla|Volta|Hopper|Lovelace|GK\d+|GP\d+|GM\d+|TU\d+|GA\d+|AD\d+)/gi, '')
                    name = name.replace(/\s+(Alder Lake|Rocket Lake|Tiger Lake|Ice Lake|Comet Lake|Coffee Lake|Kaby Lake|Skylake|Broadwell|Haswell|Ivy Bridge|Sandy Bridge|Gen\d+)/gi, '')
                    name = name.trim()
                }
                
                gpus.push({
                    driver: vendor.toLowerCase(),
                    vendor: vendor,
                    displayName: name,
                    fullName: name,
                    pciId: "",
                    temperature: 0
                })
            }
        }
        if (gpus.length > 0) availableGpus = gpus
    }

    function parseAmdGpuStats(text) {
        if (!text || !text.trim()) return
        
        const lines = text.trim().split('\n')
        if (lines.length < 2) return
        
        const usage = parseInt(lines[0])
        const tempMillidegrees = parseInt(lines[1])
        
        if (availableGpus.length > 0 && !isNaN(usage) && !isNaN(tempMillidegrees)) {
            const updatedGpus = availableGpus.slice()
            updatedGpus[0].usage = usage
            updatedGpus[0].temperature = tempMillidegrees / 1000
            availableGpus = updatedGpus
        }
    }

    function parseDiskMounts(text) {
        const lines = text.trim().split('\n')
        const mounts = []
        
        // Skip header line
        for (let i = 1; i < lines.length; i++) {
            const parts = lines[i].trim().split(/\s+/)
            if (parts.length < 6) continue
            
            const device = parts[0]
            const mount = parts[1]
            const size = parts[2]
            const used = parts[3]
            const avail = parts[4]
            const percent = parts[5]
            
            // Skip virtual filesystems
            if (device.startsWith('tmpfs') || device.startsWith('devtmpfs') || 
                device.startsWith('udev') || device.startsWith('overlay') ||
                device.startsWith('none') || device === 'efivarfs') {
                continue
            }
            
            // Skip system mounts
            if (mount.startsWith('/dev') || mount.startsWith('/sys') || 
                mount.startsWith('/proc') || mount.startsWith('/run')) {
                continue
            }
            
            // Skip boot partitions (EFI, boot)
            if (mount === '/boot' || mount === '/efi' || mount === '/boot/efi' ||
                mount.startsWith('/boot/') || mount.startsWith('/efi/')) {
                continue
            }
            
            // Skip snap mounts
            if (mount.startsWith('/snap/')) {
                continue
            }
            
            // Create display name
            let displayName = mount
            if (mount === '/') {
                displayName = 'System'
            } else {
                // Extract last part of path: /mnt/ssd2 -> ssd2
                const pathParts = mount.split('/').filter(p => p.length > 0)
                displayName = pathParts[pathParts.length - 1] || mount
            }
            
            mounts.push({
                device: device,
                mount: mount,
                displayName: displayName,
                size: size,
                used: used,
                avail: avail,
                percent: percent
            })
        }
        
        diskMounts = mounts
    }

    Timer { id: updateTimer; interval: root.updateInterval; running: root.refCount > 0 && root.enabledModules.length > 0; repeat: true; triggeredOnStart: true; onTriggered: root.updateAllStats() }
    Process { id: cpuProcess; command: ["cat", "/proc/stat"]; running: false; onExited: () => { isUpdating = false }; stdout: StdioCollector { onStreamFinished: { if (text.trim()) parseCpuStats(text) } } }
    Process { id: cpuTempProcess; command: ["sh", "-c", "grep -l 'k10temp\\|coretemp\\|zenpower\\|cpu_thermal\\|soc_thermal' /sys/class/hwmon/hwmon*/name 2>/dev/null | head -1 | xargs -I {} sh -c 'name=$(cat {}); dir=$(dirname {}); temp=$(cat $dir/temp*_input 2>/dev/null | head -1); echo \"$name:$temp\"'"]; running: false; stdout: StdioCollector { onStreamFinished: { if (text.trim()) parseCpuTemp(text) } } }
    Process { id: memoryProcess; command: ["cat", "/proc/meminfo"]; running: false; stdout: StdioCollector { onStreamFinished: { if (text.trim()) parseMemoryStats(text) } } }
    Process { id: networkProcess; command: ["cat", "/proc/net/dev"]; running: false; stdout: StdioCollector { onStreamFinished: { if (text.trim()) parseNetworkStats(text) } } }
    Process { id: processProcess; command: ["ps", "-eo", "pid,pcpu,pmem,rss,comm", "--sort=-%cpu", "--no-headers"]; running: false; stdout: StdioCollector { onStreamFinished: { if (text.trim()) parseProcessStats(text) } } }
    Process { id: gpuDetectProcess; command: ["lspci"]; running: false; stdout: StdioCollector { onStreamFinished: { if (text.trim()) parseGpuDetect(text) } } }
    Process { id: amdGpuStatsProcess; command: ["sh", "-c", "cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null && cat /sys/class/drm/card1/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -1"]; running: false; stdout: StdioCollector { onStreamFinished: { if (text.trim()) parseAmdGpuStats(text) } } }
    Process { id: diskMountsProcess; command: ["df", "-h", "--output=source,target,size,used,avail,pcent"]; running: false; stdout: StdioCollector { onStreamFinished: { if (text.trim()) parseDiskMounts(text) } } }
    Process { id: osReleaseProcess; command: ["cat", "/etc/os-release"]; running: false; stdout: StdioCollector { onStreamFinished: { if (text.trim()) { const lines = text.trim().split('\n'); let prettyName = "", name = ""; for (const line of lines) { const t = line.trim(); if (t.startsWith('PRETTY_NAME=')) prettyName = t.substring(12).replace(/^["']|["']$/g, ''); else if (t.startsWith('NAME=')) name = t.substring(5).replace(/^["']|["']$/g, '') } distribution = prettyName || name || "Linux" } } } }
    Component.onCompleted: { 
        osReleaseProcess.running = true
        gpuDetectProcess.running = true // Detect GPU once at startup
        diskMountsProcess.running = true // Detect disk mounts once at startup
        dgopAvailable = true 
    }
}
