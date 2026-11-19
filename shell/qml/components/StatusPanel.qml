import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 48
    color: SRITECTheme.backgroundSurface
    border.color: SRITECTheme.borderSubtle
    border.width: 1

    signal toggleFullscreen()
    signal performanceModeSelected(string mode)
    signal calendarRequested()
    signal quickSettingsRequested()
    signal notificationCenterRequested()
    signal universalSearchRequested()

    property string currentPerformanceMode: "Balanced"
    property string activeWorkspaceTitle: "NEBULA [Home]"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 16

        // Left: Workspace Mode & Path
        RowLayout {
            spacing: 8
            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                radius: 4
                color: SRITECTheme.accentEmerald
            }
            Text {
                text: "WORKSPACE:"
                color: SRITECTheme.textTertiary
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1
            }
            Text {
                text: root.activeWorkspaceTitle
                color: SRITECTheme.textSecondary
                font.pixelSize: 11
                font.family: SRITECTheme.fontMono
            }
        }

        Item { Layout.fillWidth: true }

        // Center: Unified Neural Engine Gateway Status Pill
        Rectangle {
            Layout.preferredHeight: 28
            Layout.preferredWidth: pillRow.implicitWidth + 24
            radius: 14
            color: SRITECTheme.backgroundElevated
            border.color: globalAIBridge.connectionState === "Error" ? SRITECTheme.accentCrimson :
                          globalAIBridge.isGenerating ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
            border.width: 1

            Behavior on border.color { ColorAnimation { duration: SRITECTheme.animFast } }

            RowLayout {
                id: pillRow
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
                          "STREAMING (" + globalAIBridge.selectedProvider.toUpperCase() + ")" :
                          (globalAIBridge.connectionState === "Error" ?
                              "GATEWAY ALERT" :
                              globalAIBridge.selectedProvider.toUpperCase() + " • " + globalAIBridge.selectedModel)
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
                              "•  Local (11434)" :
                              (globalAIBridge.hasApiKey ? "•  Key Active" : "•  Key Needed"))
                    color: !globalAIBridge.hasApiKey && globalAIBridge.selectedProvider !== "Mock" && globalAIBridge.selectedProvider !== "Local AI (Ollama)" ?
                           SRITECTheme.accentAmber : SRITECTheme.textTertiary
                    font.pixelSize: 10
                    font.family: SRITECTheme.fontMono
                }
            }
        }

        Item { Layout.fillWidth: true }

        // Right: Performance Mode, Sandbox, Clock & Fullscreen Toggle
        RowLayout {
            spacing: 12

            // Performance Mode Toggle Pill
            Rectangle {
                Layout.preferredHeight: 24
                implicitWidth: perfModeRow.implicitWidth + 14
                radius: 12
                color: SRITECTheme.backgroundElevated
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    id: perfModeRow
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "⚡"
                        color: root.currentPerformanceMode === "Ultra" ? SRITECTheme.accentCyan : SRITECTheme.accentEmerald
                        font.pixelSize: 9
                    }
                    Text {
                        text: root.currentPerformanceMode.toUpperCase()
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 9
                        font.bold: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.currentPerformanceMode === "Balanced") {
                            root.currentPerformanceMode = "Ultra";
                        } else if (root.currentPerformanceMode === "Ultra") {
                            root.currentPerformanceMode = "Low";
                        } else if (root.currentPerformanceMode === "Low") {
                            root.currentPerformanceMode = "Reduced Motion";
                        } else {
                            root.currentPerformanceMode = "Balanced";
                        }
                        root.performanceModeSelected(root.currentPerformanceMode);
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                color: SRITECTheme.borderSubtle
            }

            // Sandbox Indicator
            RowLayout {
                spacing: 6
                Text {
                    text: "SANDBOX:"
                    color: SRITECTheme.textTertiary
                    font.pixelSize: 10
                    font.bold: true
                }
                Text {
                    text: "STRICT"
                    color: SRITECTheme.accentEmerald
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                color: SRITECTheme.borderSubtle
            }

            // Universal Search Trigger Button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 24
                radius: 4
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
                    onClicked: root.universalSearchRequested()
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                color: SRITECTheme.borderSubtle
            }

            // Real Hardware Status Mini-Indicators
            RowLayout {
                spacing: 8

                // Wired Network
                Text {
                    text: "🖧"
                    font.pixelSize: 12
                    color: SRITECTheme.accentEmerald
                }

                // Audio Volume Indicator
                Text {
                    text: globalDesktopManager.isMuted ? "🔇" : (globalDesktopManager.audioVolume > 50 ? "🔊" : "🔉")
                    font.pixelSize: 12
                    color: globalDesktopManager.isMuted ? SRITECTheme.accentCrimson : SRITECTheme.textSecondary
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
                Layout.preferredHeight: 16
                color: SRITECTheme.borderSubtle
            }

            // Interactive Live Clock & Calendar Trigger
            Rectangle {
                Layout.preferredHeight: 26
                implicitWidth: clockLayout.implicitWidth + 12
                radius: 4
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
                    onClicked: root.calendarRequested()
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                color: SRITECTheme.borderSubtle
            }

            // Notification Bell Trigger
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 24
                radius: 4
                color: notifMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "🔔"
                    font.pixelSize: 12
                }

                // Unread Badge
                Rectangle {
                    visible: globalDesktopManager.unreadNotificationsCount > 0
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: -2
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
                    onClicked: root.notificationCenterRequested()
                }
            }

            // Quick Settings Trigger Button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 24
                radius: 4
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
                    onClicked: root.quickSettingsRequested()
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                color: SRITECTheme.borderSubtle
            }

            // Fullscreen Toggle Button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 24
                radius: 4
                color: fsMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "⛶"
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 13
                }

                MouseArea {
                    id: fsMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleFullscreen()
                }
            }
        }
    }
}
