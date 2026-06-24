# ----------------------------------------------------------------------------
# The mylib library target + install/export rules.
# ----------------------------------------------------------------------------
include(GenerateExportHeader)
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

add_library(mylib)
add_library(mylib::mylib ALIAS mylib)

target_sources(mylib PRIVATE sum.cpp)

# Generated headers live under a dedicated tree so they can be installed too.
set(MYLIB_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(MYLIB_GENERATED_INCLUDE "${MYLIB_GENERATED_DIR}/include")

# Version header from include/mylib/version.hpp.in
configure_file(
  "${PROJECT_SOURCE_DIR}/include/mylib/version.hpp.in"
  "${MYLIB_GENERATED_INCLUDE}/mylib/version.hpp"
  @ONLY)

# Symbol-visibility export macros (MYLIB_EXPORT, ...).
generate_export_header(mylib
  BASE_NAME mylib
  EXPORT_FILE_NAME "${MYLIB_GENERATED_INCLUDE}/mylib/mylib_export.h")

# Public headers via FILE_SET so install() places them correctly.
target_sources(mylib
  PUBLIC
    FILE_SET public_headers TYPE HEADERS
      BASE_DIRS "${PROJECT_SOURCE_DIR}/include"
      FILES
        "${PROJECT_SOURCE_DIR}/include/mylib/mylib.hpp"
        "${PROJECT_SOURCE_DIR}/include/mylib/sum.hpp"
    FILE_SET generated_headers TYPE HEADERS
      BASE_DIRS "${MYLIB_GENERATED_INCLUDE}"
      FILES
        "${MYLIB_GENERATED_INCLUDE}/mylib/version.hpp"
        "${MYLIB_GENERATED_INCLUDE}/mylib/mylib_export.h")

target_compile_features(mylib PUBLIC cxx_std_26)

set_target_properties(mylib PROPERTIES
  VERSION "${PROJECT_VERSION}"
  SOVERSION "${PROJECT_VERSION_MAJOR}"
  EXPORT_NAME mylib)

# A static build needs MYLIB_STATIC_DEFINE so the export macros expand to empty,
# both here and for consumers (hence PUBLIC, which is carried into the export).
get_target_property(_mylib_type mylib TYPE)
if(_mylib_type STREQUAL "STATIC_LIBRARY")
  target_compile_definitions(mylib PUBLIC MYLIB_STATIC_DEFINE)
endif()

# Instrumentation + warnings. Wrapped in BUILD_INTERFACE so these internal
# INTERFACE helpers are used while building mylib but are NOT pulled into the
# installed/exported package (a static lib would otherwise export its PRIVATE
# link deps).
target_link_libraries(mylib PRIVATE
  $<BUILD_INTERFACE:mylib_warnings>
  $<BUILD_INTERFACE:mylib_sanitizers>
  $<BUILD_INTERFACE:mylib_coverage>)

# --- Install / export -------------------------------------------------------
install(TARGETS mylib
  EXPORT mylib-targets
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  FILE_SET public_headers DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  FILE_SET generated_headers DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

set(MYLIB_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/mylib")

install(EXPORT mylib-targets
  FILE mylib-targets.cmake
  NAMESPACE mylib::
  DESTINATION "${MYLIB_INSTALL_CMAKEDIR}")

configure_package_config_file(
  "${PROJECT_SOURCE_DIR}/cmake/package-config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/mylib-config.cmake"
  INSTALL_DESTINATION "${MYLIB_INSTALL_CMAKEDIR}")

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/mylib-config-version.cmake"
  VERSION "${PROJECT_VERSION}"
  COMPATIBILITY SameMajorVersion)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/mylib-config.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/mylib-config-version.cmake"
  DESTINATION "${MYLIB_INSTALL_CMAKEDIR}")
