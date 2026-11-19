import QtQuick

pragma Singleton

QtObject {
    // Backgrounds
    readonly property color backgroundVoid: "#070A0F"
    readonly property color backgroundSurface: "#0D111A"
    readonly property color backgroundElevated: "#131A28"
    readonly property color backgroundHover: "#1B2438"
    readonly property color backgroundInput: "#0A0E17"
    readonly property color backgroundGlass: Qt.rgba(13/255, 17/255, 26/255, 0.78)
    readonly property color backgroundGlassElevated: Qt.rgba(19/255, 26/255, 40/255, 0.88)

    // Borders & Dividers
    readonly property color borderSubtle: "#172033"
    readonly property color borderAccent: "#00E5FF"
    readonly property color borderFocused: "#3B82F6"
    readonly property color borderGlowViolet: "#8B5CF6"

    // Accents & Signals
    readonly property color accentCyan: "#00E5FF"
    readonly property color accentBlue: "#2563EB"
    readonly property color accentViolet: "#8B5CF6"
    readonly property color accentNeonPink: "#EC4899"
    readonly property color accentEmerald: "#00F5A0"
    readonly property color accentAmber: "#FFB800"
    readonly property color accentCrimson: "#FF3B5C"

    // Typography Colors
    readonly property color textPrimary: "#F0F4FC"
    readonly property color textSecondary: "#8E9EB5"
    readonly property color textTertiary: "#506078"
    readonly property color textCode: "#00E5FF"

    // Metrics
    readonly property int radiusSmall: 6
    readonly property int radiusMedium: 10
    readonly property int radiusLarge: 14
    readonly property int radiusDock: 22
    readonly property int radiusPill: 999

    // Typography
    readonly property string fontUI: "Ubuntu, Inter, sans-serif"
    readonly property string fontMono: "JetBrains Mono, Fira Code, monospace"

    // Animations
    readonly property int animFast: 150
    readonly property int animNormal: 250
    readonly property int animSlow: 400
}
