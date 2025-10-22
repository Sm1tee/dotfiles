pragma Singleton

pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property bool dmsAvailable: false
    property var capabilities: []
    property int apiVersion: 0
    readonly property int expectedApiVersion: 1
    property var availablePlugins: []
    property var installedPlugins: []
    property bool isConnected: false
    property bool isConnecting: false
    property bool subscribeConnected: false

    readonly property string socketPath: Quickshell.env("DMS_SOCKET")
    readonly property bool verboseLogs: Quickshell.env("DMS_VERBOSE_LOGS") === "1"

    property var pendingRequests: ({})
    property int requestIdCounter: 0
    property bool shownOutdatedError: false
    property string updateCommand: ""
    property bool checkingUpdateCommand: false

    signal pluginsListReceived(var plugins)
    signal installedPluginsReceived(var plugins)
    signal searchResultsReceived(var plugins)
    signal operationSuccess(string message)
    signal operationError(string error)
    signal connectionStateChanged()

    signal networkStateUpdate(var data)
    signal loginctlStateUpdate(var data)
    signal loginctlEvent(var event)

    Component.onCompleted: {
        if (socketPath && socketPath.length > 0) {
            detectUpdateCommand()
        }
    }

    function detectUpdateCommand() {
        checkingUpdateCommand = true
        checkAurHelper.running = true
    }

    function startSocketConnection() {
        if (socketPath && socketPath.length > 0) {
            testProcess.running = true
        }
    }



    Process {
        id: testProcess
        command: ["test", "-S", root.socketPath]

        onExited: exitCode => {
            if (exitCode === 0) {
                root.dmsAvailable = true
                connectSocket()
            } else {
                root.dmsAvailable = false
            }
        }
    }

    function connectSocket() {
        if (!dmsAvailable || isConnected || isConnecting) {
            return
        }

        isConnecting = true
        requestSocket.connected = true
    }

    DankSocket {
        id: requestSocket
        path: root.socketPath
        connected: false

        onConnectionStateChanged: {
            if (connected) {
                root.isConnected = true
                root.isConnecting = false
                root.connectionStateChanged()
                subscribeSocket.connected = true
            } else {
                root.isConnected = false
                root.isConnecting = false
                root.apiVersion = 0
                root.capabilities = []
                root.connectionStateChanged()
            }
        }

        parser: SplitParser {
            onRead: line => {
                if (!line || line.length === 0) {
                    return
                }

                if (root.verboseLogs) {
                    console.log("DMSService: Request socket <<", line)
                }

                try {
                    const response = JSON.parse(line)
                    handleResponse(response)
                } catch (e) {
                    console.warn("DMSService: Failed to parse request response:", line, e)
                }
            }
        }
    }

    DankSocket {
        id: subscribeSocket
        path: root.socketPath
        connected: false

        onConnectionStateChanged: {
            root.subscribeConnected = connected
            if (connected) {
                sendSubscribeRequest()
            }
        }

        parser: SplitParser {
            onRead: line => {
                if (!line || line.length === 0) {
                    return
                }

                if (root.verboseLogs) {
                    console.log("DMSService: Subscribe socket <<", line)
                }

                try {
                    const response = JSON.parse(line)
                    handleSubscriptionEvent(response)
                } catch (e) {
                    console.warn("DMSService: Failed to parse subscription event:", line, e)
                }
            }
        }
    }

    function sendSubscribeRequest() {
        const request = {
            "method": "subscribe"
        }

        if (verboseLogs) {
            console.log("DMSService: Subscribing to all services")
        }
        subscribeSocket.send(request)
    }

    function handleSubscriptionEvent(response) {
        if (response.error) {
            if (response.error.includes("unknown method") && response.error.includes("subscribe")) {
                if (!shownOutdatedError) {
                    console.error("DMSService: Server does not support subscribe method")
                    ToastService.showError(
                        "DMS устарел",
                        "Для обновления выполните следующую команду:",
                        updateCommand
                    )
                    shownOutdatedError = true
                }
            }
            return
        }

        if (!response.result) {
            return
        }

        const service = response.result.service
        const data = response.result.data

        if (service === "server") {
            apiVersion = data.apiVersion || 0
            capabilities = data.capabilities || []

            console.log("DMSService: Connected (API v" + apiVersion + ") -", JSON.stringify(capabilities))

            if (apiVersion < expectedApiVersion) {
                ToastService.showError("DMS server is outdated (API v" + apiVersion + ", expected v" + expectedApiVersion + ")")
            }
        } else if (service === "network") {
            networkStateUpdate(data)
        } else if (service === "loginctl") {
            if (data.event) {
                loginctlEvent(data)
            } else {
                loginctlStateUpdate(data)
            }
        }
    }

    function sendRequest(method, params, callback) {
        if (!isConnected) {
            if (callback) {
                callback({
                    "error": "not connected to DMS socket"
                })
            }
            return
        }

        requestIdCounter++
        const id = Date.now() + requestIdCounter
        const request = {
            "id": id,
            "method": method
        }

        if (params) {
            request.params = params
        }

        if (callback) {
            pendingRequests[id] = callback
        }

        requestSocket.send(request)
    }

    function handleResponse(response) {
        const callback = pendingRequests[response.id]

        if (callback) {
            delete pendingRequests[response.id]
            callback(response)
        }
    }

    function ping(callback) {
        sendRequest("ping", null, callback)
    }

    function listPlugins(callback) {
        sendRequest("plugins.list", null, response => {
                        if (response.result) {
                            availablePlugins = response.result
                            pluginsListReceived(response.result)
                        }
                        if (callback) {
                            callback(response)
                        }
                    })
    }

    function listInstalled(callback) {
        sendRequest("plugins.listInstalled", null, response => {
                        if (response.result) {
                            installedPlugins = response.result
                            installedPluginsReceived(response.result)
                        }
                        if (callback) {
                            callback(response)
                        }
                    })
    }

    function search(query, category, compositor, capability, callback) {
        const params = {
            "query": query
        }
        if (category) {
            params.category = category
        }
        if (compositor) {
            params.compositor = compositor
        }
        if (capability) {
            params.capability = capability
        }

        sendRequest("plugins.search", params, response => {
                        if (response.result) {
                            searchResultsReceived(response.result)
                        }
                        if (callback) {
                            callback(response)
                        }
                    })
    }

    function install(pluginName, callback) {
        sendRequest("plugins.install", {
                        "name": pluginName
                    }, response => {
                        if (callback) {
                            callback(response)
                        }
                        if (!response.error) {
                            listInstalled()
                        }
                    })
    }

    function uninstall(pluginName, callback) {
        sendRequest("plugins.uninstall", {
                        "name": pluginName
                    }, response => {
                        if (callback) {
                            callback(response)
                        }
                        if (!response.error) {
                            listInstalled()
                        }
                    })
    }

    function update(pluginName, callback) {
        sendRequest("plugins.update", {
                        "name": pluginName
                    }, response => {
                        if (callback) {
                            callback(response)
                        }
                        if (!response.error) {
                            listInstalled()
                        }
                    })
    }
}
