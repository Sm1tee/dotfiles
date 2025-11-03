import QtQuick
import QtQuick.Effects
import Quickshell.Io
import qs.Common
import qs.Modals.Common
import qs.Modals.FileBrowser
import qs.Modules.Settings
import qs.Services
import qs.Widgets

Modal {
    id: settingsModal

    property Component settingsContent
    property alias profileBrowser: profileBrowser

    signal closingModal()

    function show() {
        open();
    }

    function hide() {
        close();
    }

    function toggle() {
        if (shouldBeVisible) {
            hide();
        } else {
            show();
        }
    }

    objectName: "settingsModal"
    width: Math.max(800, Math.min(1200, 800 * SettingsData.fontScale))
    height: Math.max(800, Math.min(1000, 800 * SettingsData.fontScale))
    visible: false
    onBackgroundClicked: () => {
        return hide();
    }
    content: settingsContent

    IpcHandler {
        function open(): string {
            settingsModal.show();
            return "SETTINGS_OPEN_SUCCESS";
        }

        function close(): string {
            settingsModal.hide();
            return "SETTINGS_CLOSE_SUCCESS";
        }

        function toggle(): string {
            settingsModal.toggle();
            return "SETTINGS_TOGGLE_SUCCESS";
        }

        target: "settings"
    }

    IpcHandler {
        function browse(type: string) {
            if (type === "wallpaper") {
                wallpaperBrowser.allowStacking = false;
                wallpaperBrowser.open();
            } else if (type === "profile") {
                profileBrowser.allowStacking = false;
                profileBrowser.open();
            }
        }

        target: "file"
    }

    Connections {
        target: PortalService
        
        function onProfileImageUpdateCompleted() {
            // Восстанавливаем окно настроек после завершения обновления аватарки
            settingsModal.visible = true;
        }
    }

    FileBrowserModal {
        id: profileBrowser

        allowStacking: true
        parentModal: settingsModal
        browserTitle: "Select Profile Image"
        browserIcon: "person"
        browserType: "profile"
        fileExtensions: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
        onFileSelected: (path) => {
            // Временно скрываем окно настроек, чтобы не перекрывать диалог pkexec
            settingsModal.visible = false;
            PortalService.setProfileImage(path);
            close();
        }
        onDialogClosed: () => {
            allowStacking = true;
        }
    }

    FileBrowserModal {
        id: wallpaperBrowser

        allowStacking: true
        parentModal: settingsModal
        browserTitle: "Select Wallpaper"
        browserIcon: "wallpaper"
        browserType: "wallpaper"
        fileExtensions: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
        onFileSelected: (path) => {
            SessionData.setWallpaper(path);
            close();
        }
        onDialogClosed: () => {
            allowStacking = true;
        }
    }

    settingsContent: Component {
        FocusScope {
            anchors.fill: parent
            focus: true

            Column {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingL
                anchors.rightMargin: Theme.spacingL
                anchors.topMargin: Theme.spacingM
                anchors.bottomMargin: Theme.spacingL
                spacing: 0

                Item {
                    width: parent.width
                    height: 35

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingM

                        Icon {
                            name: "settings"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Настройки"
                            font.pixelSize: Theme.fontSizeXLarge
                            color: Theme.surfaceText
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                    ActionButton {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        circular: false
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        onClicked: () => {
                            return settingsModal.hide();
                        }
                    }

                }

                Row {
                    width: parent.width
                    height: parent.height - 35
                    spacing: 0

                    SettingsSidebar {
                        id: sidebar

                        parentModal: settingsModal
                        onCurrentIndexChanged: content.currentIndex = currentIndex
                    }

                    SettingsContent {
                        id: content

                        width: parent.width - sidebar.width
                        height: parent.height
                        parentModal: settingsModal
                        currentIndex: sidebar.currentIndex
                    }

                }

            }

        }

    }

}
