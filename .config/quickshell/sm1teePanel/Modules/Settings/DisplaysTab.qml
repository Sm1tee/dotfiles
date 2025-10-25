import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: displaysTab

    property var variantComponents: [{
        "id": "dankBar",
        "name": "Панель",
        "description": "Системная панель с виджетами и информацией о системе",
        "icon": "toolbar"
    }, {
        "id": "dock",
        "name": "Док приложений",
        "description": "Док для закрепленных и запущенных приложений",
        "icon": "dock"
    }, {
        "id": "notifications",
        "name": "Всплывающие уведомления",
        "description": "Всплывающие уведомления",
        "icon": "notifications"
    }, {
        "id": "wallpaper",
        "name": "Обои",
        "description": "Фоновые изображения рабочего стола",
        "icon": "wallpaper"
    }, {
        "id": "osd",
        "name": "Экранные индикаторы",
        "description": "Индикаторы громкости, яркости и другие системные OSD",
        "icon": "picture_in_picture"
    }, {
        "id": "toast",
        "name": "Всплывающие сообщения",
        "description": "Системные всплывающие уведомления",
        "icon": "campaign"
    }, {
        "id": "notepad",
        "name": "Выдвижной блокнот",
        "description": "Выдвижная панель для быстрых заметок",
        "icon": "sticky_note_2"
    }, {
        "id": "systemTray",
        "name": "Системный трей",
        "description": "Иконки системного трея",
        "icon": "notifications"
    }]

    function getScreenPreferences(componentId) {
        return SettingsData.screenPreferences && SettingsData.screenPreferences[componentId] || ["all"];
    }

    function setScreenPreferences(componentId, screenNames) {
        var prefs = SettingsData.screenPreferences || {
        };
        prefs[componentId] = screenNames;
        SettingsData.setScreenPreferences(prefs);
    }

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        anchors.bottomMargin: Theme.spacingS
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL

            StyledRect {
                width: parent.width
                height: gammaSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: gammaSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "brightness_6"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Управление гаммой"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankToggle {
                        id: nightModeToggle

                        width: parent.width
                        text: "Ночной режим"
                        description: "Применить теплую цветовую температуру для снижения нагрузки на глаза."
                        checked: DisplayService.nightModeEnabled
                        onToggled: checked => {
                                       DisplayService.toggleNightMode()
                                   }

                        Connections {
                            function onNightModeEnabledChanged() {
                                nightModeToggle.checked = DisplayService.nightModeEnabled
                            }

                            target: DisplayService
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 0
                        leftPadding: Theme.spacingM
                        rightPadding: Theme.spacingM

                        DankDropdown {
                            width: parent.width - parent.leftPadding - parent.rightPadding
                            text: "Температура"
                            description: "Цветовая температура для ночного режима"
                            currentValue: SessionData.nightModeTemperature + "K"
                            options: {
                                var temps = []
                                for (var i = 2500; i <= 6000; i += 500) {
                                    temps.push(i + "K")
                                }
                                return temps
                            }
                            onValueChanged: value => {
                                                var temp = parseInt(value.replace("K", ""))
                                                SessionData.setNightModeTemperature(temp)
                                            }
                        }
                    }

                    DankToggle {
                        id: automaticToggle
                        width: parent.width
                        text: "Автонастройка гаммы"
                        description: "Включать и выключать ночной режим по рассписанию"
                        checked: SessionData.nightModeAutoEnabled
                        onToggled: checked => {
                                       if (checked && !DisplayService.nightModeEnabled) {
                                           DisplayService.toggleNightMode()
                                       } else if (!checked && DisplayService.nightModeEnabled) {
                                           DisplayService.toggleNightMode()
                                       }
                                       SessionData.setNightModeAutoEnabled(checked)
                                   }

                        Connections {
                            target: SessionData
                            function onNightModeAutoEnabledChanged() {
                                automaticToggle.checked = SessionData.nightModeAutoEnabled
                            }
                        }
                    }

                    Column {
                        id: automaticSettings
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: SessionData.nightModeAutoEnabled

                        Connections {
                            target: SessionData
                            function onNightModeAutoEnabledChanged() {
                                automaticSettings.visible = SessionData.nightModeAutoEnabled
                            }
                        }

                        DankButtonGroup {
                            id: modeButtonGroup
                            width: 300
                            model: ["Время", "Местоположение"]
                            currentIndex: SessionData.nightModeAutoMode === "location" ? 1 : 0
                            checkEnabled: false
                            fillWidth: false

                            Component.onCompleted: {
                                currentIndex = SessionData.nightModeAutoMode === "location" ? 1 : 0
                            }

                            onSelectionChanged: (index, selected) => {
                                if (selected) {
                                    const newMode = index === 1 ? "location" : "time"
                                    if (SessionData.nightModeAutoMode !== newMode) {
                                        DisplayService.setNightModeAutomationMode(newMode)
                                    }
                                }
                            }

                            Connections {
                                target: SessionData
                                function onNightModeAutoModeChanged() {
                                    modeButtonGroup.currentIndex = SessionData.nightModeAutoMode === "location" ? 1 : 0
                                }
                            }
                        }

                        Column {
                            property bool isTimeMode: SessionData.nightModeAutoMode === "time"
                            visible: isTimeMode
                            spacing: Theme.spacingM

                            Row {
                                spacing: Theme.spacingM
                                height: 24

                                Item {
                                    width: 70
                                    height: 1
                                }

                                StyledText {
                                    text: "Час"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    width: 100
                                    horizontalAlignment: Text.AlignHCenter
                                    anchors.bottom: parent.bottom
                                }

                                StyledText {
                                    text: "Минута"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceVariantText
                                    width: 100
                                    horizontalAlignment: Text.AlignHCenter
                                    anchors.bottom: parent.bottom
                                }
                            }

                            Row {
                                spacing: Theme.spacingM
                                height: 40

                                StyledText {
                                    id: startLabel
                                    text: "Начало"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    width: 70
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                DankDropdown {
                                    width: 100
                                    height: 40
                                    dropdownWidth: 100
                                    text: ""
                                    currentValue: SessionData.nightModeStartHour.toString()
                                    options: {
                                        var hours = []
                                        for (var i = 0; i < 24; i++) {
                                            hours.push(i.toString())
                                        }
                                        return hours
                                    }
                                    onValueChanged: value => {
                                                        SessionData.setNightModeStartHour(parseInt(value))
                                                    }
                                }

                                DankDropdown {
                                    width: 100
                                    height: 40
                                    dropdownWidth: 100
                                    text: ""
                                    currentValue: SessionData.nightModeStartMinute.toString().padStart(2, '0')
                                    options: {
                                        var minutes = []
                                        for (var i = 0; i < 60; i += 5) {
                                            minutes.push(i.toString().padStart(2, '0'))
                                        }
                                        return minutes
                                    }
                                    onValueChanged: value => {
                                                        SessionData.setNightModeStartMinute(parseInt(value))
                                                    }
                                }
                            }

                            Row {
                                spacing: Theme.spacingM
                                height: 40

                                StyledText {
                                    text: "Конец"
                                    font.pixelSize: Theme.fontSizeMedium
                                    color: Theme.surfaceText
                                    width: startLabel.width
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                DankDropdown {
                                    width: 100
                                    height: 40
                                    dropdownWidth: 100
                                    text: ""
                                    currentValue: SessionData.nightModeEndHour.toString()
                                    options: {
                                        var hours = []
                                        for (var i = 0; i < 24; i++) {
                                            hours.push(i.toString())
                                        }
                                        return hours
                                    }
                                    onValueChanged: value => {
                                                        SessionData.setNightModeEndHour(parseInt(value))
                                                    }
                                }

                                DankDropdown {
                                    width: 100
                                    height: 40
                                    dropdownWidth: 100
                                    text: ""
                                    currentValue: SessionData.nightModeEndMinute.toString().padStart(2, '0')
                                    options: {
                                        var minutes = []
                                        for (var i = 0; i < 60; i += 5) {
                                            minutes.push(i.toString().padStart(2, '0'))
                                        }
                                        return minutes
                                    }
                                    onValueChanged: value => {
                                                        SessionData.setNightModeEndMinute(parseInt(value))
                                                    }
                                }
                            }
                        }

                        Column {
                            property bool isLocationMode: SessionData.nightModeAutoMode === "location"
                            visible: isLocationMode
                            spacing: Theme.spacingM
                            width: parent.width

                            DankToggle {
                                width: parent.width
                                text: "Автоопределение местоположения"
                                description: DisplayService.geoclueAvailable ? "Использовать автоматическое определение местоположения (geoclue2)" : "Служба Geoclue не запущена - невозможно автоматически определить местоположение"
                                checked: SessionData.nightModeLocationProvider === "geoclue2"
                                enabled: DisplayService.geoclueAvailable
                                onToggled: checked => {
                                               if (checked && DisplayService.geoclueAvailable) {
                                                   SessionData.setNightModeLocationProvider("geoclue2")
                                                   SessionData.setLatitude(0.0)
                                                   SessionData.setLongitude(0.0)
                                               } else {
                                                   SessionData.setNightModeLocationProvider("")
                                               }
                                           }
                            }

                            StyledText {
                                text: "Ручные координаты"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                visible: SessionData.nightModeLocationProvider !== "geoclue2"
                            }

                            Row {
                                spacing: Theme.spacingM
                                visible: SessionData.nightModeLocationProvider !== "geoclue2"

                                Column {
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: "Широта"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    DankTextField {
                                        width: 120
                                        height: 40
                                        text: SessionData.latitude.toString()
                                        placeholderText: "0.0"
                                        onTextChanged: {
                                            const lat = parseFloat(text) || 0.0
                                            if (lat >= -90 && lat <= 90) {
                                                SessionData.setLatitude(lat)
                                            }
                                        }
                                    }
                                }

                                Column {
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: "Долгота"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    DankTextField {
                                        width: 120
                                        height: 40
                                        text: SessionData.longitude.toString()
                                        placeholderText: "0.0"
                                        onTextChanged: {
                                            const lon = parseFloat(text) || 0.0
                                            if (lon >= -180 && lon <= 180) {
                                                SessionData.setLongitude(lon)
                                            }
                                        }
                                    }
                                }
                            }

                            StyledText {
                                text: "Использует время восхода/заката для автоматической настройки ночного режима на основе вашего местоположения."
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: parent.width
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: screensInfoSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: screensInfoSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "monitor"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Подключенные дисплеи"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Настройте, на каких дисплеях отображать компоненты оболочки"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                        }

                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Доступные экраны (" + Quickshell.screens.length + ")"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        Repeater {
                            model: Quickshell.screens

                            delegate: Rectangle {
                                width: parent.width
                                height: screenRow.implicitHeight + Theme.spacingS * 2
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.3)
                                border.width: 0

                                Row {
                                    id: screenRow

                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingS
                                    spacing: Theme.spacingM

                                    DankIcon {
                                        name: "desktop_windows"
                                        size: Theme.iconSize - 4
                                        color: Theme.primary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        width: parent.width - Theme.iconSize - Theme.spacingM * 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: Theme.spacingXS / 2

                                        StyledText {
                                            text: modelData.name
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: Theme.surfaceText
                                        }

                                        Row {
                                            spacing: Theme.spacingS

                                            StyledText {
                                                text: modelData.width + "×" + modelData.height
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceVariantText
                                            }

                                            StyledText {
                                                text: "•"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceVariantText
                                            }

                                            StyledText {
                                                text: modelData.model || "Unknown Model"
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceVariantText
                                            }

                                        }

                                    }

                                }

                            }

                        }

                    }

                }

            }

            Column {
                width: parent.width
                spacing: Theme.spacingL

                Repeater {
                    model: displaysTab.variantComponents

                    delegate: StyledRect {
                        width: parent.width
                        height: componentSection.implicitHeight + Theme.spacingL * 2
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                        border.width: 0

                        Column {
                            id: componentSection

                            anchors.fill: parent
                            anchors.margins: Theme.spacingL
                            spacing: Theme.spacingM

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                DankIcon {
                                    name: modelData.icon
                                    size: Theme.iconSize
                                    color: Theme.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width - Theme.iconSize - Theme.spacingM
                                    spacing: Theme.spacingXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    StyledText {
                                        text: modelData.name
                                        font.pixelSize: Theme.fontSizeLarge
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: modelData.description
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                    }

                                }

                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Показывать на экранах:"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    font.weight: Font.Medium
                                }

                                Column {
                                    property string componentId: modelData.id
                                    property var selectedScreens: displaysTab.getScreenPreferences(componentId)

                                    width: parent.width
                                    spacing: Theme.spacingXS

                                    DankToggle {
                                        width: parent.width
                                        text: "Все дисплеи"
                                        description: "Показывать на всех подключенных дисплеях"
                                        checked: parent.selectedScreens.includes("all")
                                        onToggled: (checked) => {
                                            if (checked)
                                                displaysTab.setScreenPreferences(parent.componentId, ["all"]);
                                            else
                                                displaysTab.setScreenPreferences(parent.componentId, []);
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: Theme.outline
                                        opacity: 0.2
                                        visible: !parent.selectedScreens.includes("all")
                                    }

                                    Column {
                                        width: parent.width
                                        spacing: Theme.spacingXS
                                        visible: !parent.selectedScreens.includes("all")

                                        Repeater {
                                            model: Quickshell.screens

                                            delegate: DankToggle {
                                                property string screenName: modelData.name
                                                property string componentId: parent.parent.componentId

                                                width: parent.width
                                                text: screenName
                                                description: modelData.width + "×" + modelData.height + " • " + (modelData.model || "Unknown Model")
                                                checked: {
                                                    var prefs = displaysTab.getScreenPreferences(componentId);
                                                    return !prefs.includes("all") && prefs.includes(screenName);
                                                }
                                                onToggled: (checked) => {
                                                    var currentPrefs = displaysTab.getScreenPreferences(componentId);
                                                    if (currentPrefs.includes("all"))
                                                        currentPrefs = [];

                                                    var newPrefs = currentPrefs.slice();
                                                    if (checked) {
                                                        if (!newPrefs.includes(screenName))
                                                            newPrefs.push(screenName);

                                                    } else {
                                                        var index = newPrefs.indexOf(screenName);
                                                        if (index > -1)
                                                            newPrefs.splice(index, 1);

                                                    }
                                                    displaysTab.setScreenPreferences(componentId, newPrefs);
                                                }
                                            }

                                        }

                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
