import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Widgets

CompoundPill {
    id: root

    iconName: BatteryService.getBatteryIcon()

    isActive: BatteryService.batteryAvailable && (BatteryService.isCharging || BatteryService.isPluggedIn)

    primaryText: {
        if (!BatteryService.batteryAvailable) {
            return "Нет батареи"
        }
        return "Батарея"
    }

    secondaryText: {
        if (!BatteryService.batteryAvailable) {
            return "Недоступно"
        }
        if (BatteryService.isCharging) {
            return `${BatteryService.batteryLevel}% • Зарядка`
        }
        if (BatteryService.isPluggedIn) {
            return `${BatteryService.batteryLevel}% • Подключено`
        }
        return `${BatteryService.batteryLevel}%`
    }

    iconColor: {
        if (BatteryService.isLowBattery && !BatteryService.isCharging) {
            return Theme.error
        }
        if (BatteryService.isCharging || BatteryService.isPluggedIn) {
            return Theme.primary
        }
        return Theme.surfaceText
    }

    onToggled: {
        expandClicked()
    }
}