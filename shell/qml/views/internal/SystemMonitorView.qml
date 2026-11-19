import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root

    color: SRITECTheme.backgroundSurface
    radius: SRITECTheme.radiusLarge
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        // Top Telemetry Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "⚡"
                color: SRITECTheme.accentCyan
                font.pixelSize: 16
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "SYSTEM RESOURCE & HARDWARE MONITOR"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1.2
                }
                Text {
                    text: globalAppLauncher.hostDistro + " • " + globalAppLauncher.hostKernel
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 9
                    font.family: SRITECTheme.fontMono
                }
            }

            Item { Layout.fillWidth: true }

            // Refresh Button
            Rectangle {
                Layout.preferredWidth: 84
                Layout.preferredHeight: 28
                radius: 14
                color: refreshMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : Qt.rgba(19/255, 26/255, 40/255, 0.6)
                border.color: refreshMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "⟳"; color: SRITECTheme.accentCyan; font.pixelSize: 12 }
                    Text { text: "Refresh"; color: SRITECTheme.textPrimary; font.pixelSize: 10; font.bold: true }
                }

                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: globalAppLauncher.refreshTelemetry()
                }
            }
        }

        // Live Resource Gauges Row
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 96
            spacing: 12

            // CPU Gauge
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: Qt.rgba(13/255, 17/255, 26/255, 0.90)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Text { text: "CPU LOAD"; color: SRITECTheme.accentCyan; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono }
                        Item { Layout.fillWidth: true }
                        Text { text: globalAppLauncher.cpuUsagePercent + "%"; color: SRITECTheme.accentCyan; font.pixelSize: 13; font.bold: true; font.family: SRITECTheme.fontMono }
                    }

                    ProgressBar {
                        id: cpuBar
                        Layout.fillWidth: true
                        from: 0; to: 100; value: globalAppLauncher.cpuUsagePercent
                        background: Rectangle { implicitHeight: 6; radius: 3; color: "#172033" }
                        contentItem: Item { Rectangle { width: cpuBar.visualPosition * parent.width; height: 6; radius: 3; color: SRITECTheme.accentCyan } }
                    }

                    Text { text: "Threads: 16 • Max Freq: 4.8 GHz"; color: SRITECTheme.textTertiary; font.pixelSize: 8; font.family: SRITECTheme.fontMono }
                }
            }

            // RAM Gauge
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: Qt.rgba(13/255, 17/255, 26/255, 0.90)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Text { text: "MEMORY USAGE"; color: SRITECTheme.accentViolet; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono }
                        Item { Layout.fillWidth: true }
                        Text { text: globalAppLauncher.ramUsagePercent + "%"; color: SRITECTheme.accentViolet; font.pixelSize: 13; font.bold: true; font.family: SRITECTheme.fontMono }
                    }

                    ProgressBar {
                        id: ramBar
                        Layout.fillWidth: true
                        from: 0; to: 100; value: globalAppLauncher.ramUsagePercent
                        background: Rectangle { implicitHeight: 6; radius: 3; color: "#172033" }
                        contentItem: Item { Rectangle { width: ramBar.visualPosition * parent.width; height: 6; radius: 3; color: SRITECTheme.accentViolet } }
                    }

                    Text { text: "Allocated: 6.8 GB / 15.6 GB Total"; color: SRITECTheme.textTertiary; font.pixelSize: 8; font.family: SRITECTheme.fontMono }
                }
            }

            // Disk Gauge
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: Qt.rgba(13/255, 17/255, 26/255, 0.90)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Text { text: "STORAGE NVME"; color: SRITECTheme.accentEmerald; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono }
                        Item { Layout.fillWidth: true }
                        Text { text: globalAppLauncher.diskUsagePercent + "%"; color: SRITECTheme.accentEmerald; font.pixelSize: 13; font.bold: true; font.family: SRITECTheme.fontMono }
                    }

                    ProgressBar {
                        id: diskBar
                        Layout.fillWidth: true
                        from: 0; to: 100; value: globalAppLauncher.diskUsagePercent
                        background: Rectangle { implicitHeight: 6; radius: 3; color: "#172033" }
                        contentItem: Item { Rectangle { width: diskBar.visualPosition * parent.width; height: 6; radius: 3; color: SRITECTheme.accentEmerald } }
                    }

                    Text { text: "Used: 108 GB • Free: 142 GB (Ext4)"; color: SRITECTheme.textTertiary; font.pixelSize: 8; font.family: SRITECTheme.fontMono }
                }
            }
        }

        // Running Process List Table
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: Qt.rgba(13/255, 17/255, 26/255, 0.90)
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: "ACTIVE SPATIAL PROCESSES"
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1.0
                }

                // Table Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text { text: "PID"; color: SRITECTheme.textTertiary; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 60 }
                    Text { text: "PROCESS NAME"; color: SRITECTheme.textTertiary; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono; Layout.fillWidth: true }
                    Text { text: "CPU"; color: SRITECTheme.textTertiary; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 60 }
                    Text { text: "MEMORY"; color: SRITECTheme.textTertiary; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 80 }
                    Text { text: "STATUS"; color: SRITECTheme.textTertiary; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 80 }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6

                    model: [
                        { pid: "4102", name: "sritec-shell (NEBULA)", cpu: "1.2%", mem: "46.4 MB", status: "Running", color: SRITECTheme.accentCyan },
                        { pid: "1820", name: "wayland-compositor", cpu: "0.8%", mem: "92.1 MB", status: "Running", color: SRITECTheme.accentEmerald },
                        { pid: "2405", name: "sritec_gateway_stream", cpu: "0.2%", mem: "18.3 MB", status: "Sleeping", color: SRITECTheme.textSecondary },
                        { pid: "0891", name: "pipewire-audio", cpu: "0.1%", mem: "14.2 MB", status: "Sleeping", color: SRITECTheme.textSecondary },
                        { pid: "0412", name: "systemd-journald", cpu: "0.0%", mem: "8.5 MB", status: "Sleeping", color: SRITECTheme.textSecondary },
                        { pid: "0001", name: "systemd (init)", cpu: "0.0%", mem: "12.8 MB", status: "Running", color: SRITECTheme.textSecondary }
                    ]

                    delegate: RowLayout {
                        id: procRow
                        required property var modelData
                        width: parent.width
                        spacing: 12

                        Text { text: procRow.modelData.pid; color: SRITECTheme.textSecondary; font.pixelSize: 10; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 60 }
                        Text { text: procRow.modelData.name; color: procRow.modelData.color; font.pixelSize: 10; font.bold: true; Layout.fillWidth: true }
                        Text { text: procRow.modelData.cpu; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 60 }
                        Text { text: procRow.modelData.mem; color: SRITECTheme.textSecondary; font.pixelSize: 10; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 80 }
                        Text { text: procRow.modelData.status; color: SRITECTheme.accentEmerald; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 80 }
                    }
                }
            }
        }
    }
}
