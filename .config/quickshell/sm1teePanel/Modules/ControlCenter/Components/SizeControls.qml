import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Row {
    id: root

    property int currentSize: 50
    property bool isSlider: false
    property int widgetIndex: -1

    signal sizeChanged(int newSize)

    readonly property var availableSizes: [50, 100]

    spacing: 4

    Repeater {
        model: root.availableSizes

        Rectangle {
            width: 24
            height: 24
            radius: 4
            color: modelData === root.currentSize ? "#4CAF50" : Theme.surfaceContainerHigh
            border.color: modelData === root.currentSize ? "#4CAF50" : Theme.outline
            border.width: modelData === root.currentSize ? 2 : 1

            Row {
                anchors.centerIn: parent
                spacing: 2

                // Визуальное представление размера - квадраты горизонтально
                Repeater {
                    model: modelData === 50 ? 1 : 2
                    
                    Rectangle {
                        width: 6
                        height: 6
                        radius: 1
                        color: modelData === root.currentSize ? "white" : Theme.surfaceText
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    root.currentSize = modelData
                    root.sizeChanged(modelData)
                }
            }

            Behavior on color {
                ColorAnimation { duration: Theme.shortDuration }
            }
            
            Behavior on border.width {
                NumberAnimation { duration: Theme.shortDuration }
            }
        }
    }
}