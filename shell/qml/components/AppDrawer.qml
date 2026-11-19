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
    Behavior on opacity { NumberAnimation { duration: SRITECTheme.animNormal } }

    property string searchQuery: ""
    property string activeCategory: "All"

    // Dimmed spatial backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.65)

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeDrawer()
        }
    }

    // Floating Holographic Application Prism Card
    Rectangle {
        id: drawerCard
        anchors.centerIn: parent
        width: Math.min(parent.width - 64, 960)
        height: Math.min(parent.height - 80, 620)
        radius: SRITECTheme.radiusLarge
        color: Qt.rgba(13/255, 17/255, 26/255, 0.88)
        border.color: SRITECTheme.accentCyan
        border.width: 1

        scale: root.isOpen ? 1.0 : 0.94
        Behavior on scale {
            NumberAnimation { duration: SRITECTheme.animNormal; easing.type: Easing.OutBack }
        }

        // Consume clicks
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Header: Title + Search Omnibar + Close Button
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    spacing: 8
                    Rectangle {
                        Layout.preferredWidth: 8
                        Layout.preferredHeight: 8
                        radius: 4
                        color: SRITECTheme.accentCyan
                    }
                    Text {
                        text: "APPLICATIONS & NEURAL TOOLS"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 2
                    }
                }

                Item { Layout.fillWidth: true }

                // Search Omnibar
                Rectangle {
                    Layout.preferredWidth: 320
                    Layout.preferredHeight: 38
                    radius: 19
                    color: SRITECTheme.backgroundInput
                    border.color: searchInput.activeFocus ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            text: "🔍"
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 11
                        }

                        TextField {
                            id: searchInput
                            Layout.fillWidth: true
                            placeholderText: "Search apps (Chrome, VS Code, Gemini, Terminal)..."
                            placeholderTextColor: SRITECTheme.textTertiary
                            color: SRITECTheme.textPrimary
                            font.pixelSize: 11
                            background: null
                            onTextChanged: root.searchQuery = text.toLowerCase().trim()
                        }

                        Text {
                            visible: root.searchQuery.length > 0
                            text: "✕"
                            color: SRITECTheme.textTertiary
                            font.pixelSize: 11
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    searchInput.text = "";
                                    root.searchQuery = "";
                                }
                            }
                        }
                    }
                }

                // Close Button
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 16
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
                        onClicked: root.closeDrawer()
                    }
                }
            }

            // Category Filter Pills
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: ["All", "Internet", "Development", "AI Engines", "System", "Utilities", "Recent"]

                    delegate: Rectangle {
                        id: catBtn
                        required property string modelData
                        property bool isSelected: root.activeCategory === catBtn.modelData

                        Layout.preferredHeight: 28
                        Layout.preferredWidth: catText.implicitWidth + 20
                        radius: 14
                        color: isSelected ? SRITECTheme.accentCyan :
                               (catMouse.containsMouse ? SRITECTheme.backgroundHover : SRITECTheme.backgroundElevated)

                        Text {
                            id: catText
                            anchors.centerIn: parent
                            text: catBtn.modelData
                            color: catBtn.isSelected ? SRITECTheme.backgroundVoid : SRITECTheme.textSecondary
                            font.pixelSize: 11
                            font.bold: catBtn.isSelected
                        }

                        MouseArea {
                            id: catMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeCategory = catBtn.modelData
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: SRITECTheme.borderSubtle
            }

            // Applications Grid View
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                GridView {
                    id: appGrid
                    anchors.fill: parent
                    cellWidth: 290
                    cellHeight: 96

                    model: filterApps(globalAppLauncher.installedApps, root.searchQuery, root.activeCategory)

                    delegate: Rectangle {
                        id: appCard
                        required property var modelData
                        property bool isHovered: cardMouse.containsMouse
                        property bool isAvailable: modelData.isAvailable
                        property bool isPinned: globalDesktopManager.isAppPinned(modelData.id)

                        width: 276
                        height: 84
                        radius: SRITECTheme.radiusMedium
                        color: isHovered ? SRITECTheme.backgroundElevated : Qt.rgba(255, 255, 255, 0.03)
                        border.color: isHovered ? (isAvailable ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle) : SRITECTheme.borderSubtle
                        border.width: 1
                        opacity: isAvailable ? 1.0 : 0.65

                        Behavior on color { ColorAnimation { duration: SRITECTheme.animFast } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 12

                            // AI Holographic Icon Tile
                            AIIcon {
                                Layout.preferredWidth: 46
                                Layout.preferredHeight: 46
                                iconId: appCard.modelData.id
                                size: 46
                                isHovered: appCard.isHovered
                                isAvailable: appCard.isAvailable
                                showTile: true
                            }

                            // App Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: appCard.modelData.name
                                    color: SRITECTheme.textPrimary
                                    font.pixelSize: 12
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: appCard.modelData.description
                                    color: SRITECTheme.textTertiary
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                RowLayout {
                                    spacing: 6
                                    Rectangle {
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: appCard.isAvailable ? SRITECTheme.accentEmerald : SRITECTheme.accentAmber
                                    }

                                    Text {
                                        text: appCard.isAvailable ? "INSTALLED" : "UNAVAILABLE"
                                        color: appCard.isAvailable ? SRITECTheme.accentEmerald : SRITECTheme.accentAmber
                                        font.pixelSize: 9
                                        font.bold: true
                                    }

                                    Text {
                                        text: "• " + appCard.modelData.category
                                        color: SRITECTheme.textTertiary
                                        font.pixelSize: 9
                                    }
                                }
                            }

                            // Action Controls (Pin & Launch)
                            ColumnLayout {
                                spacing: 4

                                // Pin Button
                                Rectangle {
                                    Layout.preferredWidth: 26
                                    Layout.preferredHeight: 26
                                    radius: 6
                                    color: appCard.isPinned ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : (pinMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent")
                                    border.color: appCard.isPinned ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: "📌"
                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        id: pinMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (appCard.isPinned) {
                                                globalDesktopManager.unpinApp(appCard.modelData.id);
                                            } else {
                                                globalDesktopManager.pinApp(appCard.modelData.id);
                                            }
                                        }
                                    }
                                }

                                // Launch Button (Active if installed)
                                Rectangle {
                                    visible: appCard.isAvailable
                                    Layout.preferredWidth: 26
                                    Layout.preferredHeight: 26
                                    radius: 6
                                    color: launchMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.backgroundHover

                                    Text {
                                        anchors.centerIn: parent
                                        text: "▶"
                                        color: launchMouse.containsMouse ? SRITECTheme.backgroundVoid : SRITECTheme.textSecondary
                                        font.pixelSize: 10
                                    }

                                    MouseArea {
                                        id: launchMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var pt = appCard.mapToItem(null, 0, 0);
                                            globalAppLaunchManager.requestAppLaunch(appCard.modelData.id, pt.x, pt.y, appCard.width, appCard.height);
                                            root.closeDrawer();
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: cardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: appCard.isAvailable ? Qt.PointingHandCursor : Qt.ArrowCursor
                            z: -1
                            onDoubleClicked: {
                                var pt = appCard.mapToItem(null, 0, 0);
                                globalAppLaunchManager.requestAppLaunch(appCard.modelData.id, pt.x, pt.y, appCard.width, appCard.height);
                                root.closeDrawer();
                            }
                        }
                    }
                }
            }
        }
    }

    function openDrawer() {
        isOpen = true;
        searchInput.forceActiveFocus();
    }

    function closeDrawer() {
        isOpen = false;
        closed();
    }

    function filterApps(apps, query, category) {
        if (!apps) return [];
        var result = [];
        var recents = globalDesktopManager.recentApps;

        for (var i = 0; i < apps.length; ++i) {
            var app = apps[i];
            var matchQuery = query.length === 0 ||
                             app.name.toLowerCase().indexOf(query) !== -1 ||
                             app.description.toLowerCase().indexOf(query) !== -1 ||
                             app.id.toLowerCase().indexOf(query) !== -1;

            if (!matchQuery) continue;

            if (category === "All") {
                result.push(app);
            } else if (category === "Recent") {
                if (recents.indexOf(app.id) !== -1) {
                    result.push(app);
                }
            } else if (app.category && app.category.toLowerCase() === category.toLowerCase()) {
                result.push(app);
            }
        }
        return result;
    }
}
