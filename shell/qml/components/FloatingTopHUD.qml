import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    implicitHeight: 46
    implicitWidth: Math.min(parent ? parent.width - 48 : 1200, 1160)
    radius: 23
    color: Qt.rgba(13/255, 17/255, 26/255, 0.72)
    border.color: SRITECTheme.borderSubtle
    border.width: 1

    signal toggleFullscreen()
    signal performanceModeSelected(string mode)
    signal calendarRequested()
    signal quickSettingsRequested()
    signal notificationCenterRequested()
    signal universalSearchRequested()
    signal openAppDrawer()
    signal powerControlRequested()
    signal screenshotRequested()
    signal screenRecordRequested()
    signal jarvisHUDRequested()

    property string currentPerformanceMode: globalDesktopManager.performanceMode
    property string activeWorkspaceTitle: "NEBULA [Desktop Space]"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        // Left: Brand Identity & Active Workspace Capsule
        RowLayout {
            spacing: 10

            // Glowing Brand Core
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 14
                color: Qt.rgba(0/255, 229/255, 255/255, 0.15)
                border.color: SRITECTheme.accentCyan
                border.width: 1.5

                Text {
                    anchors.centerIn: parent
                    text: "✦"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 13
                    font.bold: true
                }
            }

            Text {
                text: "NEBULA"
                color: SRITECTheme.textPrimary
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 2
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                color: SRITECTheme.borderSubtle
            }

            Text {
                text: root.activeWorkspaceTitle
                color: SRITECTheme.accentCyan
                font.pixelSize: 10
                font.family: SRITECTheme.fontMono
                font.bold: true
            }
        }

        Item { Layout.fillWidth: true }

        // Center: Unified Neural Engine Gateway Status Pill
        Rectangle {
            Layout.preferredHeight: 28
            implicitWidth: gatewayRow.implicitWidth + 24
            radius: 14
            color: SRITECTheme.backgroundElevated
            border.color: globalAIBridge.connectionState === "Error" ? SRITECTheme.accentCrimson :
                          globalAIBridge.isGenerating ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
            border.width: 1

            Behavior on border.color { ColorAnimation { duration: SRITECTheme.animFast } }

            RowLayout {
                id: gatewayRow
                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 7
                    Layout.preferredHeight: 7
                    radius: 3.5
                    color: globalAIBridge.connectionState === "Error" ? SRITECTheme.accentCrimson :
                           globalAIBridge.isGenerating ? SRITECTheme.accentCyan :
                           globalAIBridge.connectionState === "Connecting" ? SRITECTheme.accentAmber : SRITECTheme.accentEmerald

                    SequentialAnimation on opacity {
                        running: globalAIBridge.isGenerating || globalAIBridge.connectionState === "Connecting"
                        loops: Animation.Infinite
                        PropertyAnimation { to: 0.2; duration: 400 }
                        PropertyAnimation { to: 1.0; duration: 400 }
                    }
                }

                Text {
                    text: globalAIBridge.isGenerating ?
                          "SYNTHESIZING (" + globalAIBridge.selectedProvider.toUpperCase() + ")" :
                          globalAIBridge.selectedProvider.toUpperCase() + " • " + globalAIBridge.selectedModel
                    color: globalAIBridge.connectionState === "Error" ? SRITECTheme.accentCrimson :
                           globalAIBridge.isGenerating ? SRITECTheme.accentCyan : SRITECTheme.textSecondary
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                }

                Text {
                    text: globalAIBridge.selectedProvider === "Mock" ?
                          "•  0ms (Local)" :
                          (globalAIBridge.selectedProvider === "Local AI (Ollama)" ?
                              "•  11434" : (globalAIBridge.hasApiKey ? "•  Key Active" : "•  Key Needed"))
                    color: !globalAIBridge.hasApiKey && globalAIBridge.selectedProvider !== "Mock" && globalAIBridge.selectedProvider !== "Local AI (Ollama)" ?
                           SRITECTheme.accentAmber : SRITECTheme.textTertiary
                    font.pixelSize: 9
                    font.family: SRITECTheme.fontMono
                }
            }
        }

        Item { Layout.fillWidth: true }

        // Right: Telemetry, Clock, Notifications & Controls
        RowLayout {
            spacing: 10

            // Search Trigger Button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 13
                color: srchMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "🔍"
                    font.pixelSize: 11
                }

                MouseArea {
                    id: srchMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        globalAudioService.playClick();
                        root.universalSearchRequested();
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                color: SRITECTheme.borderSubtle
            }

            // Real Hardware Status Mini-Indicators
            RowLayout {
                spacing: 8

                // Wired Network eno1
                Text {
                    text: "🖧"
                    font.pixelSize: 12
                    color: SRITECTheme.accentEmerald
                }

                // JARVIS Mic Indicator
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 12
                    color: globalJarvis && globalJarvis.isMicListening ? Qt.rgba(244/255, 114/255, 182/255, 0.25) :
                           (jarvisMicMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent")
                    border.color: globalJarvis && globalJarvis.isMicListening ? SRITECTheme.accentNeonPink : "transparent"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: globalJarvis && globalJarvis.isMicMuted ? "🔇" : "🎙"
                        font.pixelSize: 11
                        color: globalJarvis && globalJarvis.isMicListening ? SRITECTheme.accentNeonPink :
                               (globalJarvis && globalJarvis.isMicMuted ? SRITECTheme.accentCrimson : SRITECTheme.accentCyan)
                    }

                    MouseArea {
                        id: jarvisMicMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            globalAudioService.playClick();
                            root.jarvisHUDRequested();
                        }
                    }
                }

                // JARVIS Vision / Camera Status Indicator
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 12
                    color: globalJarvis && globalJarvis.isCameraActive ? Qt.rgba(0/255, 229/255, 255/255, 0.25) :
                           (jarvisCamMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent")
                    border.color: globalJarvis && globalJarvis.isCameraActive ? SRITECTheme.accentCyan : "transparent"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: globalJarvis && globalJarvis.isCameraActive ? "👁" : "📷"
                        font.pixelSize: 11
                        color: globalJarvis && globalJarvis.isCameraActive ? SRITECTheme.accentCyan : SRITECTheme.textTertiary
                    }

                    MouseArea {
                        id: jarvisCamMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            globalAudioService.playClick();
                            root.jarvisHUDRequested();
                        }
                    }
                }

                // Audio Volume Indicator (Clickable to Mute/Unmute)
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 12
                    color: volMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: globalAudioService.isMuted ? "🔇" : (globalAudioService.volume > 50 ? "🔊" : "🔉")
                        font.pixelSize: 12
                        color: globalAudioService.isMuted ? SRITECTheme.accentCrimson : SRITECTheme.textSecondary
                    }

                    MouseArea {
                        id: volMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.isMuted = !globalAudioService.isMuted;
                            globalAudioService.playClick();
                        }
                    }
                }

                // Power Source
                Text {
                    text: "🔌"
                    font.pixelSize: 12
                    color: SRITECTheme.accentCyan
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                color: SRITECTheme.borderSubtle
            }

            // Live Clock & Calendar Trigger
            Rectangle {
                Layout.preferredHeight: 26
                implicitWidth: clockLayout.implicitWidth + 12
                radius: 13
                color: clkMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                RowLayout {
                    id: clockLayout
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "📅"
                        font.pixelSize: 10
                    }

                    Text {
                        id: clockText
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 11
                        font.family: SRITECTheme.fontMono

                        function updateTime() {
                            var now = new Date();
                            clockText.text = Qt.formatTime(now, "hh:mm:ss AP");
                        }

                        Component.onCompleted: updateTime()
                    }
                }

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clockText.updateTime()
                }

                MouseArea {
                    id: clkMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        globalAudioService.playClick();
                        root.calendarRequested();
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                color: SRITECTheme.borderSubtle
            }

            // Notification Bell Trigger
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 13
                color: notifMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "🔔"
                    font.pixelSize: 12
                }

                Rectangle {
                    visible: globalDesktopManager.unreadNotificationsCount > 0
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: -1
                    width: 14
                    height: 14
                    radius: 7
                    color: SRITECTheme.accentCyan

                    Text {
                        anchors.centerIn: parent
                        text: globalDesktopManager.unreadNotificationsCount
                        color: SRITECTheme.backgroundVoid
                        font.pixelSize: 8
                        font.bold: true
                    }
                }

                MouseArea {
                    id: notifMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        globalAudioService.playClick();
                        root.notificationCenterRequested();
                    }
                }
            }

            // Quick Settings Trigger Button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 13
                color: qsMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "⚙"
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 13
                }

                MouseArea {
                    id: qsMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        globalAudioService.playClick();
                        root.quickSettingsRequested();
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                color: SRITECTheme.borderSubtle
            }

            // Fullscreen Toggle Button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 13
                color: fsMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "⛶"
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 12
                }

                MouseArea {
                    id: fsMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        globalAudioService.playClick();
                        root.toggleFullscreen();
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                color: SRITECTheme.borderSubtle
            }

            // Screenshot Capture Button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 13
                color: ssMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "📸"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: ssMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.screenshotRequested();
                    }
                }
            }

            // Screen Recorder Toggle Button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 13
                color: globalScreenCapture.isRecording ? SRITECTheme.accentCrimson :
                       (recMouse.containsMouse ? Qt.rgba(255/255, 23/255, 68/255, 0.2) : "transparent")

                Text {
                    anchors.centerIn: parent
                    text: globalScreenCapture.isRecording ? "⏹" : "🎥"
                    color: globalScreenCapture.isRecording ? SRITECTheme.backgroundVoid : SRITECTheme.textSecondary
                    font.pixelSize: 11
                }

                MouseArea {
                    id: recMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.screenRecordRequested();
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                color: SRITECTheme.borderSubtle
            }

            // System Power Control Button
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 14
                color: pwrMouse.containsMouse ? Qt.rgba(255/255, 23/255, 68/255, 0.25) : Qt.rgba(13/255, 17/255, 26/255, 0.8)
                border.color: pwrMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.borderSubtle
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "⏻"
                    color: pwrMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.textSecondary
                    font.pixelSize: 13
                    font.bold: true
                }

                MouseArea {
                    id: pwrMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        globalAudioService.playClick();
                        root.powerControlRequested();
                    }
                }
            }
        }
    }
}
