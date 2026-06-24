# Dependency Management

How this project acquires, pins, and exposes dependencies — and exactly how to
add or remove one. Linked from [AGENTS.md](../../AGENTS.md).

## Model: vcpkg manifest, with a FetchContent fallback

The project uses **[vcpkg](https://vcpkg.io) in manifest mode** as the primary
dependency manager, with a **CMake FetchContent fallback** so the project still
builds when vcpkg isn't present. Three files cooperate:

| File | Role |
|------|------|
| `vcpkg.json` | The manifest: declares dependencies, version constraints, the pinned baseline, and optional features. |
| `CMakePresets.json` / root `CMakeLists.txt` | Wires the vcpkg toolchain via `VCPKG_ROOT` (never a hardcoded path) and selects manifest features. |
| `cmake/package-config.cmake.in` | Re-discovers **public** dependencies for downstream consumers via `find_dependency()`. |

### vcpkg.json anatomy

```jsonc
{
  "name": "mylib",
  "version": "0.1.0",
  "builtin-baseline": "<a vcpkg commit SHA>", // pins ALL transitive versions
  "dependencies": [],                          // runtime/build deps of the library
  "default-features": [],                       // a library should keep this empty
  "features": {
    "tests": {                                  // opt-in deps, requested by presets
      "description": "Dependencies for the test suite",
      "dependencies": [{ "name": "catch2", "version>=": "3.7.1" }]
    }
  }
}
```

- **`builtin-baseline`** is a commit SHA of the vcpkg registry; it locks the
  versions of every dependency so builds are reproducible across machines/CI.
- **Features** keep optional deps (like the test framework) out of a consumer's
  build. The presets request the `tests` feature via `VCPKG_MANIFEST_FEATURES=tests`.
- **`default-features: []`** — for a *library*, don't pull optional deps by default.

### How dependencies reach the build

1. If `VCPKG_ROOT` is set, the root `CMakeLists.txt` (or a preset) points
   `CMAKE_TOOLCHAIN_FILE` at vcpkg, which installs the manifest and makes
   `find_package(<dep>)` work.
2. `test/CMakeLists.txt` shows the **fallback pattern**: it tries
   `find_package(Catch2 3 QUIET CONFIG)` and, if not found, pulls the dependency
   with `FetchContent` (marked `SYSTEM` so the dep's headers don't trip our strict
   warnings). Use this same pattern for any dependency that should be optional or
   that must work without vcpkg.

### CI binary caching

In CI, use `lukka/run-vcpkg` with GitHub Actions cache / NuGet-on-GitHub-Packages
for binary caching (note: the old `x-gha` provider was removed in June 2025).
`dependabot.yml` watches `vcpkg` for updates.

## How to ADD a dependency

Say you want `fmt` as a **public** dependency (it appears in your headers):

1. **Declare it** in `vcpkg.json`:
   ```jsonc
   "dependencies": [{ "name": "fmt", "version>=": "11.0.0" }]
   ```
2. **Find & link it** in CMake (`src/CMakeLists.txt`):
   ```cmake
   find_package(fmt CONFIG REQUIRED)
   target_link_libraries(mylib PUBLIC fmt::fmt)   # PUBLIC: it's in our headers
   ```
   Use `PRIVATE` instead if the dependency is an implementation detail not exposed
   in public headers (most cases) — that keeps it out of the consumer's interface.
3. **Propagate to consumers** *only if PUBLIC*: add to `cmake/package-config.cmake.in`
   so `find_package(mylib)` re-discovers it:
   ```cmake
   include(CMakeFindDependencyMacro)
   find_dependency(fmt)
   ```
4. **(Optional) update the baseline** to a newer vcpkg SHA if you need a newer
   version than the current baseline provides:
   `vcpkg x-update-baseline` (or set `builtin-baseline` to a fresh commit).
5. **Rebuild**: `make build` (vcpkg installs the dep) and re-run `make test`.

> Per [AGENTS.md](../../AGENTS.md), **adding a dependency is an "ASK" action** —
> confirm with a human and consider an ADR for non-trivial deps.

## How to REMOVE a dependency

Reverse the steps: remove the `target_link_libraries` entry and any `#include`s,
delete the `find_package`/`find_dependency` lines, remove it from `vcpkg.json`,
rebuild, and confirm `make test` + `make lint` stay green.

## Adding test-only or optional dependencies

Put them under a **feature** in `vcpkg.json` (like `tests`) and request the
feature from the preset, or use the **FetchContent fallback** pattern in the
relevant `CMakeLists.txt`. This keeps them out of a normal consumer build.

## Python dependencies (bindings)

The Python bindings have their own dependency story driven by **`uv`** and
`pyproject.toml` (see [python-compatibility.md](python-compatibility.md)):

- **Build deps** (PEP 517): `nanobind`, `scikit-build-core` under `[build-system].requires`.
- **Dev/docs tooling** via PEP 735 **dependency groups** in `pyproject.toml`:
  - `[dependency-groups] dev` — `pytest`, `pytest-cov`, `mypy`, `ruff`.
  - `[dependency-groups] docs` — `sphinx`, `furo`, `breathe`, `myst-parser`, …
  - Use them with `uv run --group dev <cmd>` (the `make py-*` targets do this).
- **Add a Python dev dependency**: add it to the relevant group in `pyproject.toml`;
  `uv` resolves it on the next `uv run` (and updates `uv.lock`). **Runtime** deps of
  the bindings themselves go under `[project].dependencies`.
- `uv` provides and pins the interpreter; `uv.lock` pins the resolved versions.

The C++ core never depends on any Python tooling; `requires-python` is `>=3.10`.

## Alternatives (not used here)

- **[CPM.cmake](https://github.com/cpm-cmake/CPM.cmake)** — a thin FetchContent
  wrapper; zero external tooling, source builds. Great when you want no package
  manager at all. Our FetchContent fallback already covers the "works without a
  package manager" case.
- **[Conan 2](https://conan.io)** — powerful profiles for complex cross-compile
  matrices and binary caching.
- **[PackageProject.cmake](https://github.com/TheLartians/PackageProject.cmake)** —
  collapses the install/export boilerplate we write by hand in `src/CMakeLists.txt`.

If you prefer one of these, it's a deliberate, documented switch — record it as an
ADR under `adr/`.
