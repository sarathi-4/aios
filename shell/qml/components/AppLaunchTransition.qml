import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    anchors.fill: parent
    visible: globalAppLaunchManager.isTransitionActive || transitionFadeAnim.running
    z: 150

    property var trans: globalAppLaunchManager.activeTransition
    property bool isInternal: trans ? (trans.launchType === "internal") : true
    property bool isAvail: trans ? (trans.isAvailable !== false) : true
    property string statusText: "INITIALIZING SPATIAL RUNTIME..."

    // Performance mode check
    readonly property bool isReducedMotion: globalDesktopManager.performanceMode === "reduced_motion"

    // Background Dimming Scrim
    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Qt.rgba(7/255, 10/255, 15/255, 0.45)
        opacity: globalAppLaunchManager.isTransitionActive ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: root.isReducedMotion ? 120 : 250 } }
    }

    // Visual Effects: Energy Beam & Particle Burst
    AppTransitionEffects {
        id: effects
        originX: trans && trans.originX !== undefined ? (trans.originX + trans.originWidth * 0.5) : width * 0.5
        originY: trans && trans.originY !== undefined ? (trans.originY + trans.originHeight * 0.5) : height * 0.5
        targetX: expandingPanel.x
        targetY: expandingPanel.y
        targetWidth: expandingPanel.width
        targetHeight: expandingPanel.height
        accentColor: trans && trans.accentColor ? trans.accentColor : SRITECTheme.accentCyan
        active: globalAppLaunchManager.isTransitionActive
        performanceMode: globalDesktopManager.performanceMode
    }

    // Expanding Holographic Glass Panel
    Rectangle {
        id: expandingPanel
        radius: SRITECTheme.radiusLarge
        color: Qt.rgba(13/255, 17/255, 26/255, 0.90)
        border.color: trans && trans.accentColor ? trans.accentColor : SRITECTheme.accentCyan
        border.width: 1.5
        clip: true

        // Initial Geometry Binding
        x: trans && trans.originX !== undefined ? trans.originX : width * 0.5
        y: trans && trans.originY !== undefined ? trans.originY : height * 0.5
        width: trans && trans.originWidth !== undefined ? trans.originWidth : 48
        height: trans && trans.originHeight !== undefined ? trans.originHeight : 48
        opacity: 0.0
        scale: 0.3

        // Ambient Outer Glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius + 4
            color: "transparent"
            border.color: expandingPanel.border.color
            border.width: 1
            opacity: 0.4
            z: -1
        }

        // Sci-Fi Corner Brackets
        Canvas {
            id: cornerCanvas
            anchors.fill: parent
            z: 2
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = expandingPanel.border.color;
                ctx.lineWidth = 1.5;

                var bLen = 12;
                var off = 6;

                // Top-Left
                ctx.beginPath();
                ctx.moveTo(off, off + bLen); ctx.lineTo(off, off); ctx.lineTo(off + bLen, off);
                ctx.stroke();

                // Top-Right
                ctx.beginPath();
                ctx.moveTo(width - off - bLen, off); ctx.lineTo(width - off, off); ctx.lineTo(width - off, off + bLen);
                ctx.stroke();

                // Bottom-Left
                ctx.beginPath();
                ctx.moveTo(off, height - off - bLen); ctx.lineTo(off, height - off); ctx.lineTo(off + bLen, height - off);
                ctx.stroke();

                // Bottom-Right
                ctx.beginPath();
                ctx.moveTo(width - off - bLen, height - off); ctx.lineTo(width - off, height - off); ctx.lineTo(width - off, height - off - bLen);
                ctx.stroke();
            }
        }

        // Vertical Laser Scanline Sweep
        Rectangle {
            id: laserSweep
            width: parent.width
            height: 2
            color: expandingPanel.border.color
            opacity: 0.8
            visible: !root.isReducedMotion

            SequentialAnimation on y {
                loops: Animation.Infinite
                running: globalAppLaunchManager.isTransitionActive
                NumberAnimation { from: 0; to: expandingPanel.height - 2; duration: 1800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: expandingPanel.height - 2; to: 0; duration: 1800; easing.type: Easing.InOutQuad }
            }
        }

        // Panel Center Content (Application Icon, Title, Status Readout)
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 14

            // Animated Application Icon
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64

                AIIcon {
                    id: launchIcon
                    anchors.centerIn: parent
                    iconId: trans && trans.iconId ? trans.iconId : "ai_core"
                    size: 64
                    showTile: true
                    isHovered: true
                }

                // Pulsing Halo Ring
                Rectangle {
                    anchors.centerIn: parent
                    width: 76
                    height: 76
                    radius: 38
                    color: "transparent"
                    border.color: expandingPanel.border.color
                    border.width: 1

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        running: globalAppLaunchManager.isTransitionActive
                        NumberAnimation { from: 0.9; to: 1.25; duration: 900; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 1.25; to: 0.9; duration: 900; easing.type: Easing.InOutSine }
                    }

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: globalAppLaunchManager.isTransitionActive
                        NumberAnimation { from: 0.8; to: 0.2; duration: 900; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.2; to: 0.8; duration: 900; easing.type: Easing.InOutSine }
                    }
                }
            }

            // Application Title & Category
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: trans && trans.name ? trans.name : "Application"
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 16
                    font.bold: true
                    font.letterSpacing: 1.0
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 6
                        Layout.preferredHeight: 6
                        radius: 3
                        color: root.isAvail ? SRITECTheme.accentEmerald : SRITECTheme.accentAmber
                    }

                    Text {
                        text: (trans ? trans.category : "System") + " • " + (root.isInternal ? "NEBULA Native Surface" : (root.isAvail ? "Host Wayland Process" : "Unavailable"))
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 10
                        font.family: SRITECTheme.fontMono
                    }
                }
            }

            // Status Progress Pill
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 28
                Layout.preferredWidth: statusLabel.implicitWidth + 24
                radius: 14
                color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                border.color: root.isAvail ? (trans && trans.accentColor ? trans.accentColor : SRITECTheme.accentCyan) : SRITECTheme.accentAmber
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: root.isAvail ? "✦" : "⚠"
                        color: root.isAvail ? SRITECTheme.accentCyan : SRITECTheme.accentAmber
                        font.pixelSize: 10
                    }

                    Text {
                        id: statusLabel
                        text: root.statusText
                        color: root.isAvail ? SRITECTheme.textPrimary : SRITECTheme.accentAmber
                        font.pixelSize: 10
                        font.bold: true
                        font.family: SRITECTheme.fontMono
                    }
                }
            }
        }
    }

    // Parallel Animation Sequence: Expand from Icon to Target Window
    ParallelAnimation {
        id: expandAnim

        NumberAnimation {
            target: expandingPanel
            property: "x"
            to: trans && trans.targetX !== undefined ? trans.targetX : 400
            duration: root.isReducedMotion ? 120 : (trans && trans.durationMs ? trans.durationMs * 0.65 : 420)
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: expandingPanel
            property: "y"
            to: trans && trans.targetY !== undefined ? trans.targetY : 200
            duration: root.isReducedMotion ? 120 : (trans && trans.durationMs ? trans.durationMs * 0.65 : 420)
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: expandingPanel
            property: "width"
            to: trans && trans.targetWidth !== undefined ? trans.targetWidth : 880
            duration: root.isReducedMotion ? 120 : (trans && trans.durationMs ? trans.durationMs * 0.65 : 420)
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: expandingPanel
            property: "height"
            to: trans && trans.targetHeight !== undefined ? trans.targetHeight : 560
            duration: root.isReducedMotion ? 120 : (trans && trans.durationMs ? trans.durationMs * 0.65 : 420)
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: expandingPanel
            property: "scale"
            to: 1.0
            duration: root.isReducedMotion ? 120 : (trans ? trans.durationMs * 0.65 : 420)
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: expandingPanel
            property: "opacity"
            to: 1.0
            duration: root.isReducedMotion ? 100 : 200
            easing.type: Easing.OutQuad
        }

        onFinished: {
            cornerCanvas.requestPaint();
            handoffTimer.restart();
        }
    }

    // Handoff & Completion Timer
    Timer {
        id: handoffTimer
        interval: root.isReducedMotion ? 50 : 200
        repeat: false
        onTriggered: {
            if (!trans) return;

            var appId = trans.appId;
            if (root.isInternal) {
                root.statusText = "ACTIVATING NATIVE INTERFACE...";
                completeTimer.restart();
            } else {
                if (root.isAvail) {
                    root.statusText = "HANDOFF TO HOST DISPLAY SERVER...";
                } else {
                    root.statusText = "APPLICATION NOT INSTALLED ON HOST";
                }
                completeTimer.interval = root.isAvail ? 250 : 1200;
                completeTimer.restart();
            }
        }
    }

    Timer {
        id: completeTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (trans) {
                var appId = trans.appId;
                globalAppLaunchManager.completeTransition(appId);
                transitionFadeAnim.restart();
            }
        }
    }

    // Smooth Fadeout of Transition Overlay
    ParallelAnimation {
        id: transitionFadeAnim

        NumberAnimation {
            target: expandingPanel
            property: "opacity"
            to: 0.0
            duration: 220
            easing.type: Easing.InQuad
        }

        NumberAnimation {
            target: expandingPanel
            property: "scale"
            to: 1.04
            duration: 220
            easing.type: Easing.OutQuad
        }

        onFinished: {
            expandingPanel.scale = 0.3;
            expandingPanel.opacity = 0.0;
        }
    }

    // Listen to Transition Trigger from C++ Manager
    Connections {
        target: globalAppLaunchManager

        function onTransitionStateChanged() {
            if (globalAppLaunchManager.isTransitionActive) {
                var t = globalAppLaunchManager.activeTransition;
                if (!t || !t.active) return;

                // Reset initial geometry to origin
                expandingPanel.x = t.originX;
                expandingPanel.y = t.originY;
                expandingPanel.width = t.originWidth;
                expandingPanel.height = t.originHeight;
                expandingPanel.scale = 0.3;
                expandingPanel.opacity = 0.0;

                root.statusText = "ALLOCATING SANDBOX BUFFER...";

                // Trigger particle burst
                effects.triggerBurst(t.originX + t.originWidth * 0.5, t.originY + t.originHeight * 0.5);

                // Start expansion animation
                expandAnim.restart();
            }
        }
    }
}
