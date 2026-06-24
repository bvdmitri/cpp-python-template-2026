# ----------------------------------------------------------------------------
# Test suite (Catch2 v3).
#
# Catch2 is resolved via find_package first (the vcpkg / system path). If it is
# not found, we transparently fall back to FetchContent so the template builds
# on a fresh clone even without vcpkg bootstrapped.
# ----------------------------------------------------------------------------
find_package(Catch2 3 QUIET CONFIG)

if(NOT Catch2_FOUND)
  message(STATUS "mylib: Catch2 not found via find_package; fetching with FetchContent")
  include(FetchContent)
  FetchContent_Declare(Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG v3.7.1
    GIT_SHALLOW TRUE
    SYSTEM)
  FetchContent_MakeAvailable(Catch2)
  list(APPEND CMAKE_MODULE_PATH "${Catch2_SOURCE_DIR}/extras")
endif()

include(Catch)

add_executable(mylib_tests sum_test.cpp)
target_link_libraries(mylib_tests
  PRIVATE
    mylib::mylib
    Catch2::Catch2WithMain
    mylib::warnings
    mylib::sanitizers
    mylib::coverage)

# Register every TEST_CASE / SCENARIO as an individual CTest test.
catch_discover_tests(mylib_tests)
