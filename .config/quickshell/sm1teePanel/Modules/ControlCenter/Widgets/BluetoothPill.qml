import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Widgets

CompoundPill {
    id: root

    property var primaryDevice: {
        if (!BluetoothService.adapter || !BluetoothService.adapter.devices) {
            return null
        }

        let devices = [...BluetoothService.adapter.devices.values.filter(dev => dev && (dev.paired || dev.trusted))]
        for (let device of devices) {
            if (device && device.connected) {
                return device
            }
        }
        return null
    }

    iconName: {
        if (!BluetoothService.available) {
            return "bluetooth_disabled"
        }
        if (!BluetoothService.adapter || !BluetoothService.adapter.enabled) {
            return "bluetooth_disabled"
        }
        return "bluetooth"
    }

    isActive: !!(BluetoothService.available && BluetoothService.adapter && BluetoothService.adapter.enabled)
    showExpandArea: BluetoothService.available

    primaryText: {
        if (!BluetoothService.available) {
            return "Bluetooth"
        }
        if (!BluetoothService.adapter) {
            return "Нет адаптера"
        }
        if (!BluetoothService.adapter.enabled) {
            return "Выключен"
        }
        return "Включен"
    }

    secondaryText: {
        if (!BluetoothService.available) {
            return "Нет адаптеров"
        }
        if (!BluetoothService.adapter || !BluetoothService.adapter.enabled) {
            return "Выкл"
        }
        if (primaryDevice) {
            return primaryDevice.name || primaryDevice.alias || primaryDevice.deviceName || "Подключенное устройство"
        }
        return "Нет устройств"
    }

    onToggled: {
        if (BluetoothService.available && BluetoothService.adapter) {
            BluetoothService.adapter.enabled = !BluetoothService.adapter.enabled
        }
    }
}