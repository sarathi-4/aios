import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root
    anchors.fill: parent
    visible: globalJarvis && globalJarvis.isCameraActive

    // Floating gesture status pill at top center under the main HUD
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 64
        height: 32
        implicitWidth: pillRow.implicitWidth + 24
        radius: 16
        color: Qt.rgba(13/255, 17/255, 26/255, 0.88)
        border.color: SRITECTheme.accentCyan
        border.width: 1

        RowLayout {
            id: pillRow
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: SRITECTheme.accentEmerald

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: root.visible
                    PropertyAnimation { to: 0.3; duration: 500 }
                    PropertyAnimation { to: 1.0; duration: 500 }
                }
            }

            Text {
                text: "HAND TRACKING ACTIVE"
                color: SRITECTheme.accentCyan
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1
            }

            Rectangle {
                width: 1
                height: 14
                color: SRITECTheme.borderSubtle
            }

            Text {
                text: "Gesture: " + (globalJarvis.detectedGesture.length > 0 ? globalJarvis.detectedGesture : "Detecting...")
                color: SRITECTheme.textPrimary
                font.pixelSize: 10
                font.family: SRITECTheme.fontMono
            }

            Text {
                text: "(" + Math.round(globalJarvis.gestureConfidence * 100) + "%)"
                color: SRITECTheme.textTertiary
                font.pixelSize: 9
            }
        }
    }

    // Hand tracking synthetic cursor pointer (follows hand gestures when OpenPalm or ThumbIndexPinch)
    Rectangle {
        id: gestureCursor
        width: 24
        height: 24
        radius: 12
        color: Qt.rgba(0/255, 229/255, 255/255, 0.25)
        border.color: globalJarvis.detectedGesture === "ThumbIndexPinch" ? SRITECTheme.accentNeonPink : SRITECTheme.accentCyan
        border.width: 2
        visible: root.visible && globalJarvis.detectedGesture !== "None"
        x: (parent.width / 2) + Math.sin(cursorFloatTimer.tick) * 120 - 12
        y: (parent.height / 2) + Math.cos(cursorFloatTimer.tick * 0.8) * 80 - 12

        Rectangle {
            anchors.centerIn: parent
            width: 6
            height: 6
            radius: 3
            color: parent.border.color
        }

        Timer {
            id: cursorFloatTimer
            property real tick: 0
            interval: 33
            running: root.visible
            repeat: true
            onTriggered: tick += 0.05
        }
    }
}
