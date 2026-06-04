cmake_minimum_required(VERSION 3.15)
project(MultiDebuggerCppTargets CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Force debug symbols just in case the build type isn't passed correctly
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0")

add_executable(target1_pointers target1_pointers.cpp)
add_executable(target2_classes target2_classes.cpp)
add_executable(target3_threads target3_threads.cpp)

# Ensure pthread is linked for target3 on Linux/macOS
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
target_link_libraries(target3_threads PRIVATE Threads::Threads)
