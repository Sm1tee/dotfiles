import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets

Flickable {
    anchors.fill: parent
    contentHeight: systemColumn.implicitHeight
    clip: true
    Component.onCompleted: {
        DgopService.addRef(["system", "hardware", "diskmounts"]);
    }
    Component.onDestruction: {
        DgopService.removeRef(["system", "hardware", "diskmounts"]);
    }

    Column {
        id: systemColumn

        width: parent.width
        spacing: Theme.spacingL

        // Header
        Rectangle {
            width: parent.width
            height: headerColumn.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh
            border.width: 0

            Column {
                id: headerColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingL

                Row {
                    width: parent.width
                    spacing: Theme.spacingL

                    SystemLogo {
                        width: 80
                        height: 80
                    }

                    Column {
                        width: parent.width - 80 - Theme.spacingL
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: DgopService.hostname
                                font.pixelSize: Theme.fontSizeXLarge
                                font.family: SettingsData.monoFontFamily
                                font.weight: Font.Light
                                color: Theme.surfaceText
                            }

                            Item {
                                width: parent.width - hostnameText.width - copyButton.width - Theme.spacingM * 2
                                height: 1
                            }

                            ActionButton {
                                id: copyButton

                                circular: false
                                iconName: "content_copy"
                                iconSize: Theme.iconSize - 4
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    let info = `Система: ${DgopService.hostname}\n`;
                                    info += `Дистрибутив: ${DgopService.distribution}\n`;
                                    info += `Архитектура: ${DgopService.architecture}\n`;
                                    info += `Ядро: ${DgopService.kernelVersion}\n\n`;
                                    if (DgopService.displayInfo) info += `Дисплей: ${DgopService.displayInfo}\n`;
                                    if (DgopService.wmInfo) info += `WM: ${DgopService.wmInfo}\n\n`;
                                    info += `Процессор: ${DgopService.cpuModel}\n`;
                                    info += `Ядер: ${DgopService.cpuCores}\n\n`;
                                    if (DgopService.availableGpus.length > 0) {
                                        info += `Видеокарта: ${DgopService.availableGpus[0].displayName}\n`;
                                        const driverInfo = DgopService.mesaVersion || DgopService.availableGpus[0].driver;
                                        info += `Драйвер: ${driverInfo}\n\n`;
                                    }
                                    info += `Материнская плата: ${DgopService.motherboard}\n`;
                                    info += `BIOS: ${DgopService.biosVersion}\n\n`;
                                    info += `RAM: ${DgopService.formatSystemMemory(DgopService.totalMemoryKB)}\n\n`;
                                    info += `Процессов: ${DgopService.processCount}\n`;
                                    info += `Потоков: ${DgopService.threadCount}\n`;
                                    info += `Автозагрузка: ${DgopService.autostartCount} служб`;
                                    copyToClipboard(info);
                                    ToastService.showInfo("Скопирована вся системная информация");
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                        StyledText {
                            id: hostnameText

                            visible: false
                            text: DgopService.hostname
                            font.pixelSize: Theme.fontSizeXLarge
                            font.family: SettingsData.monoFontFamily
                        }

                        StyledText {
                            text: `${DgopService.distribution} • ${DgopService.architecture} • ${DgopService.kernelVersion}`
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                        }

                        StyledText {
                            text: {
                                let result = "Работает " + UserInfoService.uptime;
                                if (DgopService.bootTime) {
                                    result += " • Начало работы: " + DgopService.bootTime;
                                }
                                return result;
                            }
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: SettingsData.monoFontFamily
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                        }

                        StyledText {
                            text: `Процессов: ${DgopService.processCount} • Потоков: ${DgopService.threadCount}${DgopService.autostartCount > 0 ? ' • Автозагрузка: ' + DgopService.autostartCount : ''}`
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: SettingsData.monoFontFamily
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                        }

                    }

                }

            }

        }

        // Kernel
        Rectangle {
            width: parent.width
            height: kernelColumn.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh

            Column {
                id: kernelColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                StyledText {
                    text: "Ядро системы"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.cornerRadius
                    color: kernelMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                    MouseArea {
                        id: kernelMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            copyToClipboard(DgopService.kernelVersion);
                            ToastService.showInfo("Скопировано: " + DgopService.kernelVersion);
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Ядро:"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            color: Theme.surfaceVariantText
                            width: 150
                        }

                        StyledText {
                            text: DgopService.kernelVersion || "--"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                    }

                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.cornerRadius
                    color: archMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                    MouseArea {
                        id: archMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            copyToClipboard(DgopService.architecture);
                            ToastService.showInfo("Скопировано: " + DgopService.architecture);
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Архитектура:"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            color: Theme.surfaceVariantText
                            width: 150
                        }

                        StyledText {
                            text: DgopService.architecture || "--"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                    }

                }

            }

        }

        // Display & WM
        Rectangle {
            width: parent.width
            height: displayColumn.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh

            Column {
                id: displayColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                StyledText {
                    text: "Дисплей и среда"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.cornerRadius
                    color: displayMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                    MouseArea {
                        id: displayMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            copyToClipboard(DgopService.displayInfo);
                            ToastService.showInfo("Скопировано: " + DgopService.displayInfo);
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Разрешение:"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            color: Theme.surfaceVariantText
                            width: 150
                        }

                        StyledText {
                            text: DgopService.displayInfo || "--"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                    }

                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.cornerRadius
                    color: wmMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                    MouseArea {
                        id: wmMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            copyToClipboard(DgopService.wmInfo);
                            ToastService.showInfo("Скопировано: " + DgopService.wmInfo);
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "WM:"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            color: Theme.surfaceVariantText
                            width: 150
                        }

                        StyledText {
                            text: DgopService.wmInfo || "--"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                    }

                }

            }

        }

        // CPU
        Rectangle {
            width: parent.width
            height: cpuColumn.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh

            Column {
                id: cpuColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                StyledText {
                    text: "Процессор"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.cornerRadius
                    color: cpuModelMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                    MouseArea {
                        id: cpuModelMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            copyToClipboard(DgopService.cpuModel);
                            ToastService.showInfo("Скопировано: " + DgopService.cpuModel);
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Модель:"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            color: Theme.surfaceVariantText
                            width: 150
                        }

                        StyledText {
                            text: DgopService.cpuModel || "Unknown CPU"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            width: parent.width - 160
                            elide: Text.ElideRight
                        }

                    }

                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.cornerRadius
                    color: cpuCoresMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                    MouseArea {
                        id: cpuCoresMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            copyToClipboard(DgopService.cpuCores.toString());
                            ToastService.showInfo("Скопировано: " + DgopService.cpuCores + " ядер");
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Ядер:"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            color: Theme.surfaceVariantText
                            width: 150
                        }

                        StyledText {
                            text: `${DgopService.cpuCores}`
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                    }

                }

            }

        }

        // GPU
        Rectangle {
            width: parent.width
            height: gpuColumn.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh

            Column {
                id: gpuColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                StyledText {
                    text: "Видеокарта"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                Repeater {
                    model: DgopService.availableGpus

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Rectangle {
                            width: parent.width
                            height: 32
                            radius: Theme.cornerRadius
                            color: gpuModelMA.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                            MouseArea {
                                id: gpuModelMA

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    copyToClipboard(modelData.displayName);
                                    ToastService.showInfo("Скопировано: " + modelData.displayName);
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingS
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    text: "Модель:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.family: SettingsData.monoFontFamily
                                    color: Theme.surfaceVariantText
                                    width: 150
                                }

                                StyledText {
                                    text: modelData.displayName
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.family: SettingsData.monoFontFamily
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    width: parent.width - 160
                                    elide: Text.ElideRight
                                }

                            }

                        }

                        Rectangle {
                            width: parent.width
                            height: 32
                            radius: Theme.cornerRadius
                            color: gpuDriverMA.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                            MouseArea {
                                id: gpuDriverMA

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const driverInfo = DgopService.mesaVersion || (modelData.driver === "amd" ? "amdgpu" : modelData.driver);
                                    copyToClipboard(driverInfo);
                                    ToastService.showInfo("Скопировано: " + driverInfo);
                                }
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingS
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    text: "Драйвер:"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.family: SettingsData.monoFontFamily
                                    color: Theme.surfaceVariantText
                                    width: 150
                                }

                                StyledText {
                                    text: DgopService.mesaVersion || (modelData.driver === "amd" ? "amdgpu" : modelData.driver)
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.family: SettingsData.monoFontFamily
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                            }

                        }

                    }

                }

            }

        }

        // Motherboard
        Rectangle {
            width: parent.width
            height: motherboardColumn.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh

            Column {
                id: motherboardColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                StyledText {
                    text: "Материнская плата"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.cornerRadius
                    color: motherboardMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                    MouseArea {
                        id: motherboardMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            copyToClipboard(DgopService.motherboard);
                            ToastService.showInfo("Скопировано: " + DgopService.motherboard);
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Модель:"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            color: Theme.surfaceVariantText
                            width: 150
                        }

                        StyledText {
                            text: DgopService.motherboard || "Unknown"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            width: parent.width - 160
                            elide: Text.ElideRight
                        }

                    }

                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.cornerRadius
                    color: biosMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                    MouseArea {
                        id: biosMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            copyToClipboard(DgopService.biosVersion);
                            ToastService.showInfo("Скопировано: BIOS " + DgopService.biosVersion);
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "BIOS:"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            color: Theme.surfaceVariantText
                            width: 150
                        }

                        StyledText {
                            text: DgopService.biosVersion || "Unknown"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                    }

                }

            }

        }

        // RAM
        Rectangle {
            width: parent.width
            height: ramColumn.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh

            Column {
                id: ramColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                StyledText {
                    text: "Оперативная память"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Theme.cornerRadius
                    color: ramMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                    MouseArea {
                        id: ramMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            copyToClipboard(DgopService.formatSystemMemory(DgopService.totalMemoryKB));
                            ToastService.showInfo("Скопировано: " + DgopService.formatSystemMemory(DgopService.totalMemoryKB));
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Всего:"
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            color: Theme.surfaceVariantText
                            width: 150
                        }

                        StyledText {
                            text: DgopService.formatSystemMemory(DgopService.totalMemoryKB)
                            font.pixelSize: Theme.fontSizeMedium
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                    }

                }

            }

        }

        // Autostart
        Rectangle {
            width: parent.width
            height: autostartColumn.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh

            Column {
                id: autostartColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                Row {
                    width: parent.width
                    spacing: Theme.spacingS

                    StyledText {
                        text: "Автозагрузка"
                        font.pixelSize: Theme.fontSizeLarge
                        font.weight: Font.Bold
                        color: Theme.surfaceText
                    }

                    StyledText {
                        text: `(${DgopService.autostartCount} служб)`
                        font.pixelSize: Theme.fontSizeMedium
                        font.family: SettingsData.monoFontFamily
                        color: Theme.surfaceVariantText
                    }

                    Item {
                        width: parent.width - autostartTitle.width - autostartCount.width - copyAutostartButton.width - Theme.spacingS * 3
                        height: 1
                    }

                    ActionButton {
                        id: copyAutostartButton

                        circular: false
                        iconName: "content_copy"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: {
                            let servicesList = "";
                            for (let i = 0; i < DgopService.autostartServices.length; i++) {
                                servicesList += DgopService.autostartServices[i].name;
                                if (i < DgopService.autostartServices.length - 1) {
                                    servicesList += "\n";
                                }
                            }
                            copyToClipboard(servicesList);
                            ToastService.showInfo("Скопирован список служб автозагрузки");
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                StyledText {
                    id: autostartTitle
                    visible: false
                    text: "Автозагрузка"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                }

                StyledText {
                    id: autostartCount
                    visible: false
                    text: `(${DgopService.autostartCount} служб)`
                    font.pixelSize: Theme.fontSizeMedium
                }

                Flickable {
                    width: parent.width
                    height: Math.min(200, autostartRepeater.count * 28)
                    contentHeight: autostartRepeater.count * 28
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 2

                        Repeater {
                            id: autostartRepeater

                            model: DgopService.autostartServices

                            Rectangle {
                                width: parent.width
                                height: 26
                                radius: Theme.cornerRadius
                                color: autostartMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                                MouseArea {
                                    id: autostartMouseArea

                                    anchors.fill: parent
                                    hoverEnabled: true
                                }

                                StyledText {
                                    text: modelData.name
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: SettingsData.monoFontFamily
                                    color: Theme.surfaceText
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.spacingS
                                    anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideRight
                                    width: parent.width - Theme.spacingS * 2
                                }

                            }

                        }

                    }

                }

            }

        }

        // Storage
        Rectangle {
            width: parent.width
            height: storageColumn.implicitHeight + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh

            Column {
                id: storageColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM

                StyledText {
                    text: "Хранилище и диски"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                }

                Column {
                    width: parent.width
                    spacing: 2

                    Row {
                        width: parent.width
                        height: 24
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Устройство"
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                            width: parent.width * 0.25
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: "Монтирование"
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                            width: parent.width * 0.2
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: "Размер"
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                            width: parent.width * 0.15
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: "Использовано"
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                            width: parent.width * 0.15
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: "Доступно"
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                            width: parent.width * 0.15
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: "%"
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: SettingsData.monoFontFamily
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                            width: parent.width * 0.1
                            elide: Text.ElideRight
                        }

                    }

                    Repeater {
                        model: DgopService.diskMounts

                        Rectangle {
                            width: parent.width
                            height: 24
                            radius: Theme.cornerRadius
                            color: diskMouseArea.containsMouse ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.04) : "transparent"

                            MouseArea {
                                id: diskMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            Row {
                                anchors.fill: parent
                                spacing: Theme.spacingS

                                StyledText {
                                    text: modelData.device
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: SettingsData.monoFontFamily
                                    color: Theme.surfaceText
                                    width: parent.width * 0.25
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: modelData.mount
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: SettingsData.monoFontFamily
                                    color: Theme.surfaceText
                                    width: parent.width * 0.2
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: modelData.size
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: SettingsData.monoFontFamily
                                    color: Theme.surfaceText
                                    width: parent.width * 0.15
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: modelData.used
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: SettingsData.monoFontFamily
                                    color: Theme.surfaceText
                                    width: parent.width * 0.15
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: modelData.avail
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: SettingsData.monoFontFamily
                                    color: Theme.surfaceText
                                    width: parent.width * 0.15
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: modelData.percent
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: SettingsData.monoFontFamily
                                    color: Theme.surfaceText
                                    width: parent.width * 0.1
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                        }

                    }

                }

            }

        }

    }

    function copyToClipboard(text) {
        Quickshell.execDetached(["sh", "-c", "echo -n '" + text + "' | wl-copy"])
    }
}
