import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: "transparent"

    property bool showApiKeyPanel: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // 1. View Header & Global Mode Selector
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 3
                Text {
                    text: "CENTRAL NEURAL ASSISTANT"
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: 1.5
                }
                Text {
                    text: "Unified AI Provider Gateway • Multi-Model Operating System Intelligence"
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 12
                }
            }

            Item { Layout.fillWidth: true }

            // Mode Selector
            Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 220
                radius: SRITECTheme.radiusSmall
                color: SRITECTheme.backgroundSurface
                border.color: SRITECTheme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 2
                    spacing: 2

                    Repeater {
                        model: ["Chat", "Synthesis", "Safety"]
                        delegate: Rectangle {
                            id: tabItem
                            required property string modelData
                            required property int index
                            property bool isSelected: modeSelectorGroup.currentIndex === index

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: SRITECTheme.radiusSmall - 2
                            color: isSelected ? SRITECTheme.backgroundElevated : "transparent"
                            border.color: isSelected ? SRITECTheme.borderAccent : "transparent"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: tabItem.modelData
                                color: tabItem.isSelected ? SRITECTheme.textPrimary : SRITECTheme.textTertiary
                                font.pixelSize: 11
                                font.weight: tabItem.isSelected ? Font.DemiBold : Font.Normal
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modeSelectorGroup.currentIndex = tabItem.index
                            }
                        }
                    }
                }

                Item {
                    id: modeSelectorGroup
                    property int currentIndex: 0
                }
            }
        }

        // 2. Unified AI Gateway Control Bar
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: gatewayControlsColumn.implicitHeight + 20
            radius: SRITECTheme.radiusMedium
            color: SRITECTheme.backgroundSurface
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            ColumnLayout {
                id: gatewayControlsColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                // Row A: Provider Selection Pills
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "PROVIDER:"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.2
                        Layout.preferredWidth: 70
                    }

                    Repeater {
                        model: globalAIBridge.availableProviders

                        delegate: Rectangle {
                            id: provPill
                            required property string modelData
                            property bool isSelected: globalAIBridge.selectedProvider === modelData

                            Layout.preferredHeight: 30
                            implicitWidth: pillLabel.implicitWidth + 24
                            radius: SRITECTheme.radiusSmall
                            color: isSelected ? SRITECTheme.backgroundElevated : (provMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent")
                            border.color: isSelected ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                            border.width: 1

                            RowLayout {
                                id: pillLabel
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: provPill.modelData === "Mock" ? "⚡" :
                                          provPill.modelData === "Google Gemini" ? "✦" :
                                          provPill.modelData === "OpenAI" ? "✶" :
                                          provPill.modelData === "Anthropic Claude" ? "◈" : "🦙"
                                    color: provPill.isSelected ? SRITECTheme.accentCyan : SRITECTheme.textTertiary
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: provPill.modelData
                                    color: provPill.isSelected ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                    font.pixelSize: 11
                                    font.weight: provPill.isSelected ? Font.DemiBold : Font.Normal
                                }
                            }

                            MouseArea {
                                id: provMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    globalAIBridge.selectProvider(provPill.modelData);
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // History Clear Action
                    Rectangle {
                        Layout.preferredHeight: 28
                        implicitWidth: clearHistLabel.implicitWidth + 16
                        radius: SRITECTheme.radiusSmall
                        color: clearHistMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                        border.color: SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            id: clearHistLabel
                            anchors.centerIn: parent
                            spacing: 5
                            Text {
                                text: "↺"
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 11
                            }
                            Text {
                                text: "Reset History"
                                color: SRITECTheme.textSecondary
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            id: clearHistMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                globalAIBridge.clearHistory();
                                promptInput.text = "";
                            }
                        }
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: SRITECTheme.borderSubtle
                }

                // Row B: Model Selection Pills & Connection/Key Telemetry
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "MODEL:"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.2
                        Layout.preferredWidth: 70
                    }

                    Repeater {
                        model: globalAIBridge.availableModels

                        delegate: Rectangle {
                            id: modelPill
                            required property string modelData
                            property bool isCurrentModel: globalAIBridge.selectedModel === modelData

                            Layout.preferredHeight: 26
                            implicitWidth: modelLabel.implicitWidth + 20
                            radius: SRITECTheme.radiusSmall - 2
                            color: isCurrentModel ? SRITECTheme.backgroundElevated : (modelMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent")
                            border.color: isCurrentModel ? SRITECTheme.borderAccent : SRITECTheme.borderSubtle
                            border.width: 1

                            Text {
                                id: modelLabel
                                anchors.centerIn: parent
                                text: modelPill.modelData
                                color: modelPill.isCurrentModel ? SRITECTheme.accentCyan : SRITECTheme.textTertiary
                                font.pixelSize: 10
                                font.family: SRITECTheme.fontMono
                                font.weight: modelPill.isCurrentModel ? Font.DemiBold : Font.Normal
                            }

                            MouseArea {
                                id: modelMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: globalAIBridge.selectModel(modelPill.modelData)
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Connection State Indicator
                    Rectangle {
                        Layout.preferredHeight: 26
                        implicitWidth: connStateRow.implicitWidth + 16
                        radius: 13
                        color: SRITECTheme.backgroundElevated
                        border.color: globalAIBridge.connectionState === "Error" ? SRITECTheme.accentCrimson :
                                      globalAIBridge.connectionState === "Streaming" ? SRITECTheme.accentCyan :
                                      globalAIBridge.connectionState === "Connecting" ? SRITECTheme.accentAmber : SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            id: connStateRow
                            anchors.centerIn: parent
                            spacing: 6

                            Rectangle {
                                Layout.preferredWidth: 6
                                Layout.preferredHeight: 6
                                radius: 3
                                color: globalAIBridge.connectionState === "Error" ? SRITECTheme.accentCrimson :
                                       globalAIBridge.connectionState === "Streaming" ? SRITECTheme.accentCyan :
                                       globalAIBridge.connectionState === "Connecting" ? SRITECTheme.accentAmber : SRITECTheme.accentEmerald

                                SequentialAnimation on opacity {
                                    running: globalAIBridge.connectionState === "Streaming" || globalAIBridge.connectionState === "Connecting"
                                    loops: Animation.Infinite
                                    PropertyAnimation { to: 0.2; duration: 400 }
                                    PropertyAnimation { to: 1.0; duration: 400 }
                                }
                            }

                            Text {
                                text: globalAIBridge.connectionState
                                color: globalAIBridge.connectionState === "Error" ? SRITECTheme.accentCrimson :
                                       globalAIBridge.connectionState === "Streaming" ? SRITECTheme.accentCyan :
                                       globalAIBridge.connectionState === "Connecting" ? SRITECTheme.accentAmber : SRITECTheme.textSecondary
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    // Key Status & Configuration Button
                    Rectangle {
                        visible: globalAIBridge.selectedProvider !== "Mock" && globalAIBridge.selectedProvider !== "Local AI (Ollama)"
                        Layout.preferredHeight: 26
                        implicitWidth: keyBtnRow.implicitWidth + 16
                        radius: SRITECTheme.radiusSmall - 2
                        color: root.showApiKeyPanel ? SRITECTheme.backgroundElevated : (keyBtnMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent")
                        border.color: !globalAIBridge.hasApiKey ? SRITECTheme.accentAmber : (root.showApiKeyPanel ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle)
                        border.width: 1

                        RowLayout {
                            id: keyBtnRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: globalAIBridge.hasApiKey ? "●" : "⚠"
                                color: globalAIBridge.hasApiKey ? SRITECTheme.accentEmerald : SRITECTheme.accentAmber
                                font.pixelSize: 10
                            }

                            Text {
                                text: globalAIBridge.hasApiKey ? "Key Active" : "Key Needed"
                                color: globalAIBridge.hasApiKey ? SRITECTheme.textSecondary : SRITECTheme.accentAmber
                                font.pixelSize: 10
                                font.bold: !globalAIBridge.hasApiKey
                            }

                            Text {
                                text: "⚙"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            id: keyBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showApiKeyPanel = !root.showApiKeyPanel
                        }
                    }
                }
            }
        }

        // 3. API Key Secure Entry Drawer (Write-Only, Zero Exposure to QML)
        Rectangle {
            id: keyConfigDrawer
            visible: root.showApiKeyPanel
            Layout.fillWidth: true
            implicitHeight: keyDrawerCol.implicitHeight + 20
            radius: SRITECTheme.radiusMedium
            color: SRITECTheme.backgroundElevated
            border.color: SRITECTheme.accentCyan
            border.width: 1

            ColumnLayout {
                id: keyDrawerCol
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "🔐 SECURE API KEY STORAGE — " + globalAIBridge.selectedProvider.toUpperCase()
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "✕ Close"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 11
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showApiKeyPanel = false
                        }
                    }
                }

                Text {
                    text: "Security Architecture: Key is write-only and held exclusively in backend C++ memory. Never read back to QML, never committed to git. Environment variables (GEMINI_API_KEY, OPENAI_API_KEY, ANTHROPIC_API_KEY) are also auto-detected."
                    color: SRITECTheme.textSecondary
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: SRITECTheme.radiusSmall
                        color: SRITECTheme.backgroundSurface
                        border.color: SRITECTheme.borderSubtle
                        border.width: 1

                        TextField {
                            id: apiKeyInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            echoMode: TextInput.Password
                            placeholderText: "Paste " + globalAIBridge.selectedProvider + " API key here (write-only)..."
                            placeholderTextColor: SRITECTheme.textTertiary
                            color: SRITECTheme.textPrimary
                            font.pixelSize: 12
                            font.family: SRITECTheme.fontMono
                            background: null
                            onAccepted: saveKeyBtn.performSave()
                        }
                    }

                    Rectangle {
                        id: saveKeyBtn
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 34
                        radius: SRITECTheme.radiusSmall
                        color: SRITECTheme.accentCyan

                        Text {
                            anchors.centerIn: parent
                            text: "Save Key"
                            color: SRITECTheme.backgroundVoid
                            font.pixelSize: 11
                            font.bold: true
                        }

                        function performSave() {
                            if (apiKeyInput.text.trim().length > 0) {
                                globalAIBridge.setApiKey(globalAIBridge.selectedProvider, apiKeyInput.text.trim());
                                apiKeyInput.text = "";
                                root.showApiKeyPanel = false;
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: saveKeyBtn.performSave()
                        }
                    }
                }
            }
        }

        // 4. Quick Suggestion Chips
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: [
                    "Hello SRITEC",
                    "System Diagnostics",
                    "Generate C++ Module",
                    "Analyze Terminal Safety"
                ]

                delegate: Rectangle {
                    id: chip
                    required property string modelData
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: chipText.implicitWidth + 24
                    radius: 14
                    color: chipMouse.containsMouse ? SRITECTheme.backgroundElevated : SRITECTheme.backgroundSurface
                    border.color: chipMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: SRITECTheme.animFast } }
                    Behavior on border.color { ColorAnimation { duration: SRITECTheme.animFast } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "✦"
                            color: SRITECTheme.accentCyan
                            font.pixelSize: 9
                        }
                        Text {
                            id: chipText
                            text: chip.modelData
                            color: SRITECTheme.textSecondary
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        id: chipMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            promptInput.text = chip.modelData;
                            globalAIBridge.sendQuery(chip.modelData);
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }

        // 5. Conversation / Response Stream Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: SRITECTheme.radiusMedium
            color: SRITECTheme.backgroundSurface
            border.color: SRITECTheme.borderSubtle
            border.width: 1
            clip: true

            ScrollView {
                id: responseScrollView
                anchors.fill: parent
                anchors.margins: 20

                ColumnLayout {
                    width: responseScrollView.width - 24
                    spacing: 16

                    // Standby Welcome Card when stream is empty
                    Rectangle {
                        visible: globalAIBridge.currentResponse.length === 0 && !globalAIBridge.isGenerating
                        Layout.fillWidth: true
                        Layout.preferredHeight: 170
                        radius: SRITECTheme.radiusSmall
                        color: SRITECTheme.backgroundElevated
                        border.color: SRITECTheme.borderSubtle
                        border.width: 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                text: "◈  NEURAL GATEWAY STANDBY"
                                color: SRITECTheme.accentCyan
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 2
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "Active Provider: " + globalAIBridge.selectedProvider + "  |  Model: " + globalAIBridge.selectedModel + "\n" +
                                      (globalAIBridge.selectedProvider === "Mock" ?
                                          "Streaming simulated locally via C++20 worker thread. No network connection required." :
                                          (globalAIBridge.hasApiKey ?
                                              "Provider ready. Multi-turn conversation context is active." :
                                              "API key required for this cloud provider. Click 'Key Needed' above to configure."))
                                color: SRITECTheme.textTertiary
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                                lineHeight: 1.4
                            }
                        }
                    }

                    // Error Alert Card (Visible on Gateway Error)
                    Rectangle {
                        visible: globalAIBridge.connectionState === "Error"
                        Layout.fillWidth: true
                        implicitHeight: errorCol.implicitHeight + 24
                        radius: SRITECTheme.radiusSmall
                        color: SRITECTheme.backgroundElevated
                        border.color: SRITECTheme.accentCrimson
                        border.width: 1

                        ColumnLayout {
                            id: errorCol
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 8

                            RowLayout {
                                spacing: 8
                                Text {
                                    text: "⚠ GATEWAY COMMUNICATION ALERT"
                                    color: SRITECTheme.accentCrimson
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: globalAIBridge.statusMessage
                                    color: SRITECTheme.textTertiary
                                    font.pixelSize: 10
                                    font.family: SRITECTheme.fontMono
                                }
                            }

                            RowLayout {
                                spacing: 10
                                Rectangle {
                                    Layout.preferredHeight: 26
                                    implicitWidth: retryTxt.implicitWidth + 20
                                    radius: SRITECTheme.radiusSmall - 2
                                    color: SRITECTheme.accentCrimson
                                    Text {
                                        id: retryTxt
                                        anchors.centerIn: parent
                                        text: "Retry Request"
                                        color: SRITECTheme.textPrimary
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: globalAIBridge.retry()
                                    }
                                }

                                Rectangle {
                                    Layout.preferredHeight: 26
                                    implicitWidth: mockTxt.implicitWidth + 20
                                    radius: SRITECTheme.radiusSmall - 2
                                    color: SRITECTheme.backgroundSurface
                                    border.color: SRITECTheme.borderSubtle
                                    border.width: 1
                                    Text {
                                        id: mockTxt
                                        anchors.centerIn: parent
                                        text: "Switch to Offline Mock"
                                        color: SRITECTheme.accentCyan
                                        font.pixelSize: 10
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: globalAIBridge.selectProvider("Mock")
                                    }
                                }
                            }
                        }
                    }

                    // Active Response Card
                    Rectangle {
                        visible: globalAIBridge.currentResponse.length > 0 || globalAIBridge.isGenerating
                        Layout.fillWidth: true
                        implicitHeight: contentColumn.implicitHeight + 28
                        radius: SRITECTheme.radiusSmall
                        color: SRITECTheme.backgroundElevated
                        border.color: globalAIBridge.isGenerating ? SRITECTheme.borderAccent : SRITECTheme.borderSubtle
                        border.width: 1

                        ColumnLayout {
                            id: contentColumn
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "NEURAL SYNTHESIS — [" + globalAIBridge.selectedProvider.toUpperCase() + " : " + globalAIBridge.selectedModel + "]"
                                    color: SRITECTheme.accentCyan
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1.5
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: globalAIBridge.tokenCount + " tokens generated"
                                    color: SRITECTheme.textTertiary
                                    font.pixelSize: 10
                                    font.family: SRITECTheme.fontMono
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: SRITECTheme.borderSubtle
                            }

                            TextEdit {
                                Layout.fillWidth: true
                                text: globalAIBridge.currentResponse
                                color: SRITECTheme.textPrimary
                                font.pixelSize: 13
                                font.family: SRITECTheme.fontMono
                                wrapMode: TextEdit.Wrap
                                readOnly: true
                                selectByMouse: true
                            }
                        }
                    }
                }
            }
        }

        // 6. Directive / Prompt Input Area
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            radius: SRITECTheme.radiusMedium
            color: SRITECTheme.backgroundSurface
            border.color: promptInput.activeFocus ? SRITECTheme.borderAccent : SRITECTheme.borderSubtle
            border.width: 1

            Behavior on border.color { ColorAnimation { duration: SRITECTheme.animFast } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Text {
                    text: "❯"
                    color: SRITECTheme.accentCyan
                    font.pixelSize: 14
                    font.bold: true
                }

                TextField {
                    id: promptInput
                    Layout.fillWidth: true
                    placeholderText: "Directive for " + globalAIBridge.selectedProvider + " (" + globalAIBridge.selectedModel + ")..."
                    placeholderTextColor: SRITECTheme.textTertiary
                    color: SRITECTheme.textPrimary
                    font.pixelSize: 13
                    background: null
                    onAccepted: {
                        if (text.trim().length > 0) {
                            globalAIBridge.sendQuery(text);
                        }
                    }
                }

                // Send / Stop Button
                Rectangle {
                    Layout.preferredWidth: 84
                    Layout.preferredHeight: 36
                    radius: SRITECTheme.radiusSmall
                    color: globalAIBridge.isGenerating ? SRITECTheme.accentAmber : SRITECTheme.accentCyan
                    opacity: sendMouse.containsMouse ? 0.9 : 1.0

                    Text {
                        anchors.centerIn: parent
                        text: globalAIBridge.isGenerating ? "Stop" : "Transmit"
                        color: SRITECTheme.backgroundVoid
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        id: sendMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (globalAIBridge.isGenerating) {
                                globalAIBridge.cancel();
                            } else if (promptInput.text.trim().length > 0) {
                                globalAIBridge.sendQuery(promptInput.text);
                            }
                        }
                    }
                }

                // Clear Input Button
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: SRITECTheme.radiusSmall
                    color: SRITECTheme.backgroundElevated
                    border.color: SRITECTheme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: SRITECTheme.textSecondary
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            promptInput.text = "";
                            globalAIBridge.clear();
                        }
                    }
                }
            }
        }
    }
}
