import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme"
import "../../components"

Rectangle {
    id: root

    property string windowId: ""
    color: "#05080E"
    radius: SRITECTheme.radiusLarge
    clip: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // =====================================================================
        // 1. Terminal Session Tabs Bar
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: Qt.rgba(13/255, 17/255, 26/255, 0.95)
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                    RowLayout {
                        spacing: 4

                        Repeater {
                            model: globalTerminalBackend.sessions

                            delegate: Rectangle {
                                required property var modelData
                                Layout.preferredHeight: 28
                                Layout.preferredWidth: Math.min(180, Math.max(100, termTabText.implicitWidth + 40))
                                radius: 4
                                color: modelData.isActive ? Qt.rgba(0/255, 229/255, 255/255, 0.18) : Qt.rgba(19/255, 26/255, 40/255, 0.6)
                                border.color: modelData.isActive ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 6
                                    spacing: 4

                                    Text { text: ">_"; color: SRITECTheme.accentCyan; font.pixelSize: 9; font.family: SRITECTheme.fontMono }

                                    Text {
                                        id: termTabText
                                        Layout.fillWidth: true
                                        text: modelData.title
                                        color: modelData.isActive ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                        font.pixelSize: 10
                                        font.bold: modelData.isActive
                                        elide: Text.ElideRight
                                    }

                                    // Close Tab Button
                                    Rectangle {
                                        Layout.preferredWidth: 14
                                        Layout.preferredHeight: 14
                                        radius: 3
                                        color: tabCloseMouse.containsMouse ? Qt.rgba(255/255, 59/255, 92/255, 0.3) : "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "✕"
                                            color: tabCloseMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.textSecondary
                                            font.pixelSize: 8
                                        }

                                        MouseArea {
                                            id: tabCloseMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: globalTerminalBackend.closeSession(modelData.id)
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    z: -1
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: globalTerminalBackend.activeSessionId = modelData.id
                                }
                            }
                        }
                    }
                }

                // Add Tab Button
                Rectangle {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 4
                    color: addTermMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                    border.color: addTermMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    Text { anchors.centerIn: parent; text: "+"; color: SRITECTheme.accentCyan; font.pixelSize: 12; font.bold: true }

                    MouseArea {
                        id: addTermMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: globalTerminalBackend.createSession()
                    }
                }

                // Kill Process (^C)
                Rectangle {
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 48
                    radius: 4
                    color: killMouse.containsMouse ? Qt.rgba(255/255, 59/255, 92/255, 0.25) : "transparent"
                    border.color: SRITECTheme.accentCrimson
                    border.width: 1

                    Text { anchors.centerIn: parent; text: "^C Kill"; color: SRITECTheme.accentCrimson; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono }

                    MouseArea {
                        id: killMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: globalTerminalBackend.killActiveProcess()
                    }
                }

                // Clear Terminal
                Rectangle {
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 48
                    radius: 4
                    color: clrMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    Text { anchors.centerIn: parent; text: "Clear"; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.family: SRITECTheme.fontMono }

                    MouseArea {
                        id: clrMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: globalTerminalBackend.clearActiveSession()
                    }
                }
            }
        }

        // =====================================================================
        // 2. Terminal Output Stream
        // =====================================================================
        ScrollView {
            id: terminalScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: historyList
                width: terminalScroll.width - 24
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.top: parent.top
                anchors.topMargin: 10
                model: globalTerminalBackend.activeOutput
                spacing: 3

                delegate: Text {
                    required property var modelData
                    width: historyList.width
                    text: modelData.text
                    color: modelData.color
                    font.pixelSize: 11
                    font.family: SRITECTheme.fontMono
                    wrapMode: Text.WrapAnywhere
                }

                onCountChanged: {
                    historyList.positionViewAtEnd();
                }
            }
        }

        // =====================================================================
        // 3. Command Prompt Input Line
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: Qt.rgba(13/255, 17/255, 26/255, 0.95)
            border.color: termInput.activeFocus ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: "sarathi@nebula:" + (globalTerminalBackend.activeWorkingDir.split('/').pop() || "~") + "$"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 11
                    font.bold: true
                    font.family: SRITECTheme.fontMono
                }

                TextField {
                    id: termInput
                    Layout.fillWidth: true
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 11
                    font.family: SRITECTheme.fontMono
                    background: null
                    focus: true
                    selectByMouse: true

                    Keys.onUpPressed: {
                        var prev = globalTerminalBackend.getPreviousHistoryCommand();
                        if (prev.length > 0) text = prev;
                    }

                    Keys.onDownPressed: {
                        var next = globalTerminalBackend.getNextHistoryCommand();
                        text = next;
                    }

                    onAccepted: {
                        var cmd = text.trim();
                        if (cmd.length > 0) {
                            globalTerminalBackend.executeCommand(cmd);
                            text = "";
                        }
                    }
                }
            }
        }
    }
}
