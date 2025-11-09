import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets

Column {
    function formatNetworkSpeed(bytesPerSec) {
        if (bytesPerSec < 1024 * 1024 * 1024) {
            return (bytesPerSec / (1024 * 1024)).toFixed(1) + " MB/s";
        } else {
            return (bytesPerSec / (1024 * 1024 * 1024)).toFixed(1) + " GB/s";
        }
    }

    function formatDiskSpeed(bytesPerSec) {
        if (bytesPerSec < 1024 * 1024 * 1024) {
            return (bytesPerSec / (1024 * 1024)).toFixed(1) + " MB/s";
        } else {
            return (bytesPerSec / (1024 * 1024 * 1024)).toFixed(1) + " GB/s";
        }
    }

    anchors.fill: parent
    spacing: Theme.spacingM
    Component.onCompleted: {
        DgopService.addRef(["cpu", "memory", "network", "disk"]);
    }
    Component.onDestruction: {
        DgopService.removeRef(["cpu", "memory", "network", "disk"]);
    }

    Rectangle {
        width: parent.width
        height: 200
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.06)
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            Row {
                width: parent.width
                height: 32
                spacing: Theme.spacingM

                StyledText {
                    text: "CPU"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 80
                    height: 24
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                    anchors.verticalCenter: parent.verticalCenter

                    StyledText {
                        text: `${DgopService.cpuUsage.toFixed(1)}%`
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Bold
                        color: Theme.primary
                        anchors.centerIn: parent
                    }

                }

                Item {
                    width: parent.width - 280
                    height: 1
                }

                StyledText {
                    text: `${DgopService.cpuCores} cores`
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

            Flow {
                width: parent.width
                height: parent.height - 40
                spacing: Theme.spacingS

                Repeater {
                    model: DgopService.perCoreCpuUsage

                    Column {
                        width: {
                            const coreCount = DgopService.perCoreCpuUsage.length || 1
                            const spacing = Theme.spacingS
                            return Math.floor((parent.width - spacing * (coreCount - 1)) / coreCount)
                        }
                        height: parent.height
                        spacing: 4

                        Item {
                            width: parent.width
                            height: parent.height - 36

                            Rectangle {
                                width: 8
                                height: parent.height
                                radius: 4
                                color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom

                                Rectangle {
                                    width: parent.width
                                    height: parent.height * Math.min(1, modelData / 100)
                                    radius: parent.radius
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: {
                                        const usage = modelData;
                                        if (usage > 80) {
                                            return Theme.error;
                                        }
                                        if (usage > 60) {
                                            return Theme.warning;
                                        }
                                        return Theme.primary;
                                    }

                                    Behavior on height {
                                        NumberAnimation {
                                            duration: Theme.shortDuration
                                        }

                                    }

                                }

                            }

                        }

                        StyledText {
                            text: `C${index}`
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }

                        StyledText {
                            text: modelData ? `${modelData.toFixed(0)}%` : "0%"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }

                }

            }

        }

    }

    Rectangle {
        width: parent.width
        height: 80
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.06)
        border.width: 1

        Row {
            anchors.centerIn: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingM

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                StyledText {
                    text: "Память"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                StyledText {
                    text: `${DgopService.formatSystemMemory(DgopService.usedMemoryKB)} / ${DgopService.formatSystemMemory(DgopService.totalMemoryKB)}`
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

            }

            Item {
                width: Theme.spacingL
                height: 1
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                width: 200

                Rectangle {
                    width: parent.width
                    height: 16
                    radius: 8
                    color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)

                    Rectangle {
                        width: DgopService.totalMemoryKB > 0 ? parent.width * (DgopService.usedMemoryKB / DgopService.totalMemoryKB) : 0
                        height: parent.height
                        radius: parent.radius
                        color: {
                            const usage = DgopService.totalMemoryKB > 0 ? (DgopService.usedMemoryKB / DgopService.totalMemoryKB) : 0;
                            if (usage > 0.9) {
                                return Theme.error;
                            }
                            if (usage > 0.7) {
                                return Theme.warning;
                            }
                            return Theme.secondary;
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.mediumDuration
                            }

                        }

                    }

                }

                StyledText {
                    text: DgopService.totalMemoryKB > 0 ? `${((DgopService.usedMemoryKB / DgopService.totalMemoryKB) * 100).toFixed(1)}% занято` : "Нет данных"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

            }

            Item {
                width: Theme.spacingL
                height: 1
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                StyledText {
                    text: "Своп"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                StyledText {
                    text: DgopService.totalSwapKB > 0 ? `${DgopService.formatSystemMemory(DgopService.usedSwapKB)} / ${DgopService.formatSystemMemory(DgopService.totalSwapKB)}` : "No swap configured"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

            }

            Item {
                width: Theme.spacingL
                height: 1
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                width: 200

                Rectangle {
                    width: parent.width
                    height: 16
                    radius: 8
                    color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)

                    Rectangle {
                        width: DgopService.totalSwapKB > 0 ? parent.width * (DgopService.usedSwapKB / DgopService.totalSwapKB) : 0
                        height: parent.height
                        radius: parent.radius
                        color: {
                            if (!DgopService.totalSwapKB) {
                                return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.3);
                            }
                            const usage = DgopService.usedSwapKB / DgopService.totalSwapKB;
                            if (usage > 0.9) {
                                return Theme.error;
                            }
                            if (usage > 0.7) {
                                return Theme.warning;
                            }
                            return Theme.info;
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.mediumDuration
                            }

                        }

                    }

                }

                StyledText {
                    text: DgopService.totalSwapKB > 0 ? `${((DgopService.usedSwapKB / DgopService.totalSwapKB) * 100).toFixed(1)}% занято` : "Недоступно"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

            }

        }

    }

    Row {
        width: parent.width
        height: 80
        spacing: Theme.spacingM

        Rectangle {
            width: (parent.width - Theme.spacingM) / 2
            height: 80
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.06)
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                StyledText {
                    text: "Сеть"
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    spacing: Theme.spacingS
                    anchors.horizontalCenter: parent.horizontalCenter

                    Row {
                        spacing: 4

                        StyledText {
                            text: "↓"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.info
                        }

                        StyledText {
                            text: DgopService.networkRxRate > 0 ? formatNetworkSpeed(DgopService.networkRxRate) : "0 B/s"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }

                    }

                    Row {
                        spacing: 4

                        StyledText {
                            text: "↑"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.error
                        }

                        StyledText {
                            text: DgopService.networkTxRate > 0 ? formatNetworkSpeed(DgopService.networkTxRate) : "0 B/s"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }

                    }

                }

            }

        }

        Rectangle {
            width: (parent.width - Theme.spacingM) / 2
            height: 80
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh
            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.06)
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                StyledText {
                    text: "Все диски"
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    spacing: Theme.spacingS
                    anchors.horizontalCenter: parent.horizontalCenter

                    Row {
                        spacing: 4

                        StyledText {
                            text: "R"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.primary
                        }

                        StyledText {
                            text: formatDiskSpeed(DgopService.diskReadRate)
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }

                    }

                    Row {
                        spacing: 4

                        StyledText {
                            text: "W"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.warning
                        }

                        StyledText {
                            text: formatDiskSpeed(DgopService.diskWriteRate)
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }

                    }

                }

            }

        }

    }

    Rectangle {
        width: parent.width
        height: diskColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.06)
        border.width: 1
        visible: DgopService.diskDevices.length > 0

        Column {
            id: diskColumn

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: "Диски"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            Column {
                width: parent.width
                spacing: Theme.spacingS

                Repeater {
                    model: DgopService.diskDevices

                    Row {
                        width: parent.width
                        height: 32
                        spacing: Theme.spacingM

                        StyledText {
                            text: modelData.name
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            font.family: SettingsData.monoFontFamily
                            color: Theme.surfaceText
                            width: 100
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Row {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "R"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.primary
                            }

                            StyledText {
                                text: formatDiskSpeed(modelData.readRate)
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                font.family: SettingsData.monoFontFamily
                                color: Theme.surfaceText
                                width: 80
                            }

                        }

                        Row {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "W"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.warning
                            }

                            StyledText {
                                text: formatDiskSpeed(modelData.writeRate)
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                font.family: SettingsData.monoFontFamily
                                color: Theme.surfaceText
                                width: 80
                            }

                        }

                    }

                }

            }

        }

    }

}
