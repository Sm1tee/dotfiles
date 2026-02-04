import QtQuick
import qs.Common
import qs.Widgets

Item {
    id: toggle

    // API
    property bool checked: false
    property bool enabled: true
    property bool toggling: false
    property string text: ""
    property string description: ""
    property bool hideText: false

    signal clicked
    signal toggled(bool checked)
    signal toggleCompleted(bool checked)

    readonly property bool showText: text && !hideText

    readonly property int trackWidth: Math.round(52 * SettingsData.fontScale)
    readonly property int trackHeight: Math.round(32 * SettingsData.fontScale)
    readonly property int thumbSize: Math.round(24 * SettingsData.fontScale)

    width: showText ? parent.width : trackWidth
    height: showText ? Math.round(60 * SettingsData.fontScale) : trackHeight

    function handleClick() {
        if (!enabled) return
        checked = !checked
        clicked()
        toggled(checked)
    }

    StyledRect {
        id: background
        anchors.fill: parent
        radius: showText ? Theme.cornerRadius : 0
        color: "transparent"
        visible: showText

        StateLayer {
            visible: showText
            disabled: !toggle.enabled
            stateColor: Theme.primary
            cornerRadius: parent.radius
            onClicked: toggle.handleClick()
        }
    }

    Row {
        anchors.left: parent.left
        anchors.right: toggleTrack.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.spacingM
        anchors.rightMargin: Theme.spacingM
        spacing: Theme.spacingXS
        visible: showText

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacingXS

            StyledText {
                text: toggle.text
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                opacity: toggle.enabled ? 1 : 0.4
            }

            StyledText {
                text: toggle.description
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: Math.min(implicitWidth, toggle.width - 120)
                visible: toggle.description.length > 0
            }
        }
    }

    Rectangle {
        id: toggleTrack

        width: showText ? trackWidth : Math.max(parent.width, trackWidth)
        height: showText ? trackHeight : Math.max(parent.height, trackHeight)
        anchors.right: parent.right
        anchors.rightMargin: showText ? Theme.spacingM : 0
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2

        color: {
            if (!enabled) return Theme.surfaceVariant
            return checked ? Theme.primary : Theme.surfaceContainerHigh
        }
        opacity: toggling ? 0.7 : (enabled ? 1 : 0.5)

        border.color: {
            if (!enabled) return Theme.outline
            return checked ? "transparent" : Theme.outline
        }
        border.width: checked ? 0 : 2

        Behavior on color {
            ColorAnimation {
                duration: Theme.shortDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Easing.OutCubic
            }
        }

        readonly property int padding: Math.round((height - thumbSize) / 2)
        readonly property int thumbLeftPos: padding
        readonly property int thumbRightPos: width - thumbSize - padding

        // Shadow under thumb
        Rectangle {
            id: thumbShadow
            width: thumbSize + 2
            height: thumbSize + 2
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.rgba(0, 0, 0, 0.2)
            x: thumb.x - 1
            y: 1
        }

        Rectangle {
            id: thumb

            width: thumbSize
            height: thumbSize
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter

            color: toggle.enabled ? (toggle.checked ? "#000000" : Theme.surfaceVariantText) : Theme.surfaceVariant

            x: checked ? toggleTrack.thumbRightPos : toggleTrack.thumbLeftPos

            Behavior on x {
                NumberAnimation {
                    duration: Theme.shortDuration
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                    onRunningChanged: {
                        if (!running) {
                            toggle.toggleCompleted(toggle.checked)
                        }
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.shortDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: toggle.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: toggle.handleClick()
        }
    }
}
