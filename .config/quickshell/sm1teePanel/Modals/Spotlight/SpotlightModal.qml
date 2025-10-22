import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.Modals.Common
import qs.Modules.AppDrawer
import qs.Services
import qs.Widgets

DankModal {
    id: spotlightModal

    property bool spotlightOpen: false
    property Component spotlightContent

    function show() {
        spotlightOpen = true
        open()

        Qt.callLater(() => {
            if (contentLoader.item) {
                // Сбрасываем состояние после открытия
                if (contentLoader.item.appLauncher) {
                    contentLoader.item.appLauncher.searchQuery = ""
                    contentLoader.item.appLauncher.selectedIndex = 0
                    contentLoader.item.appLauncher.setCategory("Все")
                    // Принудительно обновляем модель
                    contentLoader.item.appLauncher.updateFilteredModel()
                }
                if (contentLoader.item.searchField) {
                    contentLoader.item.searchField.text = ""
                    contentLoader.item.searchField.forceActiveFocus()
                }
                if (contentLoader.item.resetScroll) {
                    contentLoader.item.resetScroll()
                }
            }
        })
    }

    function hide() {
        spotlightOpen = false
        close()
    }

    onDialogClosed: {
        // Не очищаем здесь, чтобы избежать проблем с таймингом
        // Очистка происходит в show() перед открытием
    }

    function toggle() {
        if (spotlightOpen) {
            hide()
        } else {
            show()
        }
    }

    shouldBeVisible: spotlightOpen
    width: Math.max(550, Math.min(750, 550 * SettingsData.fontScale))
    height: Math.max(700, Math.min(900, 700 * SettingsData.fontScale))
    backgroundColor: Theme.popupBackground()
    cornerRadius: Theme.cornerRadius
    borderColor: Theme.outlineMedium
    borderWidth: 1
    enableShadow: true
    keepContentLoaded: true
    onVisibleChanged: () => {
                          if (visible && !spotlightOpen) {
                              show()
                          }
                          if (visible && contentLoader.item) {
                              Qt.callLater(() => {
                                               if (contentLoader.item.searchField) {
                                                   contentLoader.item.searchField.forceActiveFocus()
                                               }
                                           })
                          }
                      }
    onBackgroundClicked: () => {
                             return hide()
                         }
    content: spotlightContent

    Connections {
        function onCloseAllModalsExcept(excludedModal) {
            if (excludedModal !== spotlightModal && !allowStacking && spotlightOpen) {
                spotlightOpen = false
            }
        }

        target: ModalManager
    }

    IpcHandler {
        function open(): string  {
            spotlightModal.show()
            return "SPOTLIGHT_OPEN_SUCCESS"
        }

        function close(): string  {
            spotlightModal.hide()
            return "SPOTLIGHT_CLOSE_SUCCESS"
        }

        function toggle(): string  {
            spotlightModal.toggle()
            return "SPOTLIGHT_TOGGLE_SUCCESS"
        }

        target: "spotlight"
    }

    spotlightContent: Component {
        SpotlightContent {
            parentModal: spotlightModal
        }
    }
}
