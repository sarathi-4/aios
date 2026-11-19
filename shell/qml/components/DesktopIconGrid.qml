import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    signal requestOpenSettings()
    signal requestChangeWallpaper()

    property string editingItemId: ""
    property string selectedItemId: ""

    // Background MouseArea for desktop right-click menu & click-to-deselect
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        z: 0

        onClicked: function(mouse) {
            root.selectedItemId = "";
            root.editingItemId = "";
            desktopContextMenu.close();
            itemContextMenu.close();

            if (mouse.button === Qt.RightButton) {
                desktopContextMenu.popup(mouse.x, mouse.y);
            }
        }
    }

    // Grid of desktop icon items
    Repeater {
        model: globalDesktopManager.desktopItems

        delegate: Item {
            id: iconItem
            required property var modelData
            property string itemId: modelData.id
            property string itemTitle: modelData.name
            property string itemType: modelData.type
            property string itemTarget: modelData.target
            property string itemIcon: modelData.icon
            property int posX: modelData.x
            property int posY: modelData.y

            x: posX
            y: posY
            width: 104
            height: 108
            z: iconMouseArea.drag.active ? 100 : 1

            Rectangle {
                id: iconCard
                anchors.fill: parent
                radius: SRITECTheme.radiusMedium
                color: root.selectedItemId === iconItem.itemId ?
                       Qt.rgba(0/255, 229/255, 255/255, 0.16) :
                       (iconMouseArea.containsMouse ? Qt.rgba(255/255, 255/255, 255/255, 0.06) : "transparent")
                border.color: root.selectedItemId === iconItem.itemId ?
                              SRITECTheme.accentCyan :
                              (iconMouseArea.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.3) : "transparent")
                border.width: 1

                Behavior on color { ColorAnimation { duration: SRITECTheme.animFast } }
                Behavior on border.color { ColorAnimation { duration: SRITECTheme.animFast } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4

                    // AI Holographic Icon Tile
                    AIIcon {
                        Layout.alignment: Qt.AlignHCenter
                        size: 52
                        iconId: resolveIconId(iconItem.itemTarget, iconItem.itemType, iconItem.itemTitle)
                        isHovered: iconMouseArea.containsMouse || root.selectedItemId === iconItem.itemId
                    }

                    // Label or Inline Edit Box
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30

                        Text {
                            visible: root.editingItemId !== iconItem.itemId
                            anchors.fill: parent
                            text: iconItem.itemTitle
                            color: (iconMouseArea.containsMouse || root.selectedItemId === iconItem.itemId) ?
                                   SRITECTheme.accentCyan : SRITECTheme.textPrimary
                            font.pixelSize: 11
                            font.family: SRITECTheme.fontUI
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            style: Text.Outline
                            styleColor: Qt.rgba(0, 0, 0, 0.95)
                        }

                        TextField {
                            id: inlineRenameField
                            visible: root.editingItemId === iconItem.itemId
                            anchors.fill: parent
                            text: iconItem.itemTitle
                            font.pixelSize: 11
                            color: SRITECTheme.textPrimary
                            background: Rectangle {
                                color: SRITECTheme.backgroundElevated
                                radius: 4
                                border.color: SRITECTheme.accentCyan
                                border.width: 1
                            }
                            onAccepted: {
                                if (text.trim().length > 0) {
                                    globalDesktopManager.renameItem(iconItem.itemId, text.trim());
                                }
                                root.editingItemId = "";
                            }
                            Component.onCompleted: {
                                if (visible) {
                                    forceActiveFocus();
                                    selectAll();
                                }
                            }
                        }
                    }
                }
            }

            // Drag and interaction MouseArea
            MouseArea {
                id: iconMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                drag.target: iconItem
                drag.axis: Drag.XAndYAxis
                drag.minimumX: 10
                drag.maximumX: root.width - iconItem.width - 10
                drag.minimumY: 10
                drag.maximumY: root.height - iconItem.height - 10

                onClicked: function(mouse) {
                    globalAudioService.playClick();
                    root.selectedItemId = iconItem.itemId;
                    if (mouse.button === Qt.RightButton) {
                        itemContextMenu.targetItemId = iconItem.itemId;
                        itemContextMenu.targetItemTitle = iconItem.itemTitle;
                        itemContextMenu.targetItemType = iconItem.itemType;
                        itemContextMenu.targetItemTarget = iconItem.itemTarget;
                        itemContextMenu.popup(iconItem.x + mouse.x, iconItem.y + mouse.y);
                    }
                }

                onDoubleClicked: function(mouse) {
                    globalAudioService.playClick();
                    if (mouse.button === Qt.LeftButton) {
                        var pt = iconItem.mapToItem(null, 0, 0);
                        if (iconItem.itemType === "folder" || iconItem.itemTarget.startsWith("/")) {
                            globalFileManager.navigateTo(iconItem.itemTarget);
                            globalAppLaunchManager.requestAppLaunch("files", pt.x, pt.y, iconItem.width, iconItem.height);
                        } else {
                            globalAppLaunchManager.requestAppLaunch(iconItem.itemTarget, pt.x, pt.y, iconItem.width, iconItem.height);
                        }
                    }
                }

                onReleased: function(mouse) {
                    if (drag.active) {
                        // Snap to nearest 20px grid
                        var snappedX = Math.round(iconItem.x / 20) * 20;
                        var snappedY = Math.round(iconItem.y / 20) * 20;
                        iconItem.x = snappedX;
                        iconItem.y = snappedY;
                        globalDesktopManager.updateItemPosition(iconItem.itemId, snappedX, snappedY);
                    }
                }
            }
        }
    }

    // Context Menu for an Individual Item
    Menu {
        id: itemContextMenu
        property string targetItemId: ""
        property string targetItemTitle: ""
        property string targetItemType: ""
        property string targetItemTarget: ""

        background: Rectangle {
            implicitWidth: 190
            color: SRITECTheme.backgroundGlassElevated
            radius: SRITECTheme.radiusMedium
            border.color: SRITECTheme.borderSubtle
            border.width: 1
        }

        Action {
            text: "▶  Open"
            onTriggered: {
                if (itemContextMenu.targetItemType === "folder" || itemContextMenu.targetItemTarget.startsWith("/")) {
                    globalFileManager.navigateTo(itemContextMenu.targetItemTarget);
                    globalAppLaunchManager.requestAppLaunch("files");
                } else {
                    globalAppLaunchManager.requestAppLaunch(itemContextMenu.targetItemTarget);
                }
            }
        }

        Action {
            text: "✎  Rename"
            onTriggered: {
                root.editingItemId = itemContextMenu.targetItemId;
            }
        }

        Action {
            text: "📌  Pin to Dock"
            enabled: itemContextMenu.targetItemType === "app"
            onTriggered: {
                globalDesktopManager.pinApp(itemContextMenu.targetItemTarget);
            }
        }

        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: SRITECTheme.borderSubtle
            }
        }

        Action {
            text: "🗑  Delete"
            onTriggered: {
                globalDesktopManager.removeItem(itemContextMenu.targetItemId);
            }
        }
    }

    // Context Menu for Empty Desktop Space
    Menu {
        id: desktopContextMenu

        background: Rectangle {
            implicitWidth: 210
            color: SRITECTheme.backgroundGlassElevated
            radius: SRITECTheme.radiusMedium
            border.color: SRITECTheme.borderSubtle
            border.width: 1
        }

        Action {
            text: "📁  New Folder"
            onTriggered: {
                newFolderDialog.open();
            }
        }

        Action {
            text: "🔗  New App Shortcut"
            onTriggered: {
                newShortcutDialog.open();
            }
        }

        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: SRITECTheme.borderSubtle
            }
        }

        Action {
            text: "🎨  Change Wallpaper"
            onTriggered: root.requestChangeWallpaper()
        }

        Action {
            text: "⚙  Desktop Settings"
            onTriggered: root.requestOpenSettings()
        }

        MenuSeparator {
            contentItem: Rectangle {
                implicitHeight: 1
                color: SRITECTheme.borderSubtle
            }
        }

        Action {
            text: "↺  Reset Default Icons"
            onTriggered: {
                globalDesktopManager.resetToDefaults();
            }
        }
    }

    // Modal: New Folder Dialog
    Dialog {
        id: newFolderDialog
        anchors.centerIn: parent
        modal: true
        title: "Create Desktop Folder"
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: SRITECTheme.backgroundGlassElevated
            radius: SRITECTheme.radiusLarge
            border.color: SRITECTheme.borderSubtle
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 12
            Text {
                text: "Folder Name:"
                color: SRITECTheme.textSecondary
                font.pixelSize: 12
            }
            TextField {
                id: folderNameInput
                Layout.preferredWidth: 260
                text: "New Project"
                color: SRITECTheme.textPrimary
                background: Rectangle {
                    color: SRITECTheme.backgroundInput
                    radius: SRITECTheme.radiusSmall
                    border.color: SRITECTheme.borderSubtle
                }
            }
        }

        onAccepted: {
            var name = folderNameInput.text.trim();
            if (name.length > 0) {
                globalDesktopManager.createFolder(name, 160, 160);
            }
            folderNameInput.text = "New Project";
        }
    }

    // Modal: New Shortcut Dialog
    Dialog {
        id: newShortcutDialog
        anchors.centerIn: parent
        modal: true
        title: "Create Application Shortcut"
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: SRITECTheme.backgroundGlassElevated
            radius: SRITECTheme.radiusLarge
            border.color: SRITECTheme.borderSubtle
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 12
            Text {
                text: "Select Installed Application:"
                color: SRITECTheme.textSecondary
                font.pixelSize: 12
            }
            ComboBox {
                id: appSelectCombo
                Layout.preferredWidth: 260
                model: [
                    { name: "Web Browser (Firefox)", id: "browser", icon: "🌐" },
                    { name: "Terminal (Ptyxis)", id: "terminal", icon: "⌨" },
                    { name: "File Manager (Nautilus)", id: "files", icon: "📁" },
                    { name: "Code Editor", id: "editor", icon: "📝" },
                    { name: "Calculator", id: "calculator", icon: "🖩" },
                    { name: "Settings", id: "settings", icon: "⚙" }
                ]
                textRole: "name"
            }
        }

        onAccepted: {
            var selected = appSelectCombo.model[appSelectCombo.currentIndex];
            globalDesktopManager.createShortcut(selected.name, selected.id, selected.icon, 240, 160);
        }
    }

    function resolveIconId(target, type, name) {
        if (!target) target = "";
        if (!name) name = "";
        var t = target.toLowerCase();
        var n = name.toLowerCase();

        if (t === "computer" || n.indexOf("computer") !== -1 || t === "/" || n.indexOf("this pc") !== -1) return "computer";
        if (t === "home" || n.indexOf("home") !== -1) return "home";
        if (t === "trash" || n.indexOf("trash") !== -1) return "trash";
        if (t === "drive" || t === "ssd" || n.indexOf("ssd") !== -1 || n.indexOf("drive") !== -1 || n.indexOf("250") !== -1 || n.indexOf("1tb") !== -1) return "drive";
        if (t === "downloads" || n.indexOf("download") !== -1) return "downloads";
        if (t === "terminal" || n.indexOf("terminal") !== -1) return "terminal";
        if (t === "browser" || t === "firefox" || n.indexOf("browser") !== -1 || n.indexOf("firefox") !== -1) return "browser";
        if (t === "chrome" || n.indexOf("chrome") !== -1) return "chrome";
        if (t === "edge" || n.indexOf("edge") !== -1) return "edge";
        if (t === "opera" || n.indexOf("opera") !== -1) return "opera";
        if (t === "files" || n.indexOf("file") !== -1) return "files";
        if (t === "editor" || t === "vscode" || n.indexOf("editor") !== -1 || n.indexOf("code") !== -1) return "code";
        if (t === "calculator" || n.indexOf("calc") !== -1) return "calculator";
        if (t === "settings" || n.indexOf("setting") !== -1) return "settings";
        if (n.indexOf("aios") !== -1 || n.indexOf("workspace") !== -1 || n.indexOf("project") !== -1) return "projects";
        if (n.indexOf("document") !== -1) return "documents";
        if (type === "folder") return "files";

        return t.length > 0 ? t : "files";
    }
}
