/// @file main.cpp
/// @brief A standalone example that consumes mylib exactly as an external user
///        would (via find_package + the mylib::mylib imported target).
///
/// This is built by standalone/CMakeLists.txt against an *installed* mylib, so it
/// validates the install/export path. CI builds it in install.yml.
#include <mylib/mylib.hpp>

#include <print>

int main()
{
    std::println("mylib version {}", mylib::version);
    std::println("sum(2, 3)            = {}", mylib::sum(2, 3));
    std::println("sum(0.5, 0.25)       = {}", mylib::sum(0.5, 0.25));
    std::println("sum(9e9, 1) [int64]  = {}", mylib::sum(9'000'000'000LL, 1LL));
    return 0;
}
