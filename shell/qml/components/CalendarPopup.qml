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

    property var currentDate: new Date()
    property int displayYear: currentDate.getFullYear()
    property int displayMonth: currentDate.getMonth() // 0-indexed

    // Dismiss on click outside
    MouseArea {
        anchors.fill: parent
        onClicked: root.closeCalendar()
    }

    // Card anchored top-right below the clock
    Rectangle {
        id: calendarCard
        anchors.top: parent.top
        anchors.topMargin: 56
        anchors.right: parent.right
        anchors.rightMargin: 120
        width: 320
        height: 420
        radius: SRITECTheme.radiusLarge
        color: SRITECTheme.backgroundGlassElevated
        border.color: SRITECTheme.borderSubtle
        border.width: 1

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Top Header: Today's date & time
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: Qt.formatDateTime(root.currentDate, "dddd, MMMM d, yyyy")
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 12
                    font.bold: true
                }

                Text {
                    id: liveClock
                    text: Qt.formatTime(root.currentDate, "hh:mm:ss AP")
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 20
                    font.bold: true
                    font.family: SRITECTheme.fontMono
                }

                Timer {
                    interval: 1000
                    running: root.isOpen
                    repeat: true
                    onTriggered: {
                        root.currentDate = new Date();
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: SRITECTheme.borderSubtle
            }

            // Month navigation bar
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: getMonthName(root.displayMonth) + " " + root.displayYear
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 13
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // Prev month
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 4
                    color: prevMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "◀"
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 10
                    }
                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.displayMonth === 0) {
                                root.displayMonth = 11;
                                root.displayYear--;
                            } else {
                                root.displayMonth--;
                            }
                        }
                    }
                }

                // Next month
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 4
                    color: nextMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "▶"
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 10
                    }
                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.displayMonth === 11) {
                                root.displayMonth = 0;
                                root.displayYear++;
                            } else {
                                root.displayMonth++;
                            }
                        }
                    }
                }
            }

            // Days of week header
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

                    delegate: Text {
                        required property string modelData
                        Layout.preferredWidth: 284 / 7
                        text: modelData
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 10
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Days Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 0

                Repeater {
                    model: 35 // 5 weeks display

                    delegate: Rectangle {
                        id: dayCell
                        required property int index
                        property int dayNumber: getDayForIndex(dayCell.index)
                        property bool isToday: isCurrentDay(dayCell.dayNumber)
                        property bool isValidDay: dayCell.dayNumber > 0

                        Layout.preferredWidth: 284 / 7
                        Layout.preferredHeight: 26
                        radius: 6
                        color: isToday ? SRITECTheme.accentCyan :
                               (cellMouse.containsMouse && isValidDay ? SRITECTheme.backgroundHover : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: dayCell.isValidDay ? dayCell.dayNumber : ""
                            color: dayCell.isToday ? SRITECTheme.backgroundVoid :
                                   (dayCell.isValidDay ? SRITECTheme.textPrimary : "transparent")
                            font.pixelSize: 11
                            font.bold: dayCell.isToday
                        }

                        MouseArea {
                            id: cellMouse
                            anchors.fill: parent
                            hoverEnabled: dayCell.isValidDay
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: SRITECTheme.borderSubtle
            }

            // Upcoming Milestones Banner
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 6
                    Layout.preferredHeight: 6
                    radius: 3
                    color: SRITECTheme.accentEmerald
                }

                Text {
                    text: "Milestone 3.2 Desktop Verified • Clean Run"
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 10
                    font.family: SRITECTheme.fontMono
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }

    function openCalendar() {
        currentDate = new Date();
        displayYear = currentDate.getFullYear();
        displayMonth = currentDate.getMonth();
        isOpen = true;
    }

    function closeCalendar() {
        isOpen = false;
        closed();
    }

    function getMonthName(m) {
        var names = ["January", "February", "March", "April", "May", "June",
                     "July", "August", "September", "October", "November", "December"];
        return names[m] || "";
    }

    function getDayForIndex(idx) {
        var firstDayIndex = new Date(displayYear, displayMonth, 1).getDay();
        var totalDays = new Date(displayYear, displayMonth + 1, 0).getDate();
        var dayNum = idx - firstDayIndex + 1;
        if (dayNum >= 1 && dayNum <= totalDays) {
            return dayNum;
        }
        return -1;
    }

    function isCurrentDay(day) {
        var now = new Date();
        return day > 0 &&
               now.getDate() === day &&
               now.getMonth() === displayMonth &&
               now.getFullYear() === displayYear;
    }
}
