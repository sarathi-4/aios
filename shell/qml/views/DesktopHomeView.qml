import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"
import "../components"

Item {
    id: root

    signal requestWorkspace(int index)
    signal appLaunched(string appId)

    // 1. Spatial Desktop Icon Layer (Draggable items, folders, shortcuts, right-click context menu)
    DesktopIconGrid {
        id: desktopIconGrid
        anchors.fill: parent
        onRequestOpenSettings: root.requestWorkspace(3)
        onRequestChangeWallpaper: root.requestWorkspace(3)
    }

    // 2. Central Spatial AI Nexus (Holographic Avatar + Omnibar + Action Chips)
    Item {
        id: aiNexus
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 680)
        height: 520

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            width: parent.width

            // The Holographic AI Avatar Core (Focal Point)
            HolographicAvatar {
                id: aiAvatar
                Layout.alignment: Qt.AlignHCenter
                onAvatarClicked: {
                    omnibarInput.forceActiveFocus();
                }
            }

            // Universal AI Omnibar ("Ask anything. Automate anything. Search anything.")
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(parent.width, 640)
                Layout.preferredHeight: 52
                radius: 26
                color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                border.color: omnibarInput.activeFocus ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: SRITECTheme.animFast } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 12
                    spacing: 12

                    Text {
                        text: "✦"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 16
                    }

                    TextField {
                        id: omnibarInput
                        Layout.fillWidth: true
                        placeholderText: "Ask anything. Automate anything. Search system..."
                        placeholderTextColor: SRITECTheme.textTertiary
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 13
                        font.family: SRITECTheme.fontUI
                        background: null
                        onAccepted: root.processCommand(text.trim())
                    }

                    // Clear / Stop or Execute Button
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 34
                        radius: 17
                        color: globalAIBridge.isGenerating ? SRITECTheme.accentCrimson : SRITECTheme.accentCyan

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                text: globalAIBridge.isGenerating ? "■" : "▶"
                                color: SRITECTheme.backgroundVoid
                                font.pixelSize: 10
                            }
                            Text {
                                text: globalAIBridge.isGenerating ? "Stop" : "Synthesize"
                                color: SRITECTheme.backgroundVoid
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (globalAIBridge.isGenerating) {
                                    globalAIBridge.cancelStream();
                                } else {
                                    root.processCommand(omnibarInput.text.trim());
                                }
                            }
                        }
                    }
                }
            }

            // Quick AI Action Chips
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                Repeater {
                    model: [
                        { name: "⚡ System Health", action: "health" },
                        { name: "🤖 Robotics Space", action: "robotics" },
                        { name: "⌨ Smart Terminal", action: "terminal" },
                        { name: "🌐 Launch Firefox", action: "browser" },
                        { name: "📁 Spatial Files", action: "files" },
                        { name: "🧠 Switch AI Provider", action: "provider" }
                    ]

                    delegate: Rectangle {
                        id: chipBtn
                        required property var modelData
                        property bool isHovered: chipMouse.containsMouse

                        Layout.preferredHeight: 28
                        Layout.preferredWidth: chipText.implicitWidth + 20
                        radius: 14
                        color: isHovered ? Qt.rgba(0/255, 229/255, 255/255, 0.18) : Qt.rgba(19/255, 26/255, 40/255, 0.6)
                        border.color: isHovered ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: SRITECTheme.animFast } }

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: chipBtn.modelData.name
                            color: chipBtn.isHovered ? SRITECTheme.accentCyan : SRITECTheme.textSecondary
                            font.pixelSize: 10
                            font.bold: true
                        }

                        MouseArea {
                            id: chipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var act = chipBtn.modelData.action;
                                var pt = chipBtn.mapToItem(null, 0, 0);
                                if (act === "health") {
                                    globalAppLaunchManager.requestAppLaunch("monitor", pt.x, pt.y, chipBtn.width, chipBtn.height);
                                } else if (act === "robotics") {
                                    globalAppLaunchManager.requestAppLaunch("robotics", pt.x, pt.y, chipBtn.width, chipBtn.height);
                                } else if (act === "terminal") {
                                    globalAppLaunchManager.requestAppLaunch("terminal", pt.x, pt.y, chipBtn.width, chipBtn.height);
                                } else if (act === "browser") {
                                    globalAppLaunchManager.requestAppLaunch("firefox", pt.x, pt.y, chipBtn.width, chipBtn.height);
                                } else if (act === "files") {
                                    globalAppLaunchManager.requestAppLaunch("files", pt.x, pt.y, chipBtn.width, chipBtn.height);
                                } else if (act === "provider") {
                                    globalAppLaunchManager.requestAppLaunch("settings", pt.x, pt.y, chipBtn.width, chipBtn.height);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function processCommand(rawInput) {
        if (!rawInput || rawInput.length === 0) return;

        var cmd = rawInput.toLowerCase();

        // Direct command evaluation
        if (cmd.indexOf("open terminal") !== -1 || cmd === "terminal") {
            globalAppLaunchManager.requestAppLaunch("terminal");
            omnibarInput.text = "";
            return;
        } else if (cmd.indexOf("open browser") !== -1 || cmd.indexOf("launch browser") !== -1 || cmd.indexOf("firefox") !== -1) {
            globalAppLaunchManager.requestAppLaunch("firefox");
            omnibarInput.text = "";
            return;
        } else if (cmd.indexOf("open files") !== -1 || cmd.indexOf("file manager") !== -1) {
            globalAppLaunchManager.requestAppLaunch("files");
            omnibarInput.text = "";
            return;
        } else if (cmd.indexOf("open settings") !== -1 || cmd === "settings") {
            globalAppLaunchManager.requestAppLaunch("settings");
            omnibarInput.text = "";
            return;
        } else if (cmd.indexOf("calculator") !== -1 || cmd === "calc") {
            globalAppLaunchManager.requestAppLaunch("calculator");
            omnibarInput.text = "";
            return;
        } else if (cmd.indexOf("system status") !== -1 || cmd === "telemetry" || cmd === "monitor") {
            globalAppLaunchManager.requestAppLaunch("monitor");
            omnibarInput.text = "";
            return;
        } else if (cmd.indexOf("code") !== -1 || cmd === "editor") {
            globalAppLaunchManager.requestAppLaunch("editor");
            omnibarInput.text = "";
            return;
        } else if (cmd.indexOf("robot") !== -1 || cmd.indexOf("robotics") !== -1) {
            globalAppLaunchManager.requestAppLaunch("robotics");
            omnibarInput.text = "";
            return;
        }

        // Dispatch natural language query to the AI Gateway
        globalAIBridge.generateStream(rawInput);
        omnibarInput.text = "";
    }
}
