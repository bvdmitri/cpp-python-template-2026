# ----------------------------------------------------------------------------
# Standalone example — built as a SEPARATE project against an installed mylib.
#
# It deliberately does NOT add_subdirectory the library; it consumes it via
# find_package, the same way a real downstream user would. This validates that
# the install/export (mylib::mylib target, headers, config package) actually work.
#
#   cmake --install <core-build> --prefix <prefix>
#   cmake -S standalone -B standalone/build -DCMAKE_PREFIX_PATH=<prefix>
#   cmake --build standalone/build
# ----------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.28)
project(mylib_standalone LANGUAGES CXX)

find_package(mylib CONFIG REQUIRED)

add_executable(mylib_standalone main.cpp)
target_link_libraries(mylib_standalone PRIVATE mylib::mylib)
