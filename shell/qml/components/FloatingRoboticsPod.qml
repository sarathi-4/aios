import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    property string imageSource: ""
    property string title: "ROBOTICS POD"
    property string subtitle: "Autonomous Unit"
    property string statusBadge: "TELEMETRY LINKED"
    property color accentColor: SRITECTheme.accentCyan
    property int floatOffset: 6
    property int floatDuration: 4200
    property string unitId: "fleet"

    signal inspectRequested(string unitId)

    implicitWidth: 280
    implicitHeight: 236

    // Internal vertical floating offset (Anchor-safe transform)
    property real currentFloatY: 0

    SequentialAnimation on currentFloatY {
        loops: Animation.Infinite
        running: true
        NumberAnimation {
            to: root.floatOffset
            duration: root.floatDuration * 0.5
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            to: -root.floatOffset
            duration: root.floatDuration * 0.5
            easing.type: Easing.InOutSine
        }
    }

    // Glass Card Pod
    Rectangle {
        id: cardContainer
        anchors.fill: parent
        anchors.margins: 4
        transform: Translate { y: root.currentFloatY }

        radius: SRITECTheme.radiusLarge
        color: podMouse.containsMouse ? Qt.rgba(19/255, 26/255, 40/255, 0.90) : Qt.rgba(13/255, 17/255, 26/255, 0.76)
        border.color: podMouse.containsMouse ? root.accentColor : SRITECTheme.borderSubtle
        border.width: 1

        scale: podMouse.containsMouse ? 1.025 : 1.0

        Behavior on scale { NumberAnimation { duration: SRITECTheme.animFast; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: SRITECTheme.animFast } }
        Behavior on border.color { ColorAnimation { duration: SRITECTheme.animFast } }

        // Subtle ambient neon backlight when hovered
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: SRITECTheme.radiusLarge + 2
            color: "transparent"
            border.color: root.accentColor
            border.width: 1
            opacity: podMouse.containsMouse ? 0.45 : 0.0
            z: -1
            Behavior on opacity { NumberAnimation { duration: SRITECTheme.animNormal } }
        }

        // Futuristic Sci-Fi Corner Brackets
        Canvas {
            id: cornerCanvas
            anchors.fill: parent
            z: 2
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = podMouse.containsMouse ? root.accentColor : Qt.rgba(142/255, 158/255, 181/255, 0.4);
                ctx.lineWidth = 1.5;

                var bracketLen = 10;
                var offset = 6;

                // Top-Left
                ctx.beginPath();
                ctx.moveTo(offset, offset + bracketLen);
                ctx.lineTo(offset, offset);
                ctx.lineTo(offset + bracketLen, offset);
                ctx.stroke();

                // Top-Right
                ctx.beginPath();
                ctx.moveTo(width - offset - bracketLen, offset);
                ctx.lineTo(width - offset, offset);
                ctx.lineTo(width - offset, offset + bracketLen);
                ctx.stroke();

                // Bottom-Left
                ctx.beginPath();
                ctx.moveTo(offset, height - offset - bracketLen);
                ctx.lineTo(offset, height - offset);
                ctx.lineTo(offset + bracketLen, height - offset);
                ctx.stroke();

                // Bottom-Right
                ctx.beginPath();
                ctx.moveTo(width - offset - bracketLen, height - offset);
                ctx.lineTo(width - offset, height - offset);
                ctx.lineTo(width - offset, height - offset - bracketLen);
                ctx.stroke();
            }

            Connections {
                target: podMouse
                function onContainsMouseChanged() { cornerCanvas.requestPaint(); }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            // Robotics Visual Thumbnail with Holographic Frame
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 124
                radius: 10
                clip: true
                color: "#05080E"
                border.color: podMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.4) : SRITECTheme.borderSubtle
                border.width: 1

                Image {
                    id: unitImage
                    anchors.fill: parent
                    source: root.imageSource
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    opacity: podMouse.containsMouse ? 1.0 : 0.88

                    Behavior on opacity { NumberAnimation { duration: SRITECTheme.animFast } }
                }

                // Cybernetic Scanline & Grid Effect Overlay
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.7; color: Qt.rgba(7/255, 10/255, 15/255, 0.25) }
                        GradientStop { position: 1.0; color: Qt.rgba(7/255, 10/255, 15/255, 0.88) }
                    }
                }

                // Live Status Pill (Simulated Telemetry Indicator)
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 8
                    height: 20
                    width: statusRow.implicitWidth + 14
                    radius: 10
                    color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                    border.color: root.accentColor
                    border.width: 1

                    RowLayout {
                        id: statusRow
                        anchors.centerIn: parent
                        spacing: 5

                        Rectangle {
                            Layout.preferredWidth: 6
                            Layout.preferredHeight: 6
                            radius: 3
                            color: SRITECTheme.accentEmerald

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: true
                                NumberAnimation { to: 0.3; duration: 900; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutQuad }
                            }
                        }

                        Text {
                            text: root.statusBadge
                            color: SRITECTheme.textPrimary
                            font.pixelSize: 8
                            font.bold: true
                            font.family: SRITECTheme.fontMono
                        }
                    }
                }

                // Reticle Aim Watermark
                Text {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 6
                    text: "⌖ SIM_LINK"
                    color: Qt.rgba(0/255, 229/255, 255/255, 0.75)
                    font.pixelSize: 9
                    font.family: SRITECTheme.fontMono
                    font.bold: true
                }
            }

            // Information & Navigation Trigger
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "◈"
                        color: root.accentColor
                        font.pixelSize: 11
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.title
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 0.8
                        elide: Text.ElideRight
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: 17
                    text: root.subtitle
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }
            }

            // Action Trigger Footer
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                radius: 12
                color: podMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.15) : "transparent"
                border.color: podMouse.containsMouse ? root.accentColor : "transparent"
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "Inspect Workspace"
                        color: podMouse.containsMouse ? root.accentColor : SRITECTheme.textTertiary
                        font.pixelSize: 9
                        font.bold: true
                    }

                    Text {
                        text: "▶"
                        color: podMouse.containsMouse ? root.accentColor : SRITECTheme.textTertiary
                        font.pixelSize: 8
                    }
                }
            }
        }

        MouseArea {
            id: podMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.inspectRequested(root.unitId)
        }
    }
}
