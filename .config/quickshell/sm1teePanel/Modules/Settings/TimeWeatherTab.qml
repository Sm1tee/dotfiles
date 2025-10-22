import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

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
                height: timeSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: timeSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "schedule"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "24-часовой формат"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: parent.width - Theme.iconSize - Theme.spacingM - toggle.width - Theme.spacingM - parent.children[1].width - Theme.spacingM
                            height: 1
                        }

                        DankToggle {
                            id: toggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.use24HourClock
                            onToggled: checked => {
                                           return SettingsData.setClockFormat(
                                               checked)
                                       }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: dateSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: dateSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "calendar_today"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Формат даты"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Формат на панели"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceVariantText
                        }

                        Item {
                            width: parent.width
                            height: clockFormatGroup.height

                            DankButtonGroup {
                                id: clockFormatGroup
                                x: (parent.width - width) / 2
                                model: ["Полный", "Без года", "Краткий", "День", "Свой"]
                                selectionMode: "single"
                                minButtonWidth: Math.floor((parent.width - spacing * 4) / 5)
                                currentIndex: {
                                    if (customFormatInput.visible) return 4
                                    if (SettingsData.clockDateFormat === "d MMMM dddd yyyy") return 0
                                    if (SettingsData.clockDateFormat === "d MMMM dddd") return 1
                                    if (SettingsData.clockDateFormat === "d MMMM") return 2
                                    if (SettingsData.clockDateFormat === "dddd") return 3
                                    return 4
                                }
                                onSelectionChanged: (index, selected) => {
                                    if (selected) {
                                        const formatMap = [
                                            "d MMMM dddd yyyy",
                                            "d MMMM dddd",
                                            "d MMMM",
                                            "dddd",
                                            ""
                                        ]
                                        if (index === 4) {
                                            customFormatInput.visible = true
                                        } else {
                                            customFormatInput.visible = false
                                            SettingsData.setClockDateFormat(formatMap[index])
                                        }
                                    }
                                }
                            }
                        }

                        DankTextField {
                            id: customFormatInput
                            width: parent.width
                            visible: false
                            placeholderText: "Введите свой формат панели (например, ddd MMM d)"
                            text: SettingsData.clockDateFormat
                            onTextChanged: {
                                if (visible && text)
                                    SettingsData.setClockDateFormat(text)
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Формат экрана блокировки"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceVariantText
                        }

                        Item {
                            width: parent.width
                            height: lockFormatGroup.height

                            DankButtonGroup {
                                id: lockFormatGroup
                                x: (parent.width - width) / 2
                                model: ["Полный", "Без года", "Краткий", "День", "Свой"]
                                selectionMode: "single"
                                minButtonWidth: Math.floor((parent.width - spacing * 4) / 5)
                                currentIndex: {
                                    if (customLockFormatInput.visible) return 4
                                    if (SettingsData.lockDateFormat === "d MMMM dddd yyyy") return 0
                                    if (SettingsData.lockDateFormat === "d MMMM dddd") return 1
                                    if (SettingsData.lockDateFormat === "d MMMM") return 2
                                    if (SettingsData.lockDateFormat === "dddd") return 3
                                    return 4
                                }
                                onSelectionChanged: (index, selected) => {
                                    if (selected) {
                                        const formatMap = [
                                            "d MMMM dddd yyyy",
                                            "d MMMM dddd",
                                            "d MMMM",
                                            "dddd",
                                            ""
                                        ]
                                        if (index === 4) {
                                            customLockFormatInput.visible = true
                                        } else {
                                            customLockFormatInput.visible = false
                                            SettingsData.setLockDateFormat(formatMap[index])
                                        }
                                    }
                                }
                            }
                        }

                        DankTextField {
                            id: customLockFormatInput
                            width: parent.width
                            visible: false
                            placeholderText: "Введите свой формат блокировки (например, dddd, MMMM d)"
                            text: SettingsData.lockDateFormat
                            onTextChanged: {
                                if (visible && text)
                                    SettingsData.setLockDateFormat(text)
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: formatHelp.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh
                        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                              Theme.outline.b, 0.1)
                        border.width: 0

                        Column {
                            id: formatHelp

                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Легенда форматов"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.primary
                                font.weight: Font.Medium
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingL

                                Column {
                                    width: (parent.width - Theme.spacingL) / 2
                                    spacing: 2

                                    StyledText {
                                        text: "• d - Число (1-31)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• dd - Число (01-31)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• ddd - День недели (Пн)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• dddd - День недели (Понедельник)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• M - Месяц (1-12)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }
                                }

                                Column {
                                    width: (parent.width - Theme.spacingL) / 2
                                    spacing: 2

                                    StyledText {
                                        text: "• MM - Месяц (01-12)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• MMM - Месяц (Янв)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• MMMM - Месяц (Январь)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• yy - Год (24)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        text: "• yyyy - Год (2024)"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: enableWeatherSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: enableWeatherSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "cloud"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - enableToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Включить погоду"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Показывать информацию о погоде на панели и в центре управления"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: enableToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.weatherEnabled
                            
                            onToggled: checked => {
                                           SettingsData.weatherEnabled = checked
                                           SettingsData.saveSettings()
                                       }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: temperatureSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0
                visible: SettingsData.weatherEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: temperatureSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "thermostat"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - temperatureToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Использовать Фаренгейт"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Использовать Фаренгейт вместо Цельсия для температуры"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: temperatureToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.useFahrenheit
                            onToggled: checked => {
                                           return SettingsData.setTemperatureUnit(
                                               checked)
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

            StyledRect {
                width: parent.width
                height: locationSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0
                visible: SettingsData.weatherEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: locationSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Timer {
                        id: coordUpdateTimer
                        interval: 1500
                        repeat: false
                        onTriggered: WeatherService.forceRefresh()
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "location_on"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - autoLocationToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Автоопределение местоположения"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Автоматически определять ваше местоположение по IP-адресу"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        DankToggle {
                            id: autoLocationToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.useAutoLocation
                            onToggled: checked => {
                                           SettingsData.setAutoLocation(checked)
                                           Qt.callLater(() => {
                                               WeatherService.forceRefresh()
                                           })
                                       }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingXS
                        visible: !SettingsData.useAutoLocation

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.outline
                            opacity: 0.2
                        }

                        StyledText {
                            text: "Свое местоположение"
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                        }

                        Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                Column {
                                    width: (parent.width - Theme.spacingM) / 2
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: "Широта"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    DankTextField {
                                        id: latitudeInput
                                        width: parent.width
                                        height: 48
                                        placeholderText: "40.7128"
                                        backgroundColor: Theme.surfaceVariant
                                        normalBorderColor: Theme.primarySelected
                                        focusedBorderColor: Theme.primary
                                        keyNavigationTab: longitudeInput

                                        Component.onCompleted: {
                                            if (SettingsData.weatherCoordinates) {
                                                const coords = SettingsData.weatherCoordinates.split(',')
                                                if (coords.length > 0) {
                                                    text = coords[0].trim()
                                                }
                                            }
                                        }

                                        Connections {
                                            target: SettingsData
                                            function onWeatherCoordinatesChanged() {
                                                if (SettingsData.weatherCoordinates) {
                                                    const coords = SettingsData.weatherCoordinates.split(',')
                                                    if (coords.length > 0) {
                                                        latitudeInput.text = coords[0].trim()
                                                    }
                                                }
                                            }
                                        }

                                        onTextEdited: {
                                            if (text && longitudeInput.text) {
                                                const coords = text + "," + longitudeInput.text
                                                SettingsData.weatherCoordinates = coords
                                                SettingsData.saveSettings()
                                                
                                                // Обновляем погоду при изменении координат
                                                coordUpdateTimer.restart()
                                            }
                                        }
                                    }
                                }

                                Column {
                                    width: (parent.width - Theme.spacingM) / 2
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: "Долгота"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    DankTextField {
                                        id: longitudeInput
                                        width: parent.width
                                        height: 48
                                        placeholderText: "-74.0060"
                                        backgroundColor: Theme.surfaceVariant
                                        normalBorderColor: Theme.primarySelected
                                        focusedBorderColor: Theme.primary
                                        keyNavigationTab: locationSearchInput
                                        keyNavigationBacktab: latitudeInput

                                        Component.onCompleted: {
                                            if (SettingsData.weatherCoordinates) {
                                                const coords = SettingsData.weatherCoordinates.split(',')
                                                if (coords.length > 1) {
                                                    text = coords[1].trim()
                                                }
                                            }
                                        }

                                        Connections {
                                            target: SettingsData
                                            function onWeatherCoordinatesChanged() {
                                                if (SettingsData.weatherCoordinates) {
                                                    const coords = SettingsData.weatherCoordinates.split(',')
                                                    if (coords.length > 1) {
                                                        longitudeInput.text = coords[1].trim()
                                                    }
                                                }
                                            }
                                        }

                                        onTextEdited: {
                                            if (text && latitudeInput.text) {
                                                const coords = latitudeInput.text + "," + text
                                                SettingsData.weatherCoordinates = coords
                                                SettingsData.saveSettings()
                                                
                                                // Обновляем погоду при изменении координат
                                                coordUpdateTimer.restart()
                                            }
                                        }
                                    }
                                }
                            }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Поиск местоположения"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                font.weight: Font.Medium
                            }

                            DankLocationSearch {
                                id: locationSearchInput
                                width: parent.width
                                currentLocation: ""
                                placeholderText: "Москва, Россия"
                                keyNavigationBacktab: longitudeInput
                                onLocationSelected: (displayName, coordinates) => {
                                                        SettingsData.setWeatherLocation(displayName, coordinates)

                                                        const coords = coordinates.split(',')
                                                        if (coords.length >= 2) {
                                                            latitudeInput.text = coords[0].trim()
                                                            longitudeInput.text = coords[1].trim()
                                                            
                                                            const lat = parseFloat(coords[0].trim())
                                                            const lon = parseFloat(coords[1].trim())
                                                            
                                                            Qt.callLater(() => {
                                                                WeatherService.location = {
                                                                    city: displayName,
                                                                    country: "",
                                                                    latitude: lat,
                                                                    longitude: lon
                                                                }
                                                                WeatherService.fetchWeather(true)
                                                            })
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

            StyledRect {
                width: parent.width
                height: weatherDisplaySection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0
                visible: SettingsData.weatherEnabled
                opacity: visible ? 1 : 0

                Column {
                    id: weatherDisplaySection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "visibility"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Текущая погода"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Item { Layout.fillWidth: true; width: 1 }
                        
                        DankIcon {
                            id: refreshButton
                            name: "refresh"
                            size: Theme.iconSize
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
                            anchors.verticalCenter: parent.verticalCenter
                            visible: WeatherService.weather.available

                            property bool isRefreshing: false
                            enabled: !isRefreshing

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                                onClicked: {
                                    refreshButton.isRefreshing = true
                                    WeatherService.forceRefresh()
                                    refreshTimer.restart()
                                }
                                enabled: parent.enabled
                            }

                            Timer {
                                id: refreshTimer
                                interval: 2000
                                onTriggered: refreshButton.isRefreshing = false
                            }

                            RotationAnimation on rotation {
                                running: refreshButton.isRefreshing
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingL
                        visible: !WeatherService.weather.available

                        DankIcon {
                            name: "cloud_off"
                            size: Theme.iconSize * 2
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: "Нет данных о погоде"
                            font.pixelSize: Theme.fontSizeLarge
                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingM
                        visible: WeatherService.weather.available

                        Item {
                            width: parent.width
                            height: 70

                            Item {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: weatherIcon.width + tempColumn.width + sunriseColumn.width + Theme.spacingM * 2
                                height: 70

                                DankIcon {
                                    id: weatherIcon
                                    name: WeatherService.getWeatherIcon(WeatherService.weather.wCode)
                                    size: Theme.iconSize * 1.5
                                    color: Theme.primary
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter

                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        shadowEnabled: true
                                        shadowHorizontalOffset: 0
                                        shadowVerticalOffset: 4
                                        shadowBlur: 0.8
                                        shadowColor: Qt.rgba(0, 0, 0, 0.2)
                                        shadowOpacity: 0.2
                                    }
                                }

                                Column {
                                    id: tempColumn
                                    spacing: Theme.spacingXS
                                    anchors.left: weatherIcon.right
                                    anchors.leftMargin: Theme.spacingM
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        width: tempText.width + unitText.width + Theme.spacingXS
                                        height: tempText.height

                                        StyledText {
                                            id: tempText
                                            text: (SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp) + "°"
                                            font.pixelSize: Theme.fontSizeLarge + 4
                                            color: Theme.surfaceText
                                            font.weight: Font.Light
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            id: unitText
                                            text: SettingsData.useFahrenheit ? "F" : "C"
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                            anchors.left: tempText.right
                                            anchors.leftMargin: Theme.spacingXS
                                            anchors.verticalCenter: parent.verticalCenter

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (WeatherService.weather.available) {
                                                        SettingsData.setTemperatureUnit(!SettingsData.useFahrenheit)
                                                    }
                                                }
                                                enabled: WeatherService.weather.available
                                            }
                                        }
                                    }

                                    StyledText {
                                        text: WeatherService.weather.city || ""
                                        font.pixelSize: Theme.fontSizeMedium
                                        color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                        visible: text.length > 0
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                        width: Math.min(implicitWidth, 300)
                                    }
                                }

                                Column {
                                    id: sunriseColumn
                                    spacing: Theme.spacingXS
                                    anchors.left: tempColumn.right
                                    anchors.leftMargin: Theme.spacingM
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: WeatherService.weather.sunrise && WeatherService.weather.sunset

                                    Item {
                                        width: sunriseIcon.width + sunriseText.width + Theme.spacingXS
                                        height: sunriseIcon.height

                                        DankIcon {
                                            id: sunriseIcon
                                            name: "wb_twilight"
                                            size: Theme.iconSize - 6
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            id: sunriseText
                                            text: WeatherService.weather.sunrise || ""
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                                            anchors.left: sunriseIcon.right
                                            anchors.leftMargin: Theme.spacingXS
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Item {
                                        width: sunsetIcon.width + sunsetText.width + Theme.spacingXS
                                        height: sunsetIcon.height

                                        DankIcon {
                                            id: sunsetIcon
                                            name: "bedtime"
                                            size: Theme.iconSize - 6
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            id: sunsetText
                                            text: WeatherService.weather.sunset || ""
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.6)
                                            anchors.left: sunsetIcon.right
                                            anchors.leftMargin: Theme.spacingXS
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                        }

                        GridLayout {
                            width: parent.width
                            columns: 3
                            columnSpacing: Theme.spacingM
                            rowSpacing: Theme.spacingM

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 110
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingS

                                    Rectangle {
                                        width: 44
                                        height: 44
                                        radius: 22
                                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        DankIcon {
                                            anchors.centerIn: parent
                                            name: "device_thermostat"
                                            size: Theme.iconSize
                                            color: Theme.primary
                                        }
                                    }

                                    Column {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 2

                                        StyledText {
                                            text: "Ощущается"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        StyledText {
                                            text: (SettingsData.useFahrenheit ? (WeatherService.weather.feelsLikeF || WeatherService.weather.tempF) : (WeatherService.weather.feelsLike || WeatherService.weather.temp)) + "°"
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            font.weight: Font.Medium
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 110
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingS

                                    Rectangle {
                                        width: 44
                                        height: 44
                                        radius: 22
                                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        DankIcon {
                                            anchors.centerIn: parent
                                            name: "humidity_low"
                                            size: Theme.iconSize
                                            color: Theme.primary
                                        }
                                    }

                                    Column {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 2

                                        StyledText {
                                            text: "Влажность"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        StyledText {
                                            text: WeatherService.weather.humidity ? WeatherService.weather.humidity + "%" : "--"
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            font.weight: Font.Medium
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 110
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingS

                                    Rectangle {
                                        width: 44
                                        height: 44
                                        radius: 22
                                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        DankIcon {
                                            anchors.centerIn: parent
                                            name: "air"
                                            size: Theme.iconSize
                                            color: Theme.primary
                                        }
                                    }

                                    Column {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 2

                                        StyledText {
                                            text: "Ветер"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        StyledText {
                                            text: WeatherService.weather.wind || "--"
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            font.weight: Font.Medium
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 110
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingS

                                    Rectangle {
                                        width: 44
                                        height: 44
                                        radius: 22
                                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        DankIcon {
                                            anchors.centerIn: parent
                                            name: "speed"
                                            size: Theme.iconSize
                                            color: Theme.primary
                                        }
                                    }

                                    Column {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 2

                                        StyledText {
                                            text: "Давление"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        StyledText {
                                            text: WeatherService.weather.pressure ? WeatherService.weather.pressure + " hPa" : "--"
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            font.weight: Font.Medium
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 110
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingS

                                    Rectangle {
                                        width: 44
                                        height: 44
                                        radius: 22
                                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        DankIcon {
                                            anchors.centerIn: parent
                                            name: "rainy"
                                            size: Theme.iconSize
                                            color: Theme.primary
                                        }
                                    }

                                    Column {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 2

                                        StyledText {
                                            text: "Дождь"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        StyledText {
                                            text: WeatherService.weather.precipitationProbability ? WeatherService.weather.precipitationProbability + "%" : "0%"
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            font.weight: Font.Medium
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 110
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacingS

                                    Rectangle {
                                        width: 44
                                        height: 44
                                        radius: 22
                                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        DankIcon {
                                            anchors.centerIn: parent
                                            name: "wb_sunny"
                                            size: Theme.iconSize
                                            color: Theme.primary
                                        }
                                    }

                                    Column {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 2

                                        StyledText {
                                            text: "Видимость"
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        StyledText {
                                            text: "Хорошая"
                                            font.pixelSize: Theme.fontSizeMedium
                                            color: Theme.surfaceText
                                            font.weight: Font.Medium
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
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
        }
    }
}
