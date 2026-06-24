# mylib

[![CI](https://github.com/your-org/mylib/actions/workflows/ci.yml/badge.svg)](https://github.com/your-org/mylib/actions/workflows/ci.yml)
[![Python](https://github.com/your-org/mylib/actions/workflows/python.yml/badge.svg)](https://github.com/your-org/mylib/actions/workflows/python.yml)
[![CodeQL](https://github.com/your-org/mylib/actions/workflows/codeql.yml/badge.svg)](https://github.com/your-org/mylib/actions/workflows/codeql.yml)
[![codecov](https://codecov.io/gh/your-org/mylib/branch/main/graph/badge.svg)](https://codecov.io/gh/your-org/mylib)
[![docs](https://img.shields.io/badge/docs-Sphinx-blue)](https://your-org.github.io/mylib/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![C++26](https://img.shields.io/badge/C%2B%2B-26-blue.svg)](https://en.cppreference.com/w/cpp/26)
[![Python 3.10+](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)

> **This repository is a template, not a finished library.**
> It is a 2026-grade, batteries-included starting point for a modern C++ library.
> The only "feature" it ships is a trivial `sum()` — its real value is the
> infrastructure around it. Clone it, rename `mylib`, delete the toy code, and
> start building. See **[Using this template](#using-this-template)** below.

---

## What this template gives you

A complete, opinionated, **2026 modern C++** project skeleton:

| Area | What's included |
|------|-----------------|
| **Language** | C++26 (`cxx_std_26`), classic headers (modules deliberately avoided for portability) |
| **TDD-first** | Catch2 v3 wired to CTest; the workflow and tooling are built around *failing test → implementation* |
| **Build** | Modern target-based CMake (3.28+), `CMakePresets.json`, namespaced `mylib::mylib`, full `install`/`export` so consumers `find_package(mylib)` |
| **Dependencies** | [vcpkg](https://vcpkg.io) manifest mode (`vcpkg.json`, pinned baseline) — with a transparent FetchContent fallback so it builds without vcpkg too |
| **One front door** | A self-documenting **`Makefile`** (`make help`) wraps every common task |
| **Quality gates** | clang-format, clang-tidy, pre-commit hooks, compiler warnings-as-errors |
| **Sanitizers** | ASan + UBSan and TSan presets/targets |
| **Coverage** | `make coverage` → inspectable HTML + lcov; Codecov upload in CI |
| **CI / CD** | GitHub Actions matrix across **Linux x86_64/arm64, macOS arm64, Windows x64**; CodeQL (build-free); Doxygen → GitHub Pages; release-please |
| **Unified docs** | One [Sphinx](https://www.sphinx-doc.org/) site documenting **both** the C++ API (via Breathe/Doxygen) and the Python API (via autodoc), auto-deployed to Pages |
| **First-class Python** | Integral [nanobind](https://nanobind.readthedocs.io/) bindings (ON by default) with their own full pipeline — pytest, `ruff`, `mypy --strict`, coverage, type stubs, `uv`-driven, dedicated CI + cibuildwheel — see [python-compatibility.md](docs/design/python-compatibility.md) |
| **Combined coverage** | C++ (llvm-cov) and Python (coverage.py) reported together in one repo via Codecov flags (`cpp` / `python`) |
| **Consumer-tested** | A `standalone/` example built against the installed package, verified in CI (validates `find_package`/install) |
| **IDE-agnostic** | Works identically in **Neovim, VSCode, CLion**, … via `compile_commands.json` + clangd (see [CONTRIBUTING](CONTRIBUTING.md)) |
| **Agent-ready** | [`AGENTS.md`](AGENTS.md) (+ `CLAUDE.md`), ADRs, and design docs (coding standards, TDD, dependencies, Python) so LLM coding agents extend the code correctly and safely |

## Quick start

```bash
make test     # configure + build + run the full test suite (the TDD loop)
make help     # see every available task
```

## Use it in your project

**vcpkg:**
```bash
vcpkg install mylib   # once published to a registry
```

**CMake FetchContent:**
```cmake
include(FetchContent)
FetchContent_Declare(mylib
  GIT_REPOSITORY https://github.com/your-org/mylib.git
  GIT_TAG v0.1.0)
FetchContent_MakeAvailable(mylib)
target_link_libraries(your_app PRIVATE mylib::mylib)
```

**After `cmake --install`:**
```cmake
find_package(mylib CONFIG REQUIRED)
target_link_libraries(your_app PRIVATE mylib::mylib)
```

```cpp
#include <mylib/mylib.hpp>
#include <print>
int main() { std::println("{}", mylib::sum(2, 3)); } // 5
```

## Using this template

After cloning, do the following to turn it into your real library:

1. **Rename the placeholder `mylib`.** It is the single token used for the
   namespace, the CMake target/alias (`mylib::mylib`), the package, the
   `include/mylib/` directory, the `MYLIB_*` macros/options, and doc strings.
   Pick a name and find-replace it everywhere, then rename the directory:
   ```bash
   NEW=yourlib
   # Replace contents everywhere (use `sed -i` without '' on GNU/Linux):
   grep -rl --exclude-dir=out --exclude-dir=.git 'mylib\|MYLIB' . \
     | xargs sed -i '' "s/mylib/$NEW/g; s/MYLIB/$(echo $NEW | tr a-z A-Z)/g"   # macOS sed
   # Rename the name-bearing files/dirs (contents are already replaced above):
   git mv include/mylib include/$NEW
   git mv include/$NEW/mylib.hpp include/$NEW/$NEW.hpp
   git mv bindings/python/mylib bindings/python/$NEW   # Python package dir
   ```
   (The Python extension module name `mylib_ext` and the `pyproject.toml` package
   name are updated by the content replace above.)
   Then run `make test` — it should still be green (this is exercised by the
   rename-sanity check in CONTRIBUTING/verification).
2. **Update project metadata**: `project(... VERSION ...)` in `CMakeLists.txt`,
   the `name`/`version`/`homepage`/`description` in `vcpkg.json`, and the
   `your-org/...` URLs in this README, `vcpkg.json`, badges, and workflows.
3. **Set the copyright holder** in `LICENSE` (or swap MIT for another license).
4. **Replace the toy API**: delete `sum.{hpp,cpp}` and `sum_test.cpp`; add your
   own headers under `include/<name>/`, sources under `src/`, tests under `test/`
   (write the failing test first — see [AGENTS.md](AGENTS.md)).
5. **Declare real dependencies** in `vcpkg.json` and re-discover them in
   `cmake/package-config.cmake.in` via `find_dependency(...)` (this file is named
   generically, so renaming the project only touches its *contents*, not its name).
6. **Fill in** `docs/design/architecture-overview.md` and add ADRs as you make
   decisions; tailor `docs/design/coding-standards.md` to your project.
7. **When ready to publish** (and only then): create the GitHub repo, push,
   enable GitHub Pages + Codecov, turn on branch protection (require the CI
   test jobs), and optionally mark the repo a **template** under repo Settings.

## Python bindings (first-class)

Bindings are an integral part of the template (ON by default for a top-level
build) with their own full quality pipeline. With [`uv`](https://docs.astral.sh/uv/):

```bash
make py-check      # ruff + mypy --strict + pytest (the Python gate)
make python-test   # just the pytest suite
make py-coverage   # tests + coverage (HTML + xml)
make wheel         # build a wheel (scikit-build-core)
make check         # run BOTH the C++ and Python pipelines
```

```python
import mylib
mylib.sum(2, 3)        # 5
mylib.__version__      # "0.1.0"
```

See [docs/design/python-compatibility.md](docs/design/python-compatibility.md) for
the binding-friendly API rules and how to expose more of the library.

## Documentation

- **[Unified docs site](https://your-org.github.io/mylib/)** — C++ **and** Python API in one Sphinx site (auto-deployed); build locally with `make docs`
- **[Contributing & IDE setup](CONTRIBUTING.md)** — Neovim / VSCode / CLion + `uv`
- **[Coding standards](docs/design/coding-standards.md)** — stable, fast, safe modern C++
- **[Test-driven development](docs/design/test-driven-development.md)**
- **[Dependency management](docs/design/dependency-management.md)** — add/remove deps
- **[Python compatibility](docs/design/python-compatibility.md)**
- **[Architecture & ADRs](docs/design/)**
- **[Agent guide](AGENTS.md)**

## Requirements

A C++26-capable compiler (GCC 16+, Clang 18+, MSVC 19.4x+), CMake ≥ 3.28, and
Ninja. vcpkg is optional. GNU Make is used for the task runner (Windows: use
WSL/Git-Bash, or call the `cmake --preset` commands directly). For the optional
Python bindings, [`uv`](https://docs.astral.sh/uv/) provides the interpreter and
build tooling.

## License

[MIT](LICENSE).
