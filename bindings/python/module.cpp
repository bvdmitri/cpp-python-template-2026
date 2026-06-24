/// @file mylib_ext.cpp
/// @brief nanobind module exposing the mylib C++ API to Python.
///
/// This is an optional component (built only when MYLIB_BUILD_PYTHON=ON). It is a
/// thin translation layer: it adds no logic, it only re-exposes the C++ API. Keep
/// it that way — all behavior lives in the C++ library and is covered by the C++
/// tests; the Python tests just check the binding wiring.
#include <mylib/mylib.hpp>

#include <nanobind/nanobind.h>
#include <nanobind/stl/string.h> // type caster for std::string (used by __version__)

#include <string>

namespace nb = nanobind;
using namespace nb::literals; // enables "name"_a keyword-argument syntax

NB_MODULE(mylib_ext, m)
{
    m.doc() = "Python bindings for the mylib C++ library";

    m.attr("__version__") = std::string{mylib::version};

    // The generic sum() is a template; bindings must expose concrete overloads.
    m.def(
        "sum", [](long long a, long long b) { return mylib::sum(a, b); }, "a"_a, "b"_a,
        "Return the sum of two integers.");

    m.def(
        "sum", [](double a, double b) { return mylib::sum(a, b); }, "a"_a, "b"_a,
        "Return the sum of two floating-point numbers.");
}
