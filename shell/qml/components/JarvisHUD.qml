import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    width: 480
    height: 580
    radius: SRITECTheme.radiusLarge
    color: Qt.rgba(13/255, 17/255, 26/255, 0.92)
    border.color: globalJarvis.isMicListening ? SRITECTheme.accentNeonPink :
                  (globalJarvis.isCameraActive ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle)
    border.width: 1.5

    signal closeRequested()

    // Smooth drop shadow simulation border glow
    Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        radius: parent.radius + 1
        color: "transparent"
        border.color: globalJarvis.isMicListening ? Qt.rgba(244/255, 114/255, 182/255, 0.3) :
                      (globalJarvis.isCameraActive ? Qt.rgba(0/255, 229/255, 255/255, 0.3) : "transparent")
        border.width: 1
        z: -1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        // 1. Header Row (Title, Master Switch, Close)
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 16
                color: Qt.rgba(0/255, 229/255, 255/255, 0.15)
                border.color: SRITECTheme.accentCyan
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "✦"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            ColumnLayout {
                spacing: 1
                Text {
                    text: "JARVIS MULTIMODAL HUB"
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 1.5
                }
                Text {
                    text: "Voice & Hand Vision Spatial Interaction Layer"
                    color: SRITECTheme.textTertiary
                    font.pixelSize: 9
                    font.family: SRITECTheme.fontMono
                }
            }

            Item { Layout.fillWidth: true }

            // Master On/Off Switch
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 28
                radius: 14
                color: globalJarvis.isActive ? Qt.rgba(16/255, 185/255, 129/255, 0.2) : Qt.rgba(239/255, 68/255, 68/255, 0.2)
                border.color: globalJarvis.isActive ? SRITECTheme.accentEmerald : SRITECTheme.accentCrimson
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: globalJarvis.isActive ? "● ACTIVE" : "○ MUTED"
                        color: globalJarvis.isActive ? SRITECTheme.accentEmerald : SRITECTheme.accentCrimson
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
                        globalJarvis.setActive(!globalJarvis.isActive);
                    }
                }
            }

            // Close Button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 13
                color: closeHover.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 12
                }
                MouseArea {
                    id: closeHover
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.closeRequested()
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: SRITECTheme.borderSubtle
        }

        // 2. Audio & Voice System Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 124
            radius: SRITECTheme.radiusMedium
            color: SRITECTheme.backgroundElevated
            border.color: globalJarvis.isMicListening ? SRITECTheme.accentNeonPink : SRITECTheme.borderSubtle
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "🎙 VOICE SUBSYSTEM (VAD & WAKE WORD)"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: globalJarvis.stateString.toUpperCase()
                        color: globalJarvis.isMicListening ? SRITECTheme.accentNeonPink : SRITECTheme.textSecondary
                        font.pixelSize: 9
                        font.family: SRITECTheme.fontMono
                        font.bold: true
                    }
                }

                // Audio Energy Waveform Spectrum Visualizer
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: 6
                    color: Qt.rgba(8/255, 11/255, 18/255, 0.9)
                    border.color: Qt.rgba(0/255, 229/255, 255/255, 0.2)
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        Repeater {
                            model: 24
                            delegate: Rectangle {
                                id: specBar
                                required property int index
                                Layout.fillWidth: true
                                property real baseAmp: Math.sin(index * 0.4 + waveHudTimer.tick) * 0.4 + 0.5
                                property real liveAmp: globalJarvis.audioLevel * 1.5
                                Layout.preferredHeight: Math.max(3, (baseAmp * liveAmp * 26) + 3)
                                Layout.alignment: Qt.AlignVCenter
                                radius: 1.5
                                color: globalJarvis.isMicListening ?
                                       (index % 2 === 0 ? SRITECTheme.accentNeonPink : SRITECTheme.accentViolet) :
                                       (!globalJarvis.isMicMuted ? SRITECTheme.accentCyan : SRITECTheme.textTertiary)
                            }
                        }
                    }

                    Timer {
                        id: waveHudTimer
                        property real tick: 0
                        interval: 40
                        running: !globalJarvis.isMicMuted
                        repeat: true
                        onTriggered: tick += 0.3
                    }
                }

                // Mic controls row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: 120
                        radius: 13
                        color: globalJarvis.isMicListening ? Qt.rgba(244/255, 114/255, 182/255, 0.2) : SRITECTheme.backgroundHover
                        border.color: globalJarvis.isMicListening ? SRITECTheme.accentNeonPink : SRITECTheme.borderSubtle
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: globalJarvis.isMicListening ? "⏹ Stop Listening" : "🎙 Talk to Jarvis"
                            color: globalJarvis.isMicListening ? SRITECTheme.accentNeonPink : SRITECTheme.textPrimary
                            font.pixelSize: 10
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (globalJarvis.isMicListening) globalJarvis.stopListening();
                                else globalJarvis.startListening();
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: 100
                        radius: 13
                        color: !globalJarvis.isMicMuted ? Qt.rgba(16/255, 185/255, 129/255, 0.15) : Qt.rgba(239/255, 68/255, 68/255, 0.15)
                        border.color: !globalJarvis.isMicMuted ? SRITECTheme.accentEmerald : SRITECTheme.accentCrimson
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: !globalJarvis.isMicMuted ? "Mic: ON" : "Mic: MUTED"
                            color: !globalJarvis.isMicMuted ? SRITECTheme.accentEmerald : SRITECTheme.accentCrimson
                            font.pixelSize: 10
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: globalJarvis.toggleMicrophone()
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "Wake: 'Hey Jarvis'"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 9
                        font.family: SRITECTheme.fontMono
                    }
                }
            }
        }

        // 3. Vision & Hand Gesture Subsystem Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 136
            radius: SRITECTheme.radiusMedium
            color: SRITECTheme.backgroundElevated
            border.color: globalJarvis.isCameraActive ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "👁 VISION & HAND GESTURE SYSTEM"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: globalJarvis.isCameraActive ? "LIVE • ADAPTIVE 30FPS" : "DISABLED (OFF BY DEFAULT)"
                        color: globalJarvis.isCameraActive ? SRITECTheme.accentEmerald : SRITECTheme.accentAmber
                        font.pixelSize: 9
                        font.family: SRITECTheme.fontMono
                        font.bold: true
                    }
                }

                // Telemetry: Active gesture & confidence
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 38
                        radius: 6
                        color: Qt.rgba(8/255, 11/255, 18/255, 0.9)
                        border.color: SRITECTheme.borderSubtle
                        border.width: 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 1
                            Text {
                                text: "DETECTED GESTURE"
                                color: SRITECTheme.textTertiary
                                font.pixelSize: 8
                                font.bold: true
                            }
                            Text {
                                text: globalJarvis.detectedGesture.length > 0 ? globalJarvis.detectedGesture : "None"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 11
                                font.bold: true
                                font.family: SRITECTheme.fontMono
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Confidence"
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 9
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: Math.round(globalJarvis.gestureConfidence * 100) + "%"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 9
                                font.family: SRITECTheme.fontMono
                            }
                        }
                        // Progress bar
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: SRITECTheme.backgroundVoid
                            Rectangle {
                                width: parent.width * Math.min(1.0, globalJarvis.gestureConfidence)
                                height: parent.height
                                radius: 3
                                color: SRITECTheme.accentCyan
                            }
                        }
                    }
                }

                // Camera toggle controls
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: 150
                        radius: 13
                        color: globalJarvis.isCameraActive ? Qt.rgba(239/255, 68/255, 68/255, 0.2) : Qt.rgba(0/255, 229/255, 255/255, 0.2)
                        border.color: globalJarvis.isCameraActive ? SRITECTheme.accentCrimson : SRITECTheme.accentCyan
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: globalJarvis.isCameraActive ? "📷 Stop Camera" : "📷 Enable Hand Tracking"
                            color: globalJarvis.isCameraActive ? SRITECTheme.accentCrimson : SRITECTheme.accentCyan
                            font.pixelSize: 10
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                globalJarvis.toggleCamera();
                            }
                        }
                    }

                    Text {
                        text: "Privacy: Local frame analysis only. Zero uploads."
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 9
                        font.family: SRITECTheme.fontMono
                    }
                }
            }
        }

        // 4. Multi-lingual Quick Commands
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "SUGGESTED INTENTS (MULTILINGUAL)"
                color: SRITECTheme.textSecondary
                font.pixelSize: 9
                font.bold: true
                font.letterSpacing: 1
            }

            Flow {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { label: "Open File Manager", cmd: "open file manager" },
                        { label: "Open VS Code", cmd: "open vs code" },
                        { label: "Open Browser", cmd: "open browser" },
                        { label: "கோப்பு மேலாளர் (Tamil)", cmd: "file manager open pannu" },
                        { label: "कोड स्टूडियो (Hindi)", cmd: "code studio kholo" },
                        { label: "System Status", cmd: "show system status" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        width: cmdTxt.implicitWidth + 16
                        height: 24
                        radius: 12
                        color: cmdMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : SRITECTheme.backgroundHover
                        border.color: cmdMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                        border.width: 1

                        Text {
                            id: cmdTxt
                            anchors.centerIn: parent
                            text: parent.modelData.label
                            color: parent.modelData.cmd.indexOf("pannu") !== -1 ? SRITECTheme.accentAmber :
                                   (parent.modelData.cmd.indexOf("kholo") !== -1 ? SRITECTheme.accentEmerald : SRITECTheme.textPrimary)
                            font.pixelSize: 9
                            font.bold: true
                        }

                        MouseArea {
                            id: cmdMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAudioService.playClick();
                                globalJarvis.processUserInput(parent.modelData.cmd);
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // 5. Emergency Sensor Kill Switch
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            radius: SRITECTheme.radiusMedium
            color: Qt.rgba(239/255, 68/255, 68/255, 0.15)
            border.color: SRITECTheme.accentCrimson
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text {
                    text: "🛑"
                    font.pixelSize: 12
                }
                Text {
                    text: "EMERGENCY SENSOR SHUTDOWN (KILL MIC & CAMERA)"
                    color: SRITECTheme.accentCrimson
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    globalAudioService.playClick();
                    globalJarvis.emergencyShutdown();
                }
            }
        }
    }
}
