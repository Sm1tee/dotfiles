pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property bool networkAvailable: activeService !== null
    property string networkStatus: activeService?.networkStatus ?? "disconnected"
    property string primaryConnection: activeService?.primaryConnection ?? ""

    property string ethernetIP: activeService?.ethernetIP ?? ""
    property string ethernetInterface: activeService?.ethernetInterface ?? ""
    property bool ethernetConnected: activeService?.ethernetConnected ?? false
    property string ethernetConnectionUuid: activeService?.ethernetConnectionUuid ?? ""

    property string wifiIP: activeService?.wifiIP ?? ""
    property string wifiInterface: activeService?.wifiInterface ?? ""
    property bool wifiConnected: activeService?.wifiConnected ?? false
    property bool wifiEnabled: activeService?.wifiEnabled ?? true
    property string wifiConnectionUuid: activeService?.wifiConnectionUuid ?? ""
    property string wifiDevicePath: activeService?.wifiDevicePath ?? ""
    property string activeAccessPointPath: activeService?.activeAccessPointPath ?? ""

    property string currentWifiSSID: activeService?.currentWifiSSID ?? ""
    property int wifiSignalStrength: activeService?.wifiSignalStrength ?? 0
    property var wifiNetworks: activeService?.wifiNetworks ?? []
    property var savedConnections: activeService?.savedConnections ?? []
    property var ssidToConnectionName: activeService?.ssidToConnectionName ?? ({})
    property var wifiSignalIcon: activeService?.wifiSignalIcon ?? "wifi_off"

    property string userPreference: activeService?.userPreference ?? "auto"
    property bool isConnecting: activeService?.isConnecting ?? false
    property string connectingSSID: activeService?.connectingSSID ?? ""
    property string connectionError: activeService?.connectionError ?? ""

    property bool isScanning: activeService?.isScanning ?? false
    property bool autoScan: activeService?.autoScan ?? false

    property bool wifiAvailable: activeService?.wifiAvailable ?? true
    property bool wifiToggling: activeService?.wifiToggling ?? false
    property bool changingPreference: activeService?.changingPreference ?? false
    property string targetPreference: activeService?.targetPreference ?? ""
    property var savedWifiNetworks: activeService?.savedWifiNetworks ?? []
    property string connectionStatus: activeService?.connectionStatus ?? ""
    property string lastConnectionError: activeService?.lastConnectionError ?? ""
    property bool passwordDialogShouldReopen: activeService?.passwordDialogShouldReopen ?? false
    property bool autoRefreshEnabled: activeService?.autoRefreshEnabled ?? false
    property string wifiPassword: activeService?.wifiPassword ?? ""
    property string forgetSSID: activeService?.forgetSSID ?? ""

    property string networkInfoSSID: activeService?.networkInfoSSID ?? ""
    property string networkInfoDetails: activeService?.networkInfoDetails ?? ""
    property bool networkInfoLoading: activeService?.networkInfoLoading ?? false

    property int refCount: activeService?.refCount ?? 0
    property bool stateInitialized: activeService?.stateInitialized ?? false

    property bool subscriptionConnected: activeService?.subscriptionConnected ?? false

    signal networksUpdated
    signal connectionChanged

    property bool usingLegacy: false
    property var activeService: null

    readonly property string socketPath: Quickshell.env("DMS_SOCKET")

    Component.onCompleted: {
        if (!socketPath || socketPath.length === 0) {
            useLegacyService()
        }
    }

    Connections {
        target: NetworkManagerService

        function onNetworkAvailableChanged() {
            if (!activeService && NetworkManagerService.networkAvailable) {
                activeService = NetworkManagerService
                usingLegacy = false
                connectSignals()
            } else if (!activeService && !NetworkManagerService.networkAvailable && socketPath && socketPath.length > 0) {
                useLegacyService()
            }
        }
    }

    function useLegacyService() {
        activeService = LegacyNetworkService
        usingLegacy = true
        if (LegacyNetworkService.activate) {
            LegacyNetworkService.activate()
        }
        connectSignals()
    }

    function connectSignals() {
        if (activeService) {
            if (activeService.networksUpdated) {
                activeService.networksUpdated.connect(root.networksUpdated)
            }
            if (activeService.connectionChanged) {
                activeService.connectionChanged.connect(root.connectionChanged)
            }
        }
    }

    function addRef() {
        if (activeService && activeService.addRef) {
            activeService.addRef()
        }
    }

    function removeRef() {
        if (activeService && activeService.removeRef) {
            activeService.removeRef()
        }
    }

    function getState() {
        if (activeService && activeService.getState) {
            activeService.getState()
        }
    }

    function scanWifi() {
        if (activeService && activeService.scanWifi) {
            activeService.scanWifi()
        }
    }

    function scanWifiNetworks() {
        if (activeService && activeService.scanWifiNetworks) {
            activeService.scanWifiNetworks()
        }
    }

    function connectToWifi(ssid, password = "", username = "") {
        if (activeService && activeService.connectToWifi) {
            activeService.connectToWifi(ssid, password, username)
        }
    }

    function disconnectWifi() {
        if (activeService && activeService.disconnectWifi) {
            activeService.disconnectWifi()
        }
    }

    function forgetWifiNetwork(ssid) {
        if (activeService && activeService.forgetWifiNetwork) {
            activeService.forgetWifiNetwork(ssid)
        }
    }

    function toggleWifiRadio() {
        if (activeService && activeService.toggleWifiRadio) {
            activeService.toggleWifiRadio()
        }
    }

    function enableWifiDevice() {
        if (activeService && activeService.enableWifiDevice) {
            activeService.enableWifiDevice()
        }
    }

    function setNetworkPreference(preference) {
        if (activeService && activeService.setNetworkPreference) {
            activeService.setNetworkPreference(preference)
        }
    }

    function setConnectionPriority(type) {
        if (activeService && activeService.setConnectionPriority) {
            activeService.setConnectionPriority(type)
        }
    }

    function connectToWifiAndSetPreference(ssid, password, username = "") {
        if (activeService && activeService.connectToWifiAndSetPreference) {
            activeService.connectToWifiAndSetPreference(ssid, password, username)
        }
    }

    function connectToHiddenWifi(ssid, password = "", username = "") {
        if (activeService && activeService.connectToHiddenWifi) {
            activeService.connectToHiddenWifi(ssid, password, username)
        }
    }

    function toggleNetworkConnection(type) {
        if (activeService && activeService.toggleNetworkConnection) {
            activeService.toggleNetworkConnection(type)
        }
    }

    function startAutoScan() {
        if (activeService && activeService.startAutoScan) {
            activeService.startAutoScan()
        }
    }

    function stopAutoScan() {
        if (activeService && activeService.stopAutoScan) {
            activeService.stopAutoScan()
        }
    }

    function fetchNetworkInfo(ssid) {
        if (activeService && activeService.fetchNetworkInfo) {
            activeService.fetchNetworkInfo(ssid)
        }
    }

    function getNetworkInfo(ssid) {
        if (activeService && activeService.getNetworkInfo) {
            return activeService.getNetworkInfo(ssid)
        }
        return null
    }

    function refreshNetworkState() {
        if (activeService && activeService.refreshNetworkState) {
            activeService.refreshNetworkState()
        }
    }
}
