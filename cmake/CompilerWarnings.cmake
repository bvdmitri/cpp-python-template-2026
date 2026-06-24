# Reusable, per-compiler warning flags applied as an INTERFACE target.
# Link `mylib_warnings` PRIVATELY into a target to opt it in.
#
# Warnings are treated as errors only when MYLIB_WARNINGS_AS_ERRORS is ON
# (default ON for top-level builds, so CI fails on new warnings; OFF when this
# project is consumed as a subdirectory so a downstream build is never blocked).

option(MYLIB_WARNINGS_AS_ERRORS "Treat compiler warnings as errors"
       ${PROJECT_IS_TOP_LEVEL})

add_library(mylib_warnings INTERFACE)
add_library(mylib::warnings ALIAS mylib_warnings)

set(_mylib_msvc_warnings /W4 /permissive- /w14640 /w14242 /w14254 /w14263
    /w14265 /w14287 /w14289 /w14296 /w14311 /w14545 /w14546 /w14547 /w14549
    /w14555 /w14619 /w14826 /w14905 /w14906 /w14928 /EHsc)

set(_mylib_gcc_clang_warnings
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion
    -Wnon-virtual-dtor -Wold-style-cast -Wcast-align -Wunused -Woverloaded-virtual
    -Wnull-dereference -Wdouble-promotion -Wformat=2 -Wimplicit-fallthrough)

if(MSVC)
  set(_mylib_warnings ${_mylib_msvc_warnings})
  if(MYLIB_WARNINGS_AS_ERRORS)
    list(APPEND _mylib_warnings /WX)
  endif()
else()
  set(_mylib_warnings ${_mylib_gcc_clang_warnings})
  if(MYLIB_WARNINGS_AS_ERRORS)
    list(APPEND _mylib_warnings -Werror)
  endif()
endif()

target_compile_options(mylib_warnings INTERFACE ${_mylib_warnings})
