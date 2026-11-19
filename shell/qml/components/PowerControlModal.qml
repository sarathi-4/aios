import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    anchors.fill: parent
    color: Qt.rgba(3/255, 7/255, 18/255, 0.85)
    visible: globalPowerManager.isConfirmationActive
    z: 300

    Behavior on opacity { NumberAnimation { duration: SRITECTheme.animFast } }

    // Intercept clicks outside
    MouseArea {
        anchors.fill: parent
        onClicked: {
            globalAudioService.playClick();
            globalPowerManager.cancelAction();
        }
    }

    // Modal Card
    Rectangle {
        anchors.centerIn: parent
        width: 600
        height: 440
        radius: SRITECTheme.radiusLarge
        color: Qt.rgba(13/255, 17/255, 26/255, 0.96)
        border.color: globalPowerManager.pendingAction === "shutdown" ? SRITECTheme.accentCrimson :
                      globalPowerManager.pendingAction === "restart" ? SRITECTheme.accentCyan :
                      globalPowerManager.pendingAction === "sleep" ? SRITECTheme.accentViolet :
                      globalPowerManager.pendingAction === "lock" ? SRITECTheme.accentEmerald : SRITECTheme.accentAmber
        border.width: 1.5

        // Prevent click propagation
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 16

            // Header Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: Qt.rgba(0/255, 229/255, 255/255, 0.12)
                    border.color: SRITECTheme.accentCyan
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: globalPowerManager.pendingAction === "shutdown" ? "⏻" :
                              globalPowerManager.pendingAction === "restart" ? "↺" :
                              globalPowerManager.pendingAction === "sleep" ? "💤" :
                              globalPowerManager.pendingAction === "lock" ? "🔒" : "⎋"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 18
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "SYSTEM POWER CONTROL"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 14
                        font.bold: true
                        font.letterSpacing: 1.5
                    }
                    Text {
                        text: "ACTION: " + globalPowerManager.pendingAction.toUpperCase()
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 10
                        font.family: SRITECTheme.fontMono
                        font.bold: true
                    }
                }

                Item { Layout.fillWidth: true }

                // Safe Simulation Mode Badge
                Rectangle {
                    Layout.preferredHeight: 24
                    implicitWidth: simRow.implicitWidth + 14
                    radius: 12
                    color: Qt.rgba(0/255, 230/255, 118/255, 0.12)
                    border.color: SRITECTheme.accentEmerald
                    border.width: 1

                    RowLayout {
                        id: simRow
                        anchors.centerIn: parent
                        spacing: 5
                        Text { text: "🛡"; font.pixelSize: 10 }
                        Text {
                            text: globalPowerManager.simulationMode ? "HOST PROTECTED" : "LIVE HARDWARE"
                            color: SRITECTheme.accentEmerald
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: SRITECTheme.borderSubtle
            }

            // Power Action Options Grid
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // 1. Shutdown
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 8
                    color: globalPowerManager.pendingAction === "shutdown" ? Qt.rgba(255/255, 23/255, 68/255, 0.2) : SRITECTheme.backgroundElevated
                    border.color: globalPowerManager.pendingAction === "shutdown" ? SRITECTheme.accentCrimson : SRITECTheme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { Layout.alignment: Qt.AlignHCenter; text: "⏻"; font.pixelSize: 16; color: SRITECTheme.accentCrimson }
                        Text { Layout.alignment: Qt.AlignHCenter; text: "Shut Down"; font.pixelSize: 11; font.bold: true; color: SRITECTheme.textPrimary }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalPowerManager.requestShutdown();
                        }
                    }
                }

                // 2. Restart
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 8
                    color: globalPowerManager.pendingAction === "restart" ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : SRITECTheme.backgroundElevated
                    border.color: globalPowerManager.pendingAction === "restart" ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { Layout.alignment: Qt.AlignHCenter; text: "↺"; font.pixelSize: 16; color: SRITECTheme.accentCyan }
                        Text { Layout.alignment: Qt.AlignHCenter; text: "Restart"; font.pixelSize: 11; font.bold: true; color: SRITECTheme.textPrimary }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalPowerManager.requestRestart();
                        }
                    }
                }

                // 3. Sleep
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 8
                    color: globalPowerManager.pendingAction === "sleep" ? Qt.rgba(179/255, 136/255, 255/255, 0.2) : SRITECTheme.backgroundElevated
                    border.color: globalPowerManager.pendingAction === "sleep" ? SRITECTheme.accentViolet : SRITECTheme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { Layout.alignment: Qt.AlignHCenter; text: "💤"; font.pixelSize: 16 }
                        Text { Layout.alignment: Qt.AlignHCenter; text: "Sleep"; font.pixelSize: 11; font.bold: true; color: SRITECTheme.textPrimary }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalPowerManager.requestSleep();
                        }
                    }
                }

                // 4. Lock
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 8
                    color: globalPowerManager.pendingAction === "lock" ? Qt.rgba(0/255, 230/255, 118/255, 0.2) : SRITECTheme.backgroundElevated
                    border.color: globalPowerManager.pendingAction === "lock" ? SRITECTheme.accentEmerald : SRITECTheme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { Layout.alignment: Qt.AlignHCenter; text: "🔒"; font.pixelSize: 16 }
                        Text { Layout.alignment: Qt.AlignHCenter; text: "Lock"; font.pixelSize: 11; font.bold: true; color: SRITECTheme.textPrimary }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalPowerManager.requestLock();
                        }
                    }
                }

                // 5. Quit
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 8
                    color: globalPowerManager.pendingAction === "quit" ? Qt.rgba(255/255, 171/255, 0/255, 0.2) : SRITECTheme.backgroundElevated
                    border.color: globalPowerManager.pendingAction === "quit" ? SRITECTheme.accentAmber : SRITECTheme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { Layout.alignment: Qt.AlignHCenter; text: "⎋"; font.pixelSize: 16; color: SRITECTheme.accentAmber }
                        Text { Layout.alignment: Qt.AlignHCenter; text: "Quit NEBULA"; font.pixelSize: 11; font.bold: true; color: SRITECTheme.textPrimary }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalPowerManager.requestQuit();
                        }
                    }
                }
            }

            // Status message
            Text {
                Layout.fillWidth: true
                text: globalPowerManager.statusMessage
                color: SRITECTheme.textSecondary
                font.pixelSize: 11
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }

            // Circular Countdown Display
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    radius: 30
                    color: Qt.rgba(13/255, 17/255, 26/255, 0.9)
                    border.color: globalPowerManager.countdownSeconds <= 5 ? SRITECTheme.accentCrimson : SRITECTheme.accentCyan
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: globalPowerManager.countdownSeconds
                        color: globalPowerManager.countdownSeconds <= 5 ? SRITECTheme.accentCrimson : SRITECTheme.textPrimary
                        font.pixelSize: 20
                        font.family: SRITECTheme.fontMono
                        font.bold: true
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "AUTOMATIC EXECUTION IN PROGRESS"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Text {
                        text: "System will execute " + globalPowerManager.pendingAction + " when timer expires."
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 10
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "Cancel"
                    onClicked: {
                        globalAudioService.playClick();
                        globalPowerManager.cancelAction();
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    text: "Execute Now (" + globalPowerManager.pendingAction.toUpperCase() + ")"
                    onClicked: {
                        globalAudioService.playChime();
                        globalPowerManager.confirmAction();
                    }
                }
            }
        }
    }
}
