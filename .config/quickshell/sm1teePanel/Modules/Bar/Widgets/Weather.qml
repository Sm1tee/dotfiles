import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    property bool isVertical: axis?.isVertical ?? false
    property var axis: null
    property string section: "center"
    property var popupTarget: null
    property var parentScreen: null
    property real barThickness: 48
    property real widgetThickness: 30
    readonly property real horizontalPadding: SettingsData.barNoBackground ? 2 : Theme.baseSpacingS

    signal clicked()

    visible: SettingsData.weatherEnabled
    width: isVertical ? widgetThickness : (visible ? Math.min(100, weatherRow.implicitWidth + horizontalPadding * 2) : 0)
    height: isVertical ? (weatherColumn.implicitHeight + horizontalPadding * 2) : widgetThickness
    radius: SettingsData.barNoBackground ? 0 : Theme.cornerRadius
    color: {
        if (SettingsData.barNoBackground) {
            return "transparent";
        }

        const baseColor = weatherArea.containsMouse ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor;
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency);
    }

    Ref {
        service: WeatherService
    }

    Column {
        id: weatherColumn
        visible: root.isVertical
        anchors.centerIn: parent
        spacing: 1

        Item {
            width: Theme.barIconSize(barThickness, -6)
            height: Theme.barIconSize(barThickness, -6)
            anchors.horizontalCenter: parent.horizontalCenter
            
            Icon {
                name: {
                    if (WeatherService.weather.loading && !WeatherService.weather.available) {
                        return "hourglass_empty"
                    }
                    return WeatherService.getWeatherIcon(WeatherService.weather.wCode)
                }
                size: Theme.barIconSize(barThickness, -6)
                color: Theme.primary
                anchors.centerIn: parent
            }
            
            rotation: WeatherService.weather.loading && !WeatherService.weather.available ? rotationValue : 0
            
            property real rotationValue: 0
            
            RotationAnimation on rotationValue {
                running: WeatherService.weather.loading && !WeatherService.weather.available
                from: 0
                to: 360
                duration: 2000
                loops: Animation.Infinite
            }
        }

        StyledText {
            text: {
                if (WeatherService.weather.loading && !WeatherService.weather.available) {
                    return "...";
                }
                
                const temp = SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp;
                if (temp === undefined || temp === null || temp === 0) {
                    return "--";
                }
                return temp;
            }
            font.pixelSize: Theme.barTextSize(barThickness)
            color: Theme.surfaceText
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Row {
        id: weatherRow

        visible: !root.isVertical
        anchors.centerIn: parent
        spacing: Theme.baseSpacingXS

        Item {
            width: Theme.barIconSize(barThickness, -6)
            height: Theme.barIconSize(barThickness, -6)
            anchors.verticalCenter: parent.verticalCenter
            
            Icon {
                name: {
                    if (WeatherService.weather.loading && !WeatherService.weather.available) {
                        return "hourglass_empty"
                    }
                    return WeatherService.getWeatherIcon(WeatherService.weather.wCode)
                }
                size: Theme.barIconSize(barThickness, -6)
                color: Theme.primary
                anchors.centerIn: parent
            }
            
            rotation: WeatherService.weather.loading && !WeatherService.weather.available ? rotationValue : 0
            
            property real rotationValue: 0
            
            RotationAnimation on rotationValue {
                running: WeatherService.weather.loading && !WeatherService.weather.available
                from: 0
                to: 360
                duration: 2000
                loops: Animation.Infinite
            }
        }

        StyledText {
            text: {
                if (WeatherService.weather.loading && !WeatherService.weather.available) {
                    return "...";
                }
                
                const temp = SettingsData.useFahrenheit ? WeatherService.weather.tempF : WeatherService.weather.temp;
                if (temp === undefined || temp === null || temp === 0) {
                    return "--°" + (SettingsData.useFahrenheit ? "F" : "C");
                }

                return temp + "°" + (SettingsData.useFahrenheit ? "F" : "C");
            }
            font.pixelSize: Theme.barTextSize(barThickness)
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
        }

    }

    MouseArea {
        id: weatherArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: {
            if (popupTarget && popupTarget.setTriggerPosition) {
                const globalPos = mapToGlobal(0, 0)
                const currentScreen = parentScreen || Screen
                const pos = SettingsData.getPopupTriggerPosition(globalPos, currentScreen, barThickness, width)
                popupTarget.setTriggerPosition(pos.x, pos.y, pos.width, section, currentScreen)
            }
            root.clicked();
        }
    }


    Behavior on width {
        NumberAnimation {
            duration: Theme.shortDuration
            easing.type: Theme.standardEasing
        }

    }

}
