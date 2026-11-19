import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    visible: globalScreenCapture.isRecording
    z: 250
    implicitHeight: 38
    implicitWidth: rowLayout.implicitWidth + 24
    radius: 19
    color: Qt.rgba(13/255, 17/255, 26/255, 0.92)
    border.color: SRITECTheme.accentCrimson
    border.width: 1.5

    Behavior on opacity { NumberAnimation { duration: SRITECTheme.animFast } }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 10

        // Pulsing Red Recording Indicator Dot
        Rectangle {
            Layout.preferredWidth: 10
            Layout.preferredHeight: 10
            radius: 5
            color: SRITECTheme.accentCrimson

            SequentialAnimation on opacity {
                running: globalScreenCapture.isRecording
                loops: Animation.Infinite
                PropertyAnimation { to: 0.2; duration: 450 }
                PropertyAnimation { to: 1.0; duration: 450 }
            }
        }

        Text {
            text: "REC"
            color: SRITECTheme.accentCrimson
            font.pixelSize: 11
            font.bold: true
            font.letterSpacing: 1.2
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 14
            color: SRITECTheme.borderSubtle
        }

        // Formatted Duration Counter MM:SS
        Text {
            function formatTime(totalSeconds) {
                var m = Math.floor(totalSeconds / 60);
                var s = totalSeconds % 60;
                var mm = m < 10 ? "0" + m : "" + m;
                var ss = s < 10 ? "0" + s : "" + s;
                return mm + ":" + ss;
            }

            text: formatTime(globalScreenCapture.recordingDurationSeconds)
            color: SRITECTheme.textPrimary
            font.pixelSize: 12
            font.family: SRITECTheme.fontMono
            font.bold: true
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 14
            color: SRITECTheme.borderSubtle
        }

        // Stop Recording Button
        Rectangle {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: 13
            color: stopMouse.containsMouse ? SRITECTheme.accentCrimson : Qt.rgba(255/255, 23/255, 68/255, 0.25)
            border.color: SRITECTheme.accentCrimson
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "⏹"
                color: stopMouse.containsMouse ? SRITECTheme.backgroundVoid : SRITECTheme.accentCrimson
                font.pixelSize: 11
            }

            MouseArea {
                id: stopMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    globalAudioService.playNotification();
                    globalScreenCapture.stopRecording();
                }
            }
        }
    }
}
