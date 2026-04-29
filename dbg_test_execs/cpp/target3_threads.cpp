#include <iostream>
#include <thread>
#include <vector>
#include <mutex>

std::mutex print_mutex;

void worker_task(int thread_id, int iterations) {
    int local_counter = 0;
    for (int i = 0; i < iterations; ++i) {
        local_counter++;
        
        // Breakpoint here: Switch between threads in your UI to see different 'thread_id' and 'local_counter' values
        std::lock_guard<std::mutex> lock(print_mutex);
        std::cout << "Thread " << thread_id << " working. Local counter: " << local_counter << "\n";
        
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
}

int main() {
    const int num_threads = 3;
    std::vector<std::thread> threads;

    std::cout << "Starting " << num_threads << " threads...\n";

    for (int i = 0; i < num_threads; ++i) {
        threads.emplace_back(worker_task, i + 1, 4);
    }

    for (auto& t : threads) {
        if (t.joinable()) {
            t.join();
        }
    }

    std::cout << "All threads finished.\n";
    return 0;
}
