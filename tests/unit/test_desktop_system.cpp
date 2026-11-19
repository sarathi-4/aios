#include <QCoreApplication>
#include <cassert>
#include <iostream>
#include <string>

#include "desktop_manager.hpp"

using namespace sritec::shell;

int main(int argc, char* argv[]) {
    QCoreApplication app(argc, argv);
    app.setOrganizationName("SRITEC_TEST");
    app.setApplicationName("AIOS_DESKTOP_TEST");

    std::cout << "[TEST] Starting SRITEC AI OS Desktop System Test Suite...\n";

    DesktopManager mgr;

    // 1. Initial State & Defaults Verification
    std::cout << "[TEST] 1. Verifying initial state and defaults...\n";
    assert(mgr.wallpaperType() == "image");
    assert(mgr.wallpaperPath().contains("ai_robotics_wallpaper.jpg"));
    assert(mgr.wallpaperMode() == "fill");
    assert(mgr.performanceMode() == "Balanced");
    assert(mgr.dockPosition() == "bottom");
    assert(mgr.dockSize() == "medium");
    assert(!mgr.dockAutoHide());
    assert(mgr.accentColor() == "#00E5FF");
    assert(mgr.glassOpacity() > 0.8 && mgr.glassOpacity() < 0.9);
    assert(mgr.fontScale() >= 0.99 && mgr.fontScale() <= 1.01);
    std::cout << "  [PASS] Initial state and configuration verified.\n";

    // 2. Desktop Items CRUD & Layout Persistence
    std::cout << "[TEST] 2. Verifying Desktop Items CRUD operations...\n";
    QVariantList initialItems = mgr.desktopItems();
    int initialCount = initialItems.size();
    assert(initialCount >= 4);

    // Create a new folder
    mgr.createFolder("Test Research Lab", 120, 240);
    QVariantList itemsAfterCreate = mgr.desktopItems();
    assert(itemsAfterCreate.size() == initialCount + 1);

    QString createdFolderId = "";
    for (const auto& var : itemsAfterCreate) {
        QVariantMap map = var.toMap();
        if (map["name"].toString() == "Test Research Lab") {
            createdFolderId = map["id"].toString();
            assert(map["type"].toString() == "folder");
            assert(map["x"].toInt() == 120);
            assert(map["y"].toInt() == 240);
            break;
        }
    }
    assert(!createdFolderId.isEmpty());

    // Rename the item
    mgr.renameItem(createdFolderId, "Quantum AI Lab");
    bool renamed = false;
    for (const auto& var : mgr.desktopItems()) {
        QVariantMap map = var.toMap();
        if (map["id"].toString() == createdFolderId) {
            assert(map["name"].toString() == "Quantum AI Lab");
            renamed = true;
            break;
        }
    }
    assert(renamed);

    // Update position
    mgr.updateItemPosition(createdFolderId, 300, 450);
    bool moved = false;
    for (const auto& var : mgr.desktopItems()) {
        QVariantMap map = var.toMap();
        if (map["id"].toString() == createdFolderId) {
            assert(map["x"].toInt() == 300);
            assert(map["y"].toInt() == 450);
            moved = true;
            break;
        }
    }
    assert(moved);

    // Create a shortcut
    mgr.createShortcut("My Terminal", "terminal", "⌨", 60, 60);
    assert(mgr.desktopItems().size() == initialCount + 2);

    // Remove the created items
    mgr.removeItem(createdFolderId);
    assert(mgr.desktopItems().size() == initialCount + 1);
    std::cout << "  [PASS] Desktop Items CRUD and repositioning verified.\n";

    // 3. Dock Pinning / Unpinning & Recent Applications
    std::cout << "[TEST] 3. Verifying Dock Pinning & App History...\n";
    assert(mgr.isAppPinned("terminal"));
    assert(mgr.isAppPinned("browser"));
    assert(!mgr.isAppPinned("custom_neural_debugger"));

    mgr.pinApp("custom_neural_debugger");
    assert(mgr.isAppPinned("custom_neural_debugger"));
    assert(mgr.pinnedApps().contains("custom_neural_debugger"));

    mgr.unpinApp("custom_neural_debugger");
    assert(!mgr.isAppPinned("custom_neural_debugger"));

    mgr.recordAppOpened("editor");
    assert(mgr.recentApps().contains("editor"));
    std::cout << "  [PASS] Dock pinning and history verified.\n";

    // 4. Notifications Engine
    std::cout << "[TEST] 4. Verifying Notification Center queue & dismiss...\n";
    mgr.clearAllNotifications();
    assert(mgr.unreadNotificationsCount() == 0);

    mgr.addNotification("Security Guardrail Active", "Disk partition mutation prevented.", "security", "⛨");
    mgr.addNotification("System Notice", "Desktop layout successfully synchronized.", "info", "ℹ");
    assert(mgr.unreadNotificationsCount() == 2);

    QVariantList notifs = mgr.notifications();
    assert(notifs.size() == 2);
    // Most recent notification is prepended at index 0
    QVariantMap latestNotif = notifs.first().toMap();
    assert(latestNotif["type"].toString() == "info");
    assert(latestNotif["title"].toString() == "System Notice");

    QVariantMap olderNotif = notifs.at(1).toMap();
    assert(olderNotif["type"].toString() == "security");
    assert(olderNotif["title"].toString() == "Security Guardrail Active");

    QString firstId = latestNotif["id"].toString();
    mgr.clearNotification(firstId);
    assert(mgr.unreadNotificationsCount() == 1);

    mgr.clearAllNotifications();
    assert(mgr.unreadNotificationsCount() == 0);

    // Do Not Disturb
    mgr.setDoNotDisturb(true);
    assert(mgr.doNotDisturb());
    mgr.setDoNotDisturb(false);
    assert(!mgr.doNotDisturb());
    std::cout << "  [PASS] Notification Center queue and DND verified.\n";

    // 5. Universal Search Indexing
    std::cout << "[TEST] 5. Verifying Universal Search Engine...\n";
    QVariantList appResults = mgr.universalSearch("Terminal");
    assert(!appResults.isEmpty());
    bool foundTerminal = false;
    for (const auto& res : appResults) {
        QVariantMap map = res.toMap();
        if (map["title"].toString().contains("Terminal", Qt::CaseInsensitive)) {
            foundTerminal = true;
            assert(map["type"].toString() == "app");
            break;
        }
    }
    assert(foundTerminal);

    // Search for project file
    QVariantList fileResults = mgr.universalSearch("main.cpp");
    assert(!fileResults.isEmpty());
    bool foundFile = false;
    for (const auto& res : fileResults) {
        QVariantMap map = res.toMap();
        if (map["title"].toString() == "main.cpp") {
            foundFile = true;
            assert(map["type"].toString() == "file");
            break;
        }
    }
    assert(foundFile);

    // Search non-existent term
    QVariantList emptyResults = mgr.universalSearch("nonexistent_xyz_query_999");
    assert(emptyResults.isEmpty());
    std::cout << "  [PASS] Universal search index and categorization verified.\n";

    // 6. Real Hardware Telemetry Integrity
    std::cout << "[TEST] 6. Verifying Hardware Telemetry Integrity (Ubuntu 26.04 Desktop Workstation)...\n";
    mgr.refreshHardwareTelemetry();

    // Verify desktop AC power reporting (no fake battery)
    assert(!mgr.hasBattery());
    assert(mgr.batteryStatusText().contains("Desktop AC Power") || mgr.batteryStatusText().contains("No Battery"));

    // Verify external desktop display reporting (no fake backlight slider)
    assert(!mgr.hasBacklight());
    assert(mgr.backlightStatusText().contains("Not Supported") || mgr.backlightStatusText().contains("External Desktop Display"));

    // Verify wired Ethernet eno1 reporting
    assert(!mgr.hasWifi());
    assert(mgr.networkInterfaceName() == "eno1");
    assert(mgr.wifiStatusText().contains("Wired Ethernet eno1"));

    // Verify Bluetooth adapter absence
    assert(!mgr.hasBluetooth());
    assert(mgr.bluetoothStatusText().contains("No Bluetooth Adapter"));

    // Audio controls
    mgr.setAudioVolume(85);
    assert(mgr.audioVolume() == 85);
    mgr.setIsMuted(true);
    assert(mgr.isMuted());
    mgr.setIsMuted(false);
    assert(!mgr.isMuted());
    std::cout << "  [PASS] Real hardware detection and telemetry integrity verified.\n";

    // 7. Factory Reset
    std::cout << "[TEST] 7. Verifying Reset to Factory Defaults...\n";
    mgr.setPerformanceMode("Low");
    mgr.setDockPosition("left");
    mgr.setAccentColor("#EC4899");

    mgr.resetToDefaults();
    assert(mgr.performanceMode() == "Balanced");
    assert(mgr.dockPosition() == "bottom");
    assert(mgr.accentColor() == "#00E5FF");
    assert(mgr.wallpaperType() == "procedural");
    std::cout << "  [PASS] Factory reset verified.\n";

    std::cout << "\n=======================================================\n";
    std::cout << "  ALL 7 DESKTOP SYSTEM TESTS PASSED SUCCESSFULLY!\n";
    std::cout << "=======================================================\n";

    return 0;
}
