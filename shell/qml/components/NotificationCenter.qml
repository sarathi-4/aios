import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    property bool isOpen: false
    signal closed()

    visible: opacity > 0
    opacity: isOpen ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: SRITECTheme.animFast } }

    // Dimmed backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5)

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeCenter()
        }
    }

    // Slide-out Drawer Panel anchored to right edge
    Rectangle {
        id: drawerCard
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: root.isOpen ? 0 : -380
        width: 360
        color: SRITECTheme.backgroundGlassElevated
        border.color: SRITECTheme.borderSubtle
        border.width: 1

        Behavior on anchors.rightMargin {
            NumberAnimation { duration: SRITECTheme.animNormal; easing.type: Easing.OutCubic }
        }

        // Consume clicks
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "🔔"
                    font.pixelSize: 16
                }

                Text {
                    text: "NOTIFICATIONS"
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 1.2
                }

                Rectangle {
                    visible: globalDesktopManager.unreadNotificationsCount > 0
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    radius: 10
                    color: SRITECTheme.accentCyan

                    Text {
                        anchors.centerIn: parent
                        text: globalDesktopManager.unreadNotificationsCount
                        color: SRITECTheme.backgroundVoid
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                Item { Layout.fillWidth: true }

                // Clear All Button
                Rectangle {
                    visible: globalDesktopManager.unreadNotificationsCount > 0
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 24
                    radius: 12
                    color: clearMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Clear All"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: globalDesktopManager.clearAllNotifications()
                    }
                }

                // Close Button
                Rectangle {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 13
                    color: closeMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeCenter()
                    }
                }
            }

            // Do Not Disturb Toggle Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                radius: SRITECTheme.radiusMedium
                color: SRITECTheme.backgroundElevated
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "🌙"
                        font.pixelSize: 12
                    }

                    Text {
                        text: "Do Not Disturb"
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    Switch {
                        id: dndSwitch
                        checked: globalDesktopManager.doNotDisturb
                        onToggled: globalDesktopManager.doNotDisturb = checked
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: SRITECTheme.borderSubtle
            }

            // Notification List or Empty State
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Empty State
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    visible: globalDesktopManager.unreadNotificationsCount === 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "✦"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 32
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "ALL CAUGHT UP"
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No pending system or security notifications."
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 11
                    }
                }

                // Notifications ListView
                ListView {
                    anchors.fill: parent
                    clip: true
                    spacing: 10
                    model: globalDesktopManager.notifications
                    visible: globalDesktopManager.unreadNotificationsCount > 0

                    delegate: Rectangle {
                        id: notifCard
                        required property var modelData
                        property string notifId: modelData.id
                        property string notifTitle: modelData.title
                        property string notifMessage: modelData.message
                        property string notifTime: modelData.timestamp
                        property string notifType: modelData.type
                        property string notifIcon: modelData.icon

                        width: parent ? parent.width : 320
                        implicitHeight: contentCol.implicitHeight + 20
                        radius: SRITECTheme.radiusMedium
                        color: SRITECTheme.backgroundElevated
                        border.color: notifType === "security" ? SRITECTheme.accentCrimson :
                                      notifType === "warning" ? SRITECTheme.accentAmber :
                                      notifType === "success" ? SRITECTheme.accentEmerald : SRITECTheme.borderSubtle
                        border.width: 1

                        ColumnLayout {
                            id: contentCol
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: notifCard.notifIcon
                                    font.pixelSize: 13
                                }

                                Text {
                                    text: notifCard.notifTitle
                                    color: SRITECTheme.textPrimary
                                    font.pixelSize: 11
                                    font.bold: true
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: notifCard.notifTime
                                    color: SRITECTheme.textTertiary
                                    font.pixelSize: 9
                                    font.family: SRITECTheme.fontMono
                                }

                                // Dismiss button
                                Text {
                                    text: "✕"
                                    color: SRITECTheme.textTertiary
                                    font.pixelSize: 11
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: globalDesktopManager.clearNotification(notifCard.notifId)
                                    }
                                }
                            }

                            Text {
                                text: notifCard.notifMessage
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }

    function openCenter() {
        isOpen = true;
    }

    function closeCenter() {
        isOpen = false;
        closed();
    }
}
