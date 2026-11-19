import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme"
import "../../components"

Rectangle {
    id: root

    color: "#070A10"
    radius: SRITECTheme.radiusLarge
    clip: true

    property string initialPortal: ""
    property string currentView: initialPortal.length > 0 ? "browser" : "selector" // "selector" or "browser"
    property string selectorNotice: ""
    property bool showBookmarksBar: true
    property bool showHistoryDrawer: false

    Component.onCompleted: {
        if (root.initialPortal === "chatgpt" || root.initialPortal === "gemini" || root.initialPortal === "claude") {
            root.currentView = "browser";
            globalBrowserBackend.openAIPortal(root.initialPortal);
        }
    }

    // =========================================================================
    // VIEW 1: BROWSER SELECTION & ENGINE HUB ("selector")
    // Identical layout & format to Code Studio Workstation Hub
    // =========================================================================
    Item {
        id: browserSelectorView
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
                            text: "🌐"
                            font.pixelSize: 22
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            spacing: 8
                            Text {
                                text: "NEBULA WEB & AI EXPLORER"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.5
                                font.family: SRITECTheme.fontMono
                            }

                            Rectangle {
                                Layout.preferredHeight: 16
                                Layout.preferredWidth: 92
                                radius: 8
                                color: Qt.rgba(0/255, 245/255, 160/255, 0.2)
                                border.color: SRITECTheme.accentEmerald
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: "MULTI-ENGINE"
                                    color: SRITECTheme.accentEmerald
                                    font.pixelSize: 8
                                    font.bold: true
                                    font.family: SRITECTheme.fontMono
                                }
                            }
                        }

                        Text {
                            text: "Select your active browser engine: Launch real host browsers (Firefox, Chrome, Edge, Opera) or browse in the built-in NEBULA Web & AI Portal."
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 11
                        }
                    }

                    // Direct Jump into Built-in Web Portal Button
                    Rectangle {
                        Layout.preferredHeight: 38
                        Layout.preferredWidth: 200
                        radius: 8
                        color: directPortalMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.25) : Qt.rgba(0/255, 229/255, 255/255, 0.12)
                        border.color: SRITECTheme.accentCyan
                        border.width: 1.5

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Text { text: "🌐"; font.pixelSize: 13 }
                            Text {
                                text: "Open Built-in Portal"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text { text: "▶"; color: SRITECTheme.accentCyan; font.pixelSize: 9 }
                        }

                        MouseArea {
                            id: directPortalMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                root.currentView = "browser";
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

            // 2. The Holographic Browser Engine Cards (Matching Code Studio Format)
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                clip: true

                RowLayout {
                    spacing: 16
                    Layout.alignment: Qt.AlignHCenter

                    // ---------------------------------------------------------
                    // CARD 1: Mozilla Firefox
                    // ---------------------------------------------------------
                    Rectangle {
                        id: cardFirefox
                        Layout.preferredWidth: 245
                        Layout.preferredHeight: 390
                        radius: 12
                        color: ffCardMouse.containsMouse ? Qt.rgba(255/255, 119/255, 0/255, 0.18) : Qt.rgba(13/255, 17/255, 26/255, 0.8)
                        border.color: ffCardMouse.containsMouse ? "#FF7700" : Qt.rgba(255/255, 119/255, 0/255, 0.35)
                        border.width: ffCardMouse.containsMouse ? 2 : 1
                        scale: ffCardMouse.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "HOST ENGINE"
                                    color: "#FF7700"
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.family: SRITECTheme.fontMono
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    Layout.preferredHeight: 16
                                    Layout.preferredWidth: 54
                                    radius: 8
                                    color: Qt.rgba(255/255, 119/255, 0/255, 0.2)
                                    border.color: "#FF7700"
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "MOZILLA"
                                        color: "#FF7700"
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
                                color: Qt.rgba(255/255, 119/255, 0/255, 0.22)
                                border.color: "#FF7700"
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "🦊"
                                    font.pixelSize: 30
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Firefox"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Mozilla Gecko Platform"
                                color: "#FF7700"
                                font.pixelSize: 10
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Fast, privacy-focused open web browser with multi-process Gecko rendering, container tabs, and add-on support."
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
                                    Text { anchors.centerIn: parent; text: "Fast Gecko"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 54; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Privacy"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 60; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Extensions"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                radius: 6
                                color: ffBtnMouse.containsMouse ? "#E65100" : "#FF7700"

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "🦊"; font.pixelSize: 11 }
                                    Text {
                                        text: "Launch Firefox"
                                        color: "#FFFFFF"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: ffBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        globalAppLauncher.launch("firefox");
                                        root.selectorNotice = "Launching Mozilla Firefox browser on host...";
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: ffCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: -1
                            onClicked: {
                                globalAudioService.playClick();
                                globalAppLauncher.launch("firefox");
                                root.selectorNotice = "Launching Mozilla Firefox browser on host...";
                            }
                        }
                    }

                    // ---------------------------------------------------------
                    // CARD 2: Google Chrome
                    // ---------------------------------------------------------
                    Rectangle {
                        id: cardChrome
                        Layout.preferredWidth: 245
                        Layout.preferredHeight: 390
                        radius: 12
                        color: crCardMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.18) : Qt.rgba(13/255, 17/255, 26/255, 0.8)
                        border.color: crCardMouse.containsMouse ? SRITECTheme.accentCyan : Qt.rgba(0/255, 229/255, 255/255, 0.35)
                        border.width: crCardMouse.containsMouse ? 2 : 1
                        scale: crCardMouse.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "WEB ENGINE"
                                    color: SRITECTheme.accentCyan
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.family: SRITECTheme.fontMono
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    Layout.preferredHeight: 16
                                    Layout.preferredWidth: 54
                                    radius: 8
                                    color: Qt.rgba(0/255, 229/255, 255/255, 0.2)
                                    border.color: SRITECTheme.accentCyan
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "GOOGLE"
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
                                    text: "⚪"
                                    font.pixelSize: 30
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Chrome"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Google Chromium Engine"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 10
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Industry-standard Chromium platform with Google ecosystem integration, rich DevTools, and high-performance V8 engine."
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
                                    Text { anchors.centerIn: parent; text: "Chromium"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 54; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "DevTools"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 60; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "V8 Engine"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                radius: 6
                                color: crBtnMouse.containsMouse ? Qt.rgba(0/255, 255/255, 255/255, 1.0) : SRITECTheme.accentCyan

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "⚪"; color: SRITECTheme.backgroundVoid; font.pixelSize: 11 }
                                    Text {
                                        text: "Launch Chrome"
                                        color: SRITECTheme.backgroundVoid
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: crBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        if (globalAppLauncher.isAvailable("chrome")) {
                                            globalAppLauncher.launch("chrome");
                                            root.selectorNotice = "Launching Google Chrome browser...";
                                        } else {
                                            globalBrowserBackend.navigate("https://google.com");
                                            root.currentView = "browser";
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: crCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: -1
                            onClicked: {
                                globalAudioService.playClick();
                                if (globalAppLauncher.isAvailable("chrome")) {
                                    globalAppLauncher.launch("chrome");
                                    root.selectorNotice = "Launching Google Chrome browser...";
                                } else {
                                    globalBrowserBackend.navigate("https://google.com");
                                    root.currentView = "browser";
                                }
                            }
                        }
                    }

                    // ---------------------------------------------------------
                    // CARD 3: Microsoft Edge
                    // ---------------------------------------------------------
                    Rectangle {
                        id: cardEdge
                        Layout.preferredWidth: 245
                        Layout.preferredHeight: 390
                        radius: 12
                        color: edCardMouse.containsMouse ? Qt.rgba(0/255, 245/255, 160/255, 0.18) : Qt.rgba(13/255, 17/255, 26/255, 0.8)
                        border.color: edCardMouse.containsMouse ? SRITECTheme.accentEmerald : Qt.rgba(0/255, 245/255, 160/255, 0.35)
                        border.width: edCardMouse.containsMouse ? 2 : 1
                        scale: edCardMouse.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "COPILOT AI"
                                    color: SRITECTheme.accentEmerald
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.family: SRITECTheme.fontMono
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    Layout.preferredHeight: 16
                                    Layout.preferredWidth: 64
                                    radius: 8
                                    color: Qt.rgba(0/255, 245/255, 160/255, 0.2)
                                    border.color: SRITECTheme.accentEmerald
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "MICROSOFT"
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
                                    text: "🔵"
                                    font.pixelSize: 30
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Edge"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Microsoft Copilot Engine"
                                color: SRITECTheme.accentEmerald
                                font.pixelSize: 10
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Optimized Chromium browser integrated with Microsoft Copilot AI, vertical tab layout, and smart tracking defense."
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
                                    Text { anchors.centerIn: parent; text: "Copilot AI"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 60; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Vertical Tabs"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 54; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Security"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                radius: 6
                                color: edBtnMouse.containsMouse ? Qt.rgba(0/255, 220/255, 140/255, 1.0) : SRITECTheme.accentEmerald

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "🔵"; font.pixelSize: 11 }
                                    Text {
                                        text: "Launch Edge"
                                        color: SRITECTheme.backgroundVoid
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: edBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        if (globalAppLauncher.isAvailable("edge")) {
                                            globalAppLauncher.launch("edge");
                                            root.selectorNotice = "Launching Microsoft Edge browser...";
                                        } else {
                                            globalBrowserBackend.navigate("https://bing.com");
                                            root.currentView = "browser";
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: edCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: -1
                            onClicked: {
                                globalAudioService.playClick();
                                if (globalAppLauncher.isAvailable("edge")) {
                                    globalAppLauncher.launch("edge");
                                    root.selectorNotice = "Launching Microsoft Edge browser...";
                                } else {
                                    globalBrowserBackend.navigate("https://bing.com");
                                    root.currentView = "browser";
                                }
                            }
                        }
                    }

                    // ---------------------------------------------------------
                    // CARD 4: Opera Browser
                    // ---------------------------------------------------------
                    Rectangle {
                        id: cardOpera
                        Layout.preferredWidth: 245
                        Layout.preferredHeight: 390
                        radius: 12
                        color: opCardMouse.containsMouse ? Qt.rgba(255/255, 59/255, 92/255, 0.18) : Qt.rgba(13/255, 17/255, 26/255, 0.8)
                        border.color: opCardMouse.containsMouse ? SRITECTheme.accentCrimson : Qt.rgba(255/255, 59/255, 92/255, 0.35)
                        border.width: opCardMouse.containsMouse ? 2 : 1
                        scale: opCardMouse.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "WEB PORTAL"
                                    color: SRITECTheme.accentCrimson
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.family: SRITECTheme.fontMono
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    Layout.preferredHeight: 16
                                    Layout.preferredWidth: 54
                                    radius: 8
                                    color: Qt.rgba(255/255, 59/255, 92/255, 0.2)
                                    border.color: SRITECTheme.accentCrimson
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "OPERA GX"
                                        color: SRITECTheme.accentCrimson
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
                                color: Qt.rgba(255/255, 59/255, 92/255, 0.22)
                                border.color: SRITECTheme.accentCrimson
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "🔴"
                                    font.pixelSize: 30
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Opera"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Opera Mini & GX Platform"
                                color: SRITECTheme.accentCrimson
                                font.pixelSize: 10
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Feature-rich portal with integrated free VPN, sidebar messengers, tab workspaces, and resource limiters."
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
                                    Text { anchors.centerIn: parent; text: "Free VPN"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 62; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Workspaces"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 50; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Aria AI"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                radius: 6
                                color: opBtnMouse.containsMouse ? "#D32F2F" : SRITECTheme.accentCrimson

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "🔴"; font.pixelSize: 11 }
                                    Text {
                                        text: "Launch Opera"
                                        color: "#FFFFFF"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: opBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        if (globalAppLauncher.isAvailable("opera")) {
                                            globalAppLauncher.launch("opera");
                                            root.selectorNotice = "Launching Opera browser...";
                                        } else {
                                            globalBrowserBackend.navigate("https://opera.com");
                                            root.currentView = "browser";
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: opCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: -1
                            onClicked: {
                                globalAudioService.playClick();
                                if (globalAppLauncher.isAvailable("opera")) {
                                    globalAppLauncher.launch("opera");
                                    root.selectorNotice = "Launching Opera browser...";
                                } else {
                                    globalBrowserBackend.navigate("https://opera.com");
                                    root.currentView = "browser";
                                }
                            }
                        }
                    }

                    // ---------------------------------------------------------
                    // CARD 5: NEBULA Web & AI Portal (Internal)
                    // ---------------------------------------------------------
                    Rectangle {
                        id: cardNebulaPortal
                        Layout.preferredWidth: 245
                        Layout.preferredHeight: 390
                        radius: 12
                        color: npCardMouse.containsMouse ? Qt.rgba(139/255, 92/255, 246/255, 0.22) : Qt.rgba(13/255, 17/255, 26/255, 0.8)
                        border.color: npCardMouse.containsMouse ? SRITECTheme.accentViolet : Qt.rgba(139/255, 92/255, 246/255, 0.4)
                        border.width: npCardMouse.containsMouse ? 2 : 1.5
                        scale: npCardMouse.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "IN-OS DESKTOP"
                                    color: SRITECTheme.accentViolet
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
                                    border.color: SRITECTheme.accentViolet
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "INTEGRATED"
                                        color: SRITECTheme.accentViolet
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
                                border.color: SRITECTheme.accentViolet
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "✦"
                                    color: SRITECTheme.accentViolet
                                    font.pixelSize: 30
                                    font.bold: true
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "NEBULA Portal"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Self-Contained Spatial Browser"
                                color: SRITECTheme.accentViolet
                                font.pixelSize: 10
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Built-in sandboxed browser with direct DuckDuckGo search, ChatGPT, Gemini, and Claude AI portals, and zero data leakage."
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
                                    Text { anchors.centerIn: parent; text: "DuckDuckGo"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 64; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "AI Portals"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 18; Layout.preferredWidth: 50; radius: 4
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.06)
                                    Text { anchors.centerIn: parent; text: "Sandbox"; color: SRITECTheme.textSecondary; font.pixelSize: 8 }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                radius: 6
                                color: npBtnMouse.containsMouse ? "#7C3AED" : SRITECTheme.accentViolet

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "✦"; color: "#FFFFFF"; font.pixelSize: 11 }
                                    Text {
                                        text: "Open Web Portal"
                                        color: "#FFFFFF"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: npBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        root.currentView = "browser";
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: npCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: -1
                            onClicked: {
                                globalAudioService.playClick();
                                root.currentView = "browser";
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
                        Text { text: "🌐"; font.pixelSize: 10 }
                        Text { text: "Default Engine:"; color: SRITECTheme.textTertiary; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                        Text { text: globalBrowserBackend.activeUrl; color: SRITECTheme.textPrimary; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                    }

                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; color: SRITECTheme.borderSubtle }

                    RowLayout {
                        spacing: 4
                        Text { text: "🔒"; color: SRITECTheme.accentEmerald; font.pixelSize: 10 }
                        Text { text: "TLS 1.3 Strict CA • Sandboxed"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
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
    // VIEW 2: INTERNAL BROWSER INTERFACE ("browser")
    // =========================================================================
    Item {
        id: internalBrowserView
        anchors.fill: parent
        visible: root.currentView === "browser"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // =================================================================
            // 1. Browser Tab Strip & Switcher
            // =================================================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                color: Qt.rgba(13/255, 17/255, 26/255, 0.95)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    // Back to Browser Engine Hub Button
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: hubBtnRow.implicitWidth + 14
                        radius: 4
                        color: backHubMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.25) : Qt.rgba(0/255, 229/255, 255/255, 0.12)
                        border.color: SRITECTheme.accentCyan
                        border.width: 1

                        RowLayout {
                            id: hubBtnRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "⊞"; color: SRITECTheme.accentCyan; font.pixelSize: 12; font.bold: true }
                            Text { text: "Browser Hub"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            id: backHubMouse
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

                    // Tab Repeater with Fluid In/Out Animations
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        RowLayout {
                            spacing: 4

                            Repeater {
                                model: globalBrowserBackend.tabs

                                delegate: Item {
                                    id: tabItem
                                    required property var modelData
                                    property real fullWidth: Math.min(220, Math.max(120, tabText.implicitWidth + 50))
                                    property bool isClosing: false

                                    Layout.preferredHeight: 28
                                    Layout.preferredWidth: isClosing ? 0 : fullWidth
                                    clip: true

                                    Behavior on Layout.preferredWidth {
                                        NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
                                    }

                                    Rectangle {
                                        id: tabCard
                                        anchors.fill: parent
                                        radius: 4
                                        color: tabItem.modelData.isActive ? Qt.rgba(0/255, 229/255, 255/255, 0.20) :
                                               (tabMouse.containsMouse ? Qt.rgba(19/255, 26/255, 40/255, 0.85) : Qt.rgba(19/255, 26/255, 40/255, 0.6))
                                        border.color: tabItem.modelData.isActive ? SRITECTheme.accentCyan :
                                                      (tabMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.4) : SRITECTheme.borderSubtle)
                                        border.width: 1

                                        Component.onCompleted: {
                                            tabCard.scale = 0.65;
                                            tabCard.opacity = 0.0;
                                            enterAnim.start();
                                        }

                                        ParallelAnimation {
                                            id: enterAnim
                                            NumberAnimation { target: tabCard; property: "scale"; from: 0.65; to: 1.0; duration: 220; easing.type: Easing.OutBack }
                                            NumberAnimation { target: tabCard; property: "opacity"; from: 0.0; to: 1.0; duration: 180; easing.type: Easing.OutQuad }
                                        }

                                        SequentialAnimation {
                                            id: exitAnim
                                            ParallelAnimation {
                                                NumberAnimation { target: tabCard; property: "scale"; to: 0.6; duration: 160; easing.type: Easing.InQuad }
                                                NumberAnimation { target: tabCard; property: "opacity"; to: 0.0; duration: 160; easing.type: Easing.InQuad }
                                            }
                                            ScriptAction {
                                                script: globalBrowserBackend.closeTab(tabItem.modelData.id)
                                            }
                                        }

                                        function triggerClose() {
                                            if (!tabItem.isClosing) {
                                                tabItem.isClosing = true;
                                                exitAnim.start();
                                            }
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10
                                            anchors.rightMargin: 6
                                            spacing: 6

                                            Text {
                                                text: tabItem.modelData.isSecure ? "🔒" : "🌐"
                                                font.pixelSize: 10
                                            }

                                            Text {
                                                id: tabText
                                                Layout.fillWidth: true
                                                text: tabItem.modelData.title
                                                color: tabItem.modelData.isActive ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                                font.pixelSize: 11
                                                font.bold: tabItem.modelData.isActive
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
                                                        tabItem.triggerClose();
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: tabMouse
                                            anchors.fill: parent
                                            z: -1
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                globalAudioService.playClick();
                                                globalBrowserBackend.activeTabId = tabItem.modelData.id;
                                            }
                                        }
                                    }
                                }
                            }

                            // Add New Tab Button
                            Rectangle {
                                Layout.preferredWidth: 26
                                Layout.preferredHeight: 26
                                radius: 4
                                color: addTabMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                                border.color: addTabMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "+"
                                    color: SRITECTheme.accentCyan
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                MouseArea {
                                    id: addTabMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        globalBrowserBackend.createTab("https://duckduckgo.com", "DuckDuckGo");
                                    }
                                }
                            }
                        }
                    }

                    // Quick Launch: Firefox
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: ffQuickRow.implicitWidth + 14
                        radius: 4
                        color: ffQuickMouse.containsMouse ? Qt.rgba(255/255, 119/255, 0/255, 0.25) : "transparent"
                        border.color: "#FF7700"
                        border.width: 1

                        RowLayout {
                            id: ffQuickRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "🦊"; font.pixelSize: 10 }
                            Text { text: "Firefox"; color: "#FF9933"; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            id: ffQuickMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                globalAppLauncher.launch("firefox");
                            }
                        }
                    }

                    // Quick Launch: Chrome
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: crQuickRow.implicitWidth + 14
                        radius: 4
                        color: crQuickMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.25) : "transparent"
                        border.color: SRITECTheme.accentCyan
                        border.width: 1

                        RowLayout {
                            id: crQuickRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "⚪"; font.pixelSize: 9 }
                            Text { text: "Chrome"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            id: crQuickMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                if (globalAppLauncher.isAvailable("chrome")) {
                                    globalAppLauncher.launch("chrome");
                                } else {
                                    globalBrowserBackend.navigate("https://google.com");
                                }
                            }
                        }
                    }

                    // Quick Launch: Edge
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: edQuickRow.implicitWidth + 14
                        radius: 4
                        color: edQuickMouse.containsMouse ? Qt.rgba(0/255, 245/255, 160/255, 0.25) : "transparent"
                        border.color: SRITECTheme.accentEmerald
                        border.width: 1

                        RowLayout {
                            id: edQuickRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "🔵"; font.pixelSize: 9 }
                            Text { text: "Edge"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.bold: true }
                        }

                        MouseArea {
                            id: edQuickMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                if (globalAppLauncher.isAvailable("edge")) {
                                    globalAppLauncher.launch("edge");
                                } else {
                                    globalBrowserBackend.navigate("https://bing.com");
                                }
                            }
                        }
                    }

                    // Private Shield Mode Button
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: privateRow.implicitWidth + 14
                        radius: 4
                        color: globalBrowserBackend.isPrivateBrowsing ? Qt.rgba(139/255, 92/255, 246/255, 0.25) : "transparent"
                        border.color: globalBrowserBackend.isPrivateBrowsing ? SRITECTheme.accentViolet : SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            id: privateRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "👁"; font.pixelSize: 10 }
                            Text {
                                text: globalBrowserBackend.isPrivateBrowsing ? "PRIVATE" : "SHIELD"
                                color: globalBrowserBackend.isPrivateBrowsing ? SRITECTheme.accentViolet : SRITECTheme.textSecondary
                                font.pixelSize: 9
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                globalBrowserBackend.isPrivateBrowsing = !globalBrowserBackend.isPrivateBrowsing;
                            }
                        }
                    }
                }
            }

            // =================================================================
            // 2. Navigation Bar (Address Bar, Back/Forward, Security Lock)
            // =================================================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: SRITECTheme.backgroundElevated
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    // Back Button
                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 6
                        color: navBackMouse.containsMouse && globalBrowserBackend.canGoBack ? SRITECTheme.backgroundHover : "transparent"
                        opacity: globalBrowserBackend.canGoBack ? 1.0 : 0.4

                        Text {
                            anchors.centerIn: parent
                            text: "◀"
                            color: SRITECTheme.accentCyan
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: navBackMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: globalBrowserBackend.canGoBack ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (globalBrowserBackend.canGoBack) {
                                    globalAudioService.playClick();
                                    globalBrowserBackend.goBack();
                                }
                            }
                        }
                    }

                    // Forward Button
                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 6
                        color: navFwdMouse.containsMouse && globalBrowserBackend.canGoForward ? SRITECTheme.backgroundHover : "transparent"
                        opacity: globalBrowserBackend.canGoForward ? 1.0 : 0.4

                        Text {
                            anchors.centerIn: parent
                            text: "▶"
                            color: SRITECTheme.accentCyan
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: navFwdMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: globalBrowserBackend.canGoForward ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (globalBrowserBackend.canGoForward) {
                                    globalAudioService.playClick();
                                    globalBrowserBackend.goForward();
                                }
                            }
                        }
                    }

                    // Reload Button
                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 6
                        color: navReloadMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "↻"
                            color: SRITECTheme.accentCyan
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: navReloadMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                globalBrowserBackend.reload();
                            }
                        }
                    }

                    // TLS Lock / Security Certificate Status
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: tlsRow.implicitWidth + 14
                        radius: 14
                        color: Qt.rgba(0/255, 245/255, 160/255, 0.15)
                        border.color: SRITECTheme.accentEmerald
                        border.width: 1

                        RowLayout {
                            id: tlsRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "🔒"; font.pixelSize: 9 }
                            Text {
                                text: "TLS 1.3"
                                color: SRITECTheme.accentEmerald
                                font.pixelSize: 9
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }
                        }
                    }

                    // Main Omni Address Input Bar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        radius: 6
                        color: Qt.rgba(7/255, 10/255, 15/255, 0.7)
                        border.color: addressInput.activeFocus ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 6

                            Text {
                                text: "🔍"
                                font.pixelSize: 10
                            }

                            TextField {
                                id: addressInput
                                Layout.fillWidth: true
                                text: globalBrowserBackend.activeUrl
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 11
                                font.family: SRITECTheme.fontMono
                                background: null
                                selectByMouse: true

                                onAccepted: {
                                    var val = text.trim();
                                    if (val.length > 0) {
                                        globalAudioService.playClick();
                                        globalBrowserBackend.navigate(val);
                                    }
                                }
                            }

                            // Bookmark Active URL Button
                            Rectangle {
                                Layout.preferredWidth: 22
                                Layout.preferredHeight: 22
                                radius: 4
                                color: bmMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: globalBrowserBackend.isBookmarked(globalBrowserBackend.activeUrl) ? "★" : "☆"
                                    color: globalBrowserBackend.isBookmarked(globalBrowserBackend.activeUrl) ? SRITECTheme.accentAmber : SRITECTheme.textSecondary
                                    font.pixelSize: 12
                                }

                                MouseArea {
                                    id: bmMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        if (globalBrowserBackend.isBookmarked(globalBrowserBackend.activeUrl)) {
                                            globalBrowserBackend.removeBookmark(globalBrowserBackend.activeUrl);
                                        } else {
                                            globalBrowserBackend.addBookmark(globalBrowserBackend.activeTitle, globalBrowserBackend.activeUrl);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // History Drawer Toggle
                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 6
                        color: histMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                        border.color: root.showHistoryDrawer ? SRITECTheme.accentCyan : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "⌛"
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: histMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                root.showHistoryDrawer = !root.showHistoryDrawer;
                            }
                        }
                    }
                }
            }

            // =================================================================
            // 3. Bookmarks & Quick AI Portals Bar
            // =================================================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "PORTALS:"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1.0
                        font.family: SRITECTheme.fontMono
                    }

                    Repeater {
                        model: globalBrowserBackend.bookmarks

                        delegate: Rectangle {
                            required property var modelData
                            Layout.preferredHeight: 22
                            Layout.preferredWidth: bmText.implicitWidth + 18
                            radius: 4
                            color: bmBarMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.15) : Qt.rgba(19/255, 26/255, 40/255, 0.4)
                            border.color: bmBarMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    text: modelData.title === "ChatGPT" ? "⚡" :
                                          modelData.title === "Google Gemini" ? "✦" :
                                          modelData.title === "Anthropic Claude" ? "◈" : "★"
                                    color: modelData.title === "ChatGPT" ? SRITECTheme.accentEmerald :
                                           modelData.title === "Google Gemini" ? SRITECTheme.accentCyan :
                                           modelData.title === "Anthropic Claude" ? SRITECTheme.accentAmber : SRITECTheme.textSecondary
                                    font.pixelSize: 9
                                }
                                Text {
                                    id: bmText
                                    text: modelData.title
                                    color: bmBarMouse.containsMouse ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                    font.pixelSize: 10
                                }
                            }

                            MouseArea {
                                id: bmBarMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    globalAudioService.playClick();
                                    globalBrowserBackend.navigate(modelData.url);
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "SECURITY: STRICT SANDBOX"
                        color: SRITECTheme.accentEmerald
                        font.pixelSize: 9
                        font.bold: true
                        font.family: SRITECTheme.fontMono
                    }
                }
            }

            // =================================================================
            // 4. Main Web & AI Portal Viewport
            // =================================================================
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                StackLayout {
                    anchors.fill: parent
                    currentIndex: {
                        var u = globalBrowserBackend.activeUrl.toLowerCase();
                        if (u.indexOf("chatgpt.com") !== -1) return 1;
                        if (u.indexOf("gemini.google.com") !== -1) return 2;
                        if (u.indexOf("claude.ai") !== -1) return 3;
                        return 0; // Default: Intelligent Search & Research Assistant
                    }

                    // View 0: Intelligent Search & Research Assistant
                    Rectangle {
                        color: "#05080E"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 16

                            // Header Status Capsule
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                radius: SRITECTheme.radiusMedium
                                color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                                border.color: SRITECTheme.accentCyan
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 12

                                    Text { text: "🌐"; font.pixelSize: 16 }
                                    Text {
                                        text: "INTELLIGENT SEARCH & RESEARCH ASSISTANT"
                                        color: SRITECTheme.accentCyan
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.letterSpacing: 1.5
                                    }

                                    Item { Layout.fillWidth: true }

                                    Rectangle {
                                        Layout.preferredHeight: 22
                                        Layout.preferredWidth: noticeRow.implicitWidth + 14
                                        radius: 11
                                        color: Qt.rgba(255/255, 184/255, 0/255, 0.15)
                                        border.color: SRITECTheme.accentAmber
                                        border.width: 1

                                        RowLayout {
                                            id: noticeRow
                                            anchors.centerIn: parent
                                            spacing: 4
                                            Text { text: "⚠"; color: SRITECTheme.accentAmber; font.pixelSize: 9 }
                                            Text {
                                                text: "Chromium Engine Pending Approval (qt6-webengine-dev)"
                                                color: SRITECTheme.accentAmber
                                                font.pixelSize: 9
                                                font.family: SRITECTheme.fontMono
                                            }
                                        }
                                    }
                                }
                            }

                            // Middle Split: Telemetry Radar & Search Results
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 16

                                // Hologram Radar Card
                                Rectangle {
                                    Layout.preferredWidth: 380
                                    Layout.fillHeight: true
                                    radius: SRITECTheme.radiusLarge
                                    color: Qt.rgba(13/255, 17/255, 26/255, 0.7)
                                    border.color: SRITECTheme.borderSubtle
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 18
                                        spacing: 14

                                        Text {
                                            text: "RESEARCH SPATIAL TELEMETRY"
                                            color: SRITECTheme.accentCyan
                                            font.pixelSize: 11
                                            font.bold: true
                                            font.family: SRITECTheme.fontMono
                                        }

                                        Canvas {
                                            id: globeCanvas
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 180
                                            property real angle: 0

                                            Timer {
                                                interval: 33
                                                running: true
                                                repeat: true
                                                onTriggered: {
                                                    globeCanvas.angle += 0.02;
                                                    globeCanvas.requestPaint();
                                                }
                                            }

                                            onPaint: {
                                                var ctx = getContext("2d");
                                                ctx.clearRect(0, 0, width, height);

                                                var cx = width / 2;
                                                var cy = height / 2;
                                                var r = 70;

                                                ctx.strokeStyle = "#00E5FF";
                                                ctx.lineWidth = 1.5;
                                                ctx.beginPath();
                                                ctx.arc(cx, cy, r, 0, Math.PI * 2);
                                                ctx.stroke();

                                                ctx.lineWidth = 1.0;
                                                ctx.strokeStyle = "rgba(0, 229, 255, 0.4)";
                                                for (var i = -2; i <= 2; ++i) {
                                                    ctx.beginPath();
                                                    ctx.ellipse(cx, cy, Math.abs(Math.cos(angle + i * 0.4)) * r, r, 0, 0, Math.PI * 2);
                                                    ctx.stroke();
                                                }

                                                ctx.fillStyle = "#00F5A0";
                                                ctx.beginPath();
                                                ctx.arc(cx, cy, 4, 0, Math.PI * 2);
                                                ctx.fill();
                                            }
                                        }

                                        Text {
                                            text: "Active Query: " + globalBrowserBackend.activeUrl + "\n" +
                                                  "Domain:       " + globalBrowserBackend.activeTitle + "\n" +
                                                  "TLS Protocol: TLS 1.3 / Strict CA\n" +
                                                  "AI Synthesis: Connected to LISA Neural Engine\n" +
                                                  "Privacy:      " + (globalBrowserBackend.isPrivateBrowsing ? "Private Shield Active" : "Standard History Recording")
                                            color: SRITECTheme.textSecondary
                                            font.pixelSize: 10
                                            font.family: SRITECTheme.fontMono
                                            lineHeight: 1.5
                                        }

                                        Item { Layout.fillHeight: true }
                                    }
                                }

                                // Interactive Search & Portal Results Stream
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: SRITECTheme.radiusLarge
                                    color: Qt.rgba(13/255, 17/255, 26/255, 0.7)
                                    border.color: SRITECTheme.borderSubtle
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 18
                                        spacing: 12

                                        RowLayout {
                                            spacing: 8
                                            Text { text: "✦"; color: SRITECTheme.accentCyan; font.pixelSize: 12 }
                                            Text {
                                                text: "WEB & AI RESEARCH RESULTS"
                                                color: SRITECTheme.textPrimary
                                                font.pixelSize: 12
                                                font.bold: true
                                            }
                                        }

                                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                                        ScrollView {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            ColumnLayout {
                                                width: parent.width
                                                spacing: 12

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 90
                                                    radius: 8
                                                    color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                                    border.color: SRITECTheme.borderSubtle
                                                    border.width: 1

                                                    ColumnLayout {
                                                        anchors.fill: parent
                                                        anchors.margins: 12
                                                        spacing: 4
                                                        Text { text: "DuckDuckGo Privacy-First Web Search"; color: SRITECTheme.accentCyan; font.pixelSize: 12; font.bold: true }
                                                        Text { text: "https://duckduckgo.com"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                                                        Text { text: "Query formulated securely without third-party tracking. TLS certificate verification active."; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 90
                                                    radius: 8
                                                    color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                                    border.color: SRITECTheme.borderSubtle
                                                    border.width: 1

                                                    ColumnLayout {
                                                        anchors.fill: parent
                                                        anchors.margins: 12
                                                        spacing: 4
                                                        Text { text: "ChatGPT — OpenAI Reasoning Intelligence"; color: SRITECTheme.accentEmerald; font.pixelSize: 12; font.bold: true }
                                                        Text { text: "https://chatgpt.com"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                                                        Text { text: "Open conversational AI portal. Integrated directly through NEBULA Unified AI Gateway."; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            globalAudioService.playClick();
                                                            globalBrowserBackend.openAIPortal("chatgpt");
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 90
                                                    radius: 8
                                                    color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                                    border.color: SRITECTheme.borderSubtle
                                                    border.width: 1

                                                    ColumnLayout {
                                                        anchors.fill: parent
                                                        anchors.margins: 12
                                                        spacing: 4
                                                        Text { text: "Google Gemini — Multimodal Neural Reasoning"; color: SRITECTheme.accentCyan; font.pixelSize: 12; font.bold: true }
                                                        Text { text: "https://gemini.google.com"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                                                        Text { text: "Access Google Gemini models, live vision and multimodal intelligence."; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            globalAudioService.playClick();
                                                            globalBrowserBackend.openAIPortal("gemini");
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 90
                                                    radius: 8
                                                    color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                                    border.color: SRITECTheme.borderSubtle
                                                    border.width: 1

                                                    ColumnLayout {
                                                        anchors.fill: parent
                                                        anchors.margins: 12
                                                        spacing: 4
                                                        Text { text: "Anthropic Claude — Constitutional AI Studio"; color: SRITECTheme.accentAmber; font.pixelSize: 12; font.bold: true }
                                                        Text { text: "https://claude.ai"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                                                        Text { text: "Deep analytical synthesis and constitutional safety alignment."; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            globalAudioService.playClick();
                                                            globalBrowserBackend.openAIPortal("claude");
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

                    // View 1: ChatGPT Dedicated Web Portal
                    Rectangle {
                        color: "#070B12"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 52
                                radius: 8
                                color: Qt.rgba(0/255, 245/255, 160/255, 0.12)
                                border.color: SRITECTheme.accentEmerald
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 10

                                    Text { text: "⚡"; color: SRITECTheme.accentEmerald; font.pixelSize: 18 }
                                    Text { text: "ChatGPT Web Portal — OpenAI"; color: SRITECTheme.textPrimary; font.pixelSize: 14; font.bold: true }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "https://chatgpt.com"; color: SRITECTheme.accentEmerald; font.pixelSize: 11; font.family: SRITECTheme.fontMono }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: SRITECTheme.radiusLarge
                                color: Qt.rgba(13/255, 17/255, 26/255, 0.8)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 16

                                    AIIcon { Layout.alignment: Qt.AlignHCenter; iconId: "chatgpt"; size: 64; showTile: true }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "OpenAI ChatGPT Portal"; color: SRITECTheme.textPrimary; font.pixelSize: 18; font.bold: true }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Running in NEBULA Secure Sandbox • Zero API Keys Exposed to Web"
                                        color: SRITECTheme.accentEmerald
                                        font.pixelSize: 11
                                        font.family: SRITECTheme.fontMono
                                    }
                                    Button {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Open in LISA AI Studio (Native Gateway)"
                                        onClicked: {
                                            globalAudioService.playClick();
                                            globalAppLaunchManager.requestAppLaunch("assistant");
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // View 2: Google Gemini Dedicated Web Portal
                    Rectangle {
                        color: "#070B12"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 52
                                radius: 8
                                color: Qt.rgba(0/255, 229/255, 255/255, 0.12)
                                border.color: SRITECTheme.accentCyan
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 10

                                    Text { text: "✦"; color: SRITECTheme.accentCyan; font.pixelSize: 18 }
                                    Text { text: "Google Gemini Web Portal"; color: SRITECTheme.textPrimary; font.pixelSize: 14; font.bold: true }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "https://gemini.google.com"; color: SRITECTheme.accentCyan; font.pixelSize: 11; font.family: SRITECTheme.fontMono }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: SRITECTheme.radiusLarge
                                color: Qt.rgba(13/255, 17/255, 26/255, 0.8)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 16

                                    AIIcon { Layout.alignment: Qt.AlignHCenter; iconId: "gemini"; size: 64; showTile: true }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Google Gemini Multimodal Portal"; color: SRITECTheme.textPrimary; font.pixelSize: 18; font.bold: true }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Secure Sandboxed Web Session • TLS 1.3 Certified"
                                        color: SRITECTheme.accentCyan
                                        font.pixelSize: 11
                                        font.family: SRITECTheme.fontMono
                                    }
                                    Button {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Switch to Gemini Native Provider"
                                        onClicked: {
                                            globalAudioService.playClick();
                                            globalAIBridge.selectedProvider = "gemini";
                                            globalAppLaunchManager.requestAppLaunch("assistant");
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // View 3: Anthropic Claude Dedicated Web Portal
                    Rectangle {
                        color: "#070B12"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 52
                                radius: 8
                                color: Qt.rgba(255/255, 184/255, 0/255, 0.12)
                                border.color: SRITECTheme.accentAmber
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 10

                                    Text { text: "◈"; color: SRITECTheme.accentAmber; font.pixelSize: 18 }
                                    Text { text: "Anthropic Claude Web Portal"; color: SRITECTheme.textPrimary; font.pixelSize: 14; font.bold: true }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "https://claude.ai"; color: SRITECTheme.accentAmber; font.pixelSize: 11; font.family: SRITECTheme.fontMono }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: SRITECTheme.radiusLarge
                                color: Qt.rgba(13/255, 17/255, 26/255, 0.8)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 16

                                    AIIcon { Layout.alignment: Qt.AlignHCenter; iconId: "claude"; size: 64; showTile: true }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Anthropic Claude Constitutional Studio"; color: SRITECTheme.textPrimary; font.pixelSize: 18; font.bold: true }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Constitutional Reasoning Engine • Session Isolated"
                                        color: SRITECTheme.accentAmber
                                        font.pixelSize: 11
                                        font.family: SRITECTheme.fontMono
                                    }
                                    Button {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Switch to Claude Native Provider"
                                        onClicked: {
                                            globalAudioService.playClick();
                                            globalAIBridge.selectedProvider = "claude";
                                            globalAppLaunchManager.requestAppLaunch("assistant");
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // History Slide-out Drawer
                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 320
                    visible: root.showHistoryDrawer
                    color: Qt.rgba(13/255, 17/255, 26/255, 0.96)
                    border.color: SRITECTheme.accentCyan
                    border.width: 1
                    z: 20

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        RowLayout {
                            Text { text: "BROWSING HISTORY"; color: SRITECTheme.accentCyan; font.pixelSize: 11; font.bold: true; font.family: SRITECTheme.fontMono }
                            Item { Layout.fillWidth: true }
                            Button {
                                text: "Clear"
                                onClicked: {
                                    globalAudioService.playClick();
                                    globalBrowserBackend.clearHistory();
                                }
                            }
                            Button {
                                text: "✕"
                                onClicked: {
                                    globalAudioService.playClick();
                                    root.showHistoryDrawer = false;
                                }
                            }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: globalBrowserBackend.history
                            clip: true

                            delegate: Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 48
                                color: "transparent"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    spacing: 2
                                    Text { text: modelData.title; color: SRITECTheme.textPrimary; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight }
                                    Text { text: modelData.timestamp + " • " + modelData.url; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; elide: Text.ElideRight }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        globalBrowserBackend.navigate(modelData.url);
                                        root.showHistoryDrawer = false;
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
