import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme"
import "../../components"

Rectangle {
    id: root

    color: "#070A0F"
    radius: SRITECTheme.radiusLarge
    clip: true

    property string searchQuery: ""
    property var selectedItem: null
    property var previewData: null
    property bool showPreviewPane: true

    // Dialog Modals State
    property bool showCreateFolderDialog: false
    property bool showCreateFileDialog: false
    property bool showRenameDialog: false
    property bool showDeleteDialog: false
    property string dialogTargetName: ""

    function selectItem(item) {
        root.selectedItem = item;
        if (item) {
            root.previewData = globalFileManager.readFilePreview(item.name);
        } else {
            root.previewData = null;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // =====================================================================
        // 1. Top Navigation, Breadcrumbs & Action Toolbar
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            color: Qt.rgba(13/255, 17/255, 26/255, 0.95)
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                // Up Directory Button
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 30
                    radius: 6
                    color: upMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                    border.color: upMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "▲"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: upMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalFileManager.navigateUp();
                            root.selectItem(null);
                        }
                    }
                }

                // Refresh Button
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 30
                    radius: 6
                    color: refMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                    border.color: refMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        id: refMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalFileManager.refresh();
                            globalFileManager.refreshDrives();
                        }
                    }
                }

                // Breadcrumbs Capsule (Clickable Segments)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    radius: 6
                    color: Qt.rgba(7/255, 10/255, 15/255, 0.7)
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    ScrollView {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        RowLayout {
                            spacing: 4

                            Text {
                                text: "📁"
                                font.pixelSize: 11
                            }

                            Repeater {
                                model: globalFileManager.pathBreadcrumbs

                                delegate: RowLayout {
                                    required property var modelData
                                    spacing: 4

                                    Rectangle {
                                        Layout.preferredHeight: 22
                                        Layout.preferredWidth: bcText.implicitWidth + 10
                                        radius: 4
                                        color: bcMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                                        Text {
                                            id: bcText
                                            anchors.centerIn: parent
                                            text: modelData.name
                                            color: bcMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.textSecondary
                                            font.pixelSize: 11
                                            font.family: SRITECTheme.fontMono
                                        }

                                        MouseArea {
                                            id: bcMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                globalFileManager.navigateTo(modelData.path);
                                                root.selectItem(null);
                                            }
                                        }
                                    }

                                    Text {
                                        text: "/"
                                        color: SRITECTheme.textTertiary
                                        font.pixelSize: 10
                                        font.family: SRITECTheme.fontMono
                                    }
                                }
                            }
                        }
                    }
                }

                // Search Filter Box
                Rectangle {
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 30
                    radius: 6
                    color: Qt.rgba(7/255, 10/255, 15/255, 0.7)
                    border.color: searchField.activeFocus ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text { text: "🔍"; font.pixelSize: 10 }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: "Filter files..."
                            color: SRITECTheme.textPrimary
                            font.pixelSize: 11
                            background: null
                            selectByMouse: true

                            onTextChanged: {
                                root.searchQuery = text;
                            }
                        }
                    }
                }

                // [+ Folder] Button
                Rectangle {
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: newFoldRow.implicitWidth + 16
                    radius: 6
                    color: newFoldMouse.containsMouse ? SRITECTheme.backgroundHover : Qt.rgba(0/255, 229/255, 255/255, 0.15)
                    border.color: SRITECTheme.accentCyan
                    border.width: 1

                    RowLayout {
                        id: newFoldRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "+"; color: SRITECTheme.accentCyan; font.pixelSize: 13; font.bold: true }
                        Text { text: "Folder"; color: SRITECTheme.textPrimary; font.pixelSize: 11; font.bold: true }
                    }

                    MouseArea {
                        id: newFoldMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showCreateFolderDialog = true
                    }
                }

                // [+ File] Button
                Rectangle {
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: newFileRow.implicitWidth + 16
                    radius: 6
                    color: newFileMouse.containsMouse ? SRITECTheme.backgroundHover : Qt.rgba(0/255, 245/255, 160/255, 0.15)
                    border.color: SRITECTheme.accentEmerald
                    border.width: 1

                    RowLayout {
                        id: newFileRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "+"; color: SRITECTheme.accentEmerald; font.pixelSize: 13; font.bold: true }
                        Text { text: "File"; color: SRITECTheme.textPrimary; font.pixelSize: 11; font.bold: true }
                    }

                    MouseArea {
                        id: newFileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showCreateFileDialog = true
                    }
                }

                // Inspector Toggle
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 30
                    radius: 6
                    color: root.showPreviewPane ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : "transparent"
                    border.color: root.showPreviewPane ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "👁"
                        color: root.showPreviewPane ? SRITECTheme.accentCyan : SRITECTheme.textSecondary
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showPreviewPane = !root.showPreviewPane
                    }
                }
            }
        }

        // =====================================================================
        // 2. Main Workspace: Left Sidebar + File Grid + Inspector
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // -----------------------------------------------------------------
            // LEFT SIDEBAR: PLACES & DRIVES (Matches User Reference Image 4)
            // -----------------------------------------------------------------
            Rectangle {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                color: Qt.rgba(10/255, 14/255, 22/255, 0.95)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 8
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: parent.width - 6
                        spacing: 4

                        // PLACES Header
                        Text {
                            text: "PLACES"
                            color: SRITECTheme.accentCyan
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1.2
                            font.family: SRITECTheme.fontMono
                            Layout.leftMargin: 8
                            Layout.topMargin: 4
                            Layout.bottomMargin: 2
                        }

                        Repeater {
                            model: globalFileManager.places

                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                radius: 6
                                property bool isActive: globalFileManager.currentPath === modelData.path
                                color: isActive ? Qt.rgba(0/255, 229/255, 255/255, 0.18) :
                                       placeMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                                border.color: isActive ? SRITECTheme.accentCyan : "transparent"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text {
                                        text: modelData.icon === "home" ? "🏠" :
                                              modelData.icon === "recent" ? "🕒" :
                                              modelData.icon === "starred" ? "⭐" :
                                              modelData.icon === "trash" ? "🗑" :
                                              modelData.icon === "documents" ? "📁" :
                                              modelData.icon === "music" ? "🎵" :
                                              modelData.icon === "pictures" ? "🖼" :
                                              modelData.icon === "videos" ? "🎬" :
                                              modelData.icon === "downloads" ? "📥" : "◈"
                                        font.pixelSize: 12
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        color: isActive ? SRITECTheme.accentCyan :
                                               placeMouse.containsMouse ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                        font.pixelSize: 11
                                        font.bold: isActive
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: placeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        globalFileManager.navigateTo(modelData.path);
                                        root.selectItem(null);
                                    }
                                }
                            }
                        }

                        // Divider Line
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.topMargin: 8
                            Layout.bottomMargin: 8
                            color: SRITECTheme.borderSubtle
                        }

                        // DRIVES & DISKS Header
                        Text {
                            text: "DRIVES & DISKS"
                            color: SRITECTheme.accentEmerald
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1.2
                            font.family: SRITECTheme.fontMono
                            Layout.leftMargin: 8
                            Layout.bottomMargin: 2
                        }

                        Repeater {
                            model: globalFileManager.drives

                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 6
                                property bool isActive: globalFileManager.currentPath === modelData.path ||
                                                        globalFileManager.currentPath.startsWith(modelData.path + "/")
                                color: isActive ? Qt.rgba(0/255, 245/255, 160/255, 0.16) :
                                       driveMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                                border.color: isActive ? SRITECTheme.accentEmerald : "transparent"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text {
                                        text: modelData.type === "system" ? "💻" :
                                              modelData.type === "ssd" ? "💽" : "💾"
                                        font.pixelSize: 13
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: isActive ? SRITECTheme.accentEmerald :
                                                   driveMouse.containsMouse ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                            font.pixelSize: 11
                                            font.bold: isActive
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: modelData.size + (modelData.isMounted ? "" : " (Unmounted)")
                                            color: SRITECTheme.textTertiary
                                            font.pixelSize: 9
                                            font.family: SRITECTheme.fontMono
                                        }
                                    }

                                    // Eject / Mount indicator
                                    Text {
                                        text: modelData.isMounted ? "⏏" : "⊕"
                                        color: modelData.isMounted ? SRITECTheme.textTertiary : SRITECTheme.accentCyan
                                        font.pixelSize: 10
                                    }
                                }

                                MouseArea {
                                    id: driveMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalAudioService.playClick();
                                        globalFileManager.navigateTo(modelData.path);
                                        root.selectItem(null);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // MAIN FILE LISTING AREA (Grid View with Cyber Neon Design)
            // -----------------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                // Context Menu on Background
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: function(mouse) {
                        bgContextMenu.popup(mouse.x, mouse.y);
                    }
                }

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 12
                    clip: true

                    GridView {
                        id: fileGrid
                        anchors.fill: parent
                        cellWidth: 140
                        cellHeight: 120

                        model: {
                            if (root.searchQuery.trim().length > 0) {
                                return globalFileManager.searchEntries(root.searchQuery);
                            }
                            return globalFileManager.directoryEntries;
                        }

                        delegate: Rectangle {
                            required property var modelData
                            width: 130
                            height: 110
                            radius: 8
                            color: root.selectedItem && root.selectedItem.name === modelData.name ?
                                   Qt.rgba(0/255, 229/255, 255/255, 0.20) :
                                   itemHover.containsMouse ? SRITECTheme.backgroundHover : Qt.rgba(19/255, 26/255, 40/255, 0.45)
                            border.color: root.selectedItem && root.selectedItem.name === modelData.name ?
                                          SRITECTheme.accentCyan :
                                          itemHover.containsMouse ? SRITECTheme.borderSubtle : "transparent"
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                // Icon with Cyber Neon Styling
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.isDir ? "📁" :
                                          modelData.type === "code" ? "⚡" :
                                          modelData.type === "image" ? "🖼" :
                                          modelData.type === "document" ? "📄" :
                                          modelData.type === "audio" ? "🎵" :
                                          modelData.type === "video" ? "🎬" :
                                          modelData.type === "archive" ? "📦" : "◈"
                                    font.pixelSize: 34
                                    color: modelData.isDir ? "#FFB800" :
                                           modelData.type === "code" ? SRITECTheme.accentCyan :
                                           modelData.type === "image" ? SRITECTheme.accentEmerald :
                                           modelData.type === "document" ? "#60A5FA" : SRITECTheme.textSecondary
                                }

                                // Name
                                Text {
                                    Layout.preferredWidth: 118
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.name
                                    color: SRITECTheme.textPrimary
                                    font.pixelSize: 11
                                    font.bold: modelData.isDir
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideMiddle
                                }

                                // Size / Type
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.size
                                    color: SRITECTheme.textTertiary
                                    font.pixelSize: 9
                                    font.family: SRITECTheme.fontMono
                                }
                            }

                            // Interaction MouseArea
                            MouseArea {
                                id: itemHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                onClicked: function(mouse) {
                                    globalAudioService.playClick();
                                    root.selectItem(modelData);
                                    if (mouse.button === Qt.RightButton) {
                                        root.dialogTargetName = modelData.name;
                                        fileItemContextMenu.popup(mouse.x + mapToItem(root, 0, 0).x, mouse.y + mapToItem(root, 0, 0).y);
                                    }
                                }

                                onDoubleClicked: {
                                    globalAudioService.playClick();
                                    if (modelData.isDir) {
                                        globalFileManager.navigateTo(modelData.path);
                                        root.selectItem(null);
                                    } else {
                                        // Open file
                                        if (modelData.type === "code") {
                                            globalDevWorkspace.openFile(modelData.path);
                                            globalAppLaunchManager.requestAppLaunch("editor");
                                        } else {
                                            globalFileManager.openItem(modelData.name);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // RIGHT INSPECTOR & PREVIEW SIDEBAR
            // -----------------------------------------------------------------
            Rectangle {
                Layout.preferredWidth: root.showPreviewPane ? 300 : 0
                Layout.fillHeight: true
                visible: root.showPreviewPane
                color: Qt.rgba(13/255, 17/255, 26/255, 0.95)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Text {
                            text: "FILE INSPECTOR"
                            color: SRITECTheme.accentCyan
                            font.pixelSize: 11
                            font.bold: true
                            font.family: SRITECTheme.fontMono
                        }
                        Item { Layout.fillWidth: true }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                    // Preview Details
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10
                            visible: root.selectedItem !== null

                            // File Name & Path
                            Text {
                                Layout.fillWidth: true
                                text: root.selectedItem ? root.selectedItem.name : ""
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 13
                                font.bold: true
                                wrapMode: Text.WrapAnywhere
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Type: " + (root.previewData ? root.previewData.type : "") + "\n" +
                                      "Size: " + (root.previewData ? root.previewData.size : "") + "\n" +
                                      "Modified: " + (root.previewData ? root.previewData.modified : "")
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 10
                                font.family: SRITECTheme.fontMono
                                lineHeight: 1.5
                            }

                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                            // Action Buttons (Open, Rename, Delete)
                            RowLayout {
                                spacing: 6
                                Button {
                                    text: "Open"
                                    onClicked: {
                                        if (root.selectedItem) {
                                            if (root.selectedItem.isDir) {
                                                globalFileManager.navigateTo(root.selectedItem.path);
                                            } else if (root.selectedItem.type === "code") {
                                                globalDevWorkspace.openFile(root.selectedItem.path);
                                                globalAppLaunchManager.requestAppLaunch("editor");
                                            } else {
                                                globalFileManager.openItem(root.selectedItem.name);
                                            }
                                        }
                                    }
                                }
                                Button {
                                    text: "Rename"
                                    onClicked: {
                                        root.dialogTargetName = root.selectedItem.name;
                                        root.showRenameDialog = true;
                                    }
                                }
                                Button {
                                    text: "Delete"
                                    onClicked: {
                                        root.dialogTargetName = root.selectedItem.name;
                                        root.showDeleteDialog = true;
                                    }
                                }
                            }

                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                            // Preview Box
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 6
                                color: "#05080E"
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ScrollView {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    clip: true

                                    Text {
                                        width: parent.width
                                        text: root.previewData ? root.previewData.content : ""
                                        color: SRITECTheme.textPrimary
                                        font.pixelSize: 10
                                        font.family: SRITECTheme.fontMono
                                        wrapMode: Text.WrapAnywhere
                                    }
                                }
                            }
                        }

                        // Placeholder when nothing selected
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            visible: root.selectedItem === null
                            Text { Layout.alignment: Qt.AlignHCenter; text: "📁"; font.pixelSize: 32 }
                            Text { Layout.alignment: Qt.AlignHCenter; text: "Select a file or folder"; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 3. Bottom Telemetry & Status Bar
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: Qt.rgba(13/255, 17/255, 26/255, 0.95)
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                Text {
                    text: globalFileManager.totalItemCount + " items in directory"
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 10
                    font.family: SRITECTheme.fontMono
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 14; color: SRITECTheme.borderSubtle }

                Text {
                    text: globalFileManager.currentPath
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 10
                    font.family: SRITECTheme.fontMono
                    Layout.fillWidth: true
                    elide: Text.ElideMiddle
                }

                Text {
                    text: globalFileManager.isReadOnly ? "🔒 Read-Only" : "⚡ Read/Write Active"
                    color: globalFileManager.isReadOnly ? SRITECTheme.accentAmber : SRITECTheme.accentEmerald
                    font.pixelSize: 9
                    font.bold: true
                    font.family: SRITECTheme.fontMono
                }
            }
        }
    }

    // =========================================================================
    // 4. Context Menus
    // =========================================================================
    Menu {
        id: bgContextMenu
        background: Rectangle { implicitWidth: 180; color: "#0D111A"; border.color: SRITECTheme.accentCyan; radius: 6 }

        Action { text: "📁 New Folder"; onTriggered: root.showCreateFolderDialog = true }
        Action { text: "📄 New File"; onTriggered: root.showCreateFileDialog = true }
        Action { text: "↻ Refresh"; onTriggered: globalFileManager.refresh() }
        Action {
            text: "⌨ Open Terminal Here"
            onTriggered: {
                globalTerminalBackend.workingDirectory = globalFileManager.currentPath;
                globalAppLaunchManager.requestAppLaunch("terminal");
            }
        }
    }

    Menu {
        id: fileItemContextMenu
        background: Rectangle { implicitWidth: 190; color: "#0D111A"; border.color: SRITECTheme.accentCyan; radius: 6 }

        Action {
            text: "▶ Open"
            onTriggered: {
                if (root.selectedItem) {
                    if (root.selectedItem.isDir) {
                        globalFileManager.navigateTo(root.selectedItem.path);
                    } else if (root.selectedItem.type === "code") {
                        globalDevWorkspace.openFile(root.selectedItem.path);
                        globalAppLaunchManager.requestAppLaunch("editor");
                    } else {
                        globalFileManager.openItem(root.selectedItem.name);
                    }
                }
            }
        }
        Action {
            text: "💻 Open in Code Studio"
            onTriggered: {
                if (root.selectedItem) {
                    globalDevWorkspace.openFile(root.selectedItem.path);
                    globalAppLaunchManager.requestAppLaunch("editor");
                }
            }
        }
        Action {
            text: "✏ Rename"
            onTriggered: root.showRenameDialog = true
        }
        Action {
            text: "🗑 Delete"
            onTriggered: root.showDeleteDialog = true
        }
    }

    // =========================================================================
    // 5. Modal Dialogs: Create Folder, Create File, Rename, Delete
    // =========================================================================
    // Create Folder Dialog
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        visible: root.showCreateFolderDialog
        z: 100

        Rectangle {
            anchors.centerIn: parent
            width: 380
            height: 180
            radius: 10
            color: SRITECTheme.backgroundElevated
            border.color: SRITECTheme.accentCyan
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Text { text: "CREATE NEW FOLDER"; color: SRITECTheme.accentCyan; font.pixelSize: 12; font.bold: true; font.family: SRITECTheme.fontMono }

                TextField {
                    id: newFolderNameInput
                    Layout.fillWidth: true
                    placeholderText: "Folder name..."
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 12
                    focus: root.showCreateFolderDialog
                    onAccepted: {
                        if (text.trim().length > 0) {
                            globalFileManager.createFolder(text.trim());
                            text = "";
                            root.showCreateFolderDialog = false;
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8
                    Button { text: "Cancel"; onClicked: root.showCreateFolderDialog = false }
                    Button {
                        text: "Create"
                        onClicked: {
                            if (newFolderNameInput.text.trim().length > 0) {
                                globalFileManager.createFolder(newFolderNameInput.text.trim());
                                newFolderNameInput.text = "";
                                root.showCreateFolderDialog = false;
                            }
                        }
                    }
                }
            }
        }
    }

    // Create File Dialog
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        visible: root.showCreateFileDialog
        z: 100

        Rectangle {
            anchors.centerIn: parent
            width: 380
            height: 180
            radius: 10
            color: SRITECTheme.backgroundElevated
            border.color: SRITECTheme.accentEmerald
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Text { text: "CREATE NEW FILE"; color: SRITECTheme.accentEmerald; font.pixelSize: 12; font.bold: true; font.family: SRITECTheme.fontMono }

                TextField {
                    id: newFileNameInput
                    Layout.fillWidth: true
                    placeholderText: "File name (e.g. script.py, notes.txt)..."
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 12
                    focus: root.showCreateFileDialog
                    onAccepted: {
                        if (text.trim().length > 0) {
                            globalFileManager.createFile(text.trim());
                            text = "";
                            root.showCreateFileDialog = false;
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8
                    Button { text: "Cancel"; onClicked: root.showCreateFileDialog = false }
                    Button {
                        text: "Create"
                        onClicked: {
                            if (newFileNameInput.text.trim().length > 0) {
                                globalFileManager.createFile(newFileNameInput.text.trim());
                                newFileNameInput.text = "";
                                root.showCreateFileDialog = false;
                            }
                        }
                    }
                }
            }
        }
    }

    // Rename Dialog
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        visible: root.showRenameDialog
        z: 100

        Rectangle {
            anchors.centerIn: parent
            width: 380
            height: 180
            radius: 10
            color: SRITECTheme.backgroundElevated
            border.color: SRITECTheme.accentCyan
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Text { text: "RENAME ITEM: " + root.dialogTargetName; color: SRITECTheme.accentCyan; font.pixelSize: 11; font.bold: true; font.family: SRITECTheme.fontMono; elide: Text.ElideRight }

                TextField {
                    id: renameInput
                    Layout.fillWidth: true
                    text: root.dialogTargetName
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 12
                    focus: root.showRenameDialog
                    onAccepted: {
                        if (text.trim().length > 0) {
                            globalFileManager.renameItem(root.dialogTargetName, text.trim());
                            root.showRenameDialog = false;
                            root.selectItem(null);
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8
                    Button { text: "Cancel"; onClicked: root.showRenameDialog = false }
                    Button {
                        text: "Rename"
                        onClicked: {
                            if (renameInput.text.trim().length > 0) {
                                globalFileManager.renameItem(root.dialogTargetName, renameInput.text.trim());
                                root.showRenameDialog = false;
                                root.selectItem(null);
                            }
                        }
                    }
                }
            }
        }
    }

    // Delete Confirmation Dialog
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        visible: root.showDeleteDialog
        z: 100

        Rectangle {
            anchors.centerIn: parent
            width: 400
            height: 180
            radius: 10
            color: SRITECTheme.backgroundElevated
            border.color: SRITECTheme.accentCrimson
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Text { text: "CONFIRM DELETION"; color: SRITECTheme.accentCrimson; font.pixelSize: 12; font.bold: true; font.family: SRITECTheme.fontMono }

                Text {
                    Layout.fillWidth: true
                    text: "Are you sure you want to permanently delete '" + root.dialogTargetName + "'?\nThis action cannot be undone."
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8
                    Button { text: "Cancel"; onClicked: root.showDeleteDialog = false }
                    Button {
                        text: "Delete"
                        onClicked: {
                            globalFileManager.deleteItem(root.dialogTargetName);
                            root.showDeleteDialog = false;
                            root.selectItem(null);
                        }
                    }
                }
            }
        }
    }
}
