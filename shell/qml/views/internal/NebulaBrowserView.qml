import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme"
import "../../components"

Rectangle {
    id: root

    color: "#070A10"
    radius: SRITECTheme.radiusLarge
    clip: true

    property string initialPortal: ""
    property bool showBookmarksBar: true
    property bool showHistoryDrawer: false

    Component.onCompleted: {
        if (root.initialPortal === "chatgpt" || root.initialPortal === "gemini" || root.initialPortal === "claude") {
            globalBrowserBackend.openAIPortal(root.initialPortal);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // =====================================================================
        // 1. Browser Tab Strip
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            color: Qt.rgba(13/255, 17/255, 26/255, 0.95)
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                // Tab Repeater
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                    RowLayout {
                        spacing: 4

                        Repeater {
                            model: globalBrowserBackend.tabs

                            delegate: Item {
                                id: tabItem
                                required property var modelData
                                property real fullWidth: Math.min(220, Math.max(120, tabText.implicitWidth + 50))
                                property bool isClosing: false

                                Layout.preferredHeight: 30
                                Layout.preferredWidth: isClosing ? 0 : fullWidth
                                clip: true

                                Behavior on Layout.preferredWidth {
                                    NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
                                }

                                Rectangle {
                                    id: tabCard
                                    anchors.fill: parent
                                    radius: 6
                                    color: tabItem.modelData.isActive ? Qt.rgba(0/255, 229/255, 255/255, 0.20) :
                                           (tabMouse.containsMouse ? Qt.rgba(19/255, 26/255, 40/255, 0.85) : Qt.rgba(19/255, 26/255, 40/255, 0.6))
                                    border.color: tabItem.modelData.isActive ? SRITECTheme.accentCyan :
                                                  (tabMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.4) : SRITECTheme.borderSubtle)
                                    border.width: 1

                                    // Enter animation (zoom & fade in)
                                    Component.onCompleted: {
                                        tabCard.scale = 0.65;
                                        tabCard.opacity = 0.0;
                                        enterAnim.start();
                                    }

                                    ParallelAnimation {
                                        id: enterAnim
                                        NumberAnimation { target: tabCard; property: "scale"; from: 0.65; to: 1.0; duration: 220; easing.type: Easing.OutBack }
                                        NumberAnimation { target: tabCard; property: "opacity"; from: 0.0; to: 1.0; duration: 180; easing.type: Easing.OutQuad }
                                    }

                                    // Exit animation (shrink & fade out)
                                    SequentialAnimation {
                                        id: exitAnim
                                        ParallelAnimation {
                                            NumberAnimation { target: tabCard; property: "scale"; to: 0.6; duration: 160; easing.type: Easing.InQuad }
                                            NumberAnimation { target: tabCard; property: "opacity"; to: 0.0; duration: 160; easing.type: Easing.InQuad }
                                        }
                                        ScriptAction {
                                            script: globalBrowserBackend.closeTab(tabItem.modelData.id)
                                        }
                                    }

                                    function triggerClose() {
                                        if (!tabItem.isClosing) {
                                            tabItem.isClosing = true;
                                            exitAnim.start();
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 6
                                        spacing: 6

                                        Text {
                                            text: tabItem.modelData.isSecure ? "🔒" : "🌐"
                                            font.pixelSize: 10
                                        }

                                        Text {
                                            id: tabText
                                            Layout.fillWidth: true
                                            text: tabItem.modelData.title
                                            color: tabItem.modelData.isActive ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                            font.pixelSize: 11
                                            font.bold: tabItem.modelData.isActive
                                            elide: Text.ElideRight
                                        }

                                        // Close Tab Button
                                        Rectangle {
                                            Layout.preferredWidth: 16
                                            Layout.preferredHeight: 16
                                            radius: 4
                                            color: tabCloseMouse.containsMouse ? Qt.rgba(255/255, 59/255, 92/255, 0.3) : "transparent"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "✕"
                                                color: tabCloseMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.textSecondary
                                                font.pixelSize: 8
                                            }

                                            MouseArea {
                                                id: tabCloseMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    globalAudioService.playClick();
                                                    tabItem.triggerClose();
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: tabMouse
                                        anchors.fill: parent
                                        z: -1
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            globalAudioService.playClick();
                                            globalBrowserBackend.activeTabId = tabItem.modelData.id;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Add New Tab Button
                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 6
                    color: addTabMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                    border.color: addTabMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: addTabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalBrowserBackend.createTab("https://duckduckgo.com", "DuckDuckGo");
                        }
                    }
                }

                // Private Browsing Toggle
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: privateRow.implicitWidth + 14
                    radius: 6
                    color: globalBrowserBackend.isPrivateBrowsing ? Qt.rgba(139/255, 92/255, 246/255, 0.25) : "transparent"
                    border.color: globalBrowserBackend.isPrivateBrowsing ? SRITECTheme.accentViolet : SRITECTheme.borderSubtle
                    border.width: 1

                    RowLayout {
                        id: privateRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "👁"; font.pixelSize: 10 }
                        Text {
                            text: globalBrowserBackend.isPrivateBrowsing ? "PRIVATE" : "SHIELD"
                            color: globalBrowserBackend.isPrivateBrowsing ? SRITECTheme.accentViolet : SRITECTheme.textSecondary
                            font.pixelSize: 9
                            font.bold: true
                            font.family: SRITECTheme.fontMono
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: globalBrowserBackend.isPrivateBrowsing = !globalBrowserBackend.isPrivateBrowsing
                    }
                }
            }
        }

        // =====================================================================
        // 2. Navigation Bar (Address Bar, Back/Forward, Security Lock)
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: SRITECTheme.backgroundElevated
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                // Back Button
                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 6
                    color: navBackMouse.containsMouse && globalBrowserBackend.canGoBack ? SRITECTheme.backgroundHover : "transparent"
                    opacity: globalBrowserBackend.canGoBack ? 1.0 : 0.4

                    Text {
                        anchors.centerIn: parent
                        text: "◀"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: navBackMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: globalBrowserBackend.canGoBack ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: if (globalBrowserBackend.canGoBack) globalBrowserBackend.goBack()
                    }
                }

                // Forward Button
                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 6
                    color: navFwdMouse.containsMouse && globalBrowserBackend.canGoForward ? SRITECTheme.backgroundHover : "transparent"
                    opacity: globalBrowserBackend.canGoForward ? 1.0 : 0.4

                    Text {
                        anchors.centerIn: parent
                        text: "▶"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: navFwdMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: globalBrowserBackend.canGoForward ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: if (globalBrowserBackend.canGoForward) globalBrowserBackend.goForward()
                    }
                }

                // Reload Button
                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 6
                    color: reloadMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        id: reloadMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: globalBrowserBackend.reload()
                    }
                }

                // Security Lock Capsule
                Rectangle {
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: secLockRow.implicitWidth + 16
                    radius: 14
                    color: Qt.rgba(0/255, 245/255, 160/255, 0.15)
                    border.color: SRITECTheme.accentEmerald
                    border.width: 1

                    RowLayout {
                        id: secLockRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "🔒"; font.pixelSize: 9 }
                        Text { text: "TLS 1.3"; color: SRITECTheme.accentEmerald; font.pixelSize: 9; font.bold: true; font.family: SRITECTheme.fontMono }
                    }
                }

                // Address / Search Input Field
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 6
                    color: Qt.rgba(7/255, 10/255, 15/255, 0.7)
                    border.color: addressInput.activeFocus ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 6

                        Text {
                            text: "🔍"
                            font.pixelSize: 10
                        }

                        TextField {
                            id: addressInput
                            Layout.fillWidth: true
                            text: globalBrowserBackend.activeUrl
                            color: SRITECTheme.textPrimary
                            font.pixelSize: 11
                            font.family: SRITECTheme.fontMono
                            background: null
                            selectByMouse: true

                            onAccepted: {
                                var val = text.trim();
                                if (val.length > 0) {
                                    globalBrowserBackend.navigate(val);
                                }
                            }
                        }

                        // Bookmark Active URL Button
                        Rectangle {
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            radius: 4
                            color: bmMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: globalBrowserBackend.isBookmarked(globalBrowserBackend.activeUrl) ? "★" : "☆"
                                color: globalBrowserBackend.isBookmarked(globalBrowserBackend.activeUrl) ? SRITECTheme.accentAmber : SRITECTheme.textSecondary
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: bmMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (globalBrowserBackend.isBookmarked(globalBrowserBackend.activeUrl)) {
                                        globalBrowserBackend.removeBookmark(globalBrowserBackend.activeUrl);
                                    } else {
                                        globalBrowserBackend.addBookmark(globalBrowserBackend.activeTitle, globalBrowserBackend.activeUrl);
                                    }
                                }
                            }
                        }
                    }
                }

                // History Drawer Toggle
                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 6
                    color: histMouse.containsMouse ? SRITECTheme.backgroundHover : "transparent"
                    border.color: root.showHistoryDrawer ? SRITECTheme.accentCyan : "transparent"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "⌛"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: histMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showHistoryDrawer = !root.showHistoryDrawer
                    }
                }
            }
        }

        // =====================================================================
        // Browser Switcher & Real Launch Selector (Firefox, Chrome, Edge, Opera)
        // Big Cybernetic Browser Application Cards with Sound & Hover Effects
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: Qt.rgba(10/255, 14/255, 22/255, 0.95)
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                ColumnLayout {
                    spacing: 1
                    Layout.alignment: Qt.AlignVCenter
                    Text {
                        text: "BROWSERS"
                        color: SRITECTheme.accentCyan
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.2
                        font.family: SRITECTheme.fontMono
                    }
                    Text {
                        text: "Real Engines"
                        color: SRITECTheme.textTertiary
                        font.pixelSize: 8
                        font.family: SRITECTheme.fontMono
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 34
                    color: SRITECTheme.borderSubtle
                }

                // 1. Firefox Card (Big Icon)
                Rectangle {
                    id: ffCard
                    Layout.preferredHeight: 46
                    Layout.preferredWidth: 145
                    radius: SRITECTheme.radiusMedium
                    color: ffMouse.containsMouse ? Qt.rgba(255/255, 119/255, 0/255, 0.22) : Qt.rgba(19/255, 26/255, 40/255, 0.7)
                    border.color: ffMouse.containsMouse ? "#FF7700" : Qt.rgba(255/255, 119/255, 0/255, 0.45)
                    border.width: 1.5
                    scale: ffMouse.containsMouse ? 1.04 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 17
                            color: Qt.rgba(255/255, 119/255, 0/255, 0.25)
                            border.color: "#FF7700"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "🦊"
                                font.pixelSize: 18
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Firefox"
                                color: ffMouse.containsMouse ? "#FF9933" : SRITECTheme.textPrimary
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: "Host Fast Engine"
                                color: SRITECTheme.textTertiary
                                font.pixelSize: 8
                                font.family: SRITECTheme.fontMono
                            }
                        }
                    }

                    MouseArea {
                        id: ffMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalAppLauncher.launch("firefox");
                        }
                    }
                }

                // 2. Chrome Card (Big Icon)
                Rectangle {
                    id: crCard
                    Layout.preferredHeight: 46
                    Layout.preferredWidth: 145
                    radius: SRITECTheme.radiusMedium
                    color: crMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.22) : Qt.rgba(19/255, 26/255, 40/255, 0.7)
                    border.color: crMouse.containsMouse ? SRITECTheme.accentCyan : Qt.rgba(0/255, 229/255, 255/255, 0.45)
                    border.width: 1.5
                    scale: crMouse.containsMouse ? 1.04 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 17
                            color: Qt.rgba(0/255, 229/255, 255/255, 0.25)
                            border.color: SRITECTheme.accentCyan
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "⚪"
                                font.pixelSize: 16
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Chrome"
                                color: crMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.textPrimary
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: "Google Engine"
                                color: SRITECTheme.textTertiary
                                font.pixelSize: 8
                                font.family: SRITECTheme.fontMono
                            }
                        }
                    }

                    MouseArea {
                        id: crMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            if (globalAppLauncher.isAvailable("chrome")) {
                                globalAppLauncher.launch("chrome");
                            } else {
                                globalBrowserBackend.navigate("https://google.com");
                            }
                        }
                    }
                }

                // 3. Microsoft Edge Card (Big Icon)
                Rectangle {
                    id: edCard
                    Layout.preferredHeight: 46
                    Layout.preferredWidth: 145
                    radius: SRITECTheme.radiusMedium
                    color: edMouse.containsMouse ? Qt.rgba(0/255, 245/255, 160/255, 0.22) : Qt.rgba(19/255, 26/255, 40/255, 0.7)
                    border.color: edMouse.containsMouse ? SRITECTheme.accentEmerald : Qt.rgba(0/255, 245/255, 160/255, 0.45)
                    border.width: 1.5
                    scale: edMouse.containsMouse ? 1.04 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 17
                            color: Qt.rgba(0/255, 245/255, 160/255, 0.25)
                            border.color: SRITECTheme.accentEmerald
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "🔵"
                                font.pixelSize: 16
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Edge"
                                color: edMouse.containsMouse ? SRITECTheme.accentEmerald : SRITECTheme.textPrimary
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: "Microsoft Copilot"
                                color: SRITECTheme.textTertiary
                                font.pixelSize: 8
                                font.family: SRITECTheme.fontMono
                            }
                        }
                    }

                    MouseArea {
                        id: edMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            if (globalAppLauncher.isAvailable("edge")) {
                                globalAppLauncher.launch("edge");
                            } else {
                                globalBrowserBackend.navigate("https://bing.com");
                            }
                        }
                    }
                }

                // 4. Opera Card (Big Icon)
                Rectangle {
                    id: opCard
                    Layout.preferredHeight: 46
                    Layout.preferredWidth: 145
                    radius: SRITECTheme.radiusMedium
                    color: opMouse.containsMouse ? Qt.rgba(255/255, 59/255, 92/255, 0.22) : Qt.rgba(19/255, 26/255, 40/255, 0.7)
                    border.color: opMouse.containsMouse ? SRITECTheme.accentCrimson : Qt.rgba(255/255, 59/255, 92/255, 0.45)
                    border.width: 1.5
                    scale: opMouse.containsMouse ? 1.04 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 17
                            color: Qt.rgba(255/255, 59/255, 92/255, 0.25)
                            border.color: SRITECTheme.accentCrimson
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "🔴"
                                font.pixelSize: 16
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Opera"
                                color: opMouse.containsMouse ? SRITECTheme.accentCrimson : SRITECTheme.textPrimary
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: "Opera Mini / GX"
                                color: SRITECTheme.textTertiary
                                font.pixelSize: 8
                                font.family: SRITECTheme.fontMono
                            }
                        }
                    }

                    MouseArea {
                        id: opMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            if (globalAppLauncher.isAvailable("opera")) {
                                globalAppLauncher.launch("opera");
                            } else {
                                globalBrowserBackend.navigate("https://opera.com");
                            }
                        }
                    }
                }

                // 5. NEBULA Portal Card (Big Icon)
                Rectangle {
                    id: aiPortalCard
                    Layout.preferredHeight: 46
                    Layout.preferredWidth: 160
                    radius: SRITECTheme.radiusMedium
                    color: aiPortalMouse.containsMouse ? Qt.rgba(139/255, 92/255, 246/255, 0.25) : Qt.rgba(19/255, 26/255, 40/255, 0.7)
                    border.color: aiPortalMouse.containsMouse ? SRITECTheme.accentViolet : Qt.rgba(139/255, 92/255, 246/255, 0.45)
                    border.width: 1.5
                    scale: aiPortalMouse.containsMouse ? 1.04 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 17
                            color: Qt.rgba(139/255, 92/255, 246/255, 0.25)
                            border.color: SRITECTheme.accentViolet
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "✦"
                                color: SRITECTheme.accentViolet
                                font.pixelSize: 16
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "NEBULA Portal"
                                color: aiPortalMouse.containsMouse ? SRITECTheme.accentViolet : SRITECTheme.textPrimary
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: "Internal Sandbox"
                                color: SRITECTheme.textTertiary
                                font.pixelSize: 8
                                font.family: SRITECTheme.fontMono
                            }
                        }
                    }

                    MouseArea {
                        id: aiPortalMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            globalAudioService.playClick();
                            globalBrowserBackend.navigate("https://duckduckgo.com");
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        // =====================================================================
        // 3. Bookmarks & Quick AI Portals Bar
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
            border.color: SRITECTheme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: "PORTALS:"
                    color: SRITECTheme.textTertiary
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1.0
                    font.family: SRITECTheme.fontMono
                }

                Repeater {
                    model: globalBrowserBackend.bookmarks

                    delegate: Rectangle {
                        required property var modelData
                        Layout.preferredHeight: 22
                        Layout.preferredWidth: bmText.implicitWidth + 18
                        radius: 4
                        color: bmBarMouse.containsMouse ? Qt.rgba(0/255, 229/255, 255/255, 0.15) : Qt.rgba(19/255, 26/255, 40/255, 0.4)
                        border.color: bmBarMouse.containsMouse ? SRITECTheme.accentCyan : SRITECTheme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                text: modelData.title === "ChatGPT" ? "⚡" :
                                      modelData.title === "Google Gemini" ? "✦" :
                                      modelData.title === "Anthropic Claude" ? "◈" : "★"
                                color: modelData.title === "ChatGPT" ? SRITECTheme.accentEmerald :
                                       modelData.title === "Google Gemini" ? SRITECTheme.accentCyan :
                                       modelData.title === "Anthropic Claude" ? SRITECTheme.accentAmber : SRITECTheme.textSecondary
                                font.pixelSize: 9
                            }
                            Text {
                                id: bmText
                                text: modelData.title
                                color: bmBarMouse.containsMouse ? SRITECTheme.textPrimary : SRITECTheme.textSecondary
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            id: bmBarMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: globalBrowserBackend.navigate(modelData.url)
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "SECURITY: STRICT SANDBOX"
                    color: SRITECTheme.accentEmerald
                    font.pixelSize: 9
                    font.bold: true
                    font.family: SRITECTheme.fontMono
                }
            }
        }

        // =====================================================================
        // 4. Main Web & AI Portal Viewport
        // =====================================================================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Content Area Stack
            StackLayout {
                anchors.fill: parent
                currentIndex: {
                    var u = globalBrowserBackend.activeUrl.toLowerCase();
                    if (u.indexOf("chatgpt.com") !== -1) return 1;
                    if (u.indexOf("gemini.google.com") !== -1) return 2;
                    if (u.indexOf("claude.ai") !== -1) return 3;
                    return 0; // Default: Intelligent Search & Research Assistant
                }

                // View 0: Intelligent Search & Research Assistant (Inspired by Reference Images 9 & 10)
                Rectangle {
                    color: "#05080E"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 16

                        // Header Status Capsule
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            radius: SRITECTheme.radiusMedium
                            color: Qt.rgba(13/255, 17/255, 26/255, 0.85)
                            border.color: SRITECTheme.accentCyan
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 12

                                Text { text: "🌐"; font.pixelSize: 16 }
                                Text {
                                    text: "INTELLIGENT SEARCH & RESEARCH ASSISTANT"
                                    color: SRITECTheme.accentCyan
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.letterSpacing: 1.5
                                }

                                Item { Layout.fillWidth: true }

                                Rectangle {
                                    Layout.preferredHeight: 22
                                    Layout.preferredWidth: noticeRow.implicitWidth + 14
                                    radius: 11
                                    color: Qt.rgba(255/255, 184/255, 0/255, 0.15)
                                    border.color: SRITECTheme.accentAmber
                                    border.width: 1

                                    RowLayout {
                                        id: noticeRow
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Text { text: "⚠"; color: SRITECTheme.accentAmber; font.pixelSize: 9 }
                                        Text {
                                            text: "Chromium Engine Pending Approval (qt6-webengine-dev)"
                                            color: SRITECTheme.accentAmber
                                            font.pixelSize: 9
                                            font.family: SRITECTheme.fontMono
                                        }
                                    }
                                }
                            }
                        }

                        // Middle Split: Rotating Hologram Globe & Search Results
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 16

                            // Hologram Radar & Knowledge Graph Card
                            Rectangle {
                                Layout.preferredWidth: 380
                                Layout.fillHeight: true
                                radius: SRITECTheme.radiusLarge
                                color: Qt.rgba(13/255, 17/255, 26/255, 0.7)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 14

                                    Text {
                                        text: "RESEARCH SPATIAL TELEMETRY"
                                        color: SRITECTheme.accentCyan
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: SRITECTheme.fontMono
                                    }

                                    // Holographic Globe Canvas
                                    Canvas {
                                        id: globeCanvas
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 180
                                        property real angle: 0

                                        Timer {
                                            interval: 33
                                            running: true
                                            repeat: true
                                            onTriggered: {
                                                globeCanvas.angle += 0.02;
                                                globeCanvas.requestPaint();
                                            }
                                        }

                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.clearRect(0, 0, width, height);

                                            var cx = width / 2;
                                            var cy = height / 2;
                                            var r = 70;

                                            // Outer circle glow
                                            ctx.strokeStyle = "#00E5FF";
                                            ctx.lineWidth = 1.5;
                                            ctx.beginPath();
                                            ctx.arc(cx, cy, r, 0, Math.PI * 2);
                                            ctx.stroke();

                                            // Rotating wireframe latitudes & longitudes
                                            ctx.lineWidth = 1.0;
                                            ctx.strokeStyle = "rgba(0, 229, 255, 0.4)";
                                            for (var i = -2; i <= 2; ++i) {
                                                ctx.beginPath();
                                                ctx.ellipse(cx, cy, Math.abs(Math.cos(angle + i * 0.4)) * r, r, 0, 0, Math.PI * 2);
                                                ctx.stroke();
                                            }

                                            // Center core
                                            ctx.fillStyle = "#00F5A0";
                                            ctx.beginPath();
                                            ctx.arc(cx, cy, 4, 0, Math.PI * 2);
                                            ctx.fill();
                                        }
                                    }

                                    Text {
                                        text: "Active Query: " + globalBrowserBackend.activeUrl + "\n" +
                                              "Domain:       " + globalBrowserBackend.activeTitle + "\n" +
                                              "TLS Protocol: TLS 1.3 / Strict CA\n" +
                                              "AI Synthesis: Connected to LISA Neural Engine\n" +
                                              "Privacy:      " + (globalBrowserBackend.isPrivateBrowsing ? "Private Shield Active" : "Standard History Recording")
                                        color: SRITECTheme.textSecondary
                                        font.pixelSize: 10
                                        font.family: SRITECTheme.fontMono
                                        lineHeight: 1.5
                                    }

                                    Item { Layout.fillHeight: true }
                                }
                            }

                            // Interactive Search & Portal Results Stream
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: SRITECTheme.radiusLarge
                                color: Qt.rgba(13/255, 17/255, 26/255, 0.7)
                                border.color: SRITECTheme.borderSubtle
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 12

                                    RowLayout {
                                        spacing: 8
                                        Text { text: "✦"; color: SRITECTheme.accentCyan; font.pixelSize: 12 }
                                        Text {
                                            text: "WEB & AI RESEARCH RESULTS"
                                            color: SRITECTheme.textPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                                    ScrollView {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        ColumnLayout {
                                            width: parent.width
                                            spacing: 12

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 90
                                                radius: 8
                                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                                border.color: SRITECTheme.borderSubtle
                                                border.width: 1

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 12
                                                    spacing: 4
                                                    Text { text: "DuckDuckGo Privacy-First Web Search"; color: SRITECTheme.accentCyan; font.pixelSize: 12; font.bold: true }
                                                    Text { text: "https://duckduckgo.com"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                                                    Text { text: "Query formulated securely without third-party tracking. TLS certificate verification active."; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 90
                                                radius: 8
                                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                                border.color: SRITECTheme.borderSubtle
                                                border.width: 1

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 12
                                                    spacing: 4
                                                    Text { text: "ChatGPT — OpenAI Reasoning Intelligence"; color: SRITECTheme.accentEmerald; font.pixelSize: 12; font.bold: true }
                                                    Text { text: "https://chatgpt.com"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                                                    Text { text: "Open conversational AI portal. Integrated directly through NEBULA Unified AI Gateway."; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: globalBrowserBackend.openAIPortal("chatgpt")
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 90
                                                radius: 8
                                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                                border.color: SRITECTheme.borderSubtle
                                                border.width: 1

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 12
                                                    spacing: 4
                                                    Text { text: "Google Gemini — Multimodal Neural Reasoning"; color: SRITECTheme.accentCyan; font.pixelSize: 12; font.bold: true }
                                                    Text { text: "https://gemini.google.com"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                                                    Text { text: "Access Google Gemini models, live vision and multimodal intelligence."; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: globalBrowserBackend.openAIPortal("gemini")
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 90
                                                radius: 8
                                                color: Qt.rgba(19/255, 26/255, 40/255, 0.7)
                                                border.color: SRITECTheme.borderSubtle
                                                border.width: 1

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 12
                                                    spacing: 4
                                                    Text { text: "Anthropic Claude — Constitutional AI Studio"; color: SRITECTheme.accentAmber; font.pixelSize: 12; font.bold: true }
                                                    Text { text: "https://claude.ai"; color: SRITECTheme.accentEmerald; font.pixelSize: 10; font.family: SRITECTheme.fontMono }
                                                    Text { text: "Deep analytical synthesis and constitutional safety alignment."; color: SRITECTheme.textSecondary; font.pixelSize: 11 }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: globalBrowserBackend.openAIPortal("claude")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // View 1: ChatGPT Dedicated Web Portal (Inspired by Reference Image 9)
                Rectangle {
                    color: "#070B12"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            radius: 8
                            color: Qt.rgba(0/255, 245/255, 160/255, 0.12)
                            border.color: SRITECTheme.accentEmerald
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 10

                                Text { text: "⚡"; color: SRITECTheme.accentEmerald; font.pixelSize: 18 }
                                Text { text: "ChatGPT Web Portal — OpenAI"; color: SRITECTheme.textPrimary; font.pixelSize: 14; font.bold: true }
                                Item { Layout.fillWidth: true }
                                Text { text: "https://chatgpt.com"; color: SRITECTheme.accentEmerald; font.pixelSize: 11; font.family: SRITECTheme.fontMono }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: SRITECTheme.radiusLarge
                            color: Qt.rgba(13/255, 17/255, 26/255, 0.8)
                            border.color: SRITECTheme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 16

                                AIIcon { Layout.alignment: Qt.AlignHCenter; iconId: "chatgpt"; size: 64; showTile: true }
                                Text { Layout.alignment: Qt.AlignHCenter; text: "OpenAI ChatGPT Portal"; color: SRITECTheme.textPrimary; font.pixelSize: 18; font.bold: true }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Running in NEBULA Secure Sandbox • Zero API Keys Exposed to Web"
                                    color: SRITECTheme.accentEmerald
                                    font.pixelSize: 11
                                    font.family: SRITECTheme.fontMono
                                }
                                Button {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Open in LISA AI Studio (Native Gateway)"
                                    onClicked: globalAppLaunchManager.requestAppLaunch("assistant")
                                }
                            }
                        }
                    }
                }

                // View 2: Google Gemini Dedicated Web Portal
                Rectangle {
                    color: "#070B12"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            radius: 8
                            color: Qt.rgba(0/255, 229/255, 255/255, 0.12)
                            border.color: SRITECTheme.accentCyan
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 10

                                Text { text: "✦"; color: SRITECTheme.accentCyan; font.pixelSize: 18 }
                                Text { text: "Google Gemini Web Portal"; color: SRITECTheme.textPrimary; font.pixelSize: 14; font.bold: true }
                                Item { Layout.fillWidth: true }
                                Text { text: "https://gemini.google.com"; color: SRITECTheme.accentCyan; font.pixelSize: 11; font.family: SRITECTheme.fontMono }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: SRITECTheme.radiusLarge
                            color: Qt.rgba(13/255, 17/255, 26/255, 0.8)
                            border.color: SRITECTheme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 16

                                AIIcon { Layout.alignment: Qt.AlignHCenter; iconId: "gemini"; size: 64; showTile: true }
                                Text { Layout.alignment: Qt.AlignHCenter; text: "Google Gemini Multimodal Portal"; color: SRITECTheme.textPrimary; font.pixelSize: 18; font.bold: true }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Secure Sandboxed Web Session • TLS 1.3 Certified"
                                    color: SRITECTheme.accentCyan
                                    font.pixelSize: 11
                                    font.family: SRITECTheme.fontMono
                                }
                                Button {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Switch to Gemini Native Provider"
                                    onClicked: {
                                        globalAIBridge.selectedProvider = "gemini";
                                        globalAppLaunchManager.requestAppLaunch("assistant");
                                    }
                                }
                            }
                        }
                    }
                }

                // View 3: Anthropic Claude Dedicated Web Portal
                Rectangle {
                    color: "#070B12"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            radius: 8
                            color: Qt.rgba(255/255, 184/255, 0/255, 0.12)
                            border.color: SRITECTheme.accentAmber
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 10

                                Text { text: "◈"; color: SRITECTheme.accentAmber; font.pixelSize: 18 }
                                Text { text: "Anthropic Claude Web Portal"; color: SRITECTheme.textPrimary; font.pixelSize: 14; font.bold: true }
                                Item { Layout.fillWidth: true }
                                Text { text: "https://claude.ai"; color: SRITECTheme.accentAmber; font.pixelSize: 11; font.family: SRITECTheme.fontMono }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: SRITECTheme.radiusLarge
                            color: Qt.rgba(13/255, 17/255, 26/255, 0.8)
                            border.color: SRITECTheme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 16

                                AIIcon { Layout.alignment: Qt.AlignHCenter; iconId: "claude"; size: 64; showTile: true }
                                Text { Layout.alignment: Qt.AlignHCenter; text: "Anthropic Claude Constitutional Studio"; color: SRITECTheme.textPrimary; font.pixelSize: 18; font.bold: true }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Constitutional Reasoning Engine • Session Isolated"
                                    color: SRITECTheme.accentAmber
                                    font.pixelSize: 11
                                    font.family: SRITECTheme.fontMono
                                }
                                Button {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Switch to Claude Native Provider"
                                    onClicked: {
                                        globalAIBridge.selectedProvider = "claude";
                                        globalAppLaunchManager.requestAppLaunch("assistant");
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // History Slide-out Drawer
            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 320
                visible: root.showHistoryDrawer
                color: Qt.rgba(13/255, 17/255, 26/255, 0.96)
                border.color: SRITECTheme.accentCyan
                border.width: 1
                z: 20

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Text { text: "BROWSING HISTORY"; color: SRITECTheme.accentCyan; font.pixelSize: 11; font.bold: true; font.family: SRITECTheme.fontMono }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: "Clear"
                            onClicked: globalBrowserBackend.clearHistory()
                        }
                        Button {
                            text: "✕"
                            onClicked: root.showHistoryDrawer = false
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: SRITECTheme.borderSubtle }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: globalBrowserBackend.history
                        clip: true

                        delegate: Rectangle {
                            required property var modelData
                            width: parent.width
                            height: 48
                            color: "transparent"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 2
                                Text { text: modelData.title; color: SRITECTheme.textPrimary; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight }
                                Text { text: modelData.timestamp + " • " + modelData.url; color: SRITECTheme.textSecondary; font.pixelSize: 9; font.family: SRITECTheme.fontMono; elide: Text.ElideRight }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    globalBrowserBackend.navigate(modelData.url);
                                    root.showHistoryDrawer = false;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
