import QtQuick
import qs.Common
import qs.Modules.Settings

FocusScope {
    id: root

    property int currentIndex: 0
    property var parentModal: null
    focus: true

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: Theme.spacingS
        anchors.bottomMargin: Theme.spacingM
        anchors.topMargin: 0
        color: "transparent"

        Loader {
            id: timeWeatherLoader

            anchors.fill: parent
            active: root.currentIndex === 0
            visible: active
            asynchronous: true

            sourceComponent: TimeWeatherTab {
            }

        }

        Loader {
            id: personalizationLoader

            anchors.fill: parent
            active: root.currentIndex === 1
            visible: active
            asynchronous: true

            sourceComponent: Component {
                PersonalizationTab {
                    parentModal: root.parentModal
                }

            }

        }

        Loader {
            id: displaysLoader

            anchors.fill: parent
            active: root.currentIndex === 2
            visible: active
            asynchronous: true

            sourceComponent: DisplaysTab {
            }

        }

        Loader {
            id: topBarLoader

            anchors.fill: parent
            active: root.currentIndex === 3
            visible: active
            asynchronous: true

            sourceComponent: DankBarTab {
                parentModal: root.parentModal
            }

        }

        Loader {
            id: dockLoader

            anchors.fill: parent
            active: root.currentIndex === 4
            visible: active
            asynchronous: true

            sourceComponent: DockTab {
            }

        }

        Loader {
            id: widgetsLoader

            anchors.fill: parent
            active: root.currentIndex === 5
            visible: active
            asynchronous: true

            sourceComponent: WidgetTweaksTab {
            }

        }

        Loader {
            id: powerLoader

            anchors.fill: parent
            active: root.currentIndex === 6
            visible: active
            asynchronous: true

            sourceComponent: PowerSettings {
            }

        }

        Loader {
            id: pluginsLoader

            anchors.fill: parent
            active: root.currentIndex === 7
            visible: active
            asynchronous: true

            sourceComponent: PluginsTab {
                parentModal: root.parentModal
            }

        }

    }

}
