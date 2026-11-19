import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    property bool isOpen: false
    signal closed()
    signal requestOpenSettings()

    visible: opacity > 0
    opacity: isOpen ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: SRITECTheme.animFast } }

    // Click outside to dismiss
    MouseArea {
        anchors.fill: parent
        onClicked: root.closePanel()
    }

    // Floating Panel Card anchored top-right below StatusPanel
    Rectangle {
        id: panelCard
        anchors.top: parent.top
        anchors.topMargin: 56
        anchors.right: parent.right
        anchors.rightMargin: 16
        width: 380
        height: 520
        radius: SRITECTheme.radiusLarge
        color: SRITECTheme.backgroundGlassElevated
        border.color: SRITECTheme.borderSubtle
        border.width: 1

        // Consume clicks inside card
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "QUICK SETTINGS"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1.2
                }
                Item { Layout.fillWidth: true }
                // Close button
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 12
                    color: closeMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closePanel()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: SRITECTheme.borderSubtle
            }

            // Quick Toggles Grid (2x2)
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                // 1. Network Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: SRITECTheme.radiusMedium
                    color: SRITECTheme.backgroundElevated
                    border.color: SRITECTheme.accentEmerald
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        Text {
                            text: "🖧"
                            font.pixelSize: 20
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: "Wired Network"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: globalDesktopManager.networkInterfaceName + " • 1 Gbps Active"
                                color: SRITECTheme.accentEmerald
                                font.pixelSize: 10
                            }
                        }
                    }
                }

                // 2. Wi-Fi Card (Unavailable)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: SRITECTheme.radiusMedium
                    color: SRITECTheme.backgroundElevated
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1
                    opacity: 0.6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        Text {
                            text: "📶"
                            font.pixelSize: 20
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: "Wi-Fi"
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: "Unavailable"
                                color: SRITECTheme.textTertiary
                                font.pixelSize: 10
                            }
                        }
                    }
                }

                // 3. Bluetooth Card (Unavailable)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: SRITECTheme.radiusMedium
                    color: SRITECTheme.backgroundElevated
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1
                    opacity: 0.6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        Text {
                            text: "ᛒ"
                            color: SRITECTheme.textTertiary
                            font.pixelSize: 20
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: "Bluetooth"
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: "No Adapter"
                                color: SRITECTheme.textTertiary
                                font.pixelSize: 10
                            }
                        }
                    }
                }

                // 4. Power & Battery Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: SRITECTheme.radiusMedium
                    color: SRITECTheme.backgroundElevated
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        Text {
                            text: "🔌"
                            font.pixelSize: 20
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: "Power Source"
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: "Desktop AC Power"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }

            // Audio Slider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: SRITECTheme.radiusMedium
                color: SRITECTheme.backgroundElevated
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: globalDesktopManager.isMuted ? "🔇" : (globalDesktopManager.audioVolume > 50 ? "🔊" : "🔉")
                        font.pixelSize: 18
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: globalDesktopManager.isMuted = !globalDesktopManager.isMuted
                        }
                    }

                    Slider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: globalDesktopManager.audioVolume
                        onMoved: globalDesktopManager.audioVolume = Math.round(value)
                    }

                    Text {
                        text: globalDesktopManager.isMuted ? "MUTED" : globalDesktopManager.audioVolume + "%"
                        color: globalDesktopManager.isMuted ? SRITECTheme.accentCrimson : SRITECTheme.accentCyan
                        font.pixelSize: 10
                        font.bold: true
                        font.family: SRITECTheme.fontMono
                        Layout.preferredWidth: 44
                    }
                }
            }

            // Display Brightness (Hardware check: External Desktop Display)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: SRITECTheme.radiusMedium
                color: SRITECTheme.backgroundElevated
                border.color: SRITECTheme.borderSubtle
                border.width: 1
                opacity: 0.7

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: "☀"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 18
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "Display Brightness"
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 11
                            font.bold: true
                        }
                        Text {
                            text: globalDesktopManager.backlightStatusText
                            color: SRITECTheme.textTertiary
                            font.pixelSize: 9
                        }
                    }

                    Text {
                        text: "N/A"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }

            // Performance Mode Selector
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "PERFORMANCE PROFILE"
                    color: SRITECTheme.textTertiary
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: ["Low", "Balanced", "Ultra", "Reduced Motion"]

                        delegate: Rectangle {
                            id: perfBtn
                            required property string modelData
                            property bool isSelected: globalDesktopManager.performanceMode === perfBtn.modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            radius: 6
                            color: isSelected ? SRITECTheme.accentCyan : (btnMouse.containsMouse ? SRITECTheme.backgroundHover : SRITECTheme.backgroundElevated)
                            border.color: isSelected ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: perfBtn.modelData === "Reduced Motion" ? "Reduced" : perfBtn.modelData
                                color: perfBtn.isSelected ? SRITECTheme.backgroundVoid : SRITECTheme.textSecondary
                                font.pixelSize: 10
                                font.bold: perfBtn.isSelected
                            }

                            MouseArea {
                                id: btnMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: globalDesktopManager.performanceMode = perfBtn.modelData
                            }
                        }
                    }
                }
            }

            // Capture & Media Quick Controls
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Screenshot Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: SRITECTheme.radiusMedium
                    color: ssBtnMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : SRITECTheme.backgroundElevated
                    border.color: ssBtnMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "📸"; font.pixelSize: 11 }
                        Text { text: "Screenshot"; font.pixelSize: 10; font.bold: true; color: SRITECTheme.textPrimary }
                    }

                    MouseArea {
                        id: ssBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            root.closePanel();
                            globalScreenCapture.captureScreen(root.Window.window);
                        }
                    }
                }

                // Screen Record Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: SRITECTheme.radiusMedium
                    color: globalScreenCapture.isRecording ? Qt.rgba(255/255, 23/255, 68/255, 0.3) :
                           (recBtnMouse.containsMouse ? Qt.rgba(255/255, 23/255, 68/255, 0.2) : SRITECTheme.backgroundElevated)
                    border.color: globalScreenCapture.isRecording ? SRITECTheme.accentCrimson :
                                  (recBtnMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.borderSubtle)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: globalScreenCapture.isRecording ? "⏹" : "🎥"; font.pixelSize: 11 }
                        Text {
                            text: globalScreenCapture.isRecording ? "Stop REC" : "Record";
                            font.pixelSize: 10
                            font.bold: true
                            color: globalScreenCapture.isRecording ? SRITECTheme.accentCrimson : SRITECTheme.textPrimary
                        }
                    }

                    MouseArea {
                        id: recBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            root.closePanel();
                            if (globalScreenCapture.isRecording) {
                                globalScreenCapture.stopRecording();
                            } else {
                                globalScreenCapture.startRecording(root.Window.window);
                            }
                        }
                    }
                }

                // Power Control Button
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: SRITECTheme.radiusMedium
                    color: pwrBtnMouse.containsMouse ? Qt.rgba(255/255, 23/255, 68/255, 0.3) : SRITECTheme.backgroundElevated
                    border.color: pwrBtnMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "⏻"
                        font.pixelSize: 13
                        font.bold: true
                        color: pwrBtnMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.textSecondary
                    }

                    MouseArea {
                        id: pwrBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            root.closePanel();
                            globalPowerManager.requestShutdown();
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Open Full Settings Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: SRITECTheme.radiusMedium
                color: SRITECTheme.backgroundElevated
                border.color: setMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "⚙"
                        font.pixelSize: 13
                    }
                    Text {
                        text: "All Settings & Personalization"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                MouseArea {
                    id: setMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.closePanel();
                        root.requestOpenSettings();
                    }
                }
            }
        }
    }

    function openPanel() {
        isOpen = true;
    }

    function closePanel() {
        isOpen = false;
        closed();
    }
}
