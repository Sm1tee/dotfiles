import QtQuick
import qs.Common
import qs.Widgets

StyledRect {
    id: root

    property string primaryMessage: ""
    property string secondaryMessage: ""

    radius: Theme.cornerRadius
    color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.1)
    border.color: Theme.warning
    border.width: 1

    Row {
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingXS

        DankIcon {
            name: "warning"
            size: 16
            color: Theme.warning
            anchors.top: parent.top
            anchors.topMargin: 2
        }

        Column {
            width: parent.width - 16 - parent.spacing
            spacing: Theme.spacingXS

            StyledText {
                width: parent.width
                text: root.primaryMessage
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.warning
                font.weight: Font.Medium
                wrapMode: Text.WordWrap
            }

            StyledText {
                width: parent.width
                text: root.secondaryMessage
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.warning
                visible: text.length > 0
            }
        }
    }
}
