import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "theme"
import "components"
import "views"

ApplicationWindow {
    id: window
    visible: true
    width: 1920
    height: 1080
    minimumWidth: 1024
    minimumHeight: 640
    title: OS_NAME + " — " + OS_CODENAME + " (" + OS_VERSION + ")"
    color: SRITECTheme.backgroundVoid

    // 1. Fullscreen, Frameless Edge-to-Edge AI OS Presentation
    flags: Qt.FramelessWindowHint | Qt.Window
    visibility: Window.FullScreen

    // 2. Procedural Neural Wave & Particle Background
    NeuralBackground {
        id: neuralBackground
        anchors.fill: parent
        performanceMode: globalDesktopManager.performanceMode
        wallpaperIntensity: globalDesktopManager.wallpaperIntensity
    }

    // 3. Central Spatial Workspace Viewport
    Item {
        anchors.fill: parent

        StackLayout {
            id: workspaceStack
            objectName: "workspaceStack"
            anchors.fill: parent
            anchors.topMargin: 64
            anchors.bottomMargin: dock.height + 24
            currentIndex: 0 // Default: Living Spatial Desktop

            // Workspace 0: Spatial Desktop Space (Living Canvas + AI Focal Nexus)
            DesktopHomeView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onRequestWorkspace: function(idx) {
                    workspaceStack.currentIndex = idx;
                    dock.activeWorkspaceIndex = idx;
                }
            }

            // Workspace 1: Expanded AI Neural Assistant Hub
            AIAssistantView {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Workspace 2: Developer Workspace & Guardrail Studio
            DeveloperWorkspaceView {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Workspace 3: Full System Settings & Personalization
            SettingsView {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Workspace 4: Detailed Hardware Sensor Diagnostics
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    Rectangle {
                        Layout.preferredWidth: 640
                        Layout.preferredHeight: 360
                        radius: SRITECTheme.radiusLarge
                        color: Qt.rgba(13/255, 17/255, 26/255, 0.88)
                        border.color: SRITECTheme.accentCyan
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 26
                            spacing: 14

                            RowLayout {
                                spacing: 8
                                Text {
                                    text: "⚡"
                                    color: SRITECTheme.accentCyan
                                    font.pixelSize: 16
                                }
                                Text {
                                    text: "HARDWARE SENSORS & SYSTEM DIAGNOSTICS"
                                    color: SRITECTheme.accentCyan
                                    font.pixelSize: 13
                                    font.bold: true
                                    font.letterSpacing: 1.5
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: SRITECTheme.borderSubtle
                            }

                            Text {
                                text: "Operating System: " + globalAppLauncher.hostDistro + "\n" +
                                      "Kernel:           " + globalAppLauncher.hostKernel + "\n" +
                                      "Display Session:  Wayland Client Window (wayland-0)\n" +
                                      "CPU Active Load:  " + globalAppLauncher.cpuUsagePercent + "%\n" +
                                      "Memory Allocated: " + globalAppLauncher.ramUsagePercent + "%\n" +
                                      "Disk Capacity:    " + globalAppLauncher.diskUsagePercent + "%\n" +
                                      "AI Subsystem:     " + globalAIBridge.selectedProvider + " • " + globalAIBridge.selectedModel + "\n" +
                                      "Network Security: Strict TLS 1.3 CA Enforcement Active\n" +
                                      "Sandbox Perimeter: Unprivileged Linux User Sandbox\n" +
                                      "Power Telemetry:  " + globalDesktopManager.batteryStatusText + "\n" +
                                      "Display Support:  " + globalDesktopManager.backlightStatusText
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 12
                                font.family: SRITECTheme.fontMono
                                lineHeight: 1.6
                            }
                        }
                    }
                }
            }

            // Workspace 5: Security & Safety Guardrail Policies
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    Rectangle {
                        Layout.preferredWidth: 640
                        Layout.preferredHeight: 360
                        radius: SRITECTheme.radiusLarge
                        color: Qt.rgba(13/255, 17/255, 26/255, 0.88)
                        border.color: SRITECTheme.accentEmerald
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 26
                            spacing: 14

                            RowLayout {
                                spacing: 8
                                Rectangle {
                                    Layout.preferredWidth: 8
                                    Layout.preferredHeight: 8
                                    radius: 4
                                    color: SRITECTheme.accentEmerald
                                }
                                Text {
                                    text: "SECURITY & SAFETY GUARDRAIL POLICIES"
                                    color: SRITECTheme.textPrimary
                                    font.pixelSize: 13
                                    font.bold: true
                                    font.letterSpacing: 1.5
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: SRITECTheme.borderSubtle
                            }

                            Text {
                                text: "• RULE 1: Host OS Integrity Guarantee (No root mutation)\n" +
                                      "• RULE 2: Disk Partitioning & Formatting Strictly Blocked\n" +
                                      "• RULE 3: API Key Isolation (Zero keys exposed to QML/client)\n" +
                                      "• RULE 4: Automated Secret Redaction on Logs and Diagnostics\n" +
                                      "• RULE 5: Strict TLS Certificate Verification (No SSL bypass)\n" +
                                      "• RULE 6: No Unrestricted Terminal Execution (Human in the loop)\n" +
                                      "• RULE 7: Real Host Binary Launching with No Shell Shell-Chaining"
                                color: SRITECTheme.accentEmerald
                                font.pixelSize: 12
                                font.family: SRITECTheme.fontMono
                                lineHeight: 1.6
                            }
                        }
                    }
                }
            }

            // Workspace 6: Robotics Ecosystem & Autonomous Agents Simulation Suite
            RoboticsWorkspaceView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onBackToDesktopRequested: {
                    workspaceStack.currentIndex = 0;
                    dock.activeWorkspaceIndex = 0;
                }
            }
        }

        // 4. Floating Holographic Top HUD Capsule
        FloatingTopHUD {
            id: topHUD
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            activeWorkspaceTitle: workspaceStack.currentIndex === 0 ? "DESKTOP" :
                                  workspaceStack.currentIndex === 1 ? "NEURAL HUB" :
                                  workspaceStack.currentIndex === 2 ? "DEV STUDIO" :
                                  workspaceStack.currentIndex === 3 ? "SETTINGS" :
                                  workspaceStack.currentIndex === 4 ? "TELEMETRY" :
                                  workspaceStack.currentIndex === 5 ? "POLICY" : "ROBOTICS"

            onToggleFullscreen: {
                if (window.visibility === Window.FullScreen) {
                    window.showNormal();
                } else {
                    window.showFullScreen();
                }
            }

            onPerformanceModeSelected: function(mode) {
                globalDesktopManager.performanceMode = mode;
            }

            onCalendarRequested: calendarPopup.openCalendar()
            onQuickSettingsRequested: quickSettingsPanel.openPanel()
            onNotificationCenterRequested: notificationCenter.openCenter()
            onUniversalSearchRequested: searchOverlay.openSearch()
            onOpenAppDrawer: appDrawer.openDrawer()
            onPowerControlRequested: globalPowerManager.requestShutdown()
            onScreenshotRequested: globalScreenCapture.captureScreen(window)
            onScreenRecordRequested: {
                if (globalScreenCapture.isRecording) {
                    globalScreenCapture.stopRecording();
                } else {
                    globalScreenCapture.startRecording(window);
                }
            }
            onJarvisHUDRequested: jarvisHUDModal.visible = !jarvisHUDModal.visible
        }

        // 5. Floating Holographic Application Dock
        AppDock {
            id: dock
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            activeWorkspaceIndex: workspaceStack.currentIndex

            states: [
                State {
                    name: "bottom"
                    when: globalDesktopManager.dockPosition === "bottom"
                    AnchorChanges { target: dock; anchors.horizontalCenter: dock.parent.horizontalCenter; anchors.left: undefined; anchors.right: undefined }
                },
                State {
                    name: "left"
                    when: globalDesktopManager.dockPosition === "left"
                    AnchorChanges { target: dock; anchors.left: dock.parent.left; anchors.horizontalCenter: undefined; anchors.right: undefined }
                },
                State {
                    name: "right"
                    when: globalDesktopManager.dockPosition === "right"
                    AnchorChanges { target: dock; anchors.right: dock.parent.right; anchors.horizontalCenter: undefined; anchors.left: undefined }
                }
            ]

            onWorkspaceSelected: function(index) {
                workspaceStack.currentIndex = index;
            }

            onAppDrawerRequested: appDrawer.openDrawer()
        }
    }

    // 6. Floating Application Window Stack Layer
    Item {
        id: windowLayer
        anchors.fill: parent
        z: 100

        Repeater {
            model: globalAppLaunchManager.openWindows

            delegate: AppWindowFrame {
                required property var modelData
                windowData: modelData
            }
        }
    }

    // 7. Universal Cinematic App Launch Transition
    AppLaunchTransition {
        id: appLaunchTransition
        objectName: "appLaunchTransition"
        anchors.fill: parent
        z: 150
    }

    // 8. Floating Sci-Fi Overlays
    CalendarPopup {
        id: calendarPopup
        anchors.fill: parent
        z: 200
    }

    QuickSettingsPanel {
        id: quickSettingsPanel
        anchors.fill: parent
        z: 201
        onRequestOpenSettings: {
            workspaceStack.currentIndex = 3;
            dock.activeWorkspaceIndex = 3;
        }
    }

    NotificationCenter {
        id: notificationCenter
        anchors.fill: parent
        z: 202
    }

    AppDrawer {
        id: appDrawer
        objectName: "appDrawer"
        anchors.fill: parent
        z: 203
    }

    UniversalSearchOverlay {
        id: searchOverlay
        anchors.fill: parent
        z: 204
    }

    // 9. Floating Screen Recorder Status HUD
    ScreenRecorderHUD {
        anchors.top: parent.top
        anchors.topMargin: 64
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // 10. Floating Screenshot Preview Notification Toast
    ScreenshotPreviewToast {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        anchors.right: parent.right
        anchors.rightMargin: 24
    }

    // 11. Holographic System Power Control Modal
    PowerControlModal {
        id: powerControlModal
        objectName: "powerControlModal"
    }

    // 12. Floating JARVIS Hand Gesture HUD Overlay
    JarvisGestureHUD {
        z: 160
    }

    // 13. JARVIS Multimodal Hub Modal
    Rectangle {
        id: jarvisHUDModal
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.65)
        visible: false
        z: 220

        MouseArea {
            anchors.fill: parent
            onClicked: jarvisHUDModal.visible = false
        }

        JarvisHUD {
            anchors.centerIn: parent
            onCloseRequested: jarvisHUDModal.visible = false
        }
    }

    // 9. Cybernetic Notice Dialog & Runtime Selector for External Applications
    Rectangle {
        id: unsupportedAppModal
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.75)
        visible: globalAppLaunchManager.hasUnsupportedNotice
        z: 210

        Rectangle {
            anchors.centerIn: parent
            width: 520
            height: 250
            radius: SRITECTheme.radiusLarge
            color: Qt.rgba(13/255, 17/255, 26/255, 0.98)
            border.color: SRITECTheme.accentCyan
            border.width: 1.5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                RowLayout {
                    spacing: 8
                    Text { text: "✦"; color: SRITECTheme.accentCyan; font.pixelSize: 16 }
                    Text {
                        text: "APPLICATION LAUNCH & RUNTIME SELECTOR"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 1.2
                        font.family: SRITECTheme.fontMono
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                Text {
                    Layout.fillWidth: true
                    text: (globalAppLaunchManager.unsupportedAppNotice && globalAppLaunchManager.unsupportedAppNotice.name ?
                           "Target Application: " + globalAppLaunchManager.unsupportedAppNotice.name + "\n" : "") +
                          "Select how you would like to run this application:\n• Launch the real application executable on your host system\n• Or open the integrated NEBULA workspace window"
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    lineHeight: 1.4
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8

                    Button {
                        text: "Cancel"
                        onClicked: globalAppLaunchManager.dismissUnsupportedNotice()
                    }

                    Button {
                        text: "🚀 Launch Real Application"
                        onClicked: {
                            var id = globalAppLaunchManager.unsupportedAppNotice ? globalAppLaunchManager.unsupportedAppNotice.appId : "";
                            globalAppLaunchManager.dismissUnsupportedNotice();
                            if (id && id.length > 0) {
                                globalAppLauncher.launch(id);
                            }
                        }
                    }

                    Button {
                        visible: globalAppLaunchManager.unsupportedAppNotice &&
                                 globalAppLaunchManager.unsupportedAppNotice.alternative !== undefined &&
                                 globalAppLaunchManager.unsupportedAppNotice.alternative.length > 0
                        text: "✦ Open in NEBULA"
                        onClicked: {
                            var alt = globalAppLaunchManager.unsupportedAppNotice.alternative;
                            globalAppLaunchManager.dismissUnsupportedNotice();
                            globalAppLaunchManager.requestAppLaunch(alt);
                        }
                    }
                }
            }
        }
    }

    // Keyboard Shortcuts
    Shortcut {
        sequence: "Ctrl+Space"
        onActivated: {
            if (searchOverlay.isOpen) {
                searchOverlay.closeSearch();
            } else {
                searchOverlay.openSearch();
            }
        }
    }

    Shortcut {
        sequence: "F11"
        onActivated: {
            if (window.visibility === Window.FullScreen) {
                window.showNormal();
            } else {
                window.showFullScreen();
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+W"
        onActivated: {
            if (globalAppLaunchManager.focusedWindowId.length > 0) {
                globalAppLaunchManager.closeWindow(globalAppLaunchManager.focusedWindowId);
            }
        }
    }

    Shortcut {
        sequence: "Print"
        onActivated: globalScreenCapture.captureScreen(window)
    }

    Shortcut {
        sequence: "Ctrl+Shift+S"
        onActivated: globalScreenCapture.captureScreen(window)
    }

    Shortcut {
        sequence: "Ctrl+Shift+R"
        onActivated: {
            if (globalScreenCapture.isRecording) {
                globalScreenCapture.stopRecording();
            } else {
                globalScreenCapture.startRecording(window);
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+Alt+Del"
        onActivated: globalPowerManager.requestShutdown()
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (globalPowerManager.isConfirmationActive) {
                globalPowerManager.cancelAction();
            } else if (searchOverlay.isOpen) {
                searchOverlay.closeSearch();
            } else if (appDrawer.isOpen) {
                appDrawer.closeDrawer();
            } else if (notificationCenter.isOpen) {
                notificationCenter.closeCenter();
            } else if (quickSettingsPanel.isOpen) {
                quickSettingsPanel.closePanel();
            } else if (calendarPopup.isOpen) {
                calendarPopup.closeCalendar();
            } else if (globalAppLaunchManager.focusedWindowId.length > 0) {
                globalAppLaunchManager.closeWindow(globalAppLaunchManager.focusedWindowId);
            } else {
                workspaceStack.currentIndex = 0;
                dock.activeWorkspaceIndex = 0;
            }
        }
    }

    Component.onCompleted: {
        globalAudioService.playChime();
    }
}
