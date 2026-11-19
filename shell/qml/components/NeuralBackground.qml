import QtQuick
import "../theme"

Item {
    id: root
    anchors.fill: parent

    property string performanceMode: "Balanced" // "Ultra", "Balanced", "Low", "Reduced Motion"
    property real wallpaperIntensity: 0.85
    property real cursorX: width / 2
    property real cursorY: height / 2
    property real timeStep: 0.0

    // Deep space backdrop
    Rectangle {
        anchors.fill: parent
        color: SRITECTheme.backgroundVoid
    }

    // Static Wallpaper Image (Edge-to-edge full screen cover)
    Image {
        id: bgImage
        visible: globalDesktopManager.wallpaperType === "image" && globalDesktopManager.wallpaperPath.length > 0
        anchors.fill: parent
        source: globalDesktopManager.wallpaperPath.startsWith("/") ?
                "file://" + globalDesktopManager.wallpaperPath : globalDesktopManager.wallpaperPath
        fillMode: globalDesktopManager.wallpaperMode === "fit" ? Image.PreserveAspectFit :
                  globalDesktopManager.wallpaperMode === "stretch" ? Image.Stretch :
                  globalDesktopManager.wallpaperMode === "tile" ? Image.Tile : Image.PreserveAspectCrop
        asynchronous: true
        opacity: 0.94
    }

    // Subtle Sci-Fi Ambient Vignette Overlay
    Rectangle {
        anchors.fill: parent
        visible: bgImage.visible
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(7/255, 10/255, 15/255, 0.40) }
            GradientStop { position: 0.35; color: Qt.rgba(7/255, 10/255, 15/255, 0.15) }
            GradientStop { position: 0.70; color: Qt.rgba(7/255, 10/255, 15/255, 0.25) }
            GradientStop { position: 1.0; color: Qt.rgba(7/255, 10/255, 15/255, 0.55) }
        }
    }

    // Procedural Neural Wave & Particle Canvas
    Canvas {
        id: waveCanvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Threaded
        opacity: bgImage.visible ? 0.35 : 1.0

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            if (root.performanceMode === "Reduced Motion" || root.performanceMode === "Low") {
                // Static subtle grid for battery saver or accessibility
                ctx.strokeStyle = "rgba(23, 32, 51, 0.4)";
                ctx.lineWidth = 1;
                for (var x = 0; x < width; x += 60) {
                    ctx.beginPath();
                    ctx.moveTo(x, 0);
                    ctx.lineTo(x, height);
                    ctx.stroke();
                }
                for (var y = 0; y < height; y += 60) {
                    ctx.beginPath();
                    ctx.moveTo(0, y);
                    ctx.lineTo(width, y);
                    ctx.stroke();
                }
                return;
            }

            var w = width;
            var h = height;
            var t = root.timeStep;

            // 1. Draw smooth harmonic waves across the screen (inspired by user images)
            var waveCount = (root.performanceMode === "Ultra") ? 4 : 2;
            for (var k = 0; k < waveCount; ++k) {
                ctx.beginPath();
                var grad = ctx.createLinearGradient(0, 0, w, 0);
                if (k % 2 === 0) {
                    grad.addColorStop(0, "rgba(0, 229, 255, 0.0)");
                    grad.addColorStop(0.3, "rgba(0, 229, 255, 0.18)");
                    grad.addColorStop(0.7, "rgba(139, 92, 246, 0.22)");
                    grad.addColorStop(1, "rgba(236, 72, 153, 0.0)");
                } else {
                    grad.addColorStop(0, "rgba(37, 99, 235, 0.0)");
                    grad.addColorStop(0.4, "rgba(139, 92, 246, 0.15)");
                    grad.addColorStop(0.8, "rgba(0, 229, 255, 0.12)");
                    grad.addColorStop(1, "rgba(0, 245, 160, 0.0)");
                }

                ctx.strokeStyle = grad;
                ctx.lineWidth = (k === 0) ? 2.5 : 1.5;

                var baseHeight = h * (0.35 + k * 0.15);
                var freq = 0.003 + k * 0.001;
                var speed = t * (0.8 + k * 0.4);

                for (var px = 0; px < w; px += 8) {
                    // Gravitational deflection near cursor
                    var dx = px - root.cursorX;
                    var dy = baseHeight - root.cursorY;
                    var dist = Math.sqrt(dx * dx + dy * dy);
                    var deflection = (dist < 220) ? (220 - dist) * 0.15 * Math.sin(t * 2) : 0;

                    var intensity = root.wallpaperIntensity;
                    var py = baseHeight + (Math.sin(px * freq + speed) * 35 + Math.cos(px * (freq * 0.6) - speed * 0.8) * 20) * intensity - deflection;
                    if (px === 0) {
                        ctx.moveTo(px, py);
                    } else {
                        ctx.lineTo(px, py);
                    }
                }
                ctx.stroke();
            }

            // 2. Draw subtle floating particles in Ultra mode
            if (root.performanceMode === "Ultra") {
                ctx.fillStyle = "rgba(0, 229, 255, 0.4)";
                for (var p = 0; p < 24; ++p) {
                    var seedX = (p * 83 + Math.sin(t * 0.4 + p) * 40) % w;
                    var seedY = (p * 57 + Math.cos(t * 0.3 + p) * 35) % h;
                    ctx.beginPath();
                    ctx.arc(seedX, seedY, 1.5, 0, Math.PI * 2);
                    ctx.fill();
                }
            }
        }
    }

    // Interactive mouse listener for cursor glow and deflection
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPositionChanged: function(mouse) {
            root.cursorX = mouse.x;
            root.cursorY = mouse.y;
        }
    }

    // Animation Driver Timer
    Timer {
        id: animTimer
        interval: (root.performanceMode === "Ultra") ? 16 : 33 // 60fps or 30fps
        running: root.performanceMode !== "Reduced Motion" && root.performanceMode !== "Low"
        repeat: true
        onTriggered: {
            root.timeStep += 0.03;
            waveCanvas.requestPaint();
        }
    }
}
