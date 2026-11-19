import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Item {
    id: root
    implicitWidth: 460
    implicitHeight: 380

    property bool isJarvisActive: globalJarvis ? globalJarvis.isActive : true
    property string jarvisState: globalJarvis ? globalJarvis.stateString : (globalAIBridge.isGenerating ? "Speaking" : "Idle")
    property real audioLevel: globalJarvis ? globalJarvis.audioLevel : (globalAIBridge.isGenerating ? 0.6 : 0.0)
    property bool isSpeaking: jarvisState === "Speaking" || globalAIBridge.isGenerating
    property bool isListening: jarvisState === "Listening"
    property bool isProcessing: jarvisState === "Processing" || globalAIBridge.connectionState === "Connecting"
    property bool isExecuting: jarvisState === "ExecutingApprovedAction"
    property bool isOffline: !isJarvisActive || jarvisState === "Offline"
    property bool isError: jarvisState === "Error"

    signal avatarClicked()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        // 1. Central Spatial Holographic Core (Concentric Rings & Neural Orb)
        Item {
            Layout.preferredWidth: 230
            Layout.preferredHeight: 230
            Layout.alignment: Qt.AlignHCenter

            // Outer Radial Wave Emission (radiates outwards when speaking or listening)
            Rectangle {
                id: waveEmitter1
                anchors.centerIn: parent
                width: 210 + root.audioLevel * 30
                height: width
                radius: width / 2
                color: "transparent"
                border.color: root.isSpeaking ? SRITECTheme.accentCyan :
                              (root.isListening ? SRITECTheme.accentNeonPink : SRITECTheme.accentViolet)
                border.width: 1.5
                opacity: 0.0

                SequentialAnimation on opacity {
                    running: root.isSpeaking || root.isListening
                    loops: Animation.Infinite
                    PropertyAnimation { to: 0.6; duration: 400; easing.type: Easing.OutQuad }
                    PropertyAnimation { to: 0.0; duration: 600; easing.type: Easing.InQuad }
                }

                SequentialAnimation on scale {
                    running: root.isSpeaking || root.isListening
                    loops: Animation.Infinite
                    PropertyAnimation { from: 0.85; to: 1.3; duration: 900; easing.type: Easing.OutQuad }
                }
            }

            // Outer Ring (Orbital Satellite System, clockwise)
            Rectangle {
                id: outerRing
                anchors.centerIn: parent
                width: 180
                height: 180
                radius: 90
                color: "transparent"
                border.color: root.isError ? SRITECTheme.accentCrimson :
                              (root.isExecuting ? SRITECTheme.accentEmerald :
                              (root.isSpeaking ? SRITECTheme.accentCyan :
                              (root.isProcessing ? SRITECTheme.accentAmber :
                              (root.isListening ? SRITECTheme.accentNeonPink : Qt.rgba(0/255, 229/255, 255/255, 0.45)))))
                border.width: 1.5

                RotationAnimation on rotation {
                    from: 0; to: 360
                    duration: root.isSpeaking ? 3000 : (root.isProcessing ? 2000 : 14000)
                    loops: Animation.Infinite
                    running: !root.isOffline
                }

                // Satellite Node Alpha (Cyan)
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: root.isListening ? SRITECTheme.accentNeonPink : SRITECTheme.accentCyan
                    x: parent.width / 2 - 4
                    y: -4
                }

                // Satellite Node Beta (Violet)
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: SRITECTheme.accentViolet
                    x: parent.width / 2 - 3
                    y: parent.height - 3
                }
            }

            // Middle Counter-Rotating Ring (Counter-clockwise)
            Rectangle {
                id: midRing
                anchors.centerIn: parent
                width: 136
                height: 136
                radius: 68
                color: "transparent"
                border.color: root.isSpeaking ? SRITECTheme.accentViolet :
                              (root.isProcessing ? SRITECTheme.accentAmber :
                              (root.isListening ? SRITECTheme.accentCyan : Qt.rgba(139/255, 92/255, 246/255, 0.5)))
                border.width: 1.5

                RotationAnimation on rotation {
                    from: 360; to: 0
                    duration: root.isSpeaking ? 2400 : (root.isProcessing ? 1500 : 10000)
                    loops: Animation.Infinite
                    running: !root.isOffline
                }

                // Satellite Node Gamma
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: SRITECTheme.accentNeonPink
                    x: -3
                    y: parent.height / 2 - 3
                }
            }

            // Radial Voice Waveform Visualizer (Surrounding core during speech or listening)
            Item {
                anchors.centerIn: parent
                width: 120
                height: 120
                visible: (root.isSpeaking || root.isListening) && !root.isOffline

                Repeater {
                    model: 16
                    delegate: Rectangle {
                        id: waveBar
                        required property int index
                        property real dynamicHeight: 8 + (root.audioLevel * 18) + Math.sin(index * 0.8 + waveTimer.tick * 0.5) * 6
                        width: 2.5
                        height: Math.max(4, dynamicHeight)
                        radius: 1.25
                        color: index % 2 === 0 ? SRITECTheme.accentCyan : SRITECTheme.accentNeonPink
                        x: 60 + Math.cos(index * (Math.PI * 2 / 16)) * 52 - 1.25
                        y: 60 + Math.sin(index * (Math.PI * 2 / 16)) * 52 - height / 2
                    }
                }

                Timer {
                    id: waveTimer
                    property real tick: 0
                    interval: 35
                    running: (root.isSpeaking || root.isListening) && !root.isOffline
                    repeat: true
                    onTriggered: tick += 0.25
                }
            }

            // Inner Holographic Core Platform / Pedestal
            Rectangle {
                id: innerCore
                anchors.centerIn: parent
                width: 90
                height: 90
                radius: 45
                color: SRITECTheme.backgroundElevated
                border.color: root.isSpeaking ? SRITECTheme.accentCyan :
                              (root.isListening ? SRITECTheme.accentNeonPink :
                              (root.isProcessing ? SRITECTheme.accentAmber :
                              (root.isExecuting ? SRITECTheme.accentEmerald :
                              (root.isError ? SRITECTheme.accentCrimson : SRITECTheme.borderAccent))))
                border.width: 2

                // Core Neural Plasma Glow Orb
                Rectangle {
                    anchors.centerIn: parent
                    width: 52 + root.audioLevel * 14
                    height: width
                    radius: width / 2
                    color: root.isError ? SRITECTheme.accentCrimson :
                           (root.isExecuting ? SRITECTheme.accentEmerald :
                           (root.isSpeaking ? SRITECTheme.accentCyan :
                           (root.isProcessing ? SRITECTheme.accentAmber :
                           (root.isListening ? SRITECTheme.accentNeonPink :
                           (root.isOffline ? SRITECTheme.textTertiary : SRITECTheme.accentViolet)))))
                    opacity: root.isOffline ? 0.3 : (root.isSpeaking || root.isListening ? 0.95 : 0.7)

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        running: !root.isOffline
                        PropertyAnimation {
                            to: 1.15;
                            duration: root.isSpeaking ? 300 : (root.isListening ? 450 : (root.isProcessing ? 350 : 1400));
                            easing.type: Easing.InOutQuad
                        }
                        PropertyAnimation {
                            to: 0.88;
                            duration: root.isSpeaking ? 300 : (root.isListening ? 450 : (root.isProcessing ? 350 : 1400));
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                // Center Identity Symbol
                Text {
                    anchors.centerIn: parent
                    text: root.isOffline ? "○" :
                          (root.isError ? "⚠" :
                          (root.isExecuting ? "✓" :
                          (root.isSpeaking ? "⚡" :
                          (root.isListening ? "🎙" :
                          (root.isProcessing ? "✦" : "✦")))))
                    color: SRITECTheme.backgroundVoid
                    font.pixelSize: 20
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if (globalJarvis) {
                            if (root.isListening) {
                                globalJarvis.stopListening();
                            } else {
                                globalJarvis.startListening();
                            }
                        }
                        root.avatarClicked();
                    }
                }
            }
        }

        // 2. Identity Label & State Capsule
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Text {
                text: "JARVIS • MULTIMODAL AI CORE"
                color: SRITECTheme.textPrimary
                font.pixelSize: 13
                font.bold: true
                font.letterSpacing: 2.2
                Layout.alignment: Qt.AlignHCenter
            }

            // State Badge Capsule
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 24
                implicitWidth: statusPillRow.implicitWidth + 24
                radius: 12
                color: SRITECTheme.backgroundElevated
                border.color: root.isError ? SRITECTheme.accentCrimson :
                              (root.isExecuting ? SRITECTheme.accentEmerald :
                              (root.isSpeaking ? SRITECTheme.accentCyan :
                              (root.isListening ? SRITECTheme.accentNeonPink :
                              (root.isProcessing ? SRITECTheme.accentAmber : SRITECTheme.borderSubtle))))
                border.width: 1

                RowLayout {
                    id: statusPillRow
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 6
                        Layout.preferredHeight: 6
                        radius: 3
                        color: root.isError ? SRITECTheme.accentCrimson :
                               (root.isExecuting ? SRITECTheme.accentEmerald :
                               (root.isSpeaking ? SRITECTheme.accentCyan :
                               (root.isListening ? SRITECTheme.accentNeonPink :
                               (root.isProcessing ? SRITECTheme.accentAmber :
                               (root.isOffline ? SRITECTheme.textTertiary : SRITECTheme.accentEmerald)))))

                        SequentialAnimation on opacity {
                            running: root.isSpeaking || root.isProcessing || root.isListening
                            loops: Animation.Infinite
                            PropertyAnimation { to: 0.2; duration: 350 }
                            PropertyAnimation { to: 1.0; duration: 350 }
                        }
                    }

                    Text {
                        text: {
                            if (root.isOffline) return "OFFLINE • STANDBY";
                            if (root.isError) return "ERROR ENCOUNTERED";
                            if (root.isExecuting) return "EXECUTING APPROVED ACTION";
                            if (root.isSpeaking) return "SPEAKING • NEURAL SYNTHESIS";
                            if (root.isListening) return "LISTENING • LIVE AUDIO STREAM";
                            if (root.isProcessing) return "PROCESSING INTENT...";
                            return "WAKE WORD ACTIVE • 'HEY JARVIS'";
                        }
                        color: root.isError ? SRITECTheme.accentCrimson :
                               (root.isExecuting ? SRITECTheme.accentEmerald :
                               (root.isSpeaking ? SRITECTheme.accentCyan :
                               (root.isListening ? SRITECTheme.accentNeonPink :
                               (root.isProcessing ? SRITECTheme.accentAmber : SRITECTheme.textSecondary))))
                        font.pixelSize: 10
                        font.family: SRITECTheme.fontMono
                        font.bold: true
                    }
                }
            }
        }

        // 3. Floating Response Capsule (Displays live tokens or transcript)
        Rectangle {
            visible: {
                var resp = globalJarvis ? globalJarvis.lastSpokenResponse : globalAIBridge.currentResponse;
                var trans = globalJarvis ? globalJarvis.lastTranscript : "";
                return (resp && resp.length > 0) || (trans && trans.length > 0) || root.isSpeaking || root.isProcessing;
            }
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(parent ? parent.width : 440, 440)
            implicitHeight: responseCol.implicitHeight + 20
            radius: SRITECTheme.radiusMedium
            color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
            border.color: root.isSpeaking ? SRITECTheme.accentCyan :
                          (root.isListening ? SRITECTheme.accentNeonPink : SRITECTheme.borderSubtle)
            border.width: 1

            ColumnLayout {
                id: responseCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root.isSpeaking ? "⚡ JARVIS VOICE OUTPUT" :
                              (root.isListening ? "🎙 USER SPEECH" : "✦ JARVIS INTENT")
                        color: root.isSpeaking ? SRITECTheme.accentCyan : SRITECTheme.accentNeonPink
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "✕"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 10
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (globalJarvis) globalJarvis.clearHistory();
                                globalAIBridge.clearHistory();
                            }
                        }
                    }
                }

                Text {
                    text: {
                        if (globalJarvis && globalJarvis.lastTranscript.length > 0 && root.isListening) {
                            return "“" + globalJarvis.lastTranscript + "”";
                        }
                        var resp = globalJarvis ? globalJarvis.lastSpokenResponse : globalAIBridge.currentResponse;
                        if (resp && resp.length > 0) return resp;
                        return "Listening for voice instructions or wake word...";
                    }
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 11
                    font.family: SRITECTheme.fontUI
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    maximumLineCount: 4
                    elide: Text.ElideRight
                }
            }
        }
    }
}
