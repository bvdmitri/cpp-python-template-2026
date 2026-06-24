# ----------------------------------------------------------------------------
# Documentation: Doxygen themed with doxygen-awesome-css, deployable to Pages.
#
# Enable with -DMYLIB_BUILD_DOCS=ON (the `docs` preset does this) and build the
# `docs` target:  cmake --build --preset docs
# ----------------------------------------------------------------------------
find_package(Doxygen REQUIRED)

include(FetchContent)
FetchContent_Declare(doxygen-awesome-css
  GIT_REPOSITORY https://github.com/jothepro/doxygen-awesome-css.git
  GIT_TAG v2.3.4
  GIT_SHALLOW TRUE)
FetchContent_MakeAvailable(doxygen-awesome-css)
FetchContent_GetProperties(doxygen-awesome-css SOURCE_DIR AWESOME_CSS_DIR)

# Graphviz (dot) is optional: enable diagrams only when available so the build
# never fails on its absence.
if(DOXYGEN_DOT_EXECUTABLE)
  set(DOXYGEN_HAVE_DOT YES)
else()
  set(DOXYGEN_HAVE_DOT NO)
endif()

set(DOXYGEN_AWESOME_CSS_DIR "${AWESOME_CSS_DIR}")
# Doxygen covers the public API headers + the main page only. The design docs
# under docs/design/ are repo-facing prose (read in-tree by humans and agents),
# not part of the generated API site.
set(DOXYGEN_INPUT_DIR "${PROJECT_SOURCE_DIR}/include ${PROJECT_SOURCE_DIR}/docs/index.md")
set(DOXYGEN_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
set(DOXYGEN_PROJECT_NUMBER "${PROJECT_VERSION}")

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in"
  "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile"
  @ONLY)

add_custom_target(docs
  COMMAND ${DOXYGEN_EXECUTABLE} "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile"
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
  COMMENT "Generating API documentation with Doxygen"
  VERBATIM)
