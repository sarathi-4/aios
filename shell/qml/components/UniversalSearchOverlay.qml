import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    property bool isOpen: false
    signal closed()
    signal appLaunched(string appId)

    visible: opacity > 0
    opacity: isOpen ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: SRITECTheme.animFast } }

    property var searchResults: []
    property int selectedResultIndex: 0

    // Backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.65)

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeSearch()
        }
    }

    // Modal Card centered vertically, positioned towards top half
    Rectangle {
        id: searchCard
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.isOpen ? 90 : 50
        width: Math.min(parent.width - 48, 680)
        height: Math.min(parent.height - 180, 500)
        radius: SRITECTheme.radiusLarge
        color: SRITECTheme.backgroundGlassElevated
        border.color: SRITECTheme.accentCyan
        border.width: 1

        Behavior on anchors.topMargin {
            NumberAnimation { duration: SRITECTheme.animFast; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            // Search Header Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "✦"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 18
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Type to search apps, desktop items, project files (Ctrl+Space)..."
                    placeholderTextColor: SRITECTheme.textTertiary
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 14
                    background: null

                    onTextChanged: {
                        var q = text.trim();
                        if (q.length > 0) {
                            root.searchResults = globalDesktopManager.universalSearch(q);
                        } else {
                            root.searchResults = [];
                        }
                        root.selectedResultIndex = 0;
                    }

                    Keys.onEscapePressed: root.closeSearch()

                    Keys.onDownPressed: {
                        if (root.selectedResultIndex < root.searchResults.length - 1) {
                            root.selectedResultIndex++;
                        }
                    }

                    Keys.onUpPressed: {
                        if (root.selectedResultIndex > 0) {
                            root.selectedResultIndex--;
                        }
                    }

                    Keys.onReturnPressed: {
                        if (root.searchResults.length > 0 && root.selectedResultIndex < root.searchResults.length) {
                            root.activateResult(root.searchResults[root.selectedResultIndex]);
                        }
                    }
                }

                // Keyboard indicator
                Rectangle {
                    Layout.preferredHeight: 22
                    implicitWidth: escText.implicitWidth + 12
                    radius: 4
                    color: SRITECTheme.backgroundElevated
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    Text {
                        id: escText
                        anchors.centerIn: parent
                        text: "ESC"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: SRITECTheme.borderSubtle
            }

            // Results List
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Zero search state
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: searchField.text.trim().length === 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "UNIVERSAL INDEX SEARCH"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Search system binaries, desktop shortcuts, and workspace files instantly."
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 11
                    }
                }

                // No results found
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: searchField.text.trim().length > 0 && root.searchResults.length === 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No matches found for \"" + searchField.text.trim() + "\""
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 12
                    }
                }

                // Results ListView
                ListView {
                    id: resultsList
                    anchors.fill: parent
                    clip: true
                    spacing: 6
                    model: root.searchResults
                    visible: root.searchResults.length > 0

                    delegate: Rectangle {
                        id: resItem
                        required property var modelData
                        required property int index
                        property bool isSelected: root.selectedResultIndex === resItem.index
                        property bool isHovered: itemMouse.containsMouse

                        width: parent ? parent.width : 640
                        height: 52
                        radius: SRITECTheme.radiusMedium
                        color: isSelected ? Qt.rgba(0/255, 229/255, 255/255, 0.14) :
                               (isHovered ? SRITECTheme.backgroundElevated : "transparent")
                        border.color: isSelected ? SRITECTheme.accentCyan : "transparent"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            // Type icon
                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: 8
                                color: resItem.modelData.type === "app" ? Qt.rgba(0/255, 229/255, 255/255, 0.15) :
                                       resItem.modelData.type === "desktop" ? Qt.rgba(139/255, 92/255, 246/255, 0.15) :
                                       Qt.rgba(255/255, 184/255, 0/255, 0.15)

                                Text {
                                    anchors.centerIn: parent
                                    text: resItem.modelData.icon || "•"
                                    font.pixelSize: 16
                                }
                            }

                            // Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    spacing: 8
                                    Text {
                                        text: resItem.modelData.title
                                        color: SRITECTheme.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                    }

                                    // Category badge
                                    Rectangle {
                                        Layout.preferredHeight: 16
                                        implicitWidth: badgeText.implicitWidth + 8
                                        radius: 4
                                        color: SRITECTheme.backgroundElevated

                                        Text {
                                            id: badgeText
                                            anchors.centerIn: parent
                                            text: resItem.modelData.category.toUpperCase()
                                            color: SRITECTheme.accentCyan
                                            font.pixelSize: 8
                                            font.bold: true
                                        }
                                    }
                                }

                                Text {
                                    text: resItem.modelData.subtitle
                                    color: SRITECTheme.textTertiary
                                    font.pixelSize: 10
                                    font.family: SRITECTheme.fontMono
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                }
                            }

                            // Action hint
                            Text {
                                text: resItem.isSelected ? "Press ↵ to Open" : ""
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedResultIndex = resItem.index;
                                root.activateResult(resItem.modelData);
                            }
                        }
                    }
                }
            }
        }
    }

    function openSearch() {
        isOpen = true;
        searchField.text = "";
        searchResults = [];
        selectedResultIndex = 0;
        searchField.forceActiveFocus();
    }

    function closeSearch() {
        isOpen = false;
        closed();
    }

    function activateResult(item) {
        if (!item) return;

        if (item.type === "app") {
            globalAppLaunchManager.requestAppLaunch(item.target, searchCard.x + searchCard.width * 0.5, searchCard.y + searchCard.height * 0.5);
            root.appLaunched(item.target);
        } else if (item.type === "desktop") {
            globalDesktopManager.openItem(item.target);
        } else if (item.type === "file") {
            globalAppLaunchManager.requestAppLaunch("files", searchCard.x + searchCard.width * 0.5, searchCard.y + searchCard.height * 0.5);
        }
        root.closeSearch();
    }
}
