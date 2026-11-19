import QtQuick
import "../theme"

Item {
    id: root

    property string iconId: "ai_core"
    property int size: 48
    property bool isHovered: false
    property bool isAvailable: true
    property bool showTile: true

    width: size
    height: size

    // Color Palette based on icon identity
    readonly property color themeColor: {
        var id = iconId.toLowerCase();
        if (id === "terminal" || id === "codex") return SRITECTheme.accentCyan;
        if (id === "browser" || id === "firefox") return "#FF7700";
        if (id === "chrome") return SRITECTheme.accentCyan;
        if (id === "edge") return "#00F5A0";
        if (id === "opera") return "#FF3B5C";
        if (id === "chatgpt") return "#00F5A0";
        if (id === "gemini") return "#00E5FF";
        if (id === "claude") return "#FFB800";
        if (id === "vscode" || id === "code" || id === "editor") return "#3B82F6";
        if (id === "antigravity") return "#8B5CF6";
        if (id === "android_studio") return "#00F5A0";
        if (id === "files" || id === "folder" || id === "documents") return "#00E5FF";
        if (id === "projects" || id === "aios") return "#8B5CF6";
        if (id === "calculator") return "#00E5FF";
        if (id === "settings") return "#8B5CF6";
        if (id === "assistant") return "#00E5FF";
        if (id === "robotics" || id === "robot") return "#00E5FF";
        if (id === "home") return "#00E5FF";
        if (id === "launcher") return "#00E5FF";
        if (id === "drive" || id === "ssd" || id === "disk") return "#00F5A0";
        if (id === "computer" || id === "system") return "#00E5FF";
        if (id === "trash") return "#FF3B5C";
        if (id === "downloads") return "#00E5FF";
        if (id === "music") return "#8B5CF6";
        if (id === "pictures") return "#00F5A0";
        if (id === "videos") return "#FF7700";
        return SRITECTheme.accentCyan;
    }

    readonly property color secondaryThemeColor: {
        var id = iconId.toLowerCase();
        if (id === "gemini" || id === "antigravity" || id === "projects") return "#EC4899";
        if (id === "chatgpt" || id === "edge") return "#00E5FF";
        if (id === "claude") return "#FF3B5C";
        if (id === "browser" || id === "firefox") return "#FF0077";
        return "#8B5CF6";
    }

    opacity: isAvailable ? 1.0 : 0.45
    scale: isHovered ? 1.08 : 1.0
    Behavior on scale { NumberAnimation { duration: SRITECTheme.animFast; easing.type: Easing.OutBack } }

    // Ambient Neon Aura Glow (Subtle back-projection)
    Rectangle {
        anchors.centerIn: parent
        width: Math.round(root.size * 0.95)
        height: Math.round(root.size * 0.95)
        radius: Math.round(width * 0.28)
        color: root.themeColor
        opacity: root.isHovered ? 0.35 : 0.12
        visible: root.showTile
        Behavior on opacity { NumberAnimation { duration: SRITECTheme.animFast } }
    }

    // Holographic Glass Tile Container
    Rectangle {
        id: tileBg
        visible: root.showTile
        anchors.fill: parent
        radius: Math.round(root.size * 0.24)
        color: root.isHovered ?
               Qt.rgba(19/255, 26/255, 40/255, 0.92) :
               Qt.rgba(13/255, 17/255, 26/255, 0.78)
        border.color: root.isHovered ? root.themeColor : Qt.rgba(root.themeColor.r, root.themeColor.g, root.themeColor.b, 0.4)
        border.width: root.isHovered ? 1.8 : 1.2

        Behavior on color { ColorAnimation { duration: SRITECTheme.animFast } }
        Behavior on border.color { ColorAnimation { duration: SRITECTheme.animFast } }

        // Cybernetic Corner Brackets (Top-left & Bottom-right)
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 3
            width: 5
            height: 5
            radius: 1
            color: "transparent"
            border.color: root.themeColor
            border.width: 1
            opacity: root.isHovered ? 1.0 : 0.4
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 3
            width: 5
            height: 5
            radius: 1
            color: "transparent"
            border.color: root.themeColor
            border.width: 1
            opacity: root.isHovered ? 1.0 : 0.4
        }
    }

    // High-Resolution 2D Vector Canvas Graphic
    Canvas {
        id: iconCanvas
        anchors.centerIn: parent
        width: Math.round(root.size * (root.showTile ? 0.68 : 0.88))
        height: width
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var w = width;
            var h = height;
            var cx = w / 2;
            var cy = h / 2;
            var c1 = root.themeColor.toString();
            var c2 = root.secondaryThemeColor.toString();

            var id = root.iconId.toLowerCase();

            ctx.save();

            // 1. TERMINAL (>_)
            if (id === "terminal") {
                // Outer cyber frame
                ctx.strokeStyle = c1;
                ctx.lineWidth = 1.8;
                roundRect(ctx, 2, 2, w - 4, h - 4, 4);
                ctx.stroke();

                // Prompt glyph >
                ctx.beginPath();
                ctx.moveTo(w * 0.24, h * 0.32);
                ctx.lineTo(w * 0.44, h * 0.50);
                ctx.lineTo(w * 0.24, h * 0.68);
                ctx.stroke();

                // Cursor _
                ctx.fillStyle = c2;
                ctx.fillRect(w * 0.50, h * 0.62, w * 0.26, 2.5);
            }
            // 2. BROWSER / FIREFOX (Quantum Orbital Hyper-Globe)
            else if (id === "browser" || id === "firefox") {
                // Glowing outer planet sphere
                var pGrad = ctx.createRadialGradient(cx, cy, 2, cx, cy, w * 0.44);
                pGrad.addColorStop(0, c1);
                pGrad.addColorStop(0.8, c2);
                pGrad.addColorStop(1, "transparent");
                ctx.fillStyle = pGrad;
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.32, 0, Math.PI * 2);
                ctx.fill();

                // Orbital ring tilted at 30 degrees
                ctx.save();
                ctx.translate(cx, cy);
                ctx.rotate(-0.5);
                ctx.scale(1.0, 0.42);
                ctx.strokeStyle = c1;
                ctx.lineWidth = 2.2;
                ctx.beginPath();
                ctx.arc(0, 0, w * 0.48, 0, Math.PI * 2);
                ctx.stroke();
                ctx.restore();

                // Inner core spark
                ctx.fillStyle = "#FFFFFF";
                ctx.beginPath();
                ctx.arc(cx, cy, 2.5, 0, Math.PI * 2);
                ctx.fill();
            }
            // 3. CHROME (Tri-Color Cyber Disk)
            else if (id === "chrome") {
                ctx.lineWidth = 3;
                // Outer cyan arc
                ctx.strokeStyle = "#00E5FF";
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.38, 0, Math.PI * 0.7);
                ctx.stroke();
                // Outer pink arc
                ctx.strokeStyle = "#EC4899";
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.38, Math.PI * 0.7, Math.PI * 1.4);
                ctx.stroke();
                // Outer emerald arc
                ctx.strokeStyle = "#00F5A0";
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.38, Math.PI * 1.4, Math.PI * 2);
                ctx.stroke();

                // Central glowing blue core
                ctx.fillStyle = "#3B82F6";
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.16, 0, Math.PI * 2);
                ctx.fill();
            }
            // 4. EDGE (Sweeping Cyber Wave Ring)
            else if (id === "edge") {
                var waveGrad = ctx.createLinearGradient(0, 0, w, h);
                waveGrad.addColorStop(0, "#00E5FF");
                waveGrad.addColorStop(1, "#00F5A0");
                ctx.strokeStyle = waveGrad;
                ctx.lineWidth = 2.8;

                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.38, 0.4, Math.PI * 1.85);
                ctx.stroke();

                ctx.beginPath();
                ctx.arc(cx + 2, cy + 2, w * 0.20, Math.PI * 0.5, Math.PI * 1.9);
                ctx.stroke();
            }
            // 5. OPERA (Neon Ring with Quantum Core)
            else if (id === "opera") {
                ctx.strokeStyle = "#FF3B5C";
                ctx.lineWidth = 3.2;
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.38, 0, Math.PI * 2);
                ctx.stroke();

                ctx.fillStyle = "#FF7700";
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.16, 0, Math.PI * 2);
                ctx.fill();
            }
            // 6. QUANTUM VAULT / FILES / FOLDERS / DOCUMENTS (Isometric Holographic Data Cube)
            else if (id === "files" || id === "folder" || id === "documents") {
                // 3D Isometric Holographic Cube (No yellow folders!)
                var topY = h * 0.16;
                var midY = h * 0.46;
                var botY = h * 0.84;
                var leftX = w * 0.15;
                var rightX = w * 0.85;

                // Top facet (cyan gradient)
                var topGrad = ctx.createLinearGradient(leftX, topY, rightX, midY);
                topGrad.addColorStop(0, "rgba(0, 229, 255, 0.45)");
                topGrad.addColorStop(1, "rgba(139, 92, 246, 0.35)");
                ctx.fillStyle = topGrad;
                ctx.strokeStyle = c1;
                ctx.lineWidth = 1.6;

                ctx.beginPath();
                ctx.moveTo(cx, topY);
                ctx.lineTo(rightX, topY + (midY - topY) * 0.5);
                ctx.lineTo(cx, midY);
                ctx.lineTo(leftX, topY + (midY - topY) * 0.5);
                ctx.closePath();
                ctx.fill();
                ctx.stroke();

                // Left facet (violet gradient)
                var lGrad = ctx.createLinearGradient(leftX, midY, cx, botY);
                lGrad.addColorStop(0, "rgba(139, 92, 246, 0.3)");
                lGrad.addColorStop(1, "rgba(0, 229, 255, 0.15)");
                ctx.fillStyle = lGrad;
                ctx.beginPath();
                ctx.moveTo(leftX, topY + (midY - topY) * 0.5);
                ctx.lineTo(cx, midY);
                ctx.lineTo(cx, botY);
                ctx.lineTo(leftX, botY - (midY - topY) * 0.5);
                ctx.closePath();
                ctx.fill();
                ctx.stroke();

                // Right facet
                var rGrad = ctx.createLinearGradient(cx, midY, rightX, botY);
                rGrad.addColorStop(0, "rgba(0, 229, 255, 0.25)");
                rGrad.addColorStop(1, "rgba(139, 92, 246, 0.1)");
                ctx.fillStyle = rGrad;
                ctx.beginPath();
                ctx.moveTo(cx, midY);
                ctx.lineTo(rightX, topY + (midY - topY) * 0.5);
                ctx.lineTo(rightX, botY - (midY - topY) * 0.5);
                ctx.lineTo(cx, botY);
                ctx.closePath();
                ctx.fill();
                ctx.stroke();

                // Central glowing quantum core crystal
                ctx.fillStyle = "#FFFFFF";
                ctx.beginPath();
                ctx.arc(cx, midY, 2.5, 0, Math.PI * 2);
                ctx.fill();
            }
            // 7. PROJECTS / AIOS WORKSPACE (Neural Synapse Cluster)
            else if (id === "projects" || id === "aios") {
                ctx.strokeStyle = c1;
                ctx.lineWidth = 1.6;

                // 6 Outer Nodes
                var rad = w * 0.36;
                var pts = [];
                for (var n = 0; n < 6; ++n) {
                    var ang = n * (Math.PI / 3);
                    var px = cx + Math.cos(ang) * rad;
                    var py = cy + Math.sin(ang) * rad;
                    pts.push({ x: px, y: py });
                }

                // Connect to center and neighbors
                for (var p = 0; p < 6; ++p) {
                    ctx.beginPath();
                    ctx.moveTo(cx, cy);
                    ctx.lineTo(pts[p].x, pts[p].y);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.moveTo(pts[p].x, pts[p].y);
                    ctx.lineTo(pts[(p + 1) % 6].x, pts[(p + 1) % 6].y);
                    ctx.stroke();
                }

                // Draw glowing node dots
                ctx.fillStyle = c2;
                for (var d = 0; d < 6; ++d) {
                    ctx.beginPath();
                    ctx.arc(pts[d].x, pts[d].y, 2.8, 0, Math.PI * 2);
                    ctx.fill();
                }

                // Center AI Core
                ctx.fillStyle = "#FFFFFF";
                ctx.beginPath();
                ctx.arc(cx, cy, 3.8, 0, Math.PI * 2);
                ctx.fill();
            }
            // 8. CODE STUDIO / EDITOR (< / >)
            else if (id === "code" || id === "editor") {
                ctx.strokeStyle = c1;
                ctx.lineWidth = 2.2;
                ctx.lineCap = "round";

                // Left Bracket <
                ctx.beginPath();
                ctx.moveTo(w * 0.32, h * 0.30);
                ctx.lineTo(w * 0.16, h * 0.50);
                ctx.lineTo(w * 0.32, h * 0.70);
                ctx.stroke();

                // Slash /
                ctx.strokeStyle = c2;
                ctx.beginPath();
                ctx.moveTo(w * 0.60, h * 0.24);
                ctx.lineTo(w * 0.40, h * 0.76);
                ctx.stroke();

                // Right Bracket >
                ctx.strokeStyle = c1;
                ctx.beginPath();
                ctx.moveTo(w * 0.68, h * 0.30);
                ctx.lineTo(w * 0.84, h * 0.50);
                ctx.lineTo(w * 0.68, h * 0.70);
                ctx.stroke();
            }
            // 9. VS CODE (Infinity Quantum Ribbon)
            else if (id === "vscode") {
                ctx.strokeStyle = "#3B82F6";
                ctx.lineWidth = 2.4;
                ctx.beginPath();
                ctx.moveTo(w * 0.22, h * 0.44);
                ctx.bezierCurveTo(w * 0.10, h * 0.20, w * 0.45, h * 0.20, cx, cy);
                ctx.bezierCurveTo(w * 0.55, h * 0.80, w * 0.90, h * 0.80, w * 0.78, h * 0.56);
                ctx.bezierCurveTo(w * 0.65, h * 0.30, w * 0.35, h * 0.70, cx, cy);
                ctx.stroke();

                ctx.fillStyle = "#00E5FF";
                ctx.beginPath();
                ctx.arc(cx, cy, 3, 0, Math.PI * 2);
                ctx.fill();
            }
            // 10. ANTIGRAVITY IDE (Quantum Singularity Ring)
            else if (id === "antigravity") {
                // Outer ring
                ctx.strokeStyle = "#8B5CF6";
                ctx.lineWidth = 2.0;
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.38, 0, Math.PI * 2);
                ctx.stroke();

                // Vertical levitation beam
                var bGrad = ctx.createLinearGradient(cx, 0, cx, h);
                bGrad.addColorStop(0, "#00E5FF");
                bGrad.addColorStop(0.5, "#EC4899");
                bGrad.addColorStop(1, "#8B5CF6");
                ctx.strokeStyle = bGrad;
                ctx.lineWidth = 3.0;
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.18);
                ctx.lineTo(cx, h * 0.82);
                ctx.stroke();

                // Glowing core
                ctx.fillStyle = "#FFFFFF";
                ctx.beginPath();
                ctx.arc(cx, cy, 3.5, 0, Math.PI * 2);
                ctx.fill();
            }
            // 11. ANDROID STUDIO (Neon Android Helm)
            else if (id === "android_studio") {
                ctx.strokeStyle = "#00F5A0";
                ctx.lineWidth = 2.0;

                // Dome head
                ctx.beginPath();
                ctx.arc(cx, cy + 4, w * 0.32, Math.PI, 0);
                ctx.closePath();
                ctx.stroke();

                // Antennae
                ctx.beginPath();
                ctx.moveTo(cx - 6, cy - w * 0.32 + 4);
                ctx.lineTo(cx - 12, cy - w * 0.32 - 4);
                ctx.moveTo(cx + 6, cy - w * 0.32 + 4);
                ctx.lineTo(cx + 12, cy - w * 0.32 - 4);
                ctx.stroke();

                // Eyes
                ctx.fillStyle = "#00F5A0";
                ctx.beginPath();
                ctx.arc(cx - 5, cy - 2, 2, 0, Math.PI * 2);
                ctx.arc(cx + 5, cy - 2, 2, 0, Math.PI * 2);
                ctx.fill();
            }
            // 12. CHATGPT (Cyber Spiral Sacred Geometry)
            else if (id === "chatgpt") {
                ctx.strokeStyle = "#00F5A0";
                ctx.lineWidth = 2.0;

                for (var r = 0; r < 6; ++r) {
                    ctx.save();
                    ctx.translate(cx, cy);
                    ctx.rotate(r * (Math.PI / 3));
                    ctx.beginPath();
                    ctx.arc(w * 0.15, 0, w * 0.22, 0, Math.PI * 1.3);
                    ctx.stroke();
                    ctx.restore();
                }

                ctx.fillStyle = "#00E5FF";
                ctx.beginPath();
                ctx.arc(cx, cy, 2.5, 0, Math.PI * 2);
                ctx.fill();
            }
            // 13. GOOGLE GEMINI (4-Point Radiant Diamond Star)
            else if (id === "gemini") {
                var sGrad = ctx.createRadialGradient(cx, cy, 1, cx, cy, w * 0.45);
                sGrad.addColorStop(0, "#FFFFFF");
                sGrad.addColorStop(0.35, "#00E5FF");
                sGrad.addColorStop(0.85, "#8B5CF6");
                sGrad.addColorStop(1, "transparent");
                ctx.fillStyle = sGrad;

                // 4-Point Diamond Sparkle Star
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.08); // Top
                ctx.quadraticCurveTo(cx + 3, cy - 3, w * 0.92, cy); // Right
                ctx.quadraticCurveTo(cx + 3, cy + 3, cx, h * 0.92); // Bottom
                ctx.quadraticCurveTo(cx - 3, cy + 3, w * 0.08, cy); // Left
                ctx.quadraticCurveTo(cx - 3, cy - 3, cx, h * 0.08);
                ctx.closePath();
                ctx.fill();

                ctx.fillStyle = "#FFFFFF";
                ctx.beginPath();
                ctx.arc(cx, cy, 3, 0, Math.PI * 2);
                ctx.fill();
            }
            // 14. ANTHROPIC CLAUDE (Solar Geometric Starburst)
            else if (id === "claude") {
                ctx.strokeStyle = "#FFB800";
                ctx.lineWidth = 2.0;

                // 8-Ray Petal Array
                for (var a = 0; a < 8; ++a) {
                    ctx.save();
                    ctx.translate(cx, cy);
                    ctx.rotate(a * (Math.PI / 4));
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(w * 0.38, 0);
                    ctx.stroke();
                    ctx.restore();
                }

                // Inner radiant circle
                ctx.fillStyle = "#FF7700";
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.18, 0, Math.PI * 2);
                ctx.fill();

                ctx.fillStyle = "#FFFFFF";
                ctx.beginPath();
                ctx.arc(cx, cy, 3, 0, Math.PI * 2);
                ctx.fill();
            }
            // 15. OPENAI CODEX (Neural Circuit Lightning)
            else if (id === "codex") {
                // Lightning Bolt
                ctx.fillStyle = "#00E5FF";
                ctx.beginPath();
                ctx.moveTo(cx + 2, h * 0.15);
                ctx.lineTo(cx - 8, h * 0.50);
                ctx.lineTo(cx + 1, h * 0.50);
                ctx.lineTo(cx - 4, h * 0.85);
                ctx.lineTo(cx + 9, h * 0.45);
                ctx.lineTo(cx, h * 0.45);
                ctx.closePath();
                ctx.fill();

                // Outer quantum box
                ctx.strokeStyle = "#8B5CF6";
                ctx.lineWidth = 1.4;
                ctx.strokeRect(w * 0.14, h * 0.14, w * 0.72, h * 0.72);
            }
            // 16. CALCULATOR (Quantum Arithmetic Matrix)
            else if (id === "calculator") {
                ctx.strokeStyle = c1;
                ctx.lineWidth = 1.8;
                roundRect(ctx, 3, 3, w - 6, h - 6, 4);
                ctx.stroke();

                // LCD screen bar
                ctx.fillStyle = Qt.rgba(0/255, 229/255, 255/255, 0.25);
                ctx.fillRect(w * 0.18, h * 0.16, w * 0.64, h * 0.18);

                // Math symbols
                ctx.fillStyle = c1;
                ctx.font = "bold 9px sans-serif";
                ctx.fillText("+", w * 0.24, h * 0.55);
                ctx.fillText("−", w * 0.62, h * 0.55);
                ctx.fillText("×", w * 0.24, h * 0.82);
                ctx.fillText("=", w * 0.62, h * 0.82);
            }
            // 17. SETTINGS (Concentric Gyroscopic Cyber-Reactor)
            else if (id === "settings") {
                ctx.strokeStyle = c1;
                ctx.lineWidth = 2.0;

                // Outer Gear Teeth (6 points)
                for (var g = 0; g < 6; ++g) {
                    ctx.save();
                    ctx.translate(cx, cy);
                    ctx.rotate(g * (Math.PI / 3));
                    ctx.fillStyle = c1;
                    ctx.fillRect(w * 0.35, -2, 5, 4);
                    ctx.restore();
                }

                // Main ring
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.35, 0, Math.PI * 2);
                ctx.stroke();

                // Inner core
                ctx.fillStyle = c2;
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.16, 0, Math.PI * 2);
                ctx.fill();

                ctx.fillStyle = "#FFFFFF";
                ctx.beginPath();
                ctx.arc(cx, cy, 3, 0, Math.PI * 2);
                ctx.fill();
            }
            // 18. ASSISTANT / AI CORE
            else if (id === "assistant" || id === "ai_core") {
                ctx.strokeStyle = "#00E5FF";
                ctx.lineWidth = 1.8;
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.40, 0, Math.PI * 2);
                ctx.stroke();

                ctx.strokeStyle = "#8B5CF6";
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.26, 0, Math.PI * 2);
                ctx.stroke();

                ctx.fillStyle = "#00E5FF";
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.14, 0, Math.PI * 2);
                ctx.fill();
            }
            // 19. HOME / DESKTOP SPACE
            else if (id === "home") {
                ctx.strokeStyle = "#00E5FF";
                ctx.lineWidth = 2.2;
                ctx.lineCap = "round";

                ctx.beginPath();
                ctx.moveTo(w * 0.18, h * 0.48);
                ctx.lineTo(cx, h * 0.18);
                ctx.lineTo(w * 0.82, h * 0.48);
                ctx.moveTo(w * 0.26, h * 0.44);
                ctx.lineTo(w * 0.26, h * 0.80);
                ctx.lineTo(w * 0.74, h * 0.80);
                ctx.lineTo(w * 0.74, h * 0.44);
                ctx.stroke();

                ctx.fillStyle = "#8B5CF6";
                ctx.fillRect(cx - 3, h * 0.60, 6, h * 0.20);
            }
            // 20. 9-DOT LAUNCHER MATRIX
            else if (id === "launcher") {
                ctx.fillStyle = "#00E5FF";
                var spacing = w * 0.28;
                for (var row = -1; row <= 1; ++row) {
                    for (var col = -1; col <= 1; ++col) {
                        ctx.beginPath();
                        ctx.arc(cx + col * spacing, cy + row * spacing, 2.5, 0, Math.PI * 2);
                        ctx.fill();
                    }
                }
            }
            // 21. ROBOTICS & CYBERNETIC CO-PILOT
            else if (id === "robotics" || id === "robot") {
                ctx.strokeStyle = "#00E5FF";
                ctx.lineWidth = 2.0;
                ctx.lineCap = "round";

                // Head chassis
                roundRect(ctx, w * 0.22, h * 0.26, w * 0.56, h * 0.50, 6);
                ctx.stroke();

                // Antenna
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.26);
                ctx.lineTo(cx, h * 0.14);
                ctx.stroke();

                ctx.fillStyle = "#8B5CF6";
                ctx.beginPath();
                ctx.arc(cx, h * 0.13, 2.5, 0, Math.PI * 2);
                ctx.fill();

                // Cyber Visor / Dual Optic Sensors
                ctx.fillStyle = "#00E5FF";
                ctx.beginPath();
                ctx.arc(w * 0.38, h * 0.46, 3, 0, Math.PI * 2);
                ctx.arc(w * 0.62, h * 0.46, 3, 0, Math.PI * 2);
                ctx.fill();

                // Sensor scanline / mouth grill
                ctx.strokeStyle = "#8B5CF6";
                ctx.beginPath();
                ctx.moveTo(w * 0.35, h * 0.64);
                ctx.lineTo(w * 0.65, h * 0.64);
                ctx.stroke();
            }
            // 22. DRIVE / SSD / DISK (Quantum High-Speed Solid-State Drive)
            else if (id === "drive" || id === "ssd" || id === "disk") {
                ctx.strokeStyle = "#00F5A0";
                ctx.lineWidth = 2.0;
                roundRect(ctx, w * 0.16, h * 0.24, w * 0.68, h * 0.52, 4);
                ctx.stroke();

                // Activity LED
                ctx.fillStyle = "#00E5FF";
                ctx.beginPath();
                ctx.arc(w * 0.28, h * 0.38, 2.5, 0, Math.PI * 2);
                ctx.fill();

                // Read/Write Pulse Wave
                ctx.strokeStyle = "#00F5A0";
                ctx.lineWidth = 1.6;
                ctx.beginPath();
                ctx.moveTo(w * 0.38, h * 0.50);
                ctx.lineTo(w * 0.48, h * 0.50);
                ctx.lineTo(w * 0.54, h * 0.38);
                ctx.lineTo(w * 0.60, h * 0.62);
                ctx.lineTo(w * 0.66, h * 0.50);
                ctx.lineTo(w * 0.74, h * 0.50);
                ctx.stroke();

                // Connector Contacts
                ctx.fillStyle = "#8B5CF6";
                ctx.fillRect(w * 0.30, h * 0.76, w * 0.40, 2);
            }
            // 23. COMPUTER / SYSTEM (Futuristic Terminal Monitor)
            else if (id === "computer" || id === "system") {
                ctx.strokeStyle = "#00E5FF";
                ctx.lineWidth = 2.0;
                // Bezel
                roundRect(ctx, w * 0.16, h * 0.18, w * 0.68, h * 0.50, 4);
                ctx.stroke();

                // Screen display
                ctx.fillStyle = Qt.rgba(0/255, 229/255, 255/255, 0.2);
                ctx.fillRect(w * 0.22, h * 0.24, w * 0.56, h * 0.38);

                // Stand neck and base
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.68);
                ctx.lineTo(cx, h * 0.80);
                ctx.moveTo(w * 0.32, h * 0.80);
                ctx.lineTo(w * 0.68, h * 0.80);
                ctx.stroke();
            }
            // 24. TRASH (Cyber Incinerator / Quantum Recycler)
            else if (id === "trash") {
                ctx.strokeStyle = "#FF3B5C";
                ctx.lineWidth = 2.0;
                // Lid
                ctx.beginPath();
                ctx.moveTo(w * 0.22, h * 0.28);
                ctx.lineTo(w * 0.78, h * 0.28);
                ctx.moveTo(w * 0.42, h * 0.22);
                ctx.lineTo(w * 0.58, h * 0.22);
                ctx.stroke();

                // Body
                ctx.beginPath();
                ctx.moveTo(w * 0.28, h * 0.32);
                ctx.lineTo(w * 0.32, h * 0.78);
                ctx.lineTo(w * 0.68, h * 0.78);
                ctx.lineTo(w * 0.72, h * 0.32);
                ctx.closePath();
                ctx.stroke();

                // Internal shredder laser beam
                ctx.strokeStyle = "#FF7700";
                ctx.lineWidth = 1.4;
                ctx.beginPath();
                ctx.moveTo(w * 0.42, h * 0.40);
                ctx.lineTo(w * 0.42, h * 0.70);
                ctx.moveTo(w * 0.50, h * 0.40);
                ctx.lineTo(w * 0.50, h * 0.70);
                ctx.moveTo(w * 0.58, h * 0.40);
                ctx.lineTo(w * 0.58, h * 0.70);
                ctx.stroke();
            }
            // 25. DOWNLOADS (Gravitational Data Influx)
            else if (id === "downloads") {
                ctx.strokeStyle = "#00E5FF";
                ctx.lineWidth = 2.2;
                ctx.lineCap = "round";

                // Down Arrow
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.20);
                ctx.lineTo(cx, h * 0.58);
                ctx.moveTo(cx - 7, h * 0.44);
                ctx.lineTo(cx, h * 0.58);
                ctx.lineTo(cx + 7, h * 0.44);
                ctx.stroke();

                // Intake Tray
                ctx.strokeStyle = "#8B5CF6";
                ctx.beginPath();
                ctx.moveTo(w * 0.24, h * 0.66);
                ctx.lineTo(w * 0.24, h * 0.80);
                ctx.lineTo(w * 0.76, h * 0.80);
                ctx.lineTo(w * 0.76, h * 0.66);
                ctx.stroke();
            }
            // 26. MUSIC (Harmonic Audio Resonator)
            else if (id === "music") {
                ctx.strokeStyle = "#8B5CF6";
                ctx.fillStyle = "#8B5CF6";
                ctx.lineWidth = 2.0;

                // Two Notes
                ctx.beginPath();
                ctx.arc(w * 0.34, h * 0.70, 4, 0, Math.PI * 2);
                ctx.arc(w * 0.66, h * 0.60, 4, 0, Math.PI * 2);
                ctx.fill();

                // Stems and Beam
                ctx.beginPath();
                ctx.moveTo(w * 0.38, h * 0.70);
                ctx.lineTo(w * 0.38, h * 0.26);
                ctx.lineTo(w * 0.70, h * 0.18);
                ctx.lineTo(w * 0.70, h * 0.60);
                ctx.stroke();
            }
            // 27. PICTURES (Holographic Projection Frame)
            else if (id === "pictures") {
                ctx.strokeStyle = "#00F5A0";
                ctx.lineWidth = 2.0;
                roundRect(ctx, w * 0.18, h * 0.22, w * 0.64, h * 0.56, 4);
                ctx.stroke();

                // Sun
                ctx.fillStyle = "#00E5FF";
                ctx.beginPath();
                ctx.arc(w * 0.34, h * 0.38, 3, 0, Math.PI * 2);
                ctx.fill();

                // Cyber Mountain peaks
                ctx.beginPath();
                ctx.moveTo(w * 0.24, h * 0.68);
                ctx.lineTo(w * 0.44, h * 0.46);
                ctx.lineTo(w * 0.58, h * 0.60);
                ctx.lineTo(w * 0.68, h * 0.50);
                ctx.lineTo(w * 0.76, h * 0.68);
                ctx.stroke();
            }
            // 28. VIDEOS (Holographic Play Slate)
            else if (id === "videos") {
                ctx.strokeStyle = "#FF7700";
                ctx.lineWidth = 2.0;
                roundRect(ctx, w * 0.18, h * 0.24, w * 0.64, h * 0.52, 4);
                ctx.stroke();

                // Play Triangle
                ctx.fillStyle = "#FF7700";
                ctx.beginPath();
                ctx.moveTo(w * 0.42, h * 0.38);
                ctx.lineTo(w * 0.64, h * 0.50);
                ctx.lineTo(w * 0.42, h * 0.62);
                ctx.closePath();
                ctx.fill();
            }
            // DEFAULT FALLBACK (Glowing Quantum Singularity)
            else {
                ctx.strokeStyle = c1;
                ctx.lineWidth = 2.0;
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.35, 0, Math.PI * 2);
                ctx.stroke();

                ctx.fillStyle = c2;
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.16, 0, Math.PI * 2);
                ctx.fill();
            }

            ctx.restore();
        }

        function roundRect(ctx, x, y, width, height, radius) {
            ctx.beginPath();
            ctx.moveTo(x + radius, y);
            ctx.lineTo(x + width - radius, y);
            ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
            ctx.lineTo(x + width, y + height - radius);
            ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
            ctx.lineTo(x + radius, y + height);
            ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
            ctx.lineTo(x, y + radius);
            ctx.quadraticCurveTo(x, y, x + radius, y);
            ctx.closePath();
        }
    }
}
