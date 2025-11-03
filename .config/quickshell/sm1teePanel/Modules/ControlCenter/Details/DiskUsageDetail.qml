import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    property string currentMountPath: "/"
    property string instanceId: ""
    property var diskMounts: []

    signal mountPathChanged(string newMountPath)

    implicitHeight: diskContent.height + Theme.spacingM
    radius: Theme.cornerRadius
    color: Theme.surfaceContainerHigh
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
    border.width: 0

    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: dfProcess.running = true
    }

    Process {
        id: dfProcess
        command: ["df", "-h", "--output=source,size,used,avail,pcent,target", "-x", "tmpfs", "-x", "devtmpfs"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: line => {
                if (line.trim().startsWith("Filesystem")) return
                
                const parts = line.trim().split(/\s+/)
                if (parts.length >= 6) {
                    const mountPoint = parts[5]
                    
                    // Фильтруем только реальные диски
                    // Показываем: / и /run/media/* (внешние диски)
                    // Скрываем: /boot, /sys, /proc, /dev, /run (кроме /run/media)
                    const isRealDisk = mountPoint === "/" || 
                                      mountPoint.startsWith("/run/media/") ||
                                      mountPoint.startsWith("/media/") ||
                                      mountPoint.startsWith("/mnt/")
                    
                    const isSystemPartition = mountPoint.startsWith("/boot") ||
                                             mountPoint.startsWith("/sys") ||
                                             mountPoint.startsWith("/proc") ||
                                             mountPoint.startsWith("/dev") ||
                                             (mountPoint.startsWith("/run") && !mountPoint.startsWith("/run/media"))
                    
                    if (!isRealDisk || isSystemPartition) return
                    
                    const mount = {
                        device: parts[0],
                        size: parts[1],
                        used: parts[2],
                        avail: parts[3],
                        percent: parts[4],
                        mount: mountPoint
                    }
                    
                    let mounts = root.diskMounts.slice()
                    const existingIndex = mounts.findIndex(m => m.mount === mount.mount)
                    if (existingIndex >= 0) {
                        mounts[existingIndex] = mount
                    } else {
                        mounts.push(mount)
                    }
                    root.diskMounts = mounts
                }
            }
        }
    }

    Flickable {
        id: diskContent
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spacingM
        anchors.topMargin: Theme.spacingM
        contentHeight: diskColumn.height
        clip: true

        Column {
            id: diskColumn
            width: parent.width
            spacing: Theme.spacingS

            Item {
                width: parent.width
                height: 100
                visible: !root.diskMounts || root.diskMounts.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacingM

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "storage"
                        size: 32
                        color: Theme.primary
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Загрузка данных о дисках..."
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Repeater {
                model: root.diskMounts || []
                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: parent.width
                    height: 80
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHighest
                    border.color: modelData.mount === currentMountPath ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.12)
                    border.width: modelData.mount === currentMountPath ? 2 : 0

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM
                        spacing: Theme.spacingM

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Icon {
                                name: "storage"
                                size: Theme.iconSize
                                color: {
                                    const percentStr = modelData.percent?.replace("%", "") || "0"
                                    const percent = parseFloat(percentStr) || 0
                                    if (percent > 90) return Theme.error
                                    if (percent > 75) return Theme.warning
                                    return modelData.mount === currentMountPath ? Theme.primary : Theme.surfaceText
                                }
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            StyledText {
                                text: {
                                    const percentStr = modelData.percent?.replace("%", "") || "0"
                                    const percent = parseFloat(percentStr) || 0
                                    return percent.toFixed(0) + "%"
                                }
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.parent.width - parent.parent.anchors.leftMargin - parent.spacing - 50 - Theme.spacingM

                            StyledText {
                                text: modelData.mount === "/" ? "Корневая файловая система" : modelData.mount
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                font.weight: modelData.mount === currentMountPath ? Font.Medium : Font.Normal
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            StyledText {
                                text: modelData.mount
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                elide: Text.ElideRight
                                width: parent.width
                                visible: modelData.mount !== "/"
                            }

                            StyledText {
                                text: `${modelData.used || "?"} / ${modelData.size || "?"}`
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            currentMountPath = modelData.mount
                            // Сохраняем в SessionData (только в памяти)
                            const paths = Object.assign({}, SessionData.diskWidgetMountPaths)
                            paths[root.instanceId] = modelData.mount
                            SessionData.diskWidgetMountPaths = paths
                            mountPathChanged(modelData.mount)
                        }
                    }

                }
            }
        }
    }
}