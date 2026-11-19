import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    signal backToDesktopRequested()

    property int selectedUnitIndex: 0

    // Simulated Kinematic angles (Micro-oscillations for live sensor feel)
    property real j1: 14.2
    property real j2: -28.5
    property real j3: 90.1
    property real j4: 0.0
    property real j5: 45.8
    property real j6: -12.3

    // Simulation pulse timer
    Timer {
        id: telemetryTimer
        interval: 100
        running: true
        repeat: true
        property real tick: 0
        onTriggered: {
            tick += 0.08;
            root.j1 = 14.2 + Math.sin(tick) * 2.1;
            root.j2 = -28.5 + Math.cos(tick * 0.8) * 1.8;
            root.j3 = 90.1 + Math.sin(tick * 1.2) * 2.4;
            root.j4 = Math.sin(tick * 0.5) * 3.0;
            root.j5 = 45.8 + Math.cos(tick * 1.1) * 2.0;
            root.j6 = -12.3 + Math.sin(tick * 0.9) * 1.5;
        }
    }

    // Units Catalog Model
    readonly property var unitsModel: [
        {
            id: "humanoid",
            code: "UNIT 01",
            name: "Humanoid AI Robot (Alpha-7)",
            category: "Anthropomorphic Co-Pilot",
            image: "qrc:/resources/images/robotics/humanoid_assistant.jpg",
            dof: "28 DoF Bipedal Chassis",
            payload: "25 kg Dual-Arm Manipulator",
            compute: "SRITEC Dual NPU Edge Matrix",
            sensors: "Stereo RGB-D + Solid-State LiDAR + Tactile Fingertips",
            status: "STANDBY • SIMULATION ACTIVE",
            statusColor: SRITECTheme.accentEmerald
        },
        {
            id: "arm",
            code: "UNIT 02",
            name: "6-DoF Industrial Robotic Arm",
            category: "Precision Micro-Assembly",
            image: "qrc:/resources/images/robotics/robotic_arm_automation.jpg",
            dof: "6-Axis Articulated Arm",
            payload: "12 kg Rated / 0.02mm Precision",
            compute: "Real-Time EtherCAT / Deterministic RTOS",
            sensors: "6-Axis Force/Torque + Tool Flange Camera",
            status: "TRAJECTORY NOMINAL",
            statusColor: SRITECTheme.accentCyan
        },
        {
            id: "rover",
            code: "UNIT 03",
            name: "Autonomous Mobile Rover (AMR-V4)",
            category: "Omnidirectional Logistics",
            image: "qrc:/resources/images/robotics/robotics_lab_fleet.jpg",
            dof: "4WD Mecanum Kinematics",
            payload: "80 kg Payload Deck",
            compute: "Embedded Jetson Orin AGX Core",
            sensors: "360° Safety LiDAR + Ultrasonic Proximity",
            status: "SLAM MAPPING SYNCED",
            statusColor: SRITECTheme.accentViolet
        },
        {
            id: "lab",
            code: "FACILITY",
            name: "Robotics Research & Fleet Testbed",
            category: "Autonomous Multi-Agent Grid",
            image: "qrc:/resources/images/robotics/robotics_lab_fleet.jpg",
            dof: "Multi-Robot Distributed Grid",
            payload: "Full Facility Coordination",
            compute: "SRITEC Central Neural Core (LISA)",
            sensors: "Overhead Optical MoCap + Environmental Array",
            status: "FLEET LINKED • 4 AGENTS",
            statusColor: SRITECTheme.accentEmerald
        }
    ]

    readonly property var currentUnit: unitsModel[selectedUnitIndex]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // 1. Futuristic Header Bar & Safety Guardrail Banner
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            // Return to Desktop Button
            Rectangle {
                Layout.preferredWidth: 160
                Layout.preferredHeight: 38
                radius: 19
                color: backMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.20) : Qt.rgba(19/255, 26/255, 40/255, 0.70)
                border.color: backMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                border.width: 1

                Behavior on color { ColorAnimation { duration: SRITECTheme.animFast } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "◀"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 11
                    }
                    Text {
                        text: "Spatial Desktop"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backToDesktopRequested()
                }
            }

            // Suite Title
            ColumnLayout {
                spacing: 2
                Text {
                    text: "ROBOTICS ECOSYSTEM & AUTONOMOUS AGENTS"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 1.5
                }
                Text {
                    text: "Multi-Agent Kinematics • Perception Telemetry • Autonomous Fleet Coordination"
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 10
                }
            }

            Item { Layout.fillWidth: true }

            // Guardrail Safety Alert Banner (Strict Rule 6 enforcement)
            Rectangle {
                Layout.preferredHeight: 38
                Layout.preferredWidth: guardrailRow.implicitWidth + 24
                radius: 19
                color: Qt.rgba(236/255, 72/255, 153/255, 0.12)
                border.color: SRITECTheme.accentNeonPink
                border.width: 1

                RowLayout {
                    id: guardrailRow
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "🛡"
                        color: SRITECTheme.accentNeonPink
                        font.pixelSize: 12
                    }

                    Text {
                        text: "SAFETY GUARDRAIL RULE 6: SIMULATION ONLY • NO PHYSICAL HARDWARE LINK"
                        color: SRITECTheme.textPrimary
                        font.pixelSize: 10
                        font.bold: true
                        font.family: SRITECTheme.fontMono
                    }
                }
            }
        }

        // 2. Unit Selection Tabs
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Repeater {
                model: root.unitsModel

                delegate: Rectangle {
                    id: unitTab
                    required property var modelData
                    required property int index

                    property bool isSelected: root.selectedUnitIndex === index
                    property bool isHovered: tabMouse.containsMouse

                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: SRITECTheme.radiusMedium
                    color: isSelected ? Qt.rgba(19/255, 26/255, 40/255, 0.90) : (isHovered ? Qt.rgba(19/255, 26/255, 40/255, 0.50) : Qt.rgba(13/255, 17/255, 26/255, 0.60))
                    border.color: isSelected ? SRITECTheme.accentCyan : (isHovered ? SRITECTheme.borderGlowViolet : SRITECTheme.borderSubtle)
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: SRITECTheme.animFast } }
                    Behavior on border.color { ColorAnimation { duration: SRITECTheme.animFast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 6
                            Layout.preferredHeight: 6
                            radius: 3
                            color: unitTab.isSelected ? SRITECTheme.accentCyan : SRITECTheme.textTertiary
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: unitTab.modelData.code + " — " + unitTab.modelData.name
                                color: unitTab.isSelected ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                font.pixelSize: 10
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: unitTab.modelData.category
                                color: SRITECTheme.textTertiary
                                font.pixelSize: 8
                            }
                        }
                    }

                    MouseArea {
                        id: tabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectedUnitIndex = unitTab.index
                    }
                }
            }
        }

        // 3. Workspace Main Stage (Left Visual Viewport + Right Telemetry Deck)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            // Left: High-Resolution Visual Render & Targeting HUD
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 6
                radius: SRITECTheme.radiusLarge
                color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                border.color: SRITECTheme.borderSubtle
                border.width: 1
                clip: true

                // Background 3D Render Image
                Image {
                    id: mainRender
                    anchors.fill: parent
                    source: root.currentUnit.image
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                }

                // Cybernetic Vignette Overlay
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(7/255, 10/255, 15/255, 0.40) }
                        GradientStop { position: 0.7; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.rgba(7/255, 10/255, 15/255, 0.92) }
                    }
                }

                // Vertical Scanning Sweep Laser
                Rectangle {
                    width: parent.width
                    height: 2
                    color: Qt.rgba(0/255, 229/255, 255/255, 0.75)

                    SequentialAnimation on y {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { from: 0; to: mainRender.height - 2; duration: 3400; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: mainRender.height - 2; to: 0; duration: 3400; easing.type: Easing.InOutQuad }
                    }
                }

                // Sci-Fi Reticle Overlay (Targeting Crosshairs)
                Item {
                    anchors.centerIn: parent
                    width: 160
                    height: 160

                    // Outer ring
                    Rectangle {
                        anchors.fill: parent
                        radius: 80
                        color: "transparent"
                        border.color: Qt.rgba(0/255, 229/255, 255/255, 0.25)
                        border.width: 1
                    }

                    // Rotating tick ring
                    Rectangle {
                        anchors.centerIn: parent
                        width: 130
                        height: 130
                        radius: 65
                        color: "transparent"
                        border.color: Qt.rgba(139/255, 92/255, 246/255, 0.40)
                        border.width: 1

                        RotationAnimation on rotation {
                            loops: Animation.Infinite
                            from: 0
                            to: 360
                            duration: 16000
                            running: true
                        }
                    }

                    // Center crosshair
                    Text {
                        anchors.centerIn: parent
                        text: "⌖"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 22
                    }
                }

                // Top-Left Unit Telemetry Tag
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 14
                    height: 26
                    width: tagRow.implicitWidth + 20
                    radius: 13
                    color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                    border.color: root.currentUnit.statusColor
                    border.width: 1

                    RowLayout {
                        id: tagRow
                        anchors.centerIn: parent
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 6
                            Layout.preferredHeight: 6
                            radius: 3
                            color: root.currentUnit.statusColor
                        }

                        Text {
                            text: root.currentUnit.status
                            color: SRITECTheme.textPrimary
                            font.pixelSize: 9
                            font.bold: true
                            font.family: SRITECTheme.fontMono
                        }
                    }
                }

                // Bottom Specs HUD Card
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 14
                    height: 74
                    radius: 12
                    color: Qt.rgba(13/255, 17/255, 26/255, 0.90)
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: "DEGREES OF FREEDOM"; color: SRITECTheme.accentCyan; font.pixelSize: 8; font.bold: true; font.family: SRITECTheme.fontMono }
                            Text { text: root.currentUnit.dof; color: SRITECTheme.textPrimary; font.pixelSize: 10; font.bold: true }
                        }

                        Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: SRITECTheme.borderSubtle }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: "PAYLOAD / DYNAMICS"; color: SRITECTheme.accentViolet; font.pixelSize: 8; font.bold: true; font.family: SRITECTheme.fontMono }
                            Text { text: root.currentUnit.payload; color: SRITECTheme.textPrimary; font.pixelSize: 10; font.bold: true }
                        }

                        Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: SRITECTheme.borderSubtle }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: "NEURAL ON-BOARD COMPUTE"; color: SRITECTheme.accentEmerald; font.pixelSize: 8; font.bold: true; font.family: SRITECTheme.fontMono }
                            Text { text: root.currentUnit.compute; color: SRITECTheme.textPrimary; font.pixelSize: 10; font.bold: true }
                        }
                    }
                }
            }

            // Right: Telemetry & Kinematics Control Deck
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 4
                spacing: 12

                // Card 1: 6-Axis Kinematic Angles (Simulated)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    radius: SRITECTheme.radiusLarge
                    color: Qt.rgba(13/255, 17/255, 26/255, 0.88)
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 8

                        RowLayout {
                            spacing: 6
                            Text { text: "⚡"; color: SRITECTheme.accentCyan; font.pixelSize: 12 }
                            Text { text: "KINEMATIC JOINT TELEMETRY [SIMULATED]"; color: SRITECTheme.accentCyan; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.0 }
                            Item { Layout.fillWidth: true }
                            Text { text: "100 Hz REFRESH"; color: SRITECTheme.textTertiary; font.pixelSize: 8; font.family: SRITECTheme.fontMono }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 6
                            columnSpacing: 16

                            // J1
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: "J1 Pan:"; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                                ProgressBar {
                                    id: barJ1
                                    Layout.fillWidth: true
                                    from: -180; to: 180; value: root.j1
                                    background: Rectangle { implicitHeight: 6; radius: 3; color: "#172033" }
                                    contentItem: Item { Rectangle { width: barJ1.visualPosition * parent.width; height: 6; radius: 3; color: SRITECTheme.accentCyan } }
                                }
                                Text { text: root.j1.toFixed(1) + "°"; color: SRITECTheme.textPrimary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                            }

                            // J2
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: "J2 Lift:"; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                                ProgressBar {
                                    id: barJ2
                                    Layout.fillWidth: true
                                    from: -90; to: 90; value: root.j2
                                    background: Rectangle { implicitHeight: 6; radius: 3; color: "#172033" }
                                    contentItem: Item { Rectangle { width: barJ2.visualPosition * parent.width; height: 6; radius: 3; color: SRITECTheme.accentCyan } }
                                }
                                Text { text: root.j2.toFixed(1) + "°"; color: SRITECTheme.textPrimary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                            }

                            // J3
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: "J3 Flex:"; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                                ProgressBar {
                                    id: barJ3
                                    Layout.fillWidth: true
                                    from: 0; to: 180; value: root.j3
                                    background: Rectangle { implicitHeight: 6; radius: 3; color: "#172033" }
                                    contentItem: Item { Rectangle { width: barJ3.visualPosition * parent.width; height: 6; radius: 3; color: SRITECTheme.accentViolet } }
                                }
                                Text { text: root.j3.toFixed(1) + "°"; color: SRITECTheme.textPrimary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                            }

                            // J4
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: "J4 Roll:"; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                                ProgressBar {
                                    id: barJ4
                                    Layout.fillWidth: true
                                    from: -180; to: 180; value: root.j4
                                    background: Rectangle { implicitHeight: 6; radius: 3; color: "#172033" }
                                    contentItem: Item { Rectangle { width: barJ4.visualPosition * parent.width; height: 6; radius: 3; color: SRITECTheme.accentViolet } }
                                }
                                Text { text: root.j4.toFixed(1) + "°"; color: SRITECTheme.textPrimary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                            }

                            // J5
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: "J5 Pitch:"; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                                ProgressBar {
                                    id: barJ5
                                    Layout.fillWidth: true
                                    from: -90; to: 90; value: root.j5
                                    background: Rectangle { implicitHeight: 6; radius: 3; color: "#172033" }
                                    contentItem: Item { Rectangle { width: barJ5.visualPosition * parent.width; height: 6; radius: 3; color: SRITECTheme.accentEmerald } }
                                }
                                Text { text: root.j5.toFixed(1) + "°"; color: SRITECTheme.textPrimary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                            }

                            // J6
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: "J6 Yaw:"; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                                ProgressBar {
                                    id: barJ6
                                    Layout.fillWidth: true
                                    from: -180; to: 180; value: root.j6
                                    background: Rectangle { implicitHeight: 6; radius: 3; color: "#172033" }
                                    contentItem: Item { Rectangle { width: barJ6.visualPosition * parent.width; height: 6; radius: 3; color: SRITECTheme.accentEmerald } }
                                }
                                Text { text: root.j6.toFixed(1) + "°"; color: SRITECTheme.textPrimary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; Layout.preferredWidth: 44 }
                            }
                        }
                    }
                }

                // Card 2: Perception, LiDAR & Power Telemetry
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    radius: SRITECTheme.radiusLarge
                    color: Qt.rgba(13/255, 17/255, 26/255, 0.88)
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        RowLayout {
                            spacing: 6
                            Text { text: "👁"; color: SRITECTheme.accentEmerald; font.pixelSize: 12 }
                            Text { text: "PERCEPTION & SENSORY MATRIX"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.0 }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            // LiDAR
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: "3D SOLID-STATE LIDAR"; color: SRITECTheme.textTertiary; font.pixelSize: 8; font.bold: true; font.family: SRITECTheme.fontMono }
                                Text { text: "240,000 pts/s"; color: SRITECTheme.textPrimary; font.pixelSize: 11; font.bold: true }
                                Text { text: "FOV: 360° x 45°"; color: SRITECTheme.accentCyan; font.pixelSize: 8; font.family: SRITECTheme.fontMono }
                            }

                            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 36; color: SRITECTheme.borderSubtle }

                            // Vision
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: "STEREO DEPTH STREAM"; color: SRITECTheme.textTertiary; font.pixelSize: 8; font.bold: true; font.family: SRITECTheme.fontMono }
                                Text { text: "60 FPS @ 1080p"; color: SRITECTheme.textPrimary; font.pixelSize: 11; font.bold: true }
                                Text { text: "Latency: 4.2 ms"; color: SRITECTheme.accentViolet; font.pixelSize: 8; font.family: SRITECTheme.fontMono }
                            }

                            Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 36; color: SRITECTheme.borderSubtle }

                            // Power
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { text: "POWER BUS / THERMALS"; color: SRITECTheme.textTertiary; font.pixelSize: 8; font.bold: true; font.family: SRITECTheme.fontMono }
                                Text { text: "48.2 V • 8.4 A"; color: SRITECTheme.textPrimary; font.pixelSize: 11; font.bold: true }
                                Text { text: "Core: 38.6°C (Nominal)"; color: SRITECTheme.accentEmerald; font.pixelSize: 8; font.family: SRITECTheme.fontMono }
                            }
                        }
                    }
                }

                // Card 3: Human-Robot Collaboration & Safety Policies
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: SRITECTheme.radiusLarge
                    color: Qt.rgba(13/255, 17/255, 26/255, 0.88)
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 8

                        RowLayout {
                            spacing: 6
                            Text { text: "🤝"; color: SRITECTheme.accentViolet; font.pixelSize: 12 }
                            Text { text: "HUMAN-ROBOT COLLABORATION PROTOCOLS"; color: SRITECTheme.accentViolet; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.0 }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "• Safety Standards: ISO 10218-1 / ISO/TS 15066 Speed & Separation Monitoring\n" +
                                  "• Dynamic Virtual Proximity Perimeter: 1.50m (Status: Clear)\n" +
                                  "• Collision Avoidance: RRT* Real-Time Path Optimization Active\n" +
                                  "• Actuator Isolation: Host sandboxing prohibits hardware port access"
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 9
                            font.family: SRITECTheme.fontMono
                            lineHeight: 1.5
                        }

                        Item { Layout.fillHeight: true }

                        // Simulated E-Stop & Test Trigger
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                radius: 8
                                color: Qt.rgba(0/255, 245/255, 160/255, 0.15)
                                border.color: SRITECTheme.accentEmerald
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "✓"; color: SRITECTheme.accentEmerald; font.bold: true; font.pixelSize: 10 }
                                    Text { text: "SIMULATED TRAJECTORY RUNNING"; color: SRITECTheme.accentEmerald; font.bold: true; font.pixelSize: 9 }
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 32
                                radius: 8
                                color: Qt.rgba(255/255, 59/255, 92/255, 0.15)
                                border.color: SRITECTheme.accentCrimson
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text { text: "⛔"; color: SRITECTheme.accentCrimson; font.pixelSize: 10 }
                                    Text { text: "E-STOP ENGAGED"; color: SRITECTheme.accentCrimson; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
