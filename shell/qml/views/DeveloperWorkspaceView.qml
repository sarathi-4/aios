import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"
import "../components"

Rectangle {
    id: root

    color: "transparent"

    property string activeMode: globalDevWorkstation ? globalDevWorkstation.activeMode : "overview"
    property var selectedChangeId: ""
    property var selectedChangeDetails: null
    property string activeNotification: ""

    function inspectChange(changeId) {
        root.selectedChangeId = changeId;
        if (globalDevWorkstation) {
            root.selectedChangeDetails = globalDevWorkstation.getChangeDetails(changeId);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // =====================================================================
        // 1. Top Developer Toolbar & Workspace Mode Switcher
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            radius: SRITECTheme.radiusMedium
            color: Qt.rgba(13/255, 17/255, 26/255, 0.90)
            border.color: SRITECTheme.accentCyan
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                // Workspace Mode Pills
                RowLayout {
                    spacing: 4

                    Rectangle {
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: modeOvText.implicitWidth + 24
                        radius: 6
                        color: root.activeMode === "overview" ? Qt.rgba(0/255, 229/255, 255/255, 0.25) : "transparent"
                        border.color: root.activeMode === "overview" ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "◈"; color: SRITECTheme.accentCyan; font.pixelSize: 11 }
                            Text { id: modeOvText; text: "OVERVIEW"; color: root.activeMode === "overview" ? SRITECTheme.textPrimary : SRITECTheme.textSecondary; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.activeMode = "overview";
                                if (globalDevWorkstation) globalDevWorkstation.activeMode = "overview";
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: modeVsText.implicitWidth + 24
                        radius: 6
                        color: root.activeMode === "vscode" ? Qt.rgba(59/255, 130/255, 246/255, 0.25) : "transparent"
                        border.color: root.activeMode === "vscode" ? SRITECTheme.accentBlue : SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "⚡"; color: SRITECTheme.accentBlue; font.pixelSize: 11 }
                            Text { id: modeVsText; text: "VS CODE WORKSPACE"; color: root.activeMode === "vscode" ? SRITECTheme.textPrimary : SRITECTheme.textSecondary; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.activeMode = "vscode";
                                if (globalDevWorkstation) globalDevWorkstation.activeMode = "vscode";
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: modeAgText.implicitWidth + 24
                        radius: 6
                        color: root.activeMode === "antigravity" ? Qt.rgba(139/255, 92/255, 246/255, 0.25) : "transparent"
                        border.color: root.activeMode === "antigravity" ? SRITECTheme.accentViolet : SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "✦"; color: SRITECTheme.accentViolet; font.pixelSize: 11 }
                            Text { id: modeAgText; text: "ANTIGRAVITY WORKSPACE"; color: root.activeMode === "antigravity" ? SRITECTheme.textPrimary : SRITECTheme.textSecondary; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.activeMode = "antigravity";
                                if (globalDevWorkstation) globalDevWorkstation.activeMode = "antigravity";
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: modeAsText.implicitWidth + 24
                        radius: 6
                        color: root.activeMode === "android_studio" ? Qt.rgba(0/255, 245/255, 160/255, 0.25) : "transparent"
                        border.color: root.activeMode === "android_studio" ? SRITECTheme.accentEmerald : SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "🤖"; font.pixelSize: 11 }
                            Text { id: modeAsText; text: "ANDROID STUDIO"; color: root.activeMode === "android_studio" ? SRITECTheme.textPrimary : SRITECTheme.textSecondary; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.activeMode = "android_studio";
                                if (globalDevWorkstation) globalDevWorkstation.activeMode = "android_studio";
                            }
                        }
                    }
                }

                Rectangle { Layout.preferredHeight: 24; Layout.preferredWidth: 1; color: SRITECTheme.borderSubtle }

                // Quick Action Buttons
                RowLayout {
                    spacing: 6

                    // Build Target
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: bldRow.implicitWidth + 14
                        radius: 4
                        color: SRITECTheme.accentCyan

                        RowLayout {
                            id: bldRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "▶"; color: SRITECTheme.backgroundVoid; font.pixelSize: 9 }
                            Text { text: globalDevWorkstation && globalDevWorkstation.isBuilding ? "Building..." : "Build"; color: SRITECTheme.backgroundVoid; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (globalDevWorkstation) globalDevWorkstation.buildProject("all")
                        }
                    }

                    // Run Project
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: 50
                        radius: 4
                        color: Qt.rgba(0/255, 245/255, 160/255, 0.15)
                        border.color: SRITECTheme.accentEmerald
                        border.width: 1

                        Text { anchors.centerIn: parent; text: "⚡ Run"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.bold: true }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (globalDevWorkstation) globalDevWorkstation.runProject()
                        }
                    }

                    // Git Status Action
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: gitRow.implicitWidth + 12
                        radius: 4
                        color: Qt.rgba(59/255, 130/255, 246/255, 0.15)
                        border.color: SRITECTheme.accentBlue
                        border.width: 1

                        RowLayout {
                            id: gitRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "⎇"; color: SRITECTheme.accentBlue; font.pixelSize: 10 }
                            Text { text: globalDevWorkstation ? globalDevWorkstation.activeBranch : "main"; color: SRITECTheme.accentBlue; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (globalDevWorkstation) globalDevWorkstation.refreshGitStatus()
                        }
                    }

                    // Docker Status Probe
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: docRow.implicitWidth + 12
                        radius: 4
                        color: "transparent"
                        border.color: SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            id: docRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "🐳"; font.pixelSize: 10 }
                            Text { text: "Docker"; color: SRITECTheme.textSecondary; font.pixelSize: 10 }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (globalDevWorkstation) {
                                    var res = globalDevWorkstation.checkToolStatus("docker");
                                    root.activeNotification = res.message;
                                }
                            }
                        }
                    }

                    // AWS CLI Status Probe
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: awsRow.implicitWidth + 12
                        radius: 4
                        color: "transparent"
                        border.color: SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            id: awsRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "☁"; font.pixelSize: 10 }
                            Text { text: "AWS"; color: SRITECTheme.textSecondary; font.pixelSize: 10 }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (globalDevWorkstation) {
                                    var res = globalDevWorkstation.checkToolStatus("aws");
                                    root.activeNotification = res.message;
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Code Studio Floating Window Quick Launch
                Rectangle {
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: csRow.implicitWidth + 16
                    radius: 14
                    color: Qt.rgba(0/255, 229/255, 255/255, 0.15)
                    border.color: SRITECTheme.accentCyan
                    border.width: 1

                    RowLayout {
                        id: csRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "◈"; color: SRITECTheme.accentCyan; font.pixelSize: 9 }
                        Text { text: "Launch Code Studio Window"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: globalAppLaunchManager.requestAppLaunch("editor")
                    }
                }
            }
        }

        // Notification Capsule (if tool clicked)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            visible: root.activeNotification.length > 0
            radius: 4
            color: Qt.rgba(139/255, 92/255, 246/255, 0.2)
            border.color: SRITECTheme.accentViolet
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8
                Text { text: "ℹ"; color: SRITECTheme.accentViolet; font.pixelSize: 11 }
                Text { text: root.activeNotification; color: SRITECTheme.textPrimary; font.pixelSize: 10; font.family: SRITECTheme.fontMono; Layout.fillWidth: true }
                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    radius: 3
                    color: "transparent"
                    Text { anchors.centerIn: parent; text: "✕"; color: SRITECTheme.textSecondary; font.pixelSize: 10 }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.activeNotification = "" }
                }
            }
        }

        // =====================================================================
        // 2. Main Workstation Multi-Pane Space
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            // Left Pane: Project Tree & System Modules
            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                radius: SRITECTheme.radiusLarge
                color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        text: "PROJECT ARCHITECTURE"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1.2
                        font.family: SRITECTheme.fontMono
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ListView {
                            width: parent.width
                            model: globalDevWorkspace.projectTree
                            spacing: 3

                            delegate: ColumnLayout {
                                required property var modelData
                                width: parent.width
                                spacing: 2

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 26
                                    radius: 4
                                    color: itemMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 6
                                        spacing: 6
                                        Text { text: modelData.isDir ? "📁" : "📄"; font.pixelSize: 10 }
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: modelData.isDir ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: itemMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (!modelData.isDir) {
                                                globalDevWorkspace.openFile(modelData.path);
                                                globalAppLaunchManager.requestAppLaunch("editor");
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                    // Git Modified Files summary
                    Text {
                        text: "GIT WORKING TREE: " + globalDevWorkspace.gitStatusFiles.length + " MODIFIED"
                        color: globalDevWorkspace.gitStatusFiles.length > 0 ? SRITECTheme.accentAmber : SRITECTheme.accentEmerald
                        font.pixelSize: 9
                        font.bold: true
                        font.family: SRITECTheme.fontMono
                    }
                }
            }

            // Center Dynamic Workspace Switcher
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.activeMode === "vscode" ? 1 :
                              root.activeMode === "antigravity" ? 2 :
                              root.activeMode === "android_studio" ? 3 : 0

                // Mode 0: Workstation Overview & LISA Nexus
                Rectangle {
                    color: Qt.rgba(7/255, 10/255, 15/255, 0.7)
                    radius: SRITECTheme.radiusLarge
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14

                        // Header Status
                        RowLayout {
                            Text { text: "AI DEVELOPER WORKSTATION // UNIFIED CONTROL PLANE"; color: SRITECTheme.accentCyan; font.pixelSize: 12; font.bold: true; font.family: SRITECTheme.fontMono }
                            Item { Layout.fillWidth: true }
                            Text { text: "WAYLAND CLIENT ISOLATION ACTIVE"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                        // Three Ecosystem Cards
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 160
                            spacing: 12

                            // Card 1: VS Code Card
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                border.color: globalDevWorkstation && globalDevWorkstation.isVSCodeInstalled ? SRITECTheme.accentBlue : SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 6
                                    RowLayout {
                                        Text { text: "⚡"; color: SRITECTheme.accentBlue; font.pixelSize: 14 }
                                        Text { text: "Visual Studio Code"; color: SRITECTheme.textPrimary; font.pixelSize: 12; font.bold: true }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: globalDevWorkstation && globalDevWorkstation.isVSCodeInstalled ?
                                              "Installed at: " + globalDevWorkstation.vsCodePath :
                                              "Not installed as host binary.\nIntegrated through Code Studio & Codex Gateway."
                                        color: SRITECTheme.textSecondary
                                        font.pixelSize: 10
                                        wrapMode: Text.Wrap
                                    }
                                    Item { Layout.fillHeight: true }
                                    Button {
                                        text: "Open VS Code Mode"
                                        onClicked: root.activeMode = "vscode"
                                    }
                                }
                            }

                            // Card 2: Antigravity Card
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                border.color: SRITECTheme.accentViolet
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 6
                                    RowLayout {
                                        Text { text: "✦"; color: SRITECTheme.accentViolet; font.pixelSize: 14 }
                                        Text { text: "Google Antigravity"; color: SRITECTheme.textPrimary; font.pixelSize: 12; font.bold: true }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: "Active agentic environment.\nHome: /home/sarathi/.gemini/antigravity\nGemini 2.0 Agent Core Active"
                                        color: SRITECTheme.textSecondary
                                        font.pixelSize: 10
                                        wrapMode: Text.Wrap
                                    }
                                    Item { Layout.fillHeight: true }
                                    Button {
                                        text: "Open Antigravity Mode"
                                        onClicked: root.activeMode = "antigravity"
                                    }
                                }
                            }

                            // Card 3: Android Studio Card
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                border.color: SRITECTheme.accentEmerald
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 6
                                    RowLayout {
                                        Text { text: "🤖"; font.pixelSize: 14 }
                                        Text { text: "Android Studio & SDK"; color: SRITECTheme.textPrimary; font.pixelSize: 12; font.bold: true }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: "Android SDK Active (/home/sarathi/Android/Sdk)\n" +
                                              "Build-tools: 35.0.0, 34.0.0\n" +
                                              "JDKs: OpenJDK 17, 21, 27 detected."
                                        color: SRITECTheme.textSecondary
                                        font.pixelSize: 10
                                        wrapMode: Text.Wrap
                                    }
                                    Item { Layout.fillHeight: true }
                                    Button {
                                        text: "Open Android Studio Mode"
                                        onClicked: root.activeMode = "android_studio"
                                    }
                                }
                            }
                        }

                        // Terminal / Build Output Console
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: "#04060A"
                            border.color: SRITECTheme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 6

                                Text { text: "WORKSTATION CONSOLE STREAM"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }

                                ScrollView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true

                                    Text {
                                        width: parent.width
                                        text: globalDevWorkstation && globalDevWorkstation.buildOutput.length > 0 ?
                                              globalDevWorkstation.buildOutput :
                                              "[WORKSTATION IDLE] All subsystems ready. Select Build to execute compile targets or switch modes above."
                                        color: SRITECTheme.textPrimary
                                        font.pixelSize: 10
                                        font.family: SRITECTheme.fontMono
                                        wrapMode: Text.WrapAnywhere
                                    }
                                }
                            }
                        }
                    }
                }

                // Mode 1: VS Code Workspace Mode
                Rectangle {
                    color: Qt.rgba(7/255, 10/255, 15/255, 0.7)
                    radius: SRITECTheme.radiusLarge
                    border.color: SRITECTheme.accentBlue
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14

                        RowLayout {
                            Text { text: "VISUAL STUDIO CODE WORKSPACE INTEGRATION"; color: SRITECTheme.accentBlue; font.pixelSize: 12; font.bold: true; font.family: SRITECTheme.fontMono }
                            Item { Layout.fillWidth: true }
                            Button {
                                text: "Launch Host VS Code"
                                onClicked: if (globalDevWorkstation) globalDevWorkstation.launchVSCode()
                            }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 12

                            // Details & Features Card
                            Rectangle {
                                Layout.preferredWidth: 320
                                Layout.fillHeight: true
                                radius: 8
                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    Text { text: "PRESERVED CAPABILITIES"; color: SRITECTheme.accentBlue; font.pixelSize: 11; font.bold: true; font.family: SRITECTheme.fontMono }

                                    Text {
                                        Layout.fillWidth: true
                                        text: "• Extensions Ecosystem (Python, C++, QML)\n" +
                                              "• Source Control & Git Diffs\n" +
                                              "• GDB / LLDB Debugger Integration\n" +
                                              "• Multi-cursor & Keyboard Shortcuts\n" +
                                              "• Integrated PTY Shell Terminals\n" +
                                              "• Claude Code CLI Integration\n" +
                                              "• OpenAI Codex Synthesis Agent"
                                        color: SRITECTheme.textSecondary
                                        font.pixelSize: 11
                                        lineHeight: 1.6
                                    }

                                    Item { Layout.fillHeight: true }
                                }
                            }

                            // Claude Code & Codex Interactive Studio
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: Qt.rgba(13/255, 17/255, 26/255, 0.8)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    Text { text: "CLAUDE CODE & CODEX SYNTHESIS CONSOLE"; color: SRITECTheme.accentCyan; font.pixelSize: 11; font.bold: true; font.family: SRITECTheme.fontMono }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "#05080E"
                                        radius: 6

                                        ScrollView {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            clip: true
                                            Text {
                                                width: parent.width
                                                text: "[AI CODE SYNTHESIS ENGINE]\nConnected to Unified AI Provider Gateway.\nClaude 3.5 Sonnet & OpenAI Codex channels active.\nType your prompt below to synthesize proposed code changes with human approval guardrails."
                                                color: SRITECTheme.textSecondary
                                                font.pixelSize: 11
                                                font.family: SRITECTheme.fontMono
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        TextField {
                                            id: codexPrompt
                                            Layout.fillWidth: true
                                            placeholderText: "Ask Codex / Claude Code to generate a change..."
                                            color: SRITECTheme.textPrimary
                                            font.pixelSize: 11
                                        }
                                        Button {
                                            text: "Propose Change"
                                            onClicked: {
                                                if (codexPrompt.text.trim().length > 0 && globalDevWorkstation) {
                                                    globalDevWorkstation.proposeCodeChange("/run/media/sarathi/250-2.1/aios/CMakeLists.txt",
                                                        "# Synthesized CMake Configuration\n# Target: SRITEC NEBULA\ncmake_minimum_required(VERSION 3.22)\nproject(sritec-aios LANGUAGES CXX)\n",
                                                        codexPrompt.text.trim());
                                                    codexPrompt.text = "";
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Mode 2: Antigravity Workspace Mode
                Rectangle {
                    color: Qt.rgba(7/255, 10/255, 15/255, 0.7)
                    radius: SRITECTheme.radiusLarge
                    border.color: SRITECTheme.accentViolet
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14

                        RowLayout {
                            Text { text: "GOOGLE ANTIGRAVITY AGENTIC WORKSPACE"; color: SRITECTheme.accentViolet; font.pixelSize: 12; font.bold: true; font.family: SRITECTheme.fontMono }
                            Item { Layout.fillWidth: true }
                            Text { text: "RUNNING ON GEMINI 2.0 / MULTI-AGENT SWARM"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 12

                            // Left: Antigravity Directory & Skills
                            Rectangle {
                                Layout.preferredWidth: 320
                                Layout.fillHeight: true
                                radius: 8
                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    Text { text: "ANTIGRAVITY SUBSYSTEMS"; color: SRITECTheme.accentViolet; font.pixelSize: 11; font.bold: true; font.family: SRITECTheme.fontMono }

                                    Text {
                                        Layout.fillWidth: true
                                        text: "• App Data: /home/sarathi/.gemini/antigravity\n" +
                                              "• Agent API: agentapi\n" +
                                              "• Skills System: builtin/skills\n" +
                                              "• Subagents: self, research, browser\n" +
                                              "• Persistent Terminals: enabled\n" +
                                              "• Artifacts & Scratch Persistence: active\n" +
                                              "• Swarm Collaboration: available"
                                        color: SRITECTheme.textSecondary
                                        font.pixelSize: 11
                                        lineHeight: 1.6
                                    }

                                    Item { Layout.fillHeight: true }
                                }
                            }

                            // Right: Agent Execution Stream
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: Qt.rgba(13/255, 17/255, 26/255, 0.8)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    Text { text: "AGENT WORKFLOW & CODE GENERATION PIPELINE"; color: SRITECTheme.accentCyan; font.pixelSize: 11; font.bold: true; font.family: SRITECTheme.fontMono }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "#05080E"
                                        radius: 6

                                        ScrollView {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            clip: true
                                            Text {
                                                width: parent.width
                                                text: "[ANTIGRAVITY AUTONOMOUS AGENT ACTIVE]\nSystem Prompt: Google DeepMind Antigravity Architecture\nAll tool executions sandboxed.\nNon-destructive execution verified.\nPreserved Google Gemini & Antigravity engine without duplication."
                                                color: SRITECTheme.textPrimary
                                                font.pixelSize: 11
                                                font.family: SRITECTheme.fontMono
                                                lineHeight: 1.6
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Mode 3: Android Studio Workspace Mode
                Rectangle {
                    color: Qt.rgba(7/255, 10/255, 15/255, 0.7)
                    radius: SRITECTheme.radiusLarge
                    border.color: SRITECTheme.accentEmerald
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14

                        RowLayout {
                            Text { text: "ANDROID STUDIO & SDK WORKSPACE"; color: SRITECTheme.accentEmerald; font.pixelSize: 12; font.bold: true; font.family: SRITECTheme.fontMono }
                            Item { Layout.fillWidth: true }
                            Button {
                                text: "Launch Android Studio"
                                onClicked: if (globalDevWorkstation) globalDevWorkstation.launchAndroidStudio()
                            }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 12

                            // Left: Installed SDK Components
                            Rectangle {
                                Layout.preferredWidth: 340
                                Layout.fillHeight: true
                                radius: 8
                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 8

                                    Text { text: "DETECTED ANDROID SDK PACKAGES"; color: SRITECTheme.accentEmerald; font.pixelSize: 11; font.bold: true; font.family: SRITECTheme.fontMono }

                                    ScrollView {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true

                                        ListView {
                                            width: parent.width
                                            model: globalDevWorkstation ? globalDevWorkstation.androidSdkComponents : []
                                            spacing: 4

                                            delegate: Rectangle {
                                                required property var modelData
                                                width: parent.width
                                                height: 38
                                                radius: 4
                                                color: Qt.rgba(13/255, 17/255, 26/255, 0.7)

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 6
                                                    Text { text: "🤖"; font.pixelSize: 10 }
                                                    ColumnLayout {
                                                        Layout.fillWidth: true
                                                        spacing: 1
                                                        Text { text: modelData.name; color: SRITECTheme.textPrimary; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight }
                                                        Text { text: modelData.category + " • " + modelData.status; color: SRITECTheme.accentEmerald; font.pixelSize: 8; font.family: SRITECTheme.fontMono }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Right: JDKs & Gradle Build Environment
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: Qt.rgba(13/255, 17/255, 26/255, 0.8)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    Text { text: "JAVA DEVELOPMENT KITS & GRADLE RUNTIME"; color: SRITECTheme.accentCyan; font.pixelSize: 11; font.bold: true; font.family: SRITECTheme.fontMono }

                                    ScrollView {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true

                                        ListView {
                                            width: parent.width
                                            model: globalDevWorkstation ? globalDevWorkstation.installedJdks : []
                                            spacing: 6

                                            delegate: Rectangle {
                                                required property var modelData
                                                width: parent.width
                                                height: 48
                                                radius: 6
                                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                                border.color: modelData.isDefault ? SRITECTheme.accentEmerald : SRITECTheme.borderSubtle
                                                border.width: 1

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 8
                                                    Text { text: "☕"; font.pixelSize: 14 }
                                                    ColumnLayout {
                                                        Layout.fillWidth: true
                                                        spacing: 2
                                                        Text { text: modelData.name; color: SRITECTheme.textPrimary; font.pixelSize: 11; font.bold: true }
                                                        Text { text: modelData.path; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; elide: Text.ElideMiddle }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Right Pane: AI File Modification & Human Approval Drawer
            Rectangle {
                Layout.preferredWidth: 340
                Layout.fillHeight: true
                radius: SRITECTheme.radiusLarge
                color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Text {
                            text: "AI CODE PROPOSALS"
                            color: SRITECTheme.accentEmerald
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.2
                            font.family: SRITECTheme.fontMono
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            Layout.preferredHeight: 18
                            Layout.preferredWidth: 22
                            radius: 9
                            color: globalDevWorkstation && globalDevWorkstation.pendingChangeCount > 0 ? SRITECTheme.accentAmber : SRITECTheme.borderSubtle
                            Text { anchors.centerIn: parent; text: "" + (globalDevWorkstation ? globalDevWorkstation.pendingChangeCount : 0); color: SRITECTheme.backgroundVoid; font.pixelSize: 9; font.bold: true }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                    // Pending Proposals List
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        clip: true

                        ListView {
                            width: parent.width
                            model: globalDevWorkstation ? globalDevWorkstation.pendingChanges : []
                            spacing: 4

                            delegate: Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 44
                                radius: 6
                                color: root.selectedChangeId === modelData.id ? Qt.rgba(0/255, 245/255, 160/255, 0.2) : Qt.rgba(19/255, 26/255, 40/255, 0.6)
                                border.color: root.selectedChangeId === modelData.id ? SRITECTheme.accentEmerald : SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 2
                                    Text { text: modelData.filePath.split('/').pop(); color: SRITECTheme.textPrimary; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight }
                                    Text { text: modelData.explanation; color: SRITECTheme.textSecondary; font.pixelSize: 9; elide: Text.ElideRight }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.inspectChange(modelData.id)
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                    // Interactive Diff Inspector
                    Text { text: "DIFF VIEWER (HUMAN APPROVAL REQUIRED)"; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: "#05080E"
                        border.color: SRITECTheme.borderSubtle
                        border.width: 1

                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 6
                            clip: true

                            ListView {
                                width: parent.width
                                model: root.selectedChangeDetails ? root.selectedChangeDetails.diffLines : []
                                spacing: 1

                                delegate: Text {
                                    required property var modelData
                                    width: parent.width
                                    text: modelData.text
                                    color: modelData.type === "add" ? SRITECTheme.accentEmerald :
                                           modelData.type === "remove" ? SRITECTheme.accentCrimson : SRITECTheme.textSecondary
                                    font.pixelSize: 9
                                    font.family: SRITECTheme.fontMono
                                    wrapMode: Text.WrapAnywhere
                                }
                            }
                        }
                    }

                    // Approval Action Buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: root.selectedChangeDetails !== null

                        Button {
                            Layout.fillWidth: true
                            text: "✕ Reject"
                            onClicked: {
                                if (globalDevWorkstation && root.selectedChangeId.length > 0) {
                                    globalDevWorkstation.rejectChange(root.selectedChangeId);
                                    root.selectedChangeDetails = null;
                                }
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "✓ Approve & Apply"
                            onClicked: {
                                if (globalDevWorkstation && root.selectedChangeId.length > 0) {
                                    globalDevWorkstation.approveChange(root.selectedChangeId);
                                    root.selectedChangeDetails = null;
                                    root.activeNotification = "Applied approved AI change to disk.";
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
