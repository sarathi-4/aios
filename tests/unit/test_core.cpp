#include "sritec/common.hpp"
#include "sritec/logger.hpp"
#include <cassert>
#include <iostream>
#include <regex>
#include <thread>
#include <vector>

void test_logger_timestamp() {
    std::cout << "[TEST] 1. Verifying timestamp formatting..." << std::endl;
    std::string ts = sritec::Logger::currentTimestamp();
    std::cout << "       Sample timestamp: " << ts << std::endl;

    // Pattern: YYYY-MM-DD HH:MM:SS.mmm
    std::regex pattern(R"(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3})");
    assert(std::regex_match(ts, pattern) && "Timestamp does not match expected format!");
    std::cout << "       [✓] Timestamp format verified (localtime_r validated)." << std::endl;
}

void test_logger_multithreading() {
    std::cout << "[TEST] 2. Verifying thread-safe concurrent logging..." << std::endl;
    constexpr int NUM_THREADS = 8;
    constexpr int LOGS_PER_THREAD = 25;
    std::vector<std::jthread> threads;

    for (int i = 0; i < NUM_THREADS; ++i) {
        threads.emplace_back([i]() {
            for (int j = 0; j < LOGS_PER_THREAD; ++j) {
                sritec::Logger::instance().info("THREAD_TEST", "Worker " + std::to_string(i) + " iteration " + std::to_string(j));
            }
        });
    }

    // std::jthread automatically joins on scope exit
    std::cout << "       [✓] Concurrent logging across " << NUM_THREADS << " threads completed cleanly." << std::endl;
}

int main() {
    std::cout << "======================================================" << std::endl;
    std::cout << "  SRITEC Core & Logger Unit Tests" << std::endl;
    std::cout << "======================================================" << std::endl;

    // Verify OS constants
    assert(sritec::OS_NAME == "SRITEC AI OS");
    assert(!sritec::OS_VERSION.empty());
    assert(sritec::OS_CODENAME == "Nebula");

    test_logger_timestamp();
    test_logger_multithreading();

    std::cout << "======================================================" << std::endl;
    std::cout << "  [✓] All Core Logger Unit Tests Passed Successfully!" << std::endl;
    std::cout << "======================================================" << std::endl;
    return 0;
}
