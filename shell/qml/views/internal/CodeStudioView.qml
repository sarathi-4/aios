import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme"
import "../../components"

Rectangle {
    id: root

    color: "#070A0F"
    radius: SRITECTheme.radiusLarge
    clip: true

    property string initialAppId: "editor"
    property string currentView: "selector" // "selector" or "editor"
    property bool showProjectExplorer: true
    property bool showSearchBar: false
    property bool showTerminalDrawer: false
    property string statusMessage: "Ready"
    property string selectorNotice: ""

    Component.onCompleted: {
        if (root.initialAppId === "vscode") {
            root.selectorNotice = "Visual Studio Code environment selected. Launch or switch below.";
        } else if (root.initialAppId === "antigravity") {
            root.selectorNotice = "Google Antigravity AI agent workspace selected.";
        } else if (root.initialAppId === "android_studio") {
            root.selectorNotice = "Android Studio mobile platform selected.";
        }
    }

    // =========================================================================
    // VIEW 1: IDE SELECTION & LAUNCH HUB ("selector")
    // =========================================================================
    Item {
        id: ideSelectorView
        anchors.fill: parent
        visible: root.currentView === "selector"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // 1. Cybernetic Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 10
                color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 16

                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 10
                        color: Qt.rgba(0/255, 229/255, 255/255, 0.15)
                        border.color: SRITECTheme.accentCyan
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "💻"
                            font.pixelSize: 22
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            spacing: 8
                            Text {
                                text: "NEBULA DEVELOPER WORKSTATION"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.5
                                font.family: SRITECTheme.fontMono
                            }

                            Rectangle {
                                Layout.preferredHeight: 16
                                Layout.preferredWidth: 80
                                radius: 8
                                color: Qt.rgba(0/255, 245/255, 160/255, 0.2)
                                border.color: SRITECTheme.accentEmerald
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: "MULTI-IDE"
                                    color: SRITECTheme.accentEmerald
                                    font.pixelSize: 8
                                    font.bold: true
                                    font.family: SRITECTheme.fontMono
                                }
                            }
                        }

                        Text {
                            text: "Select your active IDE platform: Launch real host IDEs (VS Code, Antigravity, Android Studio) or code in the built-in NEBULA Code Studio."
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 11
                        }
                    }

                    // Direct Jump into Internal Code Editor Button
                    Rectangle {
                        Layout.preferredHeight: 38
                        Layout.preferredWidth: 200
                        radius: 8
                        color: directEditorMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.25) : Qt.rgba(0/255, 229/255, 255/255, 0.12)
                        border.color: SRITECTheme.accentCyan
                        border.width: 1.5

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Text { text: "💻"; font.pixelSize: 13 }
                            Text {
                                text: "Open Built-in Editor"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text { text: "▶"; color: SRITECTheme.accentCyan; font.pixelSize: 9 }
                        }

                        MouseArea {
                            id: directEditorMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                root.currentView = "editor";
                            }
                        }
                    }
                }
            }

            // Optional notice banner
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                visible: root.selectorNotice.length > 0
                radius: 6
                color: Qt.rgba(0/255, 229/255, 255/255, 0.12)
                border.color: Qt.rgba(0/255, 229/255, 255/255, 0.4)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 8
                    Text { text: "ℹ"; color: SRITECTheme.accentCyan; font.pixelSize: 12 }
                    Text {
                        text: root.selectorNotice
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 11
                        font.family: SRITECTheme.fontMono
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "✕"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 10
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectorNotice = ""
                        }
                    }
                }
            }

            // 2. The 4 Holographic IDE Platform Cards
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                clip: true

                RowLayout {
                    spacing: 18
                    Layout.alignment: Qt.AlignHCenter

                    // -------------------------------------------------------------
                    // CARD 1: Visual Studio Code
                    // -------------------------------------------------------------
                    Rectangle {
                        id: cardVSCode
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 390
                        radius: 12
                        color: vscCardMouse.containsMouse ? Qt.rgba(59/255, 130/255, 246/255, 0.18) : Qt.rgba(13/255, 17/255, 26/255, 0.8)
                        border.color: vscCardMouse.containsMouse ? "#3B82F6" : Qt.rgba(59/255, 130/255, 246/255, 0.35)
                        border.width: vscCardMouse.containsMouse ? 2 : 1
                        scale: vscCardMouse.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            // Card Badge
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "HOST IDE"
                                    color: "#3B82F6"
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.family: SRITECTheme.fontMono
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    Layout.preferredHeight: 16
                                    Layout.preferredWidth: 60
                                    radius: 8
                                    color: Qt.rgba(59/255, 130/255, 246/255, 0.2)
                                    border.color: "#3B82F6"
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "MICROSOFT"
                                        color: "#3B82F6"
                                        font.pixelSize: 7
                                        font.bold: true
                                        font.family: SRITECTheme.fontMono
                                    }
                                }
                            }

                            // Big Glowing Icon
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 68
                                Layout.preferredHeight: 68
                                radius: 34
                                color: Qt.rgba(59/255, 130/255, 246/255, 0.22)
                                border.color: "#3B82F6"
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "🚀"
                                    font.pixelSize: 30
                                }
                            }

                            // Title & Description
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "VS Code"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Visual Studio Code"
                                color: "#3B82F6"
                                font.pixelSize: 10
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Extensible code editor with native extensions, debugger, Git source control, and integrated terminal."
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                                lineHeight: 1.3
                            }

                            // Feature Pills
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 4
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 64; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Extensions"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 64; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Debugger"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 50; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Git VCS"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            // Launch Button
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                radius: 6
                                color: vscBtnMouse.containsMouse ? "#2563EB" : "#3B82F6"

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "🚀"; font.pixelSize: 11 }
                                    Text {
                                        text: "Launch VS Code"
                                        color: "#FFFFFF"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: vscBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        globalDevWorkstation.launchVSCode("/run/media/sarathi/250-2.1/aios");
                                        globalAppLauncher.launch("vscode");
                                        root.selectorNotice = "Launching Visual Studio Code with workspace /run/media/sarathi/250-2.1/aios...";
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: vscCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: -1
                            onClicked: {
                                globalAudioService.playClick();
                                globalDevWorkstation.launchVSCode("/run/media/sarathi/250-2.1/aios");
                                globalAppLauncher.launch("vscode");
                                root.selectorNotice = "Launching Visual Studio Code with workspace /run/media/sarathi/250-2.1/aios...";
                            }
                        }
                    }

                    // -------------------------------------------------------------
                    // CARD 2: Google Antigravity
                    // -------------------------------------------------------------
                    Rectangle {
                        id: cardAntigravity
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 390
                        radius: 12
                        color: agyCardMouse.containsMouse ? Qt.rgba(139/255, 92/255, 246/255, 0.18) : Qt.rgba(13/255, 17/255, 26/255, 0.8)
                        border.color: agyCardMouse.containsMouse ? "#8B5CF6" : Qt.rgba(139/255, 92/255, 246/255, 0.35)
                        border.width: agyCardMouse.containsMouse ? 2 : 1
                        scale: agyCardMouse.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            // Card Badge
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "AI WORKSPACE"
                                    color: "#8B5CF6"
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.family: SRITECTheme.fontMono
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    Layout.preferredHeight: 16
                                    Layout.preferredWidth: 64
                                    radius: 8
                                    color: Qt.rgba(139/255, 92/255, 246/255, 0.2)
                                    border.color: "#8B5CF6"
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "GEMINI 2.0"
                                        color: "#8B5CF6"
                                        font.pixelSize: 7
                                        font.bold: true
                                        font.family: SRITECTheme.fontMono
                                    }
                                }
                            }

                            // Big Glowing Icon
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 68
                                Layout.preferredHeight: 68
                                radius: 34
                                color: Qt.rgba(139/255, 92/255, 246/255, 0.22)
                                border.color: "#8B5CF6"
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "🌌"
                                    font.pixelSize: 30
                                }
                            }

                            // Title & Description
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Antigravity"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Google Antigravity IDE"
                                color: "#8B5CF6"
                                font.pixelSize: 10
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Agentic AI software development environment powered by Gemini 2.0, autonomous workflows, and code review."
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                                lineHeight: 1.3
                            }

                            // Feature Pills
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 4
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 70; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Multi-Agent"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 64; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "DeepMind"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 50; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Synthesis"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            // Launch Button
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                radius: 6
                                color: agyBtnMouse.containsMouse ? "#7C3AED" : "#8B5CF6"

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "🌌"; font.pixelSize: 11 }
                                    Text {
                                        text: "Launch Antigravity"
                                        color: "#FFFFFF"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: agyBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        globalDevWorkstation.launchAntigravity();
                                        globalAppLauncher.launch("antigravity");
                                        root.selectorNotice = "Launching Google Antigravity Agent Workspace...";
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: agyCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: -1
                            onClicked: {
                                globalAudioService.playClick();
                                globalDevWorkstation.launchAntigravity();
                                globalAppLauncher.launch("antigravity");
                                root.selectorNotice = "Launching Google Antigravity Agent Workspace...";
                            }
                        }
                    }

                    // -------------------------------------------------------------
                    // CARD 3: Android Studio
                    // -------------------------------------------------------------
                    Rectangle {
                        id: cardAndroid
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 390
                        radius: 12
                        color: adrCardMouse.containsMouse ? Qt.rgba(0/255, 245/255, 160/255, 0.18) : Qt.rgba(13/255, 17/255, 26/255, 0.8)
                        border.color: adrCardMouse.containsMouse ? SRITECTheme.accentEmerald : Qt.rgba(0/255, 245/255, 160/255, 0.35)
                        border.width: adrCardMouse.containsMouse ? 2 : 1
                        scale: adrCardMouse.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            // Card Badge
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "MOBILE SDK"
                                    color: SRITECTheme.accentEmerald
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.family: SRITECTheme.fontMono
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    Layout.preferredHeight: 16
                                    Layout.preferredWidth: 60
                                    radius: 8
                                    color: Qt.rgba(0/255, 245/255, 160/255, 0.2)
                                    border.color: SRITECTheme.accentEmerald
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "GOOGLE"
                                        color: SRITECTheme.accentEmerald
                                        font.pixelSize: 7
                                        font.bold: true
                                        font.family: SRITECTheme.fontMono
                                    }
                                }
                            }

                            // Big Glowing Icon
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 68
                                Layout.preferredHeight: 68
                                radius: 34
                                color: Qt.rgba(0/255, 245/255, 160/255, 0.22)
                                border.color: SRITECTheme.accentEmerald
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "🤖"
                                    font.pixelSize: 30
                                }
                            }

                            // Title & Description
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Android Studio"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Android Studio IDE"
                                color: SRITECTheme.accentEmerald
                                font.pixelSize: 10
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Official Android developer suite with Kotlin, Jetpack Compose, device emulator, Gradle, and Logcat."
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                                lineHeight: 1.3
                            }

                            // Feature Pills
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 4
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 68; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Android SDK"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 60; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Emulator"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 54; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Gradle"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            // Launch Button
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                radius: 6
                                color: adrBtnMouse.containsMouse ? Qt.rgba(0/255, 220/255, 140/255, 1.0) : SRITECTheme.accentEmerald

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "🤖"; font.pixelSize: 11 }
                                    Text {
                                        text: "Launch Android Studio"
                                        color: SRITECTheme.backgroundVoid
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: adrBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        globalDevWorkstation.launchAndroidStudio("/run/media/sarathi/250-2.1/aios");
                                        globalAppLauncher.launch("android_studio");
                                        root.selectorNotice = "Launching Android Studio environment...";
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: adrCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: -1
                            onClicked: {
                                globalAudioService.playClick();
                                globalDevWorkstation.launchAndroidStudio("/run/media/sarathi/250-2.1/aios");
                                globalAppLauncher.launch("android_studio");
                                root.selectorNotice = "Launching Android Studio environment...";
                            }
                        }
                    }

                    // -------------------------------------------------------------
                    // CARD 4: NEBULA Code Studio (Internal)
                    // -------------------------------------------------------------
                    Rectangle {
                        id: cardNebulaCode
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 390
                        radius: 12
                        color: nebCardMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.22) : Qt.rgba(13/255, 17/255, 26/255, 0.8)
                        border.color: nebCardMouse.containsMouse ? SRITECTheme.accentCyan : Qt.rgba(0/255, 229/255, 255/255, 0.4)
                        border.width: nebCardMouse.containsMouse ? 2 : 1.5
                        scale: nebCardMouse.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            // Card Badge
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "IN-OS DESKTOP"
                                    color: SRITECTheme.accentCyan
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.family: SRITECTheme.fontMono
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    Layout.preferredHeight: 16
                                    Layout.preferredWidth: 64
                                    radius: 8
                                    color: Qt.rgba(0/255, 229/255, 255/255, 0.2)
                                    border.color: SRITECTheme.accentCyan
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "INTEGRATED"
                                        color: SRITECTheme.accentCyan
                                        font.pixelSize: 7
                                        font.bold: true
                                        font.family: SRITECTheme.fontMono
                                    }
                                }
                            }

                            // Big Glowing Icon
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 68
                                Layout.preferredHeight: 68
                                radius: 34
                                color: Qt.rgba(0/255, 229/255, 255/255, 0.22)
                                border.color: SRITECTheme.accentCyan
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "💻"
                                    font.pixelSize: 30
                                }
                            }

                            // Title & Description
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "NEBULA Code Studio"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Self-Contained Spatial Editor"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 10
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Built-in lightweight cybernetic editor with animated tabs, project tree, CMake / Ninja build trigger, and search/replace."
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                                lineHeight: 1.3
                            }

                            // Feature Pills
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 4
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 64; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Multi-Tab"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 68; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "CMake/Ninja"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 54; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Project Tree"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            // Launch Button
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                radius: 6
                                color: nebBtnMouse.containsMouse ? Qt.rgba(0/255, 255/255, 255/255, 1.0) : SRITECTheme.accentCyan

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "💻"; color: SRITECTheme.backgroundVoid; font.pixelSize: 11 }
                                    Text {
                                        text: "Open Code Studio"
                                        color: SRITECTheme.backgroundVoid
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: nebBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        root.currentView = "editor";
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: nebCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: -1
                            onClicked: {
                                globalAudioService.playClick();
                                root.currentView = "editor";
                            }
                        }
                    }
                }
            }

            // 3. Bottom Information Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: Qt.rgba(13/255, 17/255, 26/255, 0.95)
                radius: 6
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    RowLayout {
                        spacing: 4
                        Text { text: "📁"; font.pixelSize: 10 }
                        Text { text: "Workspace:"; color: SRITECTheme.textTertiary; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                        Text { text: globalDevWorkspace.projectRoot; color: SRITECTheme.textPrimary; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                    }

                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; color: SRITECTheme.borderSubtle }

                    RowLayout {
                        spacing: 4
                        Text { text: "⎇"; color: SRITECTheme.accentCyan; font.pixelSize: 11 }
                        Text { text: globalDevWorkspace.gitBranch; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "Audio Feedback Active • High-Fidelity UI"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 9
                        font.family: SRITECTheme.fontMono
                    }
                }
            }
        }
    }

    // =========================================================================
    // VIEW 2: INTERNAL CODE STUDIO EDITOR ("editor")
    // =========================================================================
    Item {
        id: internalEditorView
        anchors.fill: parent
        visible: root.currentView === "editor"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // =================================================================
            // 1. Top Editor Toolbar & Animated Tabs
            // =================================================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                color: SRITECTheme.backgroundElevated
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    // Back to IDE Selector Hub Button
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: selectorBtnRow.implicitWidth + 14
                        radius: 4
                        color: backSelectorMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.25) : Qt.rgba(0/255, 229/255, 255/255, 0.12)
                        border.color: SRITECTheme.accentCyan
                        border.width: 1

                        RowLayout {
                            id: selectorBtnRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "⊞"; color: SRITECTheme.accentCyan; font.pixelSize: 12; font.bold: true }
                            Text { text: "IDE Hub"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            id: backSelectorMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                root.currentView = "selector";
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 24
                        color: SRITECTheme.borderSubtle
                    }

                    // Toggle Explorer Button
                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: 4
                        color: root.showProjectExplorer ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : "transparent"
                        border.color: root.showProjectExplorer ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                        border.width: 1

                        Text { anchors.centerIn: parent; text: "📁"; font.pixelSize: 11 }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                root.showProjectExplorer = !root.showProjectExplorer;
                            }
                        }
                    }

                    // File Tabs Scroll Area with Fluid In/Out Animations
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        RowLayout {
                            spacing: 4

                            Repeater {
                                model: globalDevWorkspace.openTabs

                                delegate: Item {
                                    id: codeTabItem
                                    required property var modelData
                                    property real fullWidth: Math.min(200, Math.max(90, editorTabText.implicitWidth + 48))
                                    property bool isClosing: false

                                    Layout.preferredHeight: 28
                                    Layout.preferredWidth: isClosing ? 0 : fullWidth
                                    clip: true

                                    Behavior on Layout.preferredWidth {
                                        NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
                                    }

                                    Rectangle {
                                        id: codeTabCard
                                        anchors.fill: parent
                                        radius: 4
                                        color: codeTabItem.modelData.isActive ? Qt.rgba(0/255, 229/255, 255/255, 0.20) :
                                               (tabCardMouse.containsMouse ? Qt.rgba(19/255, 26/255, 40/255, 0.85) : Qt.rgba(19/255, 26/255, 40/255, 0.55))
                                        border.color: codeTabItem.modelData.isActive ? SRITECTheme.accentCyan :
                                                      (tabCardMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.4) : SRITECTheme.borderSubtle)
                                        border.width: 1

                                        // Tab Enter Animation (Fluid zoom & fade in)
                                        Component.onCompleted: {
                                            codeTabCard.scale = 0.65;
                                            codeTabCard.opacity = 0.0;
                                            codeTabEnterAnim.start();
                                        }

                                        ParallelAnimation {
                                            id: codeTabEnterAnim
                                            NumberAnimation { target: codeTabCard; property: "scale"; from: 0.65; to: 1.0; duration: 220; easing.type: Easing.OutBack }
                                            NumberAnimation { target: codeTabCard; property: "opacity"; from: 0.0; to: 1.0; duration: 180; easing.type: Easing.OutQuad }
                                        }

                                        // Tab Exit Animation (Fluid shrink & fade out before close)
                                        SequentialAnimation {
                                            id: codeTabExitAnim
                                            ParallelAnimation {
                                                NumberAnimation { target: codeTabCard; property: "scale"; to: 0.6; duration: 160; easing.type: Easing.InQuad }
                                                NumberAnimation { target: codeTabCard; property: "opacity"; to: 0.0; duration: 160; easing.type: Easing.InQuad }
                                            }
                                            ScriptAction {
                                                script: globalDevWorkspace.closeTab(codeTabItem.modelData.id)
                                            }
                                        }

                                        function triggerClose() {
                                            if (!codeTabItem.isClosing) {
                                                codeTabItem.isClosing = true;
                                                codeTabExitAnim.start();
                                            }
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 6
                                            spacing: 4

                                            Text {
                                                text: codeTabItem.modelData.isModified ? "●" : "◈"
                                                color: codeTabItem.modelData.isModified ? SRITECTheme.accentAmber : SRITECTheme.accentCyan
                                                font.pixelSize: 8
                                            }

                                            Text {
                                                id: editorTabText
                                                Layout.fillWidth: true
                                                text: codeTabItem.modelData.name
                                                color: codeTabItem.modelData.isActive ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                                font.pixelSize: 11
                                                font.bold: codeTabItem.modelData.isActive
                                                elide: Text.ElideRight
                                            }

                                            // Close Tab Button
                                            Rectangle {
                                                Layout.preferredWidth: 16
                                                Layout.preferredHeight: 16
                                                radius: 3
                                                color: tabCloseMouse.containsMouse ? Qt.rgba(255/255, 59/255, 92/255, 0.3) : "transparent"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "✕"
                                                    color: tabCloseMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.textSecondary
                                                    font.pixelSize: 8
                                                }

                                                MouseArea {
                                                    id: tabCloseMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        globalAudioService.playClick();
                                                        codeTabItem.triggerClose();
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: tabCardMouse
                                            anchors.fill: parent
                                            z: -1
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                globalAudioService.playClick();
                                                globalDevWorkspace.activeTabId = codeTabItem.modelData.id;
                                            }
                                        }
                                    }
                                }
                            }

                            // Add New Buffer Tab Button
                            Rectangle {
                                Layout.preferredWidth: 26
                                Layout.preferredHeight: 26
                                radius: 4
                                color: newTabMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                                border.color: newTabMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "+"
                                    color: SRITECTheme.accentCyan
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                MouseArea {
                                    id: newTabMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        globalDevWorkspace.newFile("untitled.cpp");
                                    }
                                }
                            }
                        }
                    }

                    // Search & Replace Toggle
                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: 4
                        color: root.showSearchBar ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : "transparent"
                        border.color: root.showSearchBar ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                        border.width: 1

                        Text { anchors.centerIn: parent; text: "🔍"; font.pixelSize: 11 }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                root.showSearchBar = !root.showSearchBar;
                            }
                        }
                    }

                    // Save Active File Button
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: 60
                        radius: 4
                        color: Qt.rgba(0/255, 245/255, 160/255, 0.15)
                        border.color: SRITECTheme.accentEmerald
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "💾"; font.pixelSize: 9 }
                            Text { text: "Save"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                globalDevWorkspace.saveActiveFile();
                                root.statusMessage = "Saved: " + globalDevWorkspace.activeFilePath;
                            }
                        }
                    }

                    // Build Target Button
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: 64
                        radius: 4
                        color: SRITECTheme.accentCyan

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "▶"; color: SRITECTheme.backgroundVoid; font.pixelSize: 9 }
                            Text { text: "Build"; color: SRITECTheme.backgroundVoid; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                root.showTerminalDrawer = true;
                                globalTerminalBackend.executeCommand("ninja -C build");
                            }
                        }
                    }

                    // Quick Launch: VS Code
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: vscQuickRow.implicitWidth + 14
                        radius: 4
                        color: vscQuickMouse.containsMouse ? Qt.rgba(59/255, 130/255, 246/255, 0.25) : "transparent"
                        border.color: "#3B82F6"
                        border.width: 1

                        RowLayout {
                            id: vscQuickRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "🚀"; font.pixelSize: 9 }
                            Text { text: "VS Code"; color: "#3B82F6"; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            id: vscQuickMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                globalDevWorkstation.launchVSCode("/run/media/sarathi/250-2.1/aios");
                                globalAppLauncher.launch("vscode");
                            }
                        }
                    }

                    // Quick Launch: Antigravity
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: agyQuickRow.implicitWidth + 14
                        radius: 4
                        color: agyQuickMouse.containsMouse ? Qt.rgba(139/255, 92/255, 246/255, 0.25) : "transparent"
                        border.color: "#8B5CF6"
                        border.width: 1

                        RowLayout {
                            id: agyQuickRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "🌌"; font.pixelSize: 9 }
                            Text { text: "Antigravity"; color: "#8B5CF6"; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            id: agyQuickMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                globalDevWorkstation.launchAntigravity();
                                globalAppLauncher.launch("antigravity");
                            }
                        }
                    }

                    // Quick Launch: Android Studio
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: adrQuickRow.implicitWidth + 14
                        radius: 4
                        color: adrQuickMouse.containsMouse ? Qt.rgba(0/255, 245/255, 160/255, 0.25) : "transparent"
                        border.color: SRITECTheme.accentEmerald
                        border.width: 1

                        RowLayout {
                            id: adrQuickRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "🤖"; font.pixelSize: 9 }
                            Text { text: "Android"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            id: adrQuickMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                globalDevWorkstation.launchAndroidStudio("/run/media/sarathi/250-2.1/aios");
                                globalAppLauncher.launch("android_studio");
                            }
                        }
                    }
                }
            }

            // =================================================================
            // 2. Search & Replace Toolbar
            // =================================================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                visible: root.showSearchBar
                color: Qt.rgba(19/255, 26/255, 40/255, 0.95)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text { text: "Find:"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true }

                    TextField {
                        id: findInput
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 24
                        placeholderText: "Search term..."
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 11
                        background: Rectangle { color: Qt.rgba(7/255, 10/255, 15/255, 0.8); border.color: SRITECTheme.borderSubtle; radius: 4 }
                    }

                    Text { text: "Replace:"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.bold: true }

                    TextField {
                        id: replaceInput
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 24
                        placeholderText: "Replacement..."
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 11
                        background: Rectangle { color: Qt.rgba(7/255, 10/255, 15/255, 0.8); border.color: SRITECTheme.borderSubtle; radius: 4 }
                    }

                    Button {
                        text: "Replace All"
                        onClicked: {
                            globalAudioService.playClick();
                            if (findInput.text.length > 0) {
                                globalDevWorkspace.replaceInActiveFile(findInput.text, replaceInput.text, true);
                                root.statusMessage = "Replaced occurrences of '" + findInput.text + "'";
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }

            // =================================================================
            // 3. Main Workspace: Project Tree + Editor
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Project Explorer Sidebar
                Rectangle {
                    Layout.preferredWidth: root.showProjectExplorer ? 240 : 0
                    Layout.fillHeight: true
                    visible: root.showProjectExplorer
                    color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        RowLayout {
                            Text { text: "PROJECT EXPLORER"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                radius: 3
                                color: "transparent"
                                Text { anchors.centerIn: parent; text: "↻"; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        globalDevWorkspace.refreshProjectTree();
                                    }
                                }
                            }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ListView {
                                width: parent.width
                                model: globalDevWorkspace.projectTree
                                spacing: 2

                                delegate: ColumnLayout {
                                    required property var modelData
                                    width: parent.width
                                    spacing: 2

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 24
                                        radius: 4
                                        color: nodeMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

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
                                            id: nodeMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                globalAudioService.playClick();
                                                if (!modelData.isDir) {
                                                    globalDevWorkspace.openFile(modelData.path);
                                                }
                                            }
                                        }
                                    }

                                    // Children repeater if dir
                                    Repeater {
                                        model: modelData.children !== undefined ? modelData.children : []
                                        delegate: Rectangle {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 22
                                            radius: 4
                                            color: childMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 18
                                                spacing: 6
                                                Text { text: modelData.isDir ? "📁" : "◈"; font.pixelSize: 9 }
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: modelData.name
                                                    color: SRITECTheme.textSecondary
                                                    font.pixelSize: 10
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            MouseArea {
                                                id: childMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    globalAudioService.playClick();
                                                    if (!modelData.isDir) {
                                                        globalDevWorkspace.openFile(modelData.path);
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

                // Editor Text Area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#05080E"

                    ScrollView {
                        id: codeScroll
                        anchors.fill: parent
                        clip: true

                        TextArea {
                            id: codeEditor
                            text: globalDevWorkspace.activeContent
                            color: "#E2E8F0"
                            font.pixelSize: 12
                            font.family: SRITECTheme.fontMono
                            wrapMode: TextEdit.NoWrap
                            selectByMouse: true
                            background: null

                            onTextChanged: {
                                if (text !== globalDevWorkspace.activeContent) {
                                    globalDevWorkspace.activeContent = text;
                                }
                            }

                            Keys.onPressed: function(event) {
                                if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_S) {
                                    globalAudioService.playClick();
                                    globalDevWorkspace.saveActiveFile();
                                    root.statusMessage = "Saved: " + globalDevWorkspace.activeFilePath;
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }
            }

            // =================================================================
            // 4. Integrated Terminal Drawer
            // =================================================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.showTerminalDrawer ? 200 : 0
                visible: root.showTerminalDrawer
                color: "#030508"
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 26
                        color: Qt.rgba(13/255, 17/255, 26/255, 0.95)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8
                            Text { text: "TERMINAL CONSOLE"; color: SRITECTheme.accentCyan; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                radius: 3
                                color: "transparent"
                                Text { anchors.centerIn: parent; text: "✕"; color: SRITECTheme.textSecondary; font.pixelSize: 10 }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        root.showTerminalDrawer = false;
                                    }
                                }
                            }
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ListView {
                            id: termDrawerList
                            width: parent.width - 20
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            model: globalTerminalBackend.activeOutput
                            spacing: 2

                            delegate: Text {
                                required property var modelData
                                width: termDrawerList.width
                                text: modelData.text
                                color: modelData.color
                                font.pixelSize: 10
                                font.family: SRITECTheme.fontMono
                                wrapMode: Text.WrapAnywhere
                            }
                        }
                    }
                }
            }

            // =================================================================
            // 5. Bottom Status & Git Bar
            // =================================================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                color: Qt.rgba(13/255, 17/255, 26/255, 0.95)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 12

                    // Git Branch
                    RowLayout {
                        spacing: 4
                        Text { text: "⎇"; color: SRITECTheme.accentCyan; font.pixelSize: 11 }
                        Text { text: globalDevWorkspace.gitBranch; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
                    }

                    // Git Modified files count
                    Text {
                        text: globalDevWorkspace.gitStatusFiles.length > 0 ?
                              "● " + globalDevWorkspace.gitStatusFiles.length + " modified" :
                              "✓ working tree clean"
                        color: globalDevWorkspace.gitStatusFiles.length > 0 ? SRITECTheme.accentAmber : SRITECTheme.accentEmerald
                        font.pixelSize: 10
                        font.family: SRITECTheme.fontMono
                    }

                    // Terminal Drawer Toggle
                    Rectangle {
                        Layout.preferredHeight: 18
                        Layout.preferredWidth: termToggleRow.implicitWidth + 10
                        radius: 3
                        color: root.showTerminalDrawer ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : "transparent"
                        border.color: SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            id: termToggleRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "⌨"; font.pixelSize: 9 }
                            Text { text: "Terminal"; color: SRITECTheme.textSecondary; font.pixelSize: 9 }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                root.showTerminalDrawer = !root.showTerminalDrawer;
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text { text: root.statusMessage; color: SRITECTheme.textTertiary; font.pixelSize: 10; font.family: SRITECTheme.fontMono }

                    Text {
                        text: globalDevWorkspace.activeLanguage + " • UTF-8"
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 10
                        font.family: SRITECTheme.fontMono
                    }
                }
            }
        }
    }
}
