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

    property bool showProjectExplorer: true
    property bool showSearchBar: false
    property bool showTerminalDrawer: false
    property string statusMessage: "Ready"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // =====================================================================
        // 1. Top Editor Toolbar & Tabs
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            color: SRITECTheme.backgroundElevated
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                // Toggle Explorer Button
                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 4
                    color: root.showProjectExplorer ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : "transparent"
                    border.color: root.showProjectExplorer ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    Text { anchors.centerIn: parent; text: "📁"; font.pixelSize: 11 }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showProjectExplorer = !root.showProjectExplorer
                    }
                }

                // File Tabs Scroll Area
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                    RowLayout {
                        spacing: 4

                        Repeater {
                            model: globalDevWorkspace.openTabs

                            delegate: Rectangle {
                                required property var modelData
                                Layout.preferredHeight: 28
                                Layout.preferredWidth: Math.min(180, Math.max(90, editorTabText.implicitWidth + 38))
                                radius: 4
                                color: modelData.isActive ? Qt.rgba(0/255, 229/255, 255/255, 0.18) : Qt.rgba(19/255, 26/255, 40/255, 0.5)
                                border.color: modelData.isActive ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 6
                                    spacing: 4

                                    Text {
                                        text: modelData.isModified ? "●" : "◈"
                                        color: modelData.isModified ? SRITECTheme.accentAmber : SRITECTheme.accentCyan
                                        font.pixelSize: 8
                                    }

                                    Text {
                                        id: editorTabText
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        color: modelData.isActive ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                        font.pixelSize: 11
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
                                            onClicked: globalDevWorkspace.closeTab(modelData.id)
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    z: -1
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: globalDevWorkspace.activeTabId = modelData.id
                                }
                            }
                        }
                    }
                }

                // Search & Replace Toggle
                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 4
                    color: root.showSearchBar ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : "transparent"
                    border.color: root.showSearchBar ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    Text { anchors.centerIn: parent; text: "🔍"; font.pixelSize: 11 }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showSearchBar = !root.showSearchBar
                    }
                }

                // Save Active File Button
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: 60
                    radius: 4
                    color: Qt.rgba(0/255, 245/255, 160/255, 0.15)
                    border.color: SRITECTheme.accentEmerald
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "💾"; font.pixelSize: 9 }
                        Text { text: "Save"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.bold: true }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalDevWorkspace.saveActiveFile();
                            root.statusMessage = "Saved: " + globalDevWorkspace.activeFilePath;
                        }
                    }
                }

                // Build Target Button
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: 64
                    radius: 4
                    color: SRITECTheme.accentCyan

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "▶"; color: SRITECTheme.backgroundVoid; font.pixelSize: 9 }
                        Text { text: "Build"; color: SRITECTheme.backgroundVoid; font.pixelSize: 10; font.bold: true }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.showTerminalDrawer = true;
                            globalTerminalBackend.executeCommand("ninja -C build");
                        }
                    }
                }

                // VS Code Launcher Button
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: vscRow.implicitWidth + 14
                    radius: 4
                    color: vscMouse.containsMouse ? Qt.rgba(59/255, 130/255, 246/255, 0.25) : "transparent"
                    border.color: "#3B82F6"
                    border.width: 1

                    RowLayout {
                        id: vscRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "🚀"; font.pixelSize: 9 }
                        Text { text: "VS Code"; color: "#3B82F6"; font.pixelSize: 10; font.bold: true }
                    }

                    MouseArea {
                        id: vscMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalAppLauncher.launch("vscode");
                        }
                    }
                }

                // Antigravity Launcher Button
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: agyRow.implicitWidth + 14
                    radius: 4
                    color: agyMouse.containsMouse ? Qt.rgba(139/255, 92/255, 246/255, 0.25) : "transparent"
                    border.color: "#8B5CF6"
                    border.width: 1

                    RowLayout {
                        id: agyRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "🌌"; font.pixelSize: 9 }
                        Text { text: "Antigravity"; color: "#8B5CF6"; font.pixelSize: 10; font.bold: true }
                    }

                    MouseArea {
                        id: agyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalAppLauncher.launch("antigravity");
                        }
                    }
                }

                // Host Text Editor Launcher Button
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: hstRow.implicitWidth + 14
                    radius: 4
                    color: hstMouse.containsMouse ? Qt.rgba(0/255, 245/255, 160/255, 0.25) : "transparent"
                    border.color: SRITECTheme.accentEmerald
                    border.width: 1

                    RowLayout {
                        id: hstRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "📝"; font.pixelSize: 9 }
                        Text { text: "Host Editor"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.bold: true }
                    }

                    MouseArea {
                        id: hstMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalAppLauncher.launch("editor");
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 2. Search & Replace Toolbar
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            visible: root.showSearchBar
            color: Qt.rgba(19/255, 26/255, 40/255, 0.95)
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text { text: "Find:"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true }

                TextField {
                    id: findInput
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 24
                    placeholderText: "Search term..."
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 11
                    background: Rectangle { color: Qt.rgba(7/255, 10/255, 15/255, 0.8); border.color: SRITECTheme.borderSubtle; radius: 4 }
                }

                Text { text: "Replace:"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.bold: true }

                TextField {
                    id: replaceInput
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 24
                    placeholderText: "Replacement..."
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 11
                    background: Rectangle { color: Qt.rgba(7/255, 10/255, 15/255, 0.8); border.color: SRITECTheme.borderSubtle; radius: 4 }
                }

                Button {
                    text: "Replace All"
                    onClicked: {
                        if (findInput.text.length > 0) {
                            globalDevWorkspace.replaceInActiveFile(findInput.text, replaceInput.text, true);
                            root.statusMessage = "Replaced occurrences of '" + findInput.text + "'";
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        // =====================================================================
        // 3. Main Workspace: Project Tree + Editor
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Project Explorer Sidebar
            Rectangle {
                Layout.preferredWidth: root.showProjectExplorer ? 240 : 0
                Layout.fillHeight: true
                visible: root.showProjectExplorer
                color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    RowLayout {
                        Text { text: "PROJECT EXPLORER"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            radius: 3
                            color: "transparent"
                            Text { anchors.centerIn: parent; text: "↻"; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: globalDevWorkspace.refreshProjectTree()
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ListView {
                            width: parent.width
                            model: globalDevWorkspace.projectTree
                            spacing: 2

                            delegate: ColumnLayout {
                                required property var modelData
                                width: parent.width
                                spacing: 2

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 24
                                    radius: 4
                                    color: nodeMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 6
                                        spacing: 6
                                        Text { text: modelData.isDir ? "📁" : "📄"; font.pixelSize: 10 }
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: modelData.isDir ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: nodeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (!modelData.isDir) {
                                                globalDevWorkspace.openFile(modelData.path);
                                            }
                                        }
                                    }
                                }

                                // Children repeater if dir
                                Repeater {
                                    model: modelData.children !== undefined ? modelData.children : []
                                    delegate: Rectangle {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 22
                                        radius: 4
                                        color: childMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 18
                                            spacing: 6
                                            Text { text: modelData.isDir ? "📁" : "◈"; font.pixelSize: 9 }
                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.name
                                                color: SRITECTheme.textSecondary
                                                font.pixelSize: 10
                                                elide: Text.ElideRight
                                            }
                                        }

                                        MouseArea {
                                            id: childMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (!modelData.isDir) {
                                                    globalDevWorkspace.openFile(modelData.path);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Editor Text Area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#05080E"

                ScrollView {
                    id: codeScroll
                    anchors.fill: parent
                    clip: true

                    TextArea {
                        id: codeEditor
                        text: globalDevWorkspace.activeContent
                        color: "#E2E8F0"
                        font.pixelSize: 12
                        font.family: SRITECTheme.fontMono
                        wrapMode: TextEdit.NoWrap
                        selectByMouse: true
                        background: null

                        onTextChanged: {
                            if (text !== globalDevWorkspace.activeContent) {
                                globalDevWorkspace.activeContent = text;
                            }
                        }

                        Keys.onPressed: function(event) {
                            if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_S) {
                                globalDevWorkspace.saveActiveFile();
                                root.statusMessage = "Saved: " + globalDevWorkspace.activeFilePath;
                                event.accepted = true;
                            }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 4. Integrated Terminal Drawer
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.showTerminalDrawer ? 200 : 0
            visible: root.showTerminalDrawer
            color: "#030508"
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    color: Qt.rgba(13/255, 17/255, 26/255, 0.95)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8
                        Text { text: "TERMINAL CONSOLE"; color: SRITECTheme.accentCyan; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            radius: 3
                            color: "transparent"
                            Text { anchors.centerIn: parent; text: "✕"; color: SRITECTheme.textSecondary; font.pixelSize: 10 }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.showTerminalDrawer = false
                            }
                        }
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListView {
                        id: termDrawerList
                        width: parent.width - 20
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        model: globalTerminalBackend.activeOutput
                        spacing: 2

                        delegate: Text {
                            required property var modelData
                            width: termDrawerList.width
                            text: modelData.text
                            color: modelData.color
                            font.pixelSize: 10
                            font.family: SRITECTheme.fontMono
                            wrapMode: Text.WrapAnywhere
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 5. Bottom Status & Git Bar
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            color: Qt.rgba(13/255, 17/255, 26/255, 0.95)
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 12

                // Git Branch
                RowLayout {
                    spacing: 4
                    Text { text: "⎇"; color: SRITECTheme.accentCyan; font.pixelSize: 11 }
                    Text { text: globalDevWorkspace.gitBranch; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true; font.family: SRITECTheme.fontMono }
                }

                // Git Modified files count
                Text {
                    text: globalDevWorkspace.gitStatusFiles.length > 0 ?
                          "● " + globalDevWorkspace.gitStatusFiles.length + " modified" :
                          "✓ working tree clean"
                    color: globalDevWorkspace.gitStatusFiles.length > 0 ? SRITECTheme.accentAmber : SRITECTheme.accentEmerald
                    font.pixelSize: 10
                    font.family: SRITECTheme.fontMono
                }

                // Terminal Drawer Toggle
                Rectangle {
                    Layout.preferredHeight: 18
                    Layout.preferredWidth: termToggleRow.implicitWidth + 10
                    radius: 3
                    color: root.showTerminalDrawer ? Qt.rgba(0/255, 229/255, 255/255, 0.2) : "transparent"
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    RowLayout {
                        id: termToggleRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "⌨"; font.pixelSize: 9 }
                        Text { text: "Terminal"; color: SRITECTheme.textSecondary; font.pixelSize: 9 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showTerminalDrawer = !root.showTerminalDrawer
                    }
                }

                Item { Layout.fillWidth: true }

                Text { text: root.statusMessage; color: SRITECTheme.textTertiary; font.pixelSize: 10; font.family: SRITECTheme.fontMono }

                Text {
                    text: globalDevWorkspace.activeLanguage + " • UTF-8"
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 10
                    font.family: SRITECTheme.fontMono
                }
            }
        }
    }
}
