import QtQuick
import "../theme"

Item {
    id: root

    property real originX: 0
    property real originY: 0
    property real targetX: 0
    property real targetY: 0
    property real targetWidth: 400
    property real targetHeight: 300
    property color accentColor: SRITECTheme.accentCyan
    property bool active: false
    property string performanceMode: "ultra" // "ultra", "high", "balanced", "low", "reduced_motion"

    anchors.fill: parent

    // 1. Particle Burst Engine
    Canvas {
        id: particleCanvas
        anchors.fill: parent
        visible: root.performanceMode !== "reduced_motion" && root.performanceMode !== "low"
        property var particles: []
        property real progress: 0.0

        NumberAnimation on progress {
            id: burstAnim
            from: 0.0
            to: 1.0
            duration: 550
            running: false
            easing.type: Easing.OutQuad
            onFinished: {
                particleCanvas.particles = [];
                particleCanvas.requestPaint();
            }
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            if (particles.length === 0 || progress >= 1.0) return;

            var alpha = (1.0 - progress);
            for (var i = 0; i < particles.length; ++i) {
                var p = particles[i];
                var dist = p.speed * progress;
                var px = p.startX + Math.cos(p.angle) * dist;
                var py = p.startY + Math.sin(p.angle) * dist;

                ctx.fillStyle = p.color;
                ctx.globalAlpha = alpha * p.initialAlpha;
                ctx.beginPath();
                ctx.arc(px, py, p.size * (1.0 - progress * 0.4), 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.globalAlpha = 1.0;
        }

        Connections {
            target: particleCanvas
            function onProgressChanged() { particleCanvas.requestPaint(); }
        }
    }

    // 2. Holographic Energy Beam connecting Origin to Expanding Panel
    Canvas {
        id: energyBeamCanvas
        anchors.fill: parent
        visible: root.active && root.performanceMode !== "reduced_motion"
        property real beamAlpha: 0.0

        NumberAnimation on beamAlpha {
            id: beamAnim
            from: 0.8
            to: 0.0
            duration: 600
            running: false
            easing.type: Easing.InOutQuad
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            if (beamAlpha <= 0.01) return;

            var ox = root.originX;
            var oy = root.originY;
            var tx = root.targetX + root.targetWidth * 0.5;
            var ty = root.targetY + root.targetHeight * 0.5;

            // Gradient line
            var grad = ctx.createLinearGradient(ox, oy, tx, ty);
            grad.addColorStop(0.0, root.accentColor);
            grad.addColorStop(0.5, "#8B5CF6");
            grad.addColorStop(1.0, "transparent");

            ctx.lineWidth = 2.5;
            ctx.strokeStyle = grad;
            ctx.globalAlpha = beamAlpha;

            ctx.beginPath();
            ctx.moveTo(ox, oy);
            // Slight cybernetic bezier curve
            var cpX = (ox + tx) * 0.5 + 40;
            var cpY = (oy + ty) * 0.5 - 30;
            ctx.quadraticCurveTo(cpX, cpY, tx, ty);
            ctx.stroke();

            // Origin flare node
            ctx.fillStyle = root.accentColor;
            ctx.beginPath();
            ctx.arc(ox, oy, 6 * beamAlpha, 0, Math.PI * 2);
            ctx.fill();

            ctx.globalAlpha = 1.0;
        }

        Connections {
            target: energyBeamCanvas
            function onBeamAlphaChanged() { energyBeamCanvas.requestPaint(); }
        }
    }

    function triggerBurst(startX, startY, count) {
        if (root.performanceMode === "reduced_motion" || root.performanceMode === "low") return;

        var num = count || (root.performanceMode === "ultra" ? 28 : (root.performanceMode === "high" ? 20 : 12));
        var list = [];
        var palette = [root.accentColor, "#8B5CF6", "#00F5A0", "#EC4899", "#FFFFFF"];

        for (var i = 0; i < num; ++i) {
            list.push({
                startX: startX,
                startY: startY,
                angle: (Math.PI * 2 * i / num) + (Math.random() * 0.4 - 0.2),
                speed: 60 + Math.random() * 140,
                size: 2.0 + Math.random() * 3.5,
                color: palette[Math.floor(Math.random() * palette.length)],
                initialAlpha: 0.6 + Math.random() * 0.4
            });
        }
        particleCanvas.particles = list;
        burstAnim.restart();
        beamAnim.restart();
    }
}
