import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Widgets

CompoundPill {
    id: root

    property var colorPickerModal: null

    isActive: true
    iconName: "palette"
    iconColor: Theme.primary
    primaryText: "Выбор цвета"
    secondaryText: "Выберите цвет"

    onToggled: {

        if (colorPickerModal) {
            colorPickerModal.show()
        }
    }

    onExpandClicked: {

        if (colorPickerModal) {
            colorPickerModal.show()
        }
    }
}