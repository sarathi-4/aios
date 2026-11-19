import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    property string filePath: ""
    property string thumbnailData: ""
    property bool isShown: false

    z: 280
    width: 380
    height: 110
    radius: SRITECTheme.radiusLarge
    color: Qt.rgba(13/255, 17/255, 26/255, 0.94)
    border.color: SRITECTheme.accentCyan
    border.width: 1.5
    visible: opacity > 0
    opacity: isShown ? 1.0 : 0.0

    Behavior on opacity { NumberAnimation { duration: SRITECTheme.animFast } }

    Timer {
        id: autoDismissTimer
        interval: 6000
        repeat: false
        onTriggered: root.isShown = false
    }

    Connections {
        target: globalScreenCapture
        function onScreenshotCaptured(path, thumb) {
            root.filePath = path;
            root.thumbnailData = thumb;
            root.isShown = true;
            autoDismissTimer.restart();
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Thumbnail Preview
        Rectangle {
            Layout.preferredWidth: 100
            Layout.preferredHeight: 70
            radius: 6
            color: SRITECTheme.backgroundElevated
            border.color: SRITECTheme.borderSubtle
            border.width: 1
            clip: true

            Image {
                anchors.fill: parent
                source: root.thumbnailData
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        // Information & Actions
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "📸 SCREENSHOT SAVED"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.0
                }
                Item { Layout.fillWidth: true }
                // Dismiss X
                Text {
                    text: "✕"
                    color: SRITECTheme.textTertiary
                    font.pixelSize: 11
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            root.isShown = false;
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.filePath.split("/").pop()
                color: SRITECTheme.textSecondary
                font.pixelSize: 10
                font.family: SRITECTheme.fontMono
                elide: Text.ElideMiddle
            }

            RowLayout {
                spacing: 8
                Button {
                    Layout.preferredHeight: 26
                    text: "Open Image"
                    onClicked: {
                        globalAudioService.playClick();
                        globalScreenCapture.openFile(root.filePath);
                        root.isShown = false;
                    }
                }
                Button {
                    Layout.preferredHeight: 26
                    text: "View Folder"
                    onClicked: {
                        globalAudioService.playClick();
                        globalScreenCapture.openRecordingDirectory();
                        root.isShown = false;
                    }
                }
            }
        }
    }
}
