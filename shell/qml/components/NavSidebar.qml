import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    Layout.preferredWidth: 240
    color: SRITECTheme.backgroundSurface
    border.color: SRITECTheme.borderSubtle
    border.width: 1

    property int currentTabIndex: 0
    signal tabSelected(int index)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        // Brand Identity Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: SRITECTheme.radiusSmall
                color: SRITECTheme.backgroundVoid
                border.color: SRITECTheme.accentCyan
                border.width: 1.5

                // Glowing pulsing core
                Rectangle {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    radius: 7
                    color: SRITECTheme.accentCyan

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PropertyAnimation { to: 0.35; duration: 1400; easing.type: Easing.InOutQuad }
                        PropertyAnimation { to: 1.0; duration: 1400; easing.type: Easing.InOutQuad }
                    }
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "SRITEC"
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 15
                    font.bold: true
                    font.letterSpacing: 2
                }
                Text {
                    text: "NEBULA • v0.2.2"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: SRITECTheme.borderSubtle
            Layout.topMargin: 4
            Layout.bottomMargin: 8
        }

        // Section Title
        Text {
            text: "WORKSPACES"
            color: SRITECTheme.textTertiary
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 1.5
            Layout.leftMargin: 6
        }

        // Nav Item Helper Component
        component NavButton: Rectangle {
            id: btn
            property int index: 0
            property string label: ""
            property string glyph: ""
            property string badgeText: ""

            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: SRITECTheme.radiusSmall
            color: root.currentTabIndex === index
                   ? SRITECTheme.backgroundElevated
                   : (btnMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent")
            border.color: root.currentTabIndex === index ? SRITECTheme.borderAccent : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: SRITECTheme.animFast } }
            Behavior on border.color { ColorAnimation { duration: SRITECTheme.animFast } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                Text {
                    text: btn.glyph
                    color: root.currentTabIndex === index ? SRITECTheme.accentCyan : SRITECTheme.textSecondary
                    font.pixelSize: 14
                    font.bold: true
                }

                Text {
                    text: btn.label
                    color: root.currentTabIndex === index ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                    font.pixelSize: 12
                    font.weight: root.currentTabIndex === index ? Font.Medium : Font.Normal
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: btn.badgeText.length > 0
                    Layout.preferredWidth: badgeLabel.implicitWidth + 8
                    Layout.preferredHeight: 18
                    radius: 9
                    color: SRITECTheme.accentCyan
                    opacity: 0.15

                    Text {
                        id: badgeLabel
                        anchors.centerIn: parent
                        text: btn.badgeText
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }

            MouseArea {
                id: btnMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.currentTabIndex = btn.index;
                    root.tabSelected(btn.index);
                }
            }
        }

        NavButton {
            index: 0
            label: "Desktop Space"
            glyph: "⌂"
            badgeText: "NEBULA"
        }

        NavButton {
            index: 1
            label: "AI Neural Hub"
            glyph: "🧠"
            badgeText: "ACTIVE"
        }

        NavButton {
            index: 2
            label: "Dev Workspace"
            glyph: "💻"
            badgeText: "C++20"
        }

        NavButton {
            index: 3
            label: "System Settings"
            glyph: "⚙"
            badgeText: "PREFS"
        }

        NavButton {
            index: 4
            label: "System Telemetry"
            glyph: "⚡"
            badgeText: "LIVE"
        }

        NavButton {
            index: 5
            label: "Security & Policy"
            glyph: "⛨"
            badgeText: "STRICT"
        }

        Item { Layout.fillHeight: true }

        // Bottom User / Execution Boundary Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            radius: SRITECTheme.radiusSmall
            color: SRITECTheme.backgroundVoid
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 16
                    color: SRITECTheme.backgroundElevated
                    border.color: SRITECTheme.accentEmerald
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "S"
                        color: SRITECTheme.accentEmerald
                        font.bold: true
                        font.pixelSize: 13
                    }
                }

                ColumnLayout {
                    spacing: 1
                    Layout.fillWidth: true
                    Text {
                        text: "sarathi@sritec"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        text: "UNPRIVILEGED USER"
                        color: SRITECTheme.accentEmerald
                        font.pixelSize: 9
                        font.letterSpacing: 0.5
                    }
                }
            }
        }
    }
}
