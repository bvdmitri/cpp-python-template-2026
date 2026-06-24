# ----------------------------------------------------------------------------
# mylib — a 2026-grade modern C++ library template.
#
# `mylib` is a placeholder: rename it (namespace, target, package, dirs) to
# start a real project from this template.
# ----------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.28...4.4)

# Disallow in-source builds: they pollute the tree and clash with the presets.
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR
    "In-source builds are not allowed. Configure into a build directory, e.g. "
    "`cmake --preset dev` (writes to out/build/dev). Remove the CMakeCache.txt "
    "and CMakeFiles/ that were just created in the source tree.")
endif()

# Pick up the vcpkg toolchain automatically when VCPKG_ROOT is set and no
# toolchain was supplied (presets pass it explicitly; this helps plain users).
# Must run before project().
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
      CACHE STRING "vcpkg toolchain file")
endif()

project(mylib
  VERSION 0.1.0
  DESCRIPTION "A 2026-grade modern C++ library template"
  HOMEPAGE_URL "https://github.com/your-org/mylib"
  LANGUAGES CXX)

# --- Project-wide policy -----------------------------------------------------
set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Hide symbols by default; the export header opts symbols back in. This keeps
# shared-library ABI small and matches MSVC's dllexport model on every platform.
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

# Always emit compile_commands.json for clangd / clang-tidy / IWYU.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Symlink the compile database to the repo root so every editor's clangd finds
# it (the .clangd config points at the source dir). Harmless if it already exists.
if(PROJECT_IS_TOP_LEVEL)
  file(CREATE_LINK
    "${CMAKE_BINARY_DIR}/compile_commands.json"
    "${CMAKE_SOURCE_DIR}/compile_commands.json"
    SYMBOLIC)
endif()

# Sensible defaults when this is the top-level project.
if(PROJECT_IS_TOP_LEVEL)
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
  endif()
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# --- Options -----------------------------------------------------------------
option(MYLIB_BUILD_TESTS "Build the test suite" ${PROJECT_IS_TOP_LEVEL})
option(MYLIB_BUILD_DOCS "Build Doxygen documentation" OFF)
option(MYLIB_BUILD_PYTHON "Build the optional Python bindings (nanobind)" OFF)
option(MYLIB_ENABLE_COVERAGE "Instrument for code coverage" OFF)
set(MYLIB_SANITIZER "" CACHE STRING
    "Sanitizer to enable: '', 'address', 'address;undefined', or 'thread'")

include(CompilerWarnings)
include(Sanitizers)

# --- The library ------------------------------------------------------------
add_subdirectory(src)

# --- Tests ------------------------------------------------------------------
if(MYLIB_BUILD_TESTS)
  enable_testing()
  add_subdirectory(test)
endif()

# --- Python bindings (optional) ---------------------------------------------
if(MYLIB_BUILD_PYTHON)
  add_subdirectory(bindings/python)
endif()

# --- Docs -------------------------------------------------------------------
if(MYLIB_BUILD_DOCS)
  add_subdirectory(docs)
endif()
