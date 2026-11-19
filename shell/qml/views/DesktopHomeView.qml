import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"
import "../components"

Item {
    id: root

    signal requestWorkspace(int index)
    signal appLaunched(string appId)

    // 1. Spatial Desktop Icon Layer (Draggable items, folders, shortcuts, right-click context menu)
    DesktopIconGrid {
        id: desktopIconGrid
        anchors.fill: parent
        onRequestOpenSettings: root.requestWorkspace(3)
        onRequestChangeWallpaper: root.requestWorkspace(3)
    }

    // 2. Central Spatial AI Nexus (Holographic Avatar Core)
    Item {
        id: aiNexus
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 480)
        height: 380

        // The Holographic AI Avatar Core (Focal Point)
        HolographicAvatar {
            id: aiAvatar
            anchors.centerIn: parent
        }
    }

    function processCommand(rawInput) {
        if (!rawInput || rawInput.length === 0) return;

        var cmd = rawInput.toLowerCase();

        // Direct command evaluation
        if (cmd.indexOf("open terminal") !== -1 || cmd === "terminal") {
            globalAppLaunchManager.requestAppLaunch("terminal");
            return;
        } else if (cmd.indexOf("open browser") !== -1 || cmd.indexOf("launch browser") !== -1 || cmd.indexOf("firefox") !== -1) {
            globalAppLaunchManager.requestAppLaunch("firefox");
            return;
        } else if (cmd.indexOf("open files") !== -1 || cmd.indexOf("file manager") !== -1) {
            globalAppLaunchManager.requestAppLaunch("files");
            return;
        } else if (cmd.indexOf("open settings") !== -1 || cmd === "settings") {
            globalAppLaunchManager.requestAppLaunch("settings");
            return;
        } else if (cmd.indexOf("calculator") !== -1 || cmd === "calc") {
            globalAppLaunchManager.requestAppLaunch("calculator");
            return;
        } else if (cmd.indexOf("system status") !== -1 || cmd === "telemetry" || cmd === "monitor") {
            globalAppLaunchManager.requestAppLaunch("monitor");
            return;
        } else if (cmd.indexOf("code") !== -1 || cmd === "editor") {
            globalAppLaunchManager.requestAppLaunch("editor");
            return;
        } else if (cmd.indexOf("robot") !== -1 || cmd.indexOf("robotics") !== -1) {
            globalAppLaunchManager.requestAppLaunch("robotics");
            return;
        }

        // Dispatch natural language query to the AI Gateway
        globalAIBridge.generateStream(rawInput);
    }
}
