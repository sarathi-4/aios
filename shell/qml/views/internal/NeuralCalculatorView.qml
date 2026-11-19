import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root

    color: SRITECTheme.backgroundSurface
    radius: SRITECTheme.radiusLarge
    clip: true

    property string expression: ""
    property string displayValue: "0"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Digital Display Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            radius: SRITECTheme.radiusMedium
            color: "#05080E"
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: root.expression
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 12
                    font.family: SRITECTheme.fontMono
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideLeft
                }

                Text {
                    Layout.fillWidth: true
                    text: root.displayValue
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 32
                    font.bold: true
                    font.family: SRITECTheme.fontMono
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideLeft
                }
            }
        }

        // Scientific Keys Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: ["sin", "cos", "tan", "√", "^", "π"]
                delegate: Rectangle {
                    id: sciKey
                    required property string modelData
                    property bool isHovered: sciMouse.containsMouse

                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 6
                    color: isHovered ? Qt.rgba(139/255, 92/255, 246/255, 0.25) : Qt.rgba(19/255, 26/255, 40/255, 0.6)
                    border.color: isHovered ? SRITECTheme.accentViolet : SRITECTheme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: sciKey.modelData
                        color: SRITECTheme.accentViolet
                        font.pixelSize: 11
                        font.bold: true
                        font.family: SRITECTheme.fontMono
                    }

                    MouseArea {
                        id: sciMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.handleSciKey(sciKey.modelData)
                    }
                }
            }
        }

        // Standard 4x5 Keypad
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            rowSpacing: 8
            columnSpacing: 8

            Repeater {
                model: [
                    "AC", "+/-", "%", "÷",
                    "7", "8", "9", "×",
                    "4", "5", "6", "-",
                    "1", "2", "3", "+",
                    "0", ".", "DEL", "="
                ]

                delegate: Rectangle {
                    id: numKey
                    required property string modelData
                    property bool isHovered: keyMouse.containsMouse
                    property bool isOperator: ["÷", "×", "-", "+", "="].indexOf(modelData) !== -1
                    property bool isClear: ["AC", "DEL"].indexOf(modelData) !== -1

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8

                    color: isHovered ? (isOperator ? SRITECTheme.accentCyan : (isClear ? SRITECTheme.accentCrimson : SRITECTheme.backgroundHover)) :
                                       (isOperator ? Qt.rgba(0/255, 229/255, 255/255, 0.18) :
                                       (isClear ? Qt.rgba(255/255, 59/255, 92/255, 0.15) : Qt.rgba(19/255, 26/255, 40/255, 0.6)))
                    border.color: isHovered ? (isOperator ? SRITECTheme.accentCyan : SRITECTheme.borderGlowViolet) : SRITECTheme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: numKey.modelData
                        color: numKey.isOperator ? SRITECTheme.accentCyan :
                               (numKey.isClear ? SRITECTheme.accentCrimson : SRITECTheme.textPrimary)
                        font.pixelSize: 15
                        font.bold: true
                        font.family: SRITECTheme.fontMono
                    }

                    MouseArea {
                        id: keyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.handleKey(numKey.modelData)
                    }
                }
            }
        }
    }

    function handleKey(k) {
        if (k === "AC") {
            root.expression = "";
            root.displayValue = "0";
        } else if (k === "DEL") {
            if (root.displayValue.length > 1) {
                root.displayValue = root.displayValue.slice(0, -1);
            } else {
                root.displayValue = "0";
            }
        } else if (k === "+/-") {
            if (root.displayValue !== "0") {
                if (root.displayValue.startsWith("-")) {
                    root.displayValue = root.displayValue.substring(1);
                } else {
                    root.displayValue = "-" + root.displayValue;
                }
            }
        } else if (k === "%") {
            var val = parseFloat(root.displayValue) / 100.0;
            root.displayValue = val.toString();
        } else if (["÷", "×", "-", "+"].indexOf(k) !== -1) {
            var op = (k === "÷") ? "/" : ((k === "×") ? "*" : k);
            root.expression = root.displayValue + " " + op + " ";
            root.displayValue = "0";
        } else if (k === "=") {
            if (root.expression.length > 0) {
                var full = root.expression + root.displayValue;
                var parts = root.expression.trim().split(" ");
                if (parts.length >= 2) {
                    var a = parseFloat(parts[0]);
                    var op = parts[1];
                    var b = parseFloat(root.displayValue);
                    var res = 0;
                    if (op === "+") res = a + b;
                    else if (op === "-") res = a - b;
                    else if (op === "*" || op === "×") res = a * b;
                    else if (op === "/" || op === "÷") res = (b !== 0) ? (a / b) : 0;
                    root.expression = full + " =";
                    root.displayValue = Number(res).toFixed(4).replace(/\.?0+$/, "");
                }
            }
        } else if (k === ".") {
            if (root.displayValue.indexOf(".") === -1) {
                root.displayValue += ".";
            }
        } else {
            // Digits 0-9
            if (root.displayValue === "0") {
                root.displayValue = k;
            } else {
                root.displayValue += k;
            }
        }
    }

    function handleSciKey(k) {
        var num = parseFloat(root.displayValue);
        if (k === "sin") {
            root.displayValue = Math.sin(num * Math.PI / 180.0).toFixed(6).replace(/\.?0+$/, "");
            root.expression = "sin(" + num + "°)";
        } else if (k === "cos") {
            root.displayValue = Math.cos(num * Math.PI / 180.0).toFixed(6).replace(/\.?0+$/, "");
            root.expression = "cos(" + num + "°)";
        } else if (k === "tan") {
            root.displayValue = Math.tan(num * Math.PI / 180.0).toFixed(6).replace(/\.?0+$/, "");
            root.expression = "tan(" + num + "°)";
        } else if (k === "√") {
            root.displayValue = Math.sqrt(num).toFixed(6).replace(/\.?0+$/, "");
            root.expression = "√(" + num + ")";
        } else if (k === "^") {
            root.expression = root.displayValue + " ** ";
            root.displayValue = "0";
        } else if (k === "π") {
            root.displayValue = Math.PI.toFixed(6);
        }
    }
}
