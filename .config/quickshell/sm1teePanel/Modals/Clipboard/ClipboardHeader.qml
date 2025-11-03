import QtQuick
import qs.Common
import qs.Widgets
import qs.Modals.Clipboard

Item {
    id: header

    property int totalCount: 0
    property bool showKeyboardHints: false

    signal keyboardHintsToggled
    signal clearAllClicked
    signal closeClicked

    height: ClipboardConstants.headerHeight

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingM

        Icon {
            name: "content_paste"
            size: Theme.iconSize
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: "История буфера обмена" + ` (${totalCount})`
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.surfaceText
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingS

        ActionButton {
            iconName: "info"
            iconSize: Theme.iconSize - 4
            iconColor: showKeyboardHints ? Theme.primary : Theme.surfaceText
            onClicked: keyboardHintsToggled()
        }

        ActionButton {
            iconName: "delete_sweep"
            iconSize: Theme.iconSize
            iconColor: Theme.surfaceText
            onClicked: clearAllClicked()
        }

        ActionButton {
            iconName: "close"
            iconSize: Theme.iconSize - 4
            iconColor: Theme.surfaceText
            onClicked: closeClicked()
        }
    }
}
