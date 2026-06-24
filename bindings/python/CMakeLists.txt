# ----------------------------------------------------------------------------
# Optional Python bindings (nanobind). Built only when MYLIB_BUILD_PYTHON=ON.
#
# nanobind is resolved via find_package first (scikit-build-core sets nanobind_DIR
# when building a wheel, and `python -m nanobind --cmake_dir` works for local dev);
# if not found, we fall back to FetchContent so `make python` works on a fresh
# checkout. The core C++ library never depends on any of this.
# ----------------------------------------------------------------------------
find_package(Python 3.10 REQUIRED COMPONENTS Interpreter Development.Module)

# Ask the active interpreter where nanobind's CMake config lives, if installed.
if(NOT nanobind_FOUND)
  execute_process(
    COMMAND "${Python_EXECUTABLE}" -m nanobind --cmake_dir
    OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE _mylib_nanobind_dir
    RESULT_VARIABLE _mylib_nanobind_result
    ERROR_QUIET)
  if(_mylib_nanobind_result EQUAL 0 AND IS_DIRECTORY "${_mylib_nanobind_dir}")
    list(APPEND CMAKE_PREFIX_PATH "${_mylib_nanobind_dir}")
  endif()
endif()

find_package(nanobind CONFIG QUIET)

if(NOT nanobind_FOUND)
  message(STATUS "mylib: nanobind not found; fetching with FetchContent")
  include(FetchContent)
  FetchContent_Declare(nanobind
    GIT_REPOSITORY https://github.com/wjakob/nanobind.git
    GIT_TAG v2.13.0
    GIT_SHALLOW TRUE)
  FetchContent_MakeAvailable(nanobind)
endif()

nanobind_add_module(mylib_ext STABLE_ABI NB_STATIC module.cpp)
target_link_libraries(mylib_ext PRIVATE mylib::mylib)

# Generate a PEP 561 type stub (.pyi) from the compiled module so the bindings are
# fully typed (mypy --strict) and documented (Sphinx autodoc). Best-effort: skip
# if this nanobind version predates nanobind_add_stub.
if(COMMAND nanobind_add_stub)
  nanobind_add_stub(mylib_ext_stub
    MODULE mylib_ext
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/stubs/mylib_ext.pyi"
    PYTHON_PATH $<TARGET_FILE_DIR:mylib_ext>
    DEPENDS mylib_ext)
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/stubs/mylib_ext.pyi"
    DESTINATION mylib COMPONENT python)
endif()

# Install the extension into the package directory (scikit-build-core wheel layout).
# Tagged with the `python` component so the wheel ships ONLY the extension, not
# the C++ static lib / headers / CMake config (see install.components in pyproject).
install(TARGETS mylib_ext LIBRARY DESTINATION mylib COMPONENT python)
# Mark the package as typed (PEP 561) so consumers' type checkers use the stubs.
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/mylib/py.typed"
  DESTINATION mylib COMPONENT python)
