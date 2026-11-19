import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    property int activeSettingsTab: 0

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Settings Category Navigation List
        Rectangle {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            radius: SRITECTheme.radiusLarge
            color: SRITECTheme.backgroundGlassElevated
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 6

                // Section header
                Text {
                    text: "SYSTEM SETTINGS"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.5
                    Layout.bottomMargin: 10
                }

                Repeater {
                    model: [
                        { name: "Appearance", icon: "🎨", index: 0 },
                        { name: "Wallpaper Engine", icon: "🌌", index: 1 },
                        { name: "Application Dock", icon: "⚓", index: 2 },
                        { name: "Desktop & Icons", icon: "🖵", index: 3 },
                        { name: "Hardware & Telemetry", icon: "⚡", index: 4 },
                        { name: "AI Gateway Engine", icon: "🧠", index: 5 }
                    ]

                    delegate: Rectangle {
                        id: navItem
                        required property var modelData
                        property bool isSelected: root.activeSettingsTab === navItem.modelData.index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: SRITECTheme.radiusMedium
                        color: isSelected ? Qt.rgba(0/255, 229/255, 255/255, 0.15) :
                               (navMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent")
                        border.color: isSelected ? SRITECTheme.accentCyan : "transparent"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            Text {
                                text: navItem.modelData.icon
                                font.pixelSize: 14
                            }

                            Text {
                                text: navItem.modelData.name
                                color: navItem.isSelected ? SRITECTheme.accentCyan : SRITECTheme.textSecondary
                                font.pixelSize: 12
                                font.bold: navItem.isSelected
                            }
                        }

                        MouseArea {
                            id: navMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeSettingsTab = navItem.modelData.index
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Reset to Defaults Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: SRITECTheme.radiusSmall
                    color: rstMouse.containsMouse ? Qt.rgba(255/255, 59/255, 92/255, 0.2) : SRITECTheme.backgroundElevated
                    border.color: rstMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "↺"
                            color: SRITECTheme.accentCrimson
                            font.pixelSize: 12
                        }
                        Text {
                            text: "Reset Defaults"
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: rstMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: globalDesktopManager.resetToDefaults()
                    }
                }
            }
        }

        // Settings Content Panel
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: SRITECTheme.radiusLarge
            color: SRITECTheme.backgroundGlassElevated
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            ScrollView {
                anchors.fill: parent
                anchors.margins: 28
                clip: true

                // TAB 0: Appearance
                ColumnLayout {
                    visible: root.activeSettingsTab === 0
                    width: parent.width
                    spacing: 24

                    Text {
                        text: "APPEARANCE & PERSONALIZATION"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 16
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    // Accent Color Presets
                    ColumnLayout {
                        spacing: 8
                        Text {
                            text: "System Accent Color"
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 12
                            font.bold: true
                        }

                        RowLayout {
                            spacing: 12
                            Repeater {
                                model: [
                                    { name: "Cyan Hologram", hex: "#00E5FF" },
                                    { name: "Quantum Violet", hex: "#8B5CF6" },
                                    { name: "Emerald Matrix", hex: "#00F5A0" },
                                    { name: "Solar Amber", hex: "#FFB800" },
                                    { name: "Neon Pink", hex: "#EC4899" }
                                ]
                                delegate: Rectangle {
                                    id: colorBtn
                                    required property var modelData
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: colorBtn.modelData.hex
                                    border.color: globalDesktopManager.accentColor === colorBtn.modelData.hex ? "#FFFFFF" : "transparent"
                                    border.width: 2

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: globalDesktopManager.accentColor = colorBtn.modelData.hex
                                    }
                                }
                            }
                        }
                    }

                    // Glass Opacity Slider
                    ColumnLayout {
                        spacing: 8
                        RowLayout {
                            Text {
                                text: "Spatial Glass Window Opacity"
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: Math.round(globalDesktopManager.glassOpacity * 100) + "%"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Slider {
                            Layout.fillWidth: true
                            from: 0.4
                            to: 1.0
                            value: globalDesktopManager.glassOpacity
                            onMoved: globalDesktopManager.glassOpacity = value
                        }
                    }

                    // Font Scaling
                    ColumnLayout {
                        spacing: 8
                        RowLayout {
                            Text {
                                text: "Desktop UI Scale Factor"
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: (globalDesktopManager.fontScale * 100).toFixed(0) + "%"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Slider {
                            Layout.fillWidth: true
                            from: 0.8
                            to: 1.5
                            value: globalDesktopManager.fontScale
                            onMoved: globalDesktopManager.fontScale = value
                        }
                    }
                }

                // TAB 1: Wallpaper Engine
                ColumnLayout {
                    visible: root.activeSettingsTab === 1
                    width: parent.width
                    spacing: 24

                    Text {
                        text: "WALLPAPER & NEURAL ENGINE"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 16
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    // Mode Selection
                    RowLayout {
                        spacing: 12
                        Rectangle {
                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 38
                            radius: SRITECTheme.radiusMedium
                            color: globalDesktopManager.wallpaperType === "procedural" ? SRITECTheme.accentCyan : SRITECTheme.backgroundElevated
                            border.color: SRITECTheme.borderSubtle
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "Procedural Canvas"
                                color: globalDesktopManager.wallpaperType === "procedural" ? SRITECTheme.backgroundVoid : SRITECTheme.textSecondary
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: globalDesktopManager.wallpaperType = "procedural"
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 38
                            radius: SRITECTheme.radiusMedium
                            color: globalDesktopManager.wallpaperType === "image" ? SRITECTheme.accentCyan : SRITECTheme.backgroundElevated
                            border.color: SRITECTheme.borderSubtle
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "Static Image File"
                                color: globalDesktopManager.wallpaperType === "image" ? SRITECTheme.backgroundVoid : SRITECTheme.textSecondary
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: globalDesktopManager.wallpaperType = "image"
                            }
                        }
                    }

                    // Procedural Wave Intensity
                    ColumnLayout {
                        spacing: 8
                        RowLayout {
                            Text {
                                text: "Neural Wave Particle Animation Intensity"
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: (globalDesktopManager.wallpaperIntensity * 100).toFixed(0) + "%"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Slider {
                            Layout.fillWidth: true
                            from: 0.1
                            to: 1.5
                            value: globalDesktopManager.wallpaperIntensity
                            onMoved: globalDesktopManager.wallpaperIntensity = value
                        }
                    }

                    // Image File Path input
                    ColumnLayout {
                        visible: globalDesktopManager.wallpaperType === "image"
                        spacing: 8

                        Text {
                            text: "Local Image Path:"
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 12
                        }

                        TextField {
                            Layout.fillWidth: true
                            text: globalDesktopManager.wallpaperPath
                            placeholderText: "/home/user/Pictures/wallpaper.jpg"
                            color: SRITECTheme.textPrimary
                            background: Rectangle {
                                color: SRITECTheme.backgroundInput
                                radius: SRITECTheme.radiusSmall
                                border.color: SRITECTheme.borderSubtle
                            }
                            onAccepted: globalDesktopManager.wallpaperPath = text.trim()
                        }

                        // Aspect Ratio Mode
                        RowLayout {
                            spacing: 10
                            Text {
                                text: "Scaling Mode:"
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 11
                            }
                            Repeater {
                                model: ["fill", "fit", "stretch", "tile"]
                                delegate: Rectangle {
                                    id: modeBtn
                                    required property string modelData
                                    property bool isSel: globalDesktopManager.wallpaperMode === modeBtn.modelData
                                    Layout.preferredWidth: 68
                                    Layout.preferredHeight: 26
                                    radius: 4
                                    color: isSel ? SRITECTheme.accentCyan : SRITECTheme.backgroundElevated
                                    Text {
                                        anchors.centerIn: parent
                                        text: modeBtn.modelData.toUpperCase()
                                        color: modeBtn.isSel ? SRITECTheme.backgroundVoid : SRITECTheme.textSecondary
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            globalAudioService.playClick();
                                            globalDesktopManager.wallpaperMode = modeBtn.modelData;
                                        }
                                    }
                                }
                            }
                        }

                        // Curated AI Robotics Wallpaper Gallery
                        Text {
                            text: "Curated AI & Robotics Wallpapers:"
                            color: SRITECTheme.accentCyan
                            font.pixelSize: 11
                            font.bold: true
                            Layout.topMargin: 8
                        }

                        RowLayout {
                            spacing: 12
                            Repeater {
                                model: [
                                    { name: "AI Robotics Workspace", path: "qrc:/resources/images/wallpapers/ai_robotics_wallpaper.jpg" },
                                    { name: "Cyber Robot Core", path: "qrc:/resources/images/wallpapers/ai_robotics_cyber_robot.jpg" },
                                    { name: "Fleet Simulation", path: "qrc:/resources/images/robotics/robotics_lab_fleet.jpg" },
                                    { name: "LISA Hologram", path: "qrc:/resources/images/robotics/lisa_hologram.jpg" }
                                ]

                                delegate: Rectangle {
                                    id: wpPreset
                                    required property var modelData
                                    property bool isCurrent: globalDesktopManager.wallpaperPath === wpPreset.modelData.path

                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 75
                                    radius: 6
                                    color: SRITECTheme.backgroundElevated
                                    border.color: isCurrent ? SRITECTheme.accentCyan : (presetMouse.containsMouse ? SRITECTheme.accentViolet : SRITECTheme.borderSubtle)
                                    border.width: isCurrent ? 2 : 1
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: wpPreset.modelData.path
                                        fillMode: Image.PreserveAspectCrop
                                        opacity: isCurrent ? 1.0 : (presetMouse.containsMouse ? 0.9 : 0.65)
                                    }

                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 20
                                        color: Qt.rgba(7/255, 10/255, 15/255, 0.85)

                                        Text {
                                            anchors.centerIn: parent
                                            text: wpPreset.modelData.name
                                            color: wpPreset.isCurrent ? SRITECTheme.accentCyan : SRITECTheme.textSecondary
                                            font.pixelSize: 8
                                            font.bold: wpPreset.isCurrent
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: presetMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            globalAudioService.playClick();
                                            globalDesktopManager.wallpaperType = "image";
                                            globalDesktopManager.wallpaperMode = "fill";
                                            globalDesktopManager.wallpaperPath = wpPreset.modelData.path;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // TAB 2: Dock Settings
                ColumnLayout {
                    visible: root.activeSettingsTab === 2
                    width: parent.width
                    spacing: 24

                    Text {
                        text: "APPLICATION DOCK CUSTOMIZATION"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 16
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    // Dock Position
                    ColumnLayout {
                        spacing: 8
                        Text {
                            text: "Screen Position"
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 12
                            font.bold: true
                        }
                        RowLayout {
                            spacing: 12
                            Repeater {
                                model: ["bottom", "left", "right"]
                                delegate: Rectangle {
                                    id: posBtn
                                    required property string modelData
                                    property bool isSel: globalDesktopManager.dockPosition === posBtn.modelData
                                    Layout.preferredWidth: 90
                                    Layout.preferredHeight: 32
                                    radius: 6
                                    color: isSel ? SRITECTheme.accentCyan : SRITECTheme.backgroundElevated
                                    Text {
                                        anchors.centerIn: parent
                                        text: posBtn.modelData.toUpperCase()
                                        color: posBtn.isSel ? SRITECTheme.backgroundVoid : SRITECTheme.textSecondary
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: globalDesktopManager.dockPosition = posBtn.modelData
                                    }
                                }
                            }
                        }
                    }

                    // Dock Icon Size
                    ColumnLayout {
                        spacing: 8
                        Text {
                            text: "Dock Icon Size"
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 12
                            font.bold: true
                        }
                        RowLayout {
                            spacing: 12
                            Repeater {
                                model: ["small", "medium", "large"]
                                delegate: Rectangle {
                                    id: szBtn
                                    required property string modelData
                                    property bool isSel: globalDesktopManager.dockSize === szBtn.modelData
                                    Layout.preferredWidth: 90
                                    Layout.preferredHeight: 32
                                    radius: 6
                                    color: isSel ? SRITECTheme.accentCyan : SRITECTheme.backgroundElevated
                                    Text {
                                        anchors.centerIn: parent
                                        text: szBtn.modelData.toUpperCase()
                                        color: szBtn.isSel ? SRITECTheme.backgroundVoid : SRITECTheme.textSecondary
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: globalDesktopManager.dockSize = szBtn.modelData
                                    }
                                }
                            }
                        }
                    }

                    // Auto-hide switch
                    RowLayout {
                        spacing: 12
                        Text {
                            text: "Auto-hide Application Dock"
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Switch {
                            checked: globalDesktopManager.dockAutoHide
                            onToggled: globalDesktopManager.dockAutoHide = checked
                        }
                    }
                }

                // TAB 3: Desktop & Icons
                ColumnLayout {
                    visible: root.activeSettingsTab === 3
                    width: parent.width
                    spacing: 24

                    Text {
                        text: "DESKTOP ICON MANAGEMENT"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 16
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Text {
                        text: "Current Desktop Items: " + globalDesktopManager.desktopItems.length
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 12
                    }

                    RowLayout {
                        spacing: 12
                        Rectangle {
                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 36
                            radius: SRITECTheme.radiusSmall
                            color: SRITECTheme.backgroundElevated
                            border.color: SRITECTheme.accentCyan
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "+ Create New Folder"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: globalDesktopManager.createFolder("New Workspace Folder", 180, 180)
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 36
                            radius: SRITECTheme.radiusSmall
                            color: SRITECTheme.backgroundElevated
                            border.color: SRITECTheme.borderSubtle
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "↺ Reset Icon Grid"
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: globalDesktopManager.resetToDefaults()
                            }
                        }
                    }
                }

                // TAB 4: Hardware & Telemetry
                ColumnLayout {
                    visible: root.activeSettingsTab === 4
                    width: parent.width
                    spacing: 20

                    Text {
                        text: "HARDWARE SENSORS & SYSTEM ARCHITECTURE"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 16
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    // Host Details Box
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        radius: SRITECTheme.radiusMedium
                        color: SRITECTheme.backgroundElevated
                        border.color: SRITECTheme.borderSubtle
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            Text {
                                text: "HOST SYSTEM IDENTITY"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1.2
                            }

                            Text {
                                text: "• Host OS:            " + globalAppLauncher.hostDistro + "\n" +
                                      "• Linux Kernel:       " + globalAppLauncher.hostKernel + "\n" +
                                      "• Display Mode:       Wayland Native Surface / XWayland Client\n" +
                                      "• Network Adapter:    " + globalDesktopManager.networkInterfaceName + " (Wired Ethernet Active)\n" +
                                      "• Power Telemetry:    " + globalDesktopManager.batteryStatusText + "\n" +
                                      "• Display Backlight:  " + globalDesktopManager.backlightStatusText + "\n" +
                                      "• Bluetooth State:    " + globalDesktopManager.bluetoothStatusText
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 11
                                font.family: SRITECTheme.fontMono
                                lineHeight: 1.5
                            }
                        }
                    }
                }

                // TAB 5: AI Gateway Engine
                ColumnLayout {
                    visible: root.activeSettingsTab === 5
                    width: parent.width
                    spacing: 20

                    Text {
                        text: "AI GATEWAY PROVIDER CONFIGURATION"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 16
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Text {
                        text: "Current Active Provider: " + globalAIBridge.selectedProvider
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 13
                        font.bold: true
                    }

                    RowLayout {
                        spacing: 10
                        Repeater {
                            model: ["Mock", "Google Gemini", "OpenAI", "Anthropic Claude", "Local AI (Ollama)"]

                            delegate: Rectangle {
                                id: pBtn
                                required property string modelData
                                property bool isSel: globalAIBridge.selectedProvider === pBtn.modelData
                                Layout.preferredHeight: 32
                                Layout.preferredWidth: pText.implicitWidth + 24
                                radius: 16
                                color: isSel ? SRITECTheme.accentCyan : SRITECTheme.backgroundElevated
                                border.color: isSel ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                                border.width: 1

                                Text {
                                    id: pText
                                    anchors.centerIn: parent
                                    text: pBtn.modelData
                                    color: pBtn.isSel ? SRITECTheme.backgroundVoid : SRITECTheme.textSecondary
                                    font.pixelSize: 11
                                    font.bold: pBtn.isSel
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: globalAIBridge.selectProvider(pBtn.modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
