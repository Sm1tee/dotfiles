import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

Item {
    id: widgetTweaksTab

    function getScreenPreferences(componentId) {
        return SettingsData.screenPreferences && SettingsData.screenPreferences[componentId] || ["all"];
    }

    function setScreenPreferences(componentId, screenNames) {
        var prefs = SettingsData.screenPreferences || {};
        prefs[componentId] = screenNames;
        SettingsData.setScreenPreferences(prefs);
    }

    FileBrowserModal {
        id: logoFileBrowser
        browserTitle: "Выберите логотип лаунчера"
        browserIcon: "image"
        browserType: "generic"
        filterExtensions: ["*.svg", "*.png", "*.jpg", "*.jpeg", "*.webp"]
        onFileSelected: path => {
            SettingsData.setLauncherLogoCustomPath(path.replace("file://", ""))
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingXL

            StyledRect {
                width: parent.width
                height: launcherSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: launcherSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "apps"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Лаунчер"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Логотип кнопки лаунчера
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Логотип кнопки"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }


                    }

                    ButtonGroup {
                        id: logoModeGroup
                        width: parent.width
                        fillWidth: true
                        buttonPadding: Theme.spacingXS
                        spacing: 2
                        checkEnabled: false
                        model: ["Иконка приложений", "Свой"]
                            currentIndex: {
                                if (SettingsData.launcherLogoMode === "apps") return 0
                                if (SettingsData.launcherLogoMode === "custom") return 1
                                return 0
                            }
                            onSelectionChanged: (index, selected) => {
                                if (!selected) return
                                if (index === 0) {
                                    SettingsData.setLauncherLogoMode("apps")
                                } else if (index === 1) {
                                    SettingsData.setLauncherLogoMode("custom")
                                }
                            }
                        }

                    Row {
                        width: parent.width
                        visible: SettingsData.launcherLogoMode === "custom"
                        opacity: visible ? 1 : 0
                        spacing: Theme.spacingM

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.mediumDuration
                                easing.type: Theme.emphasizedEasing
                            }
                        }

                        StyledRect {
                            width: parent.width - selectButton.width - Theme.spacingM
                            height: 36
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.9)
                            border.color: Theme.outlineStrong
                            border.width: 1

                            StyledText {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacingM
                                anchors.verticalCenter: parent.verticalCenter
                                text: SettingsData.launcherLogoCustomPath || "Выберите файл изображения..."
                                font.pixelSize: Theme.fontSizeMedium
                                color: SettingsData.launcherLogoCustomPath ? Theme.surfaceText : Theme.outlineButton
                                width: parent.width - Theme.spacingM * 2
                                elide: Text.ElideMiddle
                            }
                        }

                        ActionButton {
                            id: selectButton
                            iconName: "folder_open"
                            width: 36
                            height: 36
                            onClicked: logoFileBrowser.open()
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingL
                        visible: SettingsData.launcherLogoMode !== "apps"
                        opacity: visible ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.mediumDuration
                                easing.type: Theme.emphasizedEasing
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Переопределение цвета"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                Item {
                                    width: parent.width
                                    height: colorModeGroup.height

                                    ButtonGroup {
                                        id: colorModeGroup
                                        width: parent.width
                                        fillWidth: true
                                        buttonPadding: Theme.spacingXS
                                        spacing: 2
                                        checkEnabled: false
                                        model: ["По умолчанию", "Основной", "Поверхность", "Свой"]
                                    currentIndex: {
                                        const override = SettingsData.launcherLogoColorOverride
                                        if (override === "") return 0
                                        if (override === "primary") return 1
                                        if (override === "surface") return 2
                                        return 3
                                    }
                                    onSelectionChanged: (index, selected) => {
                                        if (!selected) return
                                        if (index === 0) {
                                            SettingsData.setLauncherLogoColorOverride("")
                                        } else if (index === 1) {
                                            SettingsData.setLauncherLogoColorOverride("primary")
                                        } else if (index === 2) {
                                            SettingsData.setLauncherLogoColorOverride("surface")
                                        } else if (index === 3) {
                                            const currentOverride = SettingsData.launcherLogoColorOverride
                                            const isPreset = currentOverride === "" || currentOverride === "primary" || currentOverride === "surface"
                                            if (isPreset) {
                                                SettingsData.setLauncherLogoColorOverride("#ffffff")
                                            }
                                        }
                                    }
                                }
                                }

                                Rectangle {
                                    visible: {
                                        const override = SettingsData.launcherLogoColorOverride
                                        return override !== "" && override !== "primary" && override !== "surface"
                                    }
                                    width: 36
                                    height: 36
                                    radius: 18
                                    color: {
                                        const override = SettingsData.launcherLogoColorOverride
                                        if (override !== "" && override !== "primary" && override !== "surface") {
                                            return override
                                        }
                                        return "#ffffff"
                                    }
                                    border.color: Theme.outline
                                    border.width: 1
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (PopoutService.colorPickerModal) {
                                                PopoutService.colorPickerModal.selectedColor = SettingsData.launcherLogoColorOverride
                                                PopoutService.colorPickerModal.pickerTitle = "Выберите цвет логотипа лаунчера"
                                                PopoutService.colorPickerModal.onColorSelectedCallback = function(selectedColor) {
                                                    SettingsData.setLauncherLogoColorOverride(selectedColor)
                                                }
                                                PopoutService.colorPickerModal.show()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS

                            Column {
                                width: 120
                                spacing: Theme.spacingS
                                anchors.horizontalCenter: parent.horizontalCenter

                                StyledText {
                                    text: "Смещение размера"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Slider {
                                    width: 100
                                    height: 20
                                    minimum: -12
                                    maximum: 12
                                    value: SettingsData.launcherLogoSizeOffset
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    thumbOutlineColor: Theme.surfaceContainerHigh
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    onSliderValueChanged: newValue => {
                                        SettingsData.setLauncherLogoSizeOffset(newValue)
                                    }
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: customControlsFlow.height
                            visible: {
                                const override = SettingsData.launcherLogoColorOverride
                                return override !== "" && override !== "primary" && override !== "surface"
                            }
                            opacity: visible ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.mediumDuration
                                    easing.type: Theme.emphasizedEasing
                                }
                            }

                            Flow {
                                id: customControlsFlow
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: Theme.spacingS

                                Column {
                                    width: 120
                                    spacing: Theme.spacingS

                                    StyledText {
                                        text: "Яркость"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        font.weight: Font.Medium
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Slider {
                                        width: 100
                                        height: 20
                                        minimum: 0
                                        maximum: 100
                                        value: Math.round(SettingsData.launcherLogoBrightness * 100)
                                        unit: "%"
                                        showValue: true
                                        wheelEnabled: false
                                        thumbOutlineColor: Theme.surfaceContainerHigh
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        onSliderValueChanged: newValue => {
                                            SettingsData.setLauncherLogoBrightness(newValue / 100)
                                        }
                                    }
                                }

                                Column {
                                    width: 120
                                    spacing: Theme.spacingS

                                    StyledText {
                                        text: "Контраст"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        font.weight: Font.Medium
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Slider {
                                        width: 100
                                        height: 20
                                        minimum: 0
                                        maximum: 200
                                        value: Math.round(SettingsData.launcherLogoContrast * 100)
                                        unit: "%"
                                        showValue: true
                                        wheelEnabled: false
                                        thumbOutlineColor: Theme.surfaceContainerHigh
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        onSliderValueChanged: newValue => {
                                            SettingsData.setLauncherLogoContrast(newValue / 100)
                                        }
                                    }
                                }

                                Column {
                                    width: 120
                                    spacing: Theme.spacingS

                                    StyledText {
                                        text: "Инверсия при смене темы"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        font.weight: Font.Medium
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Toggle {
                                        width: 32
                                        height: 18
                                        checked: SettingsData.launcherLogoColorInvertOnMode
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        onToggled: checked => {
                                            SettingsData.setLauncherLogoColorInvertOnMode(checked)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Префикс запуска
                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Префикс запуска"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }


                    }

                    TextField {
                        width: parent.width
                        text: SessionData.launchPrefix
                        placeholderText: "Введите префикс запуска (например, 'uwsm-app')"
                        onTextEdited: {
                            SessionData.setLaunchPrefix(text)
                        }
                    }

                }
            }

            StyledRect {
                width: parent.width
                height: workspaceSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: workspaceSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "view_module"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Рабочие столы"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Toggle {
                        width: parent.width
                        text: "Отдельные столы для каждого монитора"
                        description: ""
                        checked: SettingsData.workspacesPerMonitor
                        onToggled: checked => {
                            return SettingsData.setWorkspacesPerMonitor(checked);
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Toggle {
                        id: workspaceIndexToggle
                        width: parent.width
                        text: "Показывать номера рабочих столов"
                        description: ""
                        checked: SettingsData.showWorkspaceIndex
                        
                        onToggled: checked => {
                            if (checked && SettingsData.showWorkspaceApps) {
                                SettingsData.setShowWorkspaceApps(false)
                            }
                            SettingsData.setShowWorkspaceIndex(checked)
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Toggle {
                        id: workspaceAppsToggle
                        width: parent.width
                        text: "Показывать иконки приложений"
                        description: ""
                        checked: SettingsData.showWorkspaceApps
                        
                        onToggled: checked => {
                            if (checked && SettingsData.showWorkspaceIndex) {
                                SettingsData.setShowWorkspaceIndex(false)
                            }
                            SettingsData.setShowWorkspaceApps(checked)
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Item {
                        width: parent.width
                        height: Math.round(60 * SettingsData.fontScale)
                        visible: SettingsData.showWorkspaceApps
                        opacity: visible ? 1 : 0

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.right: maxAppsDropdownBtn.left
                            anchors.rightMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Максимальное количество иконок"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }
                        }

                        Rectangle {
                            id: maxAppsDropdownBtn
                            width: 120
                            height: Math.round(40 * SettingsData.fontScale)
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            radius: Theme.cornerRadius
                            color: maxAppsArea.containsMouse || maxAppsPopup.visible ? Theme.surfaceContainerHigh : Theme.surfaceContainer
                            border.color: maxAppsPopup.visible ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            border.width: maxAppsPopup.visible ? 2 : 1

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingS

                                StyledText {
                                    text: SettingsData.maxWorkspaceIcons.toString()
                                    font.pixelSize: Theme.fontSizeMedium
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Icon {
                                    name: "expand_more"
                                    size: Theme.iconSizeSmall
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: maxAppsArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: maxAppsPopup.open()
                            }
                        }

                        Popup {
                            id: maxAppsPopup
                            x: maxAppsDropdownBtn.x
                            y: maxAppsDropdownBtn.y + maxAppsDropdownBtn.height + Theme.spacingXS
                            width: maxAppsDropdownBtn.width
                            padding: Theme.spacingXS
                            modal: false

                            background: Rectangle {
                                color: Theme.surfaceContainer
                                radius: Theme.cornerRadius
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            }

                            Column {
                                width: parent.width
                                spacing: 2

                                Repeater {
                                    model: ["1", "2", "3", "4", "5", "6"]

                                    delegate: Rectangle {
                                        width: maxAppsPopup.width - Theme.spacingXS * 2
                                        height: 32
                                        radius: Theme.cornerRadius - 2
                                        color: optionArea.containsMouse ? Theme.surfaceContainerHigh : "transparent"

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: modelData
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: SettingsData.maxWorkspaceIcons.toString() === modelData ? Theme.primary : Theme.surfaceText
                                        }

                                        MouseArea {
                                            id: optionArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                SettingsData.setMaxWorkspaceIcons(parseInt(modelData, 10))
                                                maxAppsPopup.close()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.mediumDuration
                                easing.type: Theme.emphasizedEasing
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Item {
                        width: parent.width
                        height: Math.round(60 * SettingsData.fontScale)

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.right: minWorkspacesDropdownBtn.left
                            anchors.rightMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Минимальное количество рабочих столов"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }
                        }

                        Rectangle {
                            id: minWorkspacesDropdownBtn
                            width: 120
                            height: Math.round(40 * SettingsData.fontScale)
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            radius: Theme.cornerRadius
                            color: minWorkspacesArea.containsMouse || minWorkspacesPopup.visible ? Theme.surfaceContainerHigh : Theme.surfaceContainer
                            border.color: minWorkspacesPopup.visible ? Theme.primary : Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            border.width: minWorkspacesPopup.visible ? 2 : 1

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingS

                                StyledText {
                                    text: SettingsData.workspacePaddingCount === 0 ? "Выкл" : SettingsData.workspacePaddingCount.toString()
                                    font.pixelSize: Theme.fontSizeMedium
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Icon {
                                    name: "expand_more"
                                    size: Theme.iconSizeSmall
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: minWorkspacesArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: minWorkspacesPopup.open()
                            }
                        }

                        Popup {
                            id: minWorkspacesPopup
                            x: minWorkspacesDropdownBtn.x
                            y: minWorkspacesDropdownBtn.y + minWorkspacesDropdownBtn.height + Theme.spacingXS
                            width: minWorkspacesDropdownBtn.width
                            padding: Theme.spacingXS
                            modal: false

                            background: Rectangle {
                                color: Theme.surfaceContainer
                                radius: Theme.cornerRadius
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                            }

                            Column {
                                width: parent.width
                                spacing: 2

                                Repeater {
                                    model: [{"label": "Выкл", "value": 0}, {"label": "3", "value": 3}, {"label": "6", "value": 6}, {"label": "9", "value": 9}]

                                    delegate: Rectangle {
                                        width: minWorkspacesPopup.width - Theme.spacingXS * 2
                                        height: 32
                                        radius: Theme.cornerRadius - 2
                                        color: minWsOptionArea.containsMouse ? Theme.surfaceContainerHigh : "transparent"

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: modelData.label
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: SettingsData.workspacePaddingCount === modelData.value ? Theme.primary : Theme.surfaceText
                                        }

                                        MouseArea {
                                            id: minWsOptionArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                SettingsData.setWorkspacePaddingCount(modelData.value)
                                                minWorkspacesPopup.close()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: mediaSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: mediaSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "music_note"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Медиаплеер"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Toggle {
                        width: parent.width
                        text: "Волновые индикаторы прогресса"
                        description: ""
                        checked: SettingsData.waveProgressEnabled
                        onToggled: checked => {
                            return SettingsData.setWaveProgressEnabled(checked)
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: runningAppsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: runningAppsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "apps"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Запущенные приложения"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Toggle {
                        width: parent.width
                        text: "Только приложения текущего рабочего стола"
                        description: ""
                        checked: SettingsData.runningAppsCurrentWorkspace
                        onToggled: checked => {
                                       return SettingsData.setRunningAppsCurrentWorkspace(
                                           checked)
                                   }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: workspaceIconsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0
                visible: SettingsData.hasNamedWorkspaces()

                Column {
                    id: workspaceIconsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "label"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Иконки именованных рабочих столов"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        width: parent.width
                        text: "Настройка иконок для именованных рабочих столов. Иконки имеют приоритет над номерами, когда оба включены."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.outline
                        wrapMode: Text.WordWrap
                    }

                    Repeater {
                        model: SettingsData.getNamedWorkspaces()

                        Rectangle {
                            width: parent.width
                            height: workspaceIconRow.implicitHeight + Theme.spacingM
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.surfaceContainer.r,
                                           Theme.surfaceContainer.g,
                                           Theme.surfaceContainer.b, 0.5)
                            border.color: Qt.rgba(Theme.outline.r,
                                                  Theme.outline.g,
                                                  Theme.outline.b, 0.3)
                            border.width: 0

                            Row {
                                id: workspaceIconRow

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: Theme.spacingM
                                anchors.rightMargin: Theme.spacingM
                                spacing: Theme.spacingM

                                StyledText {
                                    text: "\"" + modelData + "\""
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 150
                                    elide: Text.ElideRight
                                }

                                IconPicker {
                                    id: iconPicker
                                    anchors.verticalCenter: parent.verticalCenter

                                    Component.onCompleted: {
                                        var iconData = SettingsData.getWorkspaceNameIcon(
                                                    modelData)
                                        if (iconData) {
                                            setIcon(iconData.value,
                                                    iconData.type)
                                        }
                                    }

                                    onIconSelected: (iconName, iconType) => {
                                                        SettingsData.setWorkspaceNameIcon(
                                                            modelData, {
                                                                "type": iconType,
                                                                "value": iconName
                                                            })
                                                        setIcon(iconName,
                                                                iconType)
                                                    }

                                    Connections {
                                        target: SettingsData
                                        function onWorkspaceIconsUpdated() {
                                            var iconData = SettingsData.getWorkspaceNameIcon(
                                                        modelData)
                                            if (iconData) {
                                                iconPicker.setIcon(
                                                            iconData.value,
                                                            iconData.type)
                                            } else {
                                                iconPicker.setIcon("", "icon")
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: Theme.cornerRadius
                                    color: clearMouseArea.containsMouse ? Theme.errorHover : Theme.surfaceContainer
                                    border.color: clearMouseArea.containsMouse ? Theme.error : Theme.outline
                                    border.width: 0
                                    anchors.verticalCenter: parent.verticalCenter

                                    Icon {
                                        name: "close"
                                        size: 16
                                        color: clearMouseArea.containsMouse ? Theme.error : Theme.outline
                                        anchors.centerIn: parent
                                    }

                                    MouseArea {
                                        id: clearMouseArea

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            SettingsData.removeWorkspaceNameIcon(
                                                        modelData)
                                        }
                                    }
                                }

                                Item {
                                    width: parent.width - 150 - 240 - 28 - Theme.spacingM * 4
                                    height: 1
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: notificationSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: notificationSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "notifications"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Всплывающие уведомления"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Toggle {
                        width: parent.width
                        text: "Отображать на всех мониторах"
                        checked: widgetTweaksTab.getScreenPreferences("notifications").includes("all")
                        onToggled: checked => {
                            if (checked)
                                widgetTweaksTab.setScreenPreferences("notifications", ["all"])
                            else
                                widgetTweaksTab.setScreenPreferences("notifications", [])
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Column {
                        width: parent.width
                        spacing: 0
                        leftPadding: Theme.spacingM
                        rightPadding: Theme.spacingM

                        Dropdown {
                            width: parent.width - parent.leftPadding - parent.rightPadding
                            text: "Позиция всплывающих окон"
                            description: ""
                            currentValue: {
                                if (SettingsData.notificationPopupPosition === -1) {
                                    return "Сверху по центру"
                                }
                                switch (SettingsData.notificationPopupPosition) {
                                case SettingsData.Position.Top:
                                    return "Сверху справа"
                                case SettingsData.Position.Bottom:
                                    return "Снизу слева"
                                case SettingsData.Position.Left:
                                    return "Сверху слева"
                                case SettingsData.Position.Right:
                                    return "Снизу справа"
                                default:
                                    return "Сверху справа"
                                }
                            }
                            options: ["Сверху справа", "Сверху слева", "Сверху по центру", "Снизу справа", "Снизу слева"]
                            onValueChanged: value => {
                                switch (value) {
                                case "Сверху справа":
                                    SettingsData.setNotificationPopupPosition(SettingsData.Position.Top)
                                    break
                                case "Сверху слева":
                                    SettingsData.setNotificationPopupPosition(SettingsData.Position.Left)
                                    break
                                case "Сверху по центру":
                                    SettingsData.setNotificationPopupPosition(-1)
                                    break
                                case "Снизу справа":
                                    SettingsData.setNotificationPopupPosition(SettingsData.Position.Right)
                                    break
                                case "Снизу слева":
                                    SettingsData.setNotificationPopupPosition(SettingsData.Position.Bottom)
                                    break
                                }
                                SettingsData.sendTestNotifications()
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: osdSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: osdSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "picture_in_picture"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Экранные индикаторы"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Toggle {
                        width: parent.width
                        text: "Отображать на всех мониторах"
                        checked: widgetTweaksTab.getScreenPreferences("osd").includes("all")
                        onToggled: checked => {
                            if (checked)
                                widgetTweaksTab.setScreenPreferences("osd", ["all"])
                            else
                                widgetTweaksTab.setScreenPreferences("osd", [])
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Toggle {
                        width: parent.width
                        text: "Показывать проценты"
                        checked: SettingsData.osdAlwaysShowValue
                        onToggled: checked => {
                            SettingsData.setOsdAlwaysShowValue(checked)
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: toastSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: toastSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "campaign"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Всплывающие сообщения"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Toggle {
                        width: parent.width
                        text: "Отображать на всех мониторах"
                        checked: widgetTweaksTab.getScreenPreferences("toast").includes("all")
                        onToggled: checked => {
                            if (checked)
                                widgetTweaksTab.setScreenPreferences("toast", ["all"])
                            else
                                widgetTweaksTab.setScreenPreferences("toast", [])
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: notepadSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: notepadSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "sticky_note_2"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Блокнот"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Toggle {
                        width: parent.width
                        text: "Отображать на всех мониторах"
                        checked: widgetTweaksTab.getScreenPreferences("notepad").includes("all")
                        onToggled: checked => {
                            if (checked)
                                widgetTweaksTab.setScreenPreferences("notepad", ["all"])
                            else
                                widgetTweaksTab.setScreenPreferences("notepad", [])
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: wallpaperSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: wallpaperSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "wallpaper"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Обои"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Toggle {
                        width: parent.width
                        text: "Отображать на всех мониторах"
                        checked: widgetTweaksTab.getScreenPreferences("wallpaper").includes("all")
                        onToggled: checked => {
                            if (checked)
                                widgetTweaksTab.setScreenPreferences("wallpaper", ["all"])
                            else
                                widgetTweaksTab.setScreenPreferences("wallpaper", [])
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: systemTraySection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: systemTraySection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        Icon {
                            name: "notifications"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Системный трей"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Toggle {
                        width: parent.width
                        text: "Отображать на всех мониторах"
                        checked: widgetTweaksTab.getScreenPreferences("systemTray").includes("all")
                        onToggled: checked => {
                            if (checked)
                                widgetTweaksTab.setScreenPreferences("systemTray", ["all"])
                            else
                                widgetTweaksTab.setScreenPreferences("systemTray", [])
                        }
                    }
                }
            }
        }
    }
}
