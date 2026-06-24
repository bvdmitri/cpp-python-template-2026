# Sanitizer + coverage instrumentation, exposed as INTERFACE targets that are
# linked PRIVATELY into the things we want instrumented (library + tests).
#
#   -DMYLIB_SANITIZER="address;undefined"   # ASan + UBSan
#   -DMYLIB_SANITIZER=thread                # TSan
#   -DMYLIB_ENABLE_COVERAGE=ON              # coverage instrumentation
#
# Driven via CMakePresets (asan / tsan / coverage) so contributors never type
# these flags by hand.

add_library(mylib_sanitizers INTERFACE)
add_library(mylib::sanitizers ALIAS mylib_sanitizers)

if(MYLIB_SANITIZER AND NOT MSVC)
  string(REPLACE ";" "," _mylib_san "${MYLIB_SANITIZER}")
  message(STATUS "mylib: enabling sanitizer(s): ${_mylib_san}")
  target_compile_options(mylib_sanitizers INTERFACE
      -fsanitize=${_mylib_san} -fno-omit-frame-pointer -g)
  target_link_options(mylib_sanitizers INTERFACE -fsanitize=${_mylib_san})
elseif(MYLIB_SANITIZER AND MSVC)
  # MSVC supports AddressSanitizer; map the common case.
  if(MYLIB_SANITIZER MATCHES "address")
    target_compile_options(mylib_sanitizers INTERFACE /fsanitize=address)
  endif()
endif()

add_library(mylib_coverage INTERFACE)
add_library(mylib::coverage ALIAS mylib_coverage)

if(MYLIB_ENABLE_COVERAGE)
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message(STATUS "mylib: enabling LLVM source-based coverage")
    target_compile_options(mylib_coverage INTERFACE
        -fprofile-instr-generate -fcoverage-mapping)
    target_link_options(mylib_coverage INTERFACE -fprofile-instr-generate)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    message(STATUS "mylib: enabling gcov coverage")
    target_compile_options(mylib_coverage INTERFACE --coverage)
    target_link_options(mylib_coverage INTERFACE --coverage)
  else()
    message(WARNING "mylib: coverage not supported for ${CMAKE_CXX_COMPILER_ID}")
  endif()
endif()
