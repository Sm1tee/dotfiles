import QtQuick
import QtQuick.Effects
import qs.Common
import qs.Services
import qs.Widgets

Card {
    id: root

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingM
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingM

        DankCircularImage {
            id: avatarContainer

            width: 77
            height: 77
            anchors.verticalCenter: parent.verticalCenter
            imageSource: {
                if (PortalService.profileImage === "")
                    return ""

                if (PortalService.profileImage.startsWith("/"))
                    return "file://" + PortalService.profileImage

                return PortalService.profileImage
            }
            fallbackIcon: "person"
        }

        Column {
            spacing: Theme.spacingS
            anchors.verticalCenter: parent.verticalCenter
            width: root.width - avatarContainer.width - Theme.spacingM * 3

            StyledText {
                text: UserInfoService.username || "brandon"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Medium
                color: Theme.surfaceText
                elide: Text.ElideRight
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingXS

                DankIcon {
                    name: "schedule"
                    size: 16
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    id: uptimeText

                    property real longTextWidth: {
                        const fontSize = Math.round(Theme.fontSizeSmall || 12)
                        const testMetrics = Qt.createQmlObject('import QtQuick; TextMetrics { font.pixelSize: ' + fontSize + ' }', uptimeText)
                        testMetrics.text = UserInfoService.uptime || "работает 1 час, 23 минуты"
                        const result = testMetrics.width
                        testMetrics.destroy()
                        return result
                    }
                    property bool shouldUseShort: longTextWidth > (parent.parent.width - 16 - Theme.spacingXS)
                    
                    text: shouldUseShort ? UserInfoService.shortUptime : UserInfoService.uptime || "работает 1ч 23м"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }
            }
        }
    }
}