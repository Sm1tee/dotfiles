import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Modals.FileBrowser
import qs.Services
import qs.Widgets

Item {
    id: widgetTweaksTab

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

    DankFlickable {
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

                        DankIcon {
                            name: "apps"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Настройки лаунчера"
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

                        StyledText {
                            width: parent.width
                            text: "Выберите логотип, отображаемый на кнопке лаунчера в панели"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                        }
                    }

                    DankButtonGroup {
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

                        DankActionButton {
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

                                    DankButtonGroup {
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

                                DankSlider {
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

                                    DankSlider {
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

                                    DankSlider {
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

                                    DankToggle {
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

                        StyledText {
                            width: parent.width
                            text: "Добавить пользовательский префикс ко всем запускам приложений."
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                        }
                    }

                    DankTextField {
                        width: parent.width
                        text: SessionData.launchPrefix
                        placeholderText: "Введите префикс запуска (например, 'uwsm-app')"
                        onTextEdited: {
                            SessionData.setLaunchPrefix(text)
                        }
                    }

                    // Недавно использованные приложения
                    Column {
                        id: recentAppsSection
                        width: parent.width
                        spacing: Theme.spacingS

                        property var rankedAppsModel: {
                            var apps = []
                            for (var appId in (AppUsageHistoryData.appUsageRanking
                                               || {})) {
                                var appData = (AppUsageHistoryData.appUsageRanking
                                               || {})[appId]
                                apps.push({
                                              "id": appId,
                                              "name": appData.name,
                                              "exec": appData.exec,
                                              "icon": appData.icon,
                                              "comment": appData.comment,
                                              "usageCount": appData.usageCount,
                                              "lastUsed": appData.lastUsed
                                          })
                            }
                            apps.sort(function (a, b) {
                                if (a.usageCount !== b.usageCount)
                                    return b.usageCount - a.usageCount

                                return a.name.localeCompare(b.name)
                            })
                            return apps.slice(0, 20)
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            StyledText {
                                text: "Недавно использованные приложения"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item {
                                width: parent.width - parent.children[0].width
                                       - clearAllButton.width - Theme.spacingM * 2
                                height: 1
                            }

                            DankActionButton {
                                id: clearAllButton

                                iconName: "delete_sweep"
                                iconSize: Theme.iconSize - 2
                                iconColor: Theme.error
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    AppUsageHistoryData.appUsageRanking = {}
                                    SettingsData.saveSettings()
                                }
                            }
                        }

                        StyledText {
                            width: parent.width
                            text: "Приложения упорядочены по частоте использования, затем по времени последнего использования, затем по алфавиту."
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                        }
                    }

                    Column {
                        id: rankedAppsList

                        width: parent.width
                        spacing: Theme.spacingS

                        Repeater {
                            model: recentAppsSection.rankedAppsModel

                            delegate: Rectangle {
                                width: rankedAppsList.width
                                height: 48
                                radius: Theme.cornerRadius
                                color: Qt.rgba(Theme.surfaceContainer.r,
                                               Theme.surfaceContainer.g,
                                               Theme.surfaceContainer.b, 0.3)
                                border.color: Qt.rgba(Theme.outline.r,
                                                      Theme.outline.g,
                                                      Theme.outline.b, 0.1)
                                border.width: 0

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.spacingM
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingM

                                    StyledText {
                                        text: (index + 1).toString()
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: Font.Medium
                                        color: Theme.primary
                                        width: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Image {
                                        width: 24
                                        height: 24
                                        source: modelData.icon ? "image://icon/" + modelData.icon : "image://icon/application-x-executable"
                                        sourceSize.width: 24
                                        sourceSize.height: 24
                                        fillMode: Image.PreserveAspectFit
                                        anchors.verticalCenter: parent.verticalCenter
                                        onStatusChanged: {
                                            if (status === Image.Error)
                                                source = "image://icon/application-x-executable"
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2

                                        StyledText {
                                            text: modelData.name
                                                  || "Unknown App"
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: Theme.surfaceText
                                        }

                                        StyledText {
                                            text: {
                                                if (!modelData.lastUsed)
                                                    return "Never used"

                                                var date = new Date(modelData.lastUsed)
                                                var now = new Date()
                                                var diffMs = now - date
                                                var diffMins = Math.floor(
                                                            diffMs / (1000 * 60))
                                                var diffHours = Math.floor(
                                                            diffMs / (1000 * 60 * 60))
                                                var diffDays = Math.floor(
                                                            diffMs / (1000 * 60 * 60 * 24))
                                                if (diffMins < 1)
                                                    return "Last launched just now"

                                                if (diffMins < 60)
                                                    return "Last launched " + diffMins + " minute"
                                                            + (diffMins === 1 ? "" : "s") + " ago"

                                                if (diffHours < 24)
                                                    return "Last launched " + diffHours + " hour"
                                                            + (diffHours === 1 ? "" : "s") + " ago"

                                                if (diffDays < 7)
                                                    return "Last launched " + diffDays + " day"
                                                            + (diffDays === 1 ? "" : "s") + " ago"

                                                return "Last launched " + date.toLocaleDateString()
                                            }
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.surfaceVariantText
                                        }
                                    }
                                }

                                DankActionButton {
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.spacingM
                                    anchors.verticalCenter: parent.verticalCenter
                                    circular: true
                                    iconName: "close"
                                    iconSize: Theme.iconSizeSmall
                                    iconColor: Theme.error
                                    onClicked: {
                                        var currentRanking = Object.assign(
                                                    {},
                                                    AppUsageHistoryData.appUsageRanking
                                                    || {})
                                        delete currentRanking[modelData.id]
                                        AppUsageHistoryData.appUsageRanking = currentRanking
                                        SettingsData.saveSettings()
                                    }
                                }
                            }
                        }

                        StyledText {
                            width: parent.width
                            text: recentAppsSection.rankedAppsModel.length
                                  === 0 ? "Приложения еще не запускались." : ""
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceVariantText
                            horizontalAlignment: Text.AlignHCenter
                            visible: recentAppsSection.rankedAppsModel.length === 0
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

                        DankIcon {
                            name: "view_module"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Настройки рабочих столов"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        id: workspaceIndexToggle
                        width: parent.width
                        text: "Показывать номера рабочих столов"
                        description: "Номера в переключателях рабочих столов."
                        
                        Component.onCompleted: checked = SettingsData.showWorkspaceIndex
                        
                        Connections {
                            target: SettingsData
                            function onShowWorkspaceIndexChanged() {
                                workspaceIndexToggle.checked = SettingsData.showWorkspaceIndex
                            }
                        }
                        
                        onToggled: checked => {
                            if (checked && SettingsData.showWorkspaceApps) {
                                SettingsData.setShowWorkspaceApps(false)
                            }
                            SettingsData.setShowWorkspaceIndex(checked)
                        }
                    }

                    DankToggle {
                        id: workspaceAppsToggle
                        width: parent.width
                        text: "Показывать иконки приложений"
                        description: "Иконки открытых приложений в переключателях рабочих столов."
                        
                        Component.onCompleted: checked = SettingsData.showWorkspaceApps
                        
                        Connections {
                            target: SettingsData
                            function onShowWorkspaceAppsChanged() {
                                workspaceAppsToggle.checked = SettingsData.showWorkspaceApps
                            }
                        }
                        
                        onToggled: checked => {
                            if (checked && SettingsData.showWorkspaceIndex) {
                                SettingsData.setShowWorkspaceIndex(false)
                            }
                            SettingsData.setShowWorkspaceApps(checked)
                        }
                    }

		    Row {
                        width: parent.width - Theme.spacingL
                        spacing: Theme.spacingL
                        visible: SettingsData.showWorkspaceApps
                        opacity: visible ? 1 : 0
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingL

                        Column {
                            width: 120
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Макс. приложений"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            DankTextField {
                                width: 100
                                height: 28
                                placeholderText: "#ffffff"
                                text: SettingsData.maxWorkspaceIcons
                                maximumLength: 7
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.spacingXS
                                bottomPadding: Theme.spacingXS
                                onEditingFinished: {
                                    SettingsData.setMaxWorkspaceIcons(parseInt(text, 10))
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

                    DankToggle {
                        width: parent.width
                        text: "Рабочие столы по мониторам"
                        description: "Отдельные рабочие столы для каждого монитора."
                        checked: SettingsData.workspacesPerMonitor
                        onToggled: checked => {
                            return SettingsData.setWorkspacesPerMonitor(checked);
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Минимальное количество рабочих столов"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        DankButtonGroup {
                            id: paddingButtonGroup
                            width: parent.width
                            fillWidth: true
                            buttonPadding: Theme.spacingXS
                            spacing: 2
                            checkEnabled: false
                            model: ["Выкл", "3", "6", "9"]
                            selectionMode: "single"
                                currentIndex: {
                                    if (SettingsData.workspacePaddingCount === 0) return 0
                                    if (SettingsData.workspacePaddingCount === 3) return 1
                                    if (SettingsData.workspacePaddingCount === 6) return 2
                                    if (SettingsData.workspacePaddingCount === 9) return 3
                                    return 0
                                }
                                onSelectionChanged: (index, selected) => {
                                    if (selected) {
                                        const countMap = [0, 3, 6, 9]
                                        SettingsData.setWorkspacePaddingCount(countMap[index])
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

                        DankIcon {
                            name: "music_note"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Настройки медиаплеера"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Волновые индикаторы прогресса"
                        description: "Использовать анимированные волновые индикаторы для воспроизведения медиа"
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

                        DankIcon {
                            name: "apps"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Настройки запущенных приложений"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        width: parent.width
                        text: "Только приложения текущего рабочего стола"
                        description: "Показывать только приложения, запущенные на текущем рабочем столе"
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

                        DankIcon {
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

                                DankIconPicker {
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

                                    DankIcon {
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

                        DankIcon {
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

                    Column {
                        width: parent.width
                        spacing: 0
                        leftPadding: Theme.spacingM
                        rightPadding: Theme.spacingM

                        DankDropdown {
                            width: parent.width - parent.leftPadding - parent.rightPadding
                            text: "Позиция всплывающих окон"
                            description: "Выберите, где будут появляться всплывающие уведомления на экране"
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
                height: osdRow.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Row {
                    id: osdRow

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    DankIcon {
                        name: "tune"
                        size: Theme.iconSize
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        width: parent.width - Theme.iconSize - Theme.spacingM - osdToggle.width - Theme.spacingM
                        spacing: Theme.spacingXS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Показывать проценты на индикаторах"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        StyledText {
                            text: "Отображать проценты на всплывающих индикаторах громкости и яркости"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }

                    DankToggle {
                        id: osdToggle

                        anchors.verticalCenter: parent.verticalCenter
                        checked: SettingsData.osdAlwaysShowValue
                        onToggleCompleted: checked => {
                                       SettingsData.setOsdAlwaysShowValue(checked)
                                   }
                    }
                }
            }
        }
    }
}
