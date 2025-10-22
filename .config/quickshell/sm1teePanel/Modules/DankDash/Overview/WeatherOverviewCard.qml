import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.Common
import qs.Services
import qs.Widgets

Card {
    id: root

    signal clicked()

    Component.onCompleted: {
        WeatherService.addRef()
        Qt.callLater(() => {
            if (!WeatherService.weather.available) {
                WeatherService.forceRefresh()
            }
        })
    }
    
    Component.onDestruction: {
        WeatherService.removeRef()
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingS
        visible: !WeatherService.weather.available

        DankIcon {
            name: "cloud_off"
            size: 24
            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            text: WeatherService.weather.loading ? "Загрузка..." : "Нет данных"
            font.pixelSize: Theme.fontSizeSmall
            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        DankButton {
            text: "Обновить"
            visible: !WeatherService.weather.loading
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: WeatherService.forceRefresh()
        }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingL
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingL
        visible: WeatherService.weather.available
        
        DankIcon {
            name: WeatherService.getWeatherIcon(WeatherService.weather.wCode)
            size: 48
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Column {
            spacing: Theme.spacingXS
            anchors.verticalCenter: parent.verticalCenter
            
            StyledText {
                text: {
                    const temp = SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp;
                    if (temp === undefined || temp === null) {
                        return "--°" + (SettingsData.useFahrenheit ? "F" : "C");
                    }
                    return temp + "°" + (SettingsData.useFahrenheit ? "F" : "C");
                }
                font.pixelSize: Theme.fontSizeXLarge + 4
                color: Theme.surfaceText
                font.weight: Font.Light
            }
            
            StyledText {
                text: WeatherService.getWeatherCondition(WeatherService.weather.wCode)
                font.pixelSize: Theme.fontSizeSmall
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                elide: Text.ElideRight
                width: parent.parent.parent.width - 48 - Theme.spacingL * 2
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}