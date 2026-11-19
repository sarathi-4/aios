#include "sritec/ai/ai_bridge.hpp"
#include "sritec/ai/mock_provider.hpp"
#include <cassert>
#include <iostream>
#include <chrono>
#include <thread>
#include <vector>

void test_command_safety_classification() {
    std::cout << "[TEST] 1. Verifying whitelist-first command safety classification..." << std::endl;

    using Level = sritec::ai::CommandSafetyLevel;
    QString reason;

    // Test 1: Empty command must be INVALID (never SAFE)
    assert(sritec::ai::AIBridge::evaluateCommand("", &reason) == Level::Invalid);
    assert(sritec::ai::AIBridge::evaluateCommand("   ", &reason) == Level::Invalid);

    // Test 2: Shell chaining, pipes, redirection, substitutions must be DANGEROUS
    assert(sritec::ai::AIBridge::evaluateCommand("git status && rm -rf /", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("ls; pwd", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("cat file | sh", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("echo hello > /tmp/foo", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("echo $(whoami)", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("echo `whoami`", &reason) == Level::Dangerous);

    // Test 3: Destructive commands and flag reordering must be DANGEROUS
    assert(sritec::ai::AIBridge::evaluateCommand("rm -rf /", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("rm -r -f /", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("rm --recursive --force /", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("mkfs.ext4 /dev/sda1", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("dd if=/dev/zero of=/dev/sda", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("shred -u file.txt", &reason) == Level::Dangerous);
    assert(sritec::ai::AIBridge::evaluateCommand("sudo apt install foo", &reason) == Level::Dangerous);

    // Test 4: Unknown / unvetted commands must be SENSITIVE (never SAFE)
    assert(sritec::ai::AIBridge::evaluateCommand("some_unknown_binary", &reason) == Level::Sensitive);
    assert(sritec::ai::AIBridge::evaluateCommand("mkdir new_folder", &reason) == Level::Sensitive);
    assert(sritec::ai::AIBridge::evaluateCommand("touch file.txt", &reason) == Level::Sensitive);

    // Test 5: Whitelisted read-only inspection commands must be SAFE
    assert(sritec::ai::AIBridge::evaluateCommand("pwd", &reason) == Level::Safe);
    assert(sritec::ai::AIBridge::evaluateCommand("whoami", &reason) == Level::Safe);
    assert(sritec::ai::AIBridge::evaluateCommand("uptime", &reason) == Level::Safe);
    assert(sritec::ai::AIBridge::evaluateCommand("date", &reason) == Level::Safe);
    assert(sritec::ai::AIBridge::evaluateCommand("uname -a", &reason) == Level::Safe);
    assert(sritec::ai::AIBridge::evaluateCommand("git status", &reason) == Level::Safe);
    assert(sritec::ai::AIBridge::evaluateCommand("git log", &reason) == Level::Safe);
    assert(sritec::ai::AIBridge::evaluateCommand("git diff", &reason) == Level::Safe);
    assert(sritec::ai::AIBridge::evaluateCommand("ls -la", &reason) == Level::Safe);

    std::cout << "       [✓] Whitelist-first safety classification verified." << std::endl;
}

void test_ai_stream_cancellation() {
    std::cout << "[TEST] 2. Verifying AI stream cancellation via std::jthread..." << std::endl;

    sritec::ai::MockAIProvider provider;
    std::atomic<int> tokensReceived{0};

    provider.streamQuery("code concept for operating system", "", [&tokensReceived](const std::string&, bool) {
        tokensReceived++;
    });

    // Verify streaming is active
    assert(provider.isStreaming() && "Provider should be actively streaming!");

    // Cancel after brief wait
    std::this_thread::sleep_for(std::chrono::milliseconds(30));
    provider.cancel();

    // Verify stream stopped
    assert(!provider.isStreaming() && "Provider should report streaming stopped after cancel()!");
    std::cout << "       [✓] Stream cancellation verified (tokens emitted before cancel: " << tokensReceived.load() << ")." << std::endl;
}

void test_ai_repeated_requests() {
    std::cout << "[TEST] 3. Verifying rapid repeated AI requests (thread re-entrancy)..." << std::endl;

    sritec::ai::MockAIProvider provider;

    // Trigger 10 rapid queries back-to-back
    for (int i = 0; i < 10; ++i) {
        provider.streamQuery("Query iteration " + std::to_string(i), "", [](const std::string&, bool) {});
        std::this_thread::sleep_for(std::chrono::milliseconds(5));
    }

    // Explicit cancel and join
    provider.cancel();
    assert(!provider.isStreaming());

    std::cout << "       [✓] 10 rapid repeated queries stopped and joined without race condition." << std::endl;
}

int main() {
    std::cout << "======================================================" << std::endl;
    std::cout << "  SRITEC AI Safety & Threading Unit Tests" << std::endl;
    std::cout << "======================================================" << std::endl;

    test_command_safety_classification();
    test_ai_stream_cancellation();
    test_ai_repeated_requests();

    std::cout << "======================================================" << std::endl;
    std::cout << "  [✓] All AI Safety & Threading Tests Passed Successfully!" << std::endl;
    std::cout << "======================================================" << std::endl;
    return 0;
}
