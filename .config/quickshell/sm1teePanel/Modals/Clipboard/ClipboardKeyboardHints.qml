import QtQuick
import qs.Common
import qs.Widgets
import qs.Modals.Clipboard

Rectangle {
    id: keyboardHints

    readonly property string hintsText: "Shift+Del: Очистить всё • Esc: Закрыть"

    height: ClipboardConstants.keyboardHintsHeight
    radius: Theme.cornerRadius
    color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.95)
    border.color: Theme.primary
    border.width: 2
    opacity: visible ? 1 : 0
    z: 100

    Column {
        anchors.centerIn: parent
        spacing: 4

        StyledText {
            text: "↑/↓: Навигация • Enter/Ctrl+C: Копировать • Del: Удалить • F10: Помощь"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceText
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            text: keyboardHints.hintsText
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceText
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            text: "Требуется: cliphist (установите и добавьте в автозапуск)"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.warning
            anchors.horizontalCenter: parent.horizontalCenter
            font.italic: true
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }
    }
}
