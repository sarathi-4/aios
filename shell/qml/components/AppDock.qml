import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    signal workspaceSelected(int index)
    signal appLaunched(string appId)
    signal appDrawerRequested()

    property int activeWorkspaceIndex: 0
    property string hoveredTooltip: ""

    // Dynamic sizing based on settings
    property int itemSize: globalDesktopManager.dockSize === "small" ? 36 :
                           (globalDesktopManager.dockSize === "large" ? 52 : 44)
    property int iconFontSize: globalDesktopManager.dockSize === "small" ? 16 :
                               (globalDesktopManager.dockSize === "large" ? 24 : 20)

    implicitHeight: itemSize + 20
    implicitWidth: dockRow.implicitWidth + 32
    radius: SRITECTheme.radiusDock
    color: SRITECTheme.backgroundGlassElevated
    border.color: SRITECTheme.borderSubtle
    border.width: 1

    // Tooltip bubble floating above hovered dock icon
    Rectangle {
        id: tooltipBubble
        visible: root.hoveredTooltip.length > 0
        anchors.bottom: parent.top
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: tooltipText.implicitWidth + 16
        implicitHeight: 24
        radius: 12
        color: SRITECTheme.backgroundElevated
        border.color: SRITECTheme.accentCyan
        border.width: 1

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: root.hoveredTooltip
            color: SRITECTheme.textPrimary
            font.pixelSize: 10
            font.bold: true
        }
    }

    RowLayout {
        id: dockRow
        anchors.centerIn: parent
        spacing: 10

        // 1. Applications Drawer Button (9-dot launcher)
        Rectangle {
            id: drawerBtn
            Layout.preferredWidth: root.itemSize
            Layout.preferredHeight: root.itemSize
            radius: 12
            color: drawerMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
            border.color: drawerMouse.containsMouse ? SRITECTheme.accentCyan : "transparent"
            border.width: 1
            scale: drawerMouse.containsMouse ? 1.15 : 1.0

            Behavior on scale { NumberAnimation { duration: SRITECTheme.animFast; easing.type: Easing.OutBack } }

            AIIcon {
                anchors.centerIn: parent
                iconId: "launcher"
                size: Math.round(root.itemSize * 0.72)
                showTile: false
                isHovered: drawerMouse.containsMouse
            }

            MouseArea {
                id: drawerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.hoveredTooltip = "Applications Drawer (All Apps)"
                onExited: root.hoveredTooltip = ""
                onClicked: {
                    globalAudioService.playClick();
                    root.appDrawerRequested();
                }
            }
        }

        // Divider
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: root.itemSize - 16
            color: SRITECTheme.borderSubtle
        }

        // 2. Built-in OS Workspaces
        Repeater {
            model: [
                { id: "home", name: "Desktop Space", icon: "⌂", index: 0 },
                { id: "assistant", name: "Neural Assistant", icon: "🧠", index: 1 },
                { id: "robotics", name: "Robotics Workspace (Simulation)", icon: "🤖", index: 6 },
                { id: "workspace", name: "Developer Studio", icon: "💻", index: 2 },
                { id: "settings", name: "System Settings", icon: "⚙", index: 3 }
            ]

            delegate: Rectangle {
                id: wsItem
                required property var modelData
                property bool isCurrent: root.activeWorkspaceIndex === wsItem.modelData.index
                property bool isHovered: wsMouse.containsMouse

                Layout.preferredWidth: root.itemSize
                Layout.preferredHeight: root.itemSize
                radius: 12
                color: isCurrent ? SRITECTheme.backgroundElevated : (isHovered ? SRITECTheme.backgroundHover : "transparent")
                border.color: isCurrent ? SRITECTheme.accentCyan : (isHovered ? SRITECTheme.borderSubtle : "transparent")
                border.width: 1
                scale: isHovered ? 1.15 : 1.0

                Behavior on scale { NumberAnimation { duration: SRITECTheme.animFast; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: SRITECTheme.animFast } }

                AIIcon {
                    anchors.centerIn: parent
                    iconId: wsItem.modelData.id === "workspace" ? "code" : wsItem.modelData.id
                    size: Math.round(root.itemSize * 0.70)
                    showTile: false
                    isHovered: wsMouse.containsMouse || wsItem.isCurrent
                }

                // Active dot indicator under workspace icon
                Rectangle {
                    visible: wsItem.isCurrent
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4
                    height: 4
                    radius: 2
                    color: SRITECTheme.accentCyan
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.hoveredTooltip = wsItem.modelData.name
                    onExited: root.hoveredTooltip = ""
                    onClicked: {
                        globalAudioService.playSwipe();
                        root.activeWorkspaceIndex = wsItem.modelData.index;
                        root.workspaceSelected(wsItem.modelData.index);
                    }
                }
            }
        }

        // Divider
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: root.itemSize - 16
            color: SRITECTheme.borderSubtle
        }

        // 3. Dynamic Pinned Applications
        Repeater {
            model: globalDesktopManager.pinnedApps

            delegate: Rectangle {
                id: appItem
                required property string modelData
                property var appMeta: getAppMeta(modelData)
                property bool isHovered: appMouse.containsMouse
                property bool isAvailable: globalAppLauncher.isAvailable(modelData)

                Layout.preferredWidth: root.itemSize
                Layout.preferredHeight: root.itemSize
                radius: 12
                color: isHovered ? SRITECTheme.backgroundElevated : "transparent"
                border.color: isHovered ? SRITECTheme.accentViolet : "transparent"
                border.width: 1
                scale: isHovered ? 1.15 : 1.0
                opacity: isAvailable ? 1.0 : 0.45

                Behavior on scale { NumberAnimation { duration: SRITECTheme.animFast; easing.type: Easing.OutBack } }

                AIIcon {
                    anchors.centerIn: parent
                    iconId: appItem.modelData
                    size: Math.round(root.itemSize * 0.70)
                    showTile: false
                    isHovered: appMouse.containsMouse
                    isAvailable: appItem.isAvailable
                }

                // Active running dot indicator
                Rectangle {
                    visible: globalAppLaunchManager.isAppRunning(appItem.modelData)
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4
                    height: 4
                    radius: 2
                    color: SRITECTheme.accentEmerald
                }

                MouseArea {
                    id: appMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: appItem.isAvailable ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onEntered: root.hoveredTooltip = appItem.appMeta.name + (appItem.isAvailable ? " [Launch]" : " [Not Installed]")
                    onExited: root.hoveredTooltip = ""
                    onClicked: function(mouse) {
                        globalAudioService.playClick();
                        if (mouse.button === Qt.LeftButton) {
                            var pt = appItem.mapToItem(null, 0, 0);
                            globalAppLaunchManager.requestAppLaunch(appItem.modelData, pt.x, pt.y, appItem.width, appItem.height);
                            root.appLaunched(appItem.modelData);
                        } else if (mouse.button === Qt.RightButton) {
                            dockItemContextMenu.targetAppId = appItem.modelData;
                            dockItemContextMenu.targetAppName = appItem.appMeta.name;
                            dockItemContextMenu.popup(appItem.x + mouse.x, appItem.y + mouse.y);
                        }
                    }
                }
            }
        }
    }

    // Context Menu for Pinned Dock Items
    Menu {
        id: dockItemContextMenu
        property string targetAppId: ""
        property string targetAppName: ""

        background: Rectangle {
            implicitWidth: 160
            color: SRITECTheme.backgroundGlassElevated
            radius: SRITECTheme.radiusMedium
            border.color: SRITECTheme.borderSubtle
            border.width: 1
        }

        Action {
            text: "▶  Launch"
            onTriggered: {
                globalAppLaunchManager.requestAppLaunch(dockItemContextMenu.targetAppId);
            }
        }

        Action {
            text: "📌  Unpin from Dock"
            onTriggered: {
                globalDesktopManager.unpinApp(dockItemContextMenu.targetAppId);
            }
        }
    }

    function getAppMeta(id) {
        var map = {
            "browser": { name: "Web Portal (Firefox)", icon: "🌐" },
            "terminal": { name: "Smart Terminal (Ptyxis)", icon: "⌨" },
            "files": { name: "File Manager (Nautilus)", icon: "📁" },
            "editor": { name: "Code Editor", icon: "📝" },
            "calculator": { name: "Neural Calculator", icon: "🖩" },
            "settings": { name: "System Settings", icon: "⚙" }
        };
        return map[id] || { name: id, icon: "▣" };
    }
}
