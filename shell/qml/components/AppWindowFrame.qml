import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"
import "../views"
import "../views/internal"

Rectangle {
    id: root

    required property var windowData

    property bool isFocused: windowData ? windowData.isFocused : false
    property bool isMaximized: windowData ? windowData.isMaximized : false
    property color winAccent: windowData && windowData.accentColor ? windowData.accentColor : SRITECTheme.accentCyan

    x: windowData ? windowData.x : 100
    y: windowData ? windowData.y : 100
    width: windowData ? windowData.width : 880
    height: windowData ? windowData.height : 560
    z: windowData ? windowData.zOrder : 10
    visible: windowData ? !windowData.isMinimized : true

    radius: isMaximized ? 0 : SRITECTheme.radiusLarge
    color: Qt.rgba(13/255, 17/255, 26/255, 0.92)
    border.color: root.isFocused ? root.winAccent : SRITECTheme.borderSubtle
    border.width: root.isFocused ? 1.5 : 1
    clip: true

    // Ambient Halo Glow when Focused
    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        radius: parent.radius + 3
        color: "transparent"
        border.color: root.winAccent
        border.width: 1
        opacity: root.isFocused ? 0.35 : 0.0
        z: -1
        Behavior on opacity { NumberAnimation { duration: SRITECTheme.animFast } }
    }

    // Window Closing Scale/Fade Animation
    ParallelAnimation {
        id: closeAnimation
        NumberAnimation { target: root; property: "scale"; to: 0.4; duration: 220; easing.type: Easing.InBack }
        NumberAnimation { target: root; property: "opacity"; to: 0.0; duration: 200; easing.type: Easing.InQuad }
        onFinished: {
            if (root.windowData) {
                globalAppLaunchManager.closeWindow(root.windowData.windowId);
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. Sleek Floating Window Titlebar
        Rectangle {
            id: titleBar
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: root.isFocused ? Qt.rgba(19/255, 26/255, 40/255, 0.95) : Qt.rgba(13/255, 17/255, 26/255, 0.85)
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 10

                // App Icon
                AIIcon {
                    iconId: root.windowData ? root.windowData.iconId : "ai_core"
                    size: 20
                    showTile: false
                    isHovered: root.isFocused
                }

                // Window Title
                Text {
                    text: root.windowData ? root.windowData.title : "Application Window"
                    color: root.isFocused ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 0.8
                }

                // Status Pill
                Rectangle {
                    Layout.preferredHeight: 18
                    Layout.preferredWidth: statusRow.implicitWidth + 12
                    radius: 9
                    color: Qt.rgba(0/255, 245/255, 160/255, 0.15)
                    border.color: SRITECTheme.accentEmerald
                    border.width: 1

                    RowLayout {
                        id: statusRow
                        anchors.centerIn: parent
                        spacing: 4
                        Rectangle { Layout.preferredWidth: 4; Layout.preferredHeight: 4; radius: 2; color: SRITECTheme.accentEmerald }
                        Text { text: "SANDBOXED"; color: SRITECTheme.accentEmerald; font.pixelSize: 8; font.bold: true; font.family: SRITECTheme.fontMono }
                    }
                }

                Item { Layout.fillWidth: true }

                // Window Action Control Buttons (Minimize, Maximize, Close)
                RowLayout {
                    id: windowControlsRow
                    z: 10
                    spacing: 6

                    // Minimize
                    Rectangle {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        radius: 6
                        color: minMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                        border.color: minMouse.containsMouse ? SRITECTheme.accentCyan : "transparent"
                        border.width: 1

                        Text { anchors.centerIn: parent; text: "—"; color: SRITECTheme.textSecondary; font.pixelSize: 10; font.bold: true }

                        MouseArea {
                            id: minMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playSwipe();
                                if (root.windowData) {
                                    globalAppLaunchManager.minimizeWindow(root.windowData.windowId);
                                }
                            }
                        }
                    }

                    // Maximize / Restore
                    Rectangle {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        radius: 6
                        color: maxMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                        border.color: maxMouse.containsMouse ? SRITECTheme.accentCyan : "transparent"
                        border.width: 1

                        Text { anchors.centerIn: parent; text: root.isMaximized ? "❐" : "□"; color: SRITECTheme.textSecondary; font.pixelSize: 11 }

                        MouseArea {
                            id: maxMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                if (root.windowData) {
                                    globalAppLaunchManager.toggleMaximizeWindow(root.windowData.windowId);
                                }
                            }
                        }
                    }

                    // Close
                    Rectangle {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        radius: 6
                        color: closeMouse.containsMouse ? Qt.rgba(255/255, 59/255, 92/255, 0.25) : "transparent"
                        border.color: closeMouse.containsMouse ? SRITECTheme.accentCrimson : "transparent"
                        border.width: 1

                        Text { anchors.centerIn: parent; text: "✕"; color: closeMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.textSecondary; font.pixelSize: 10; font.bold: true }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                closeAnimation.restart();
                            }
                        }
                    }
                }
            }

            // Dragging Window via Titlebar (Leaves 110px for window control buttons)
            MouseArea {
                id: dragArea
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 110
                z: 1
                acceptedButtons: Qt.LeftButton
                property real dragStartX: 0
                property real dragStartY: 0

                onPressed: function(mouse) {
                    if (root.windowData) {
                        globalAppLaunchManager.focusWindow(root.windowData.windowId);
                    }
                    dragStartX = mouse.x;
                    dragStartY = mouse.y;
                }

                onPositionChanged: function(mouse) {
                    if (!root.isMaximized && pressed && root.windowData) {
                        var newX = root.x + (mouse.x - dragStartX);
                        var newY = root.y + (mouse.y - dragStartY);
                        globalAppLaunchManager.updateWindowGeometry(root.windowData.windowId, newX, newY, root.width, root.height);
                    }
                }

                onDoubleClicked: {
                    if (root.windowData) {
                        globalAppLaunchManager.toggleMaximizeWindow(root.windowData.windowId);
                    }
                }
            }
        }

        // 2. Window Content View (Dynamic View Dispatcher)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Loader {
                id: contentLoader
                anchors.fill: parent
                sourceComponent: {
                    var id = root.windowData ? root.windowData.appId : "";
                    if (id === "files") return filesComp;
                    if (id === "terminal") return terminalComp;
                    if (id === "calculator") return calcComp;
                    if (id === "settings") return settingsComp;
                    if (id === "monitor") return monitorComp;
                    if (id === "editor" || id === "vscode" || id === "antigravity" || id === "android_studio") return editorComp;
                    if (id === "robotics") return roboticsComp;
                    if (id === "assistant") return assistantComp;
                    if (id === "browser" || id === "firefox" || id === "chrome") return browserComp;
                    if (id === "chatgpt") return chatgptComp;
                    if (id === "gemini") return geminiComp;
                    if (id === "claude") return claudeComp;
                    return genericComp;
                }
            }

            Component { id: filesComp; SpatialFilesView {} }
            Component { id: terminalComp; SmartTerminalView { windowId: root.windowData ? root.windowData.windowId : "" } }
            Component { id: calcComp; NeuralCalculatorView {} }
            Component { id: settingsComp; SettingsView {} }
            Component { id: monitorComp; SystemMonitorView {} }
            Component { id: editorComp; CodeStudioView { initialAppId: root.windowData ? root.windowData.appId : "editor" } }
            Component { id: roboticsComp; RoboticsWorkspaceView { onBackToDesktopRequested: closeAnimation.restart() } }
            Component { id: assistantComp; AIAssistantView {} }
            Component { id: browserComp; NebulaBrowserView {} }
            Component { id: chatgptComp; NebulaBrowserView { initialPortal: "chatgpt" } }
            Component { id: geminiComp; NebulaBrowserView { initialPortal: "gemini" } }
            Component { id: claudeComp; NebulaBrowserView { initialPortal: "claude" } }

            Component {
                id: genericComp
                Rectangle {
                    color: SRITECTheme.backgroundSurface
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 14
                        AIIcon { Layout.alignment: Qt.AlignHCenter; iconId: root.windowData ? root.windowData.iconId : "ai_core"; size: 64; showTile: true }
                        Text { Layout.alignment: Qt.AlignHCenter; text: root.windowData ? root.windowData.title : "Application"; color: SRITECTheme.textPrimary; font.pixelSize: 16; font.bold: true }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Not yet available inside NEBULA\nExternal host processes are suppressed to maintain internal workspace immersion."
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 11
                            font.family: SRITECTheme.fontMono
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    // Raise window to front on click anywhere
    MouseArea {
        anchors.fill: parent
        z: -1
        onPressed: {
            if (root.windowData) {
                globalAppLaunchManager.focusWindow(root.windowData.windowId);
            }
        }
    }

    // 8-Direction Resizing Handles (When not maximized)
    // Bottom-Right Corner
    MouseArea {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 14; height: 14
        cursorShape: Qt.SizeFDiagCursor
        visible: !root.isMaximized
        property real startW: 0; property real startH: 0; property real startX: 0; property real startY: 0
        onPressed: function(m) { startW = root.width; startH = root.height; startX = m.x; startY = m.y; }
        onPositionChanged: function(m) {
            if (pressed && root.windowData) {
                globalAppLaunchManager.updateWindowGeometry(root.windowData.windowId, root.x, root.y, startW + (m.x - startX), startH + (m.y - startY));
            }
        }
    }

    // Right Edge
    MouseArea {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 40; anchors.bottomMargin: 14
        width: 8
        cursorShape: Qt.SizeHorCursor
        visible: !root.isMaximized
        property real startW: 0; property real startX: 0
        onPressed: function(m) { startW = root.width; startX = m.x; }
        onPositionChanged: function(m) {
            if (pressed && root.windowData) {
                globalAppLaunchManager.updateWindowGeometry(root.windowData.windowId, root.x, root.y, startW + (m.x - startX), root.height);
            }
        }
    }

    // Bottom Edge
    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 14; anchors.rightMargin: 14
        height: 8
        cursorShape: Qt.SizeVerCursor
        visible: !root.isMaximized
        property real startH: 0; property real startY: 0
        onPressed: function(m) { startH = root.height; startY = m.y; }
        onPositionChanged: function(m) {
            if (pressed && root.windowData) {
                globalAppLaunchManager.updateWindowGeometry(root.windowData.windowId, root.x, root.y, root.width, startH + (m.y - startY));
            }
        }
    }
}
