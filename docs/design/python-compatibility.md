# Python Compatibility

This library is designed so that **Python bindings can be added cleanly later**,
even though bindings are not its purpose. This document explains (1) the rules for
writing C++ that binds well to Python, and (2) the optional bindings scaffold that
already ships in `bindings/python/`. Linked from
[AGENTS.md](../../AGENTS.md) and [coding-standards.md](coding-standards.md).

> **Key principle:** *good idiomatic C++ is good bindable C++.* The API-design
> rules below overlap heavily with the coding standards — follow them and the
> library stays binding-ready by default.

## Toolchain (2026)

| Concern | Choice | Why |
|---------|--------|-----|
| Binding generator | **[nanobind](https://nanobind.readthedocs.io/)** | ~4× faster compiles, ~5× smaller, ~10× lower call overhead vs pybind11; stable ABI on CPython 3.12+. Requires C++17 (we're C++26). |
| Build backend | **[scikit-build-core](https://scikit-build-core.readthedocs.io/)** | Modern, TOML-only (`pyproject.toml`), drives CMake to produce wheels. Replaces setuptools. |
| Interpreter / runner | **[uv](https://docs.astral.sh/uv/)** | Fast, reproducible Python/version management; used for all Python tasks here (`make python`, `make wheel`, `make python-test`). |
| Cross-platform wheels | **[cibuildwheel](https://cibuildwheel.pypa.io/)** | Builds Linux/macOS/Windows wheels for many Python versions in CI. |

pybind11 remains a fine fallback if you need C++11 or already depend on it.

## API design rules for binding-friendly C++

### 1. Value semantics for returns; smart pointers for ownership
```cpp
Point translate(const Point& p, double dx);          // ✅ value return — copies cleanly
std::shared_ptr<Widget> make_widget();               // ✅ shared ownership is explicit
std::unique_ptr<Widget> take_widget();               // ✅ move → Python owns it
Widget* borrow();                                     // ❌ raw owning pointer: who frees it?
const Mesh& get_mesh();                               // ⚠️ dangling risk if the C++ object dies
```
nanobind maps `shared_ptr`/`unique_ptr` to natural ownership; raw pointers need an
explicit (and dangerous) return-value policy. **Never expose owning raw pointers.**

### 2. Map errors to exceptions *at the boundary*
- C++ exceptions translate to Python automatically: `std::invalid_argument` →
  `ValueError`, `std::out_of_range` → `IndexError`, others → `RuntimeError`.
- Use **`std::expected` internally** for recoverable errors (per the coding
  standards), but **translate to an exception at the binding layer** — Python
  callers expect exceptions, not a result type. Register a custom translator for
  your own exception types.

### 3. Prefer cleanly-bindable types
- ✅ `std::vector`, `std::string`, `std::optional`, `std::map`, `std::array`,
  `enum class` — nanobind has casters for all of these (include the relevant
  `<nanobind/stl/*.h>`).
- ✅ For numeric arrays, use **`nb::ndarray`** / the buffer protocol — zero-copy
  interop with NumPy, PyTorch, JAX. Don't expose `vector<vector<double>>` matrices.
- ⚠️ `std::function` callbacks are awkward to bind — prefer a virtual interface
  Python can subclass.
- ⚠️ Custom container types require hand-written casters; avoid in the public API.

### 4. Keep templates out of the public API surface
Templates can't be bound directly — each instantiation must be exposed explicitly
in the binding code. Keep the library internals as template-rich as you like, but
present **concrete types** (or factory functions) in the public API so the binding
layer just lists the few instantiations users need. (Our `mylib::sum` is a
constrained template; the binding exposes concrete `int`/`double` overloads.)

### 5. Small, stable public surface (PIMPL)
Hide implementation behind the [PIMPL idiom](https://en.cppreference.com/w/cpp/language/pimpl)
or opaque handles. A stable public API means stable bindings and ABI; changing
internals won't churn the Python layer.

### 6. Release the GIL in long-running calls
For compute-heavy functions, release the GIL so other Python threads run
(nanobind: `nb::call_guard<nb::gil_scoped_release>()`). Keep functions
thread-safe and avoid calling back into Python without re-acquiring the GIL.

### 7. Docstrings, defaults, keyword args
Expose keyword arguments (`"a"_a`), default values, and docstrings in the binding;
source docstrings from the same Doxygen text where practical.

### Binding-readiness checklist (apply to every new public API)
- [ ] Returns by value or smart pointer; no owning raw pointers.
- [ ] Errors are exceptions (or `std::expected` translated at the boundary).
- [ ] Parameters/returns use bindable STL types (or `nb::ndarray` for arrays).
- [ ] No template types leak into the public signature.
- [ ] Long-running? GIL release considered.
- [ ] Public surface minimal and documented (Doxygen).

## The optional bindings scaffold (`bindings/python/`)

Bindings are an **OFF-by-default** component; the C++ core never depends on
Python. Layout:

```
bindings/python/
├── CMakeLists.txt        # nanobind (find_package, FetchContent fallback)
├── module.cpp            # NB_MODULE(mylib_ext): exposes mylib::sum + version
├── mylib/__init__.py     # Python package re-exporting the extension
└── tests/test_sum.py     # pytest: verifies the binding wiring
pyproject.toml            # scikit-build-core + cibuildwheel config
```

Enable with `-DMYLIB_BUILD_PYTHON=ON` (the Makefile/`pyproject.toml` do this for
you). Minimal module skeleton:

```cpp
#include <mylib/mylib.hpp>
#include <nanobind/nanobind.h>
#include <nanobind/stl/string.h>   // a caster is needed for every non-builtin type
namespace nb = nanobind;
using namespace nb::literals;

NB_MODULE(mylib_ext, m) {
    m.attr("__version__") = std::string{mylib::version};
    m.def("sum", [](long long a, long long b) { return mylib::sum(a, b); },
          "a"_a, "b"_a, "Return the sum of two integers.");
}
```
> Gotcha: assigning a `std::string` (or any non-builtin) without including its
> caster (`<nanobind/stl/string.h>`) compiles but throws `std::bad_cast` at import.

## Developer workflow (uv-driven)

```bash
make python        # build the extension in-tree (uv provides Python; nanobind via FetchContent if absent)
make python-test   # pytest the bindings (uv run)
make wheel         # build a wheel with scikit-build-core (uv build)
make wheel-test    # build the wheel and pytest against the installed package
```

`uv` selects the interpreter (`PY=3.12` by default; override: `make python PY=3.11`).
The wheel ships **only** the Python package + extension (the C++ static lib,
headers, and CMake config are installed separately for C++ consumers via
`cmake --install`, controlled by `install.components` in `pyproject.toml`).

## CI

`.github/workflows/wheels.yml` runs **cibuildwheel** (Linux/macOS/Windows) to
produce wheels. It is intentionally **separate from core CI** and triggers on
tags / `workflow_dispatch`, so day-to-day C++ development is never gated on the
Python build. The core CI matrix builds the library with `MYLIB_BUILD_PYTHON` OFF.

## Adding more bindings later

1. Design the new C++ API against the checklist above.
2. Expose it in `bindings/python/mylib_ext.cpp` (`m.def(...)` / `nb::class_<T>`),
   adding the needed `<nanobind/stl/*.h>` casters.
3. Add a pytest in `bindings/python/tests/` (binding wiring only — behavior is
   covered by the C++ suite).
4. `make python-test`, then `make wheel-test`.

## References

- nanobind: https://nanobind.readthedocs.io/  ·  vs pybind11 benchmarks: https://nanobind.readthedocs.io/en/latest/benchmark.html
- scikit-build-core: https://scikit-build-core.readthedocs.io/
- cibuildwheel: https://cibuildwheel.pypa.io/  ·  uv: https://docs.astral.sh/uv/
