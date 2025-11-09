import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets

Column {
    id: root

    property var contextMenu: null
    property string searchQuery: ""

    Component.onCompleted: {
        DgopService.addRef(["processes"]);
    }
    Component.onDestruction: {
        DgopService.removeRef(["processes"]);
    }

    // Search field
    Rectangle {
        width: parent.width
        height: 36
        color: Theme.surfaceContainerHigh
        radius: Theme.cornerRadius

        MouseArea {
            anchors.fill: parent
            onClicked: searchField.forceActiveFocus()
        }

        Row {
            anchors.fill: parent
            anchors.margins: Theme.spacingS
            spacing: Theme.spacingS

            Icon {
                name: "search"
                size: Theme.iconSize
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: parent.width - Theme.iconSize - Theme.spacingS * 2
                height: parent.height

                TextInput {
                    id: searchField

                    anchors.fill: parent
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeMedium
                    font.family: SettingsData.monoFontFamily
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    onTextChanged: {
                        root.searchQuery = text.toLowerCase()
                    }

                    StyledText {
                        text: "Поиск процессов..."
                        font.pixelSize: Theme.fontSizeMedium
                        font.family: SettingsData.monoFontFamily
                        color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
                        visible: searchField.text === ""
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

        }

    }

    Item {
        id: columnHeaders

        width: parent.width
        anchors.leftMargin: 8
        height: 24

        Rectangle {
            width: 60
            height: 20
            color: {
                if (DgopService.currentSort === "name") {
                    return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12);
                }
                return processHeaderArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : Theme.withAlpha(Theme.surfaceText, 0);
            }
            radius: Theme.cornerRadius
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                text: "Процесс"
                font.pixelSize: Theme.fontSizeSmall
                font.family: SettingsData.monoFontFamily
                font.weight: DgopService.currentSort === "name" ? Font.Bold : Font.Medium
                color: Theme.surfaceText
                opacity: DgopService.currentSort === "name" ? 1 : 0.7
                anchors.centerIn: parent
            }

            MouseArea {
                id: processHeaderArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    DgopService.setSortBy("name");
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.shortDuration
                }

            }

        }

        Rectangle {
            width: 80
            height: 20
            color: {
                if (DgopService.currentSort === "cpu") {
                    return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12);
                }
                return cpuHeaderArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : Theme.withAlpha(Theme.surfaceText, 0);
            }
            radius: Theme.cornerRadius
            anchors.right: parent.right
            anchors.rightMargin: 200
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                text: "CPU"
                font.pixelSize: Theme.fontSizeSmall
                font.family: SettingsData.monoFontFamily
                font.weight: DgopService.currentSort === "cpu" ? Font.Bold : Font.Medium
                color: Theme.surfaceText
                opacity: DgopService.currentSort === "cpu" ? 1 : 0.7
                anchors.centerIn: parent
            }

            MouseArea {
                id: cpuHeaderArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    DgopService.setSortBy("cpu");
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.shortDuration
                }

            }

        }

        Rectangle {
            width: 80
            height: 20
            color: {
                if (DgopService.currentSort === "memory") {
                    return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12);
                }
                return memoryHeaderArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : Theme.withAlpha(Theme.surfaceText, 0);
            }
            radius: Theme.cornerRadius
            anchors.right: parent.right
            anchors.rightMargin: 112
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                text: "RAM"
                font.pixelSize: Theme.fontSizeSmall
                font.family: SettingsData.monoFontFamily
                font.weight: DgopService.currentSort === "memory" ? Font.Bold : Font.Medium
                color: Theme.surfaceText
                opacity: DgopService.currentSort === "memory" ? 1 : 0.7
                anchors.centerIn: parent
            }

            MouseArea {
                id: memoryHeaderArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    DgopService.setSortBy("memory");
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.shortDuration
                }

            }

        }

        Rectangle {
            width: 50
            height: 20
            color: {
                if (DgopService.currentSort === "pid") {
                    return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12);
                }
                return pidHeaderArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : Theme.withAlpha(Theme.surfaceText, 0);
            }
            radius: Theme.cornerRadius
            anchors.right: parent.right
            anchors.rightMargin: 53
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                text: "PID"
                font.pixelSize: Theme.fontSizeSmall
                font.family: SettingsData.monoFontFamily
                font.weight: DgopService.currentSort === "pid" ? Font.Bold : Font.Medium
                color: Theme.surfaceText
                opacity: DgopService.currentSort === "pid" ? 1 : 0.7
                horizontalAlignment: Text.AlignHCenter
                anchors.centerIn: parent
            }

            MouseArea {
                id: pidHeaderArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    DgopService.setSortBy("pid");
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.shortDuration
                }

            }

        }

        Rectangle {
            width: 28
            height: 28
            radius: Theme.cornerRadius
            color: sortOrderArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.08) : Theme.withAlpha(Theme.surfaceText, 0)
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                text: DgopService.sortDescending ? "↓" : "↑"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.centerIn: parent
            }

            MouseArea {
                id: sortOrderArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    DgopService.toggleSortOrder();
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.shortDuration
                }

            }

        }

    }

    ListView {
        id: processListView

        property string keyRoleName: "pid"
        property var filteredProcesses: {
            if (root.searchQuery === "") {
                return DgopService.processes
            }
            // Поиск по ВСЕМ процессам, а не только по топ-100
            const allProcs = DgopService.allProcesses || DgopService.processes
            return allProcs.filter(function(proc) {
                const name = (proc.displayName || proc.command || "").toLowerCase()
                const pid = proc.pid.toString()
                return name.includes(root.searchQuery) || pid.includes(root.searchQuery)
            })
        }

        width: parent.width
        height: parent.height - columnHeaders.height - 36 - Theme.spacingS
        clip: true
        spacing: 4
        model: filteredProcesses

        delegate: ProcessListItem {
            process: modelData
            contextMenu: root.contextMenu
        }

    }

}
