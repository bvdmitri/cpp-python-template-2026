# Architecture Overview

A map of how this project is structured, intended both for humans and for LLM
coding agents navigating the codebase.

## Big picture

`mylib` is a small, conventional CMake C++ library:

```
include/mylib/   public API (headers) ──┐
                                         ├──> consumers do find_package(mylib)
src/             implementation ─────────┘     and link mylib::mylib
test/            Catch2 tests (drive development via TDD)
docs/            Doxygen + design docs (this folder)
cmake/           build helpers + installed package config
```

There is exactly one library target, `mylib` (alias `mylib::mylib`). It is a
compiled library (static by default; `-DBUILD_SHARED_LIBS=ON` makes it shared)
with hidden default symbol visibility and a generated export header
(`mylib/mylib_export.h`) controlling the exported ABI.

## Build & dependencies

- **CMake** (≥ 3.28), target-based. Entry point `CMakeLists.txt` → `src/` and
  `test/` subdirectories. Configuration is driven by `CMakePresets.json`.
- **Dependencies** via **vcpkg** manifest (`vcpkg.json`), with a FetchContent
  fallback in `test/CMakeLists.txt` so the project also builds without vcpkg.
- **Generated headers**: `version.hpp` (from `version.hpp.in`) and the export
  header are produced at configure time into the build tree and installed.
- **Install/export**: `src/CMakeLists.txt` installs the target + headers and
  generates `mylib-config.cmake` so downstream projects use `find_package(mylib)`.

## Testing & quality flow

```
write failing test (Catch2)  →  make test (red)  →  implement  →  make test (green)
                                                                      │
                          make lint / make tidy ──────────┐          │
                          make asan / make tsan ───────────┼── all green before commit
                          make coverage ───────────────────┘
```

CI (`.github/workflows/`) runs the same steps across Linux x86_64/arm64, macOS
arm64, and Windows x64, plus sanitizers, coverage→Codecov, CodeQL, and Doxygen→
GitHub Pages.

## Key decisions

Significant choices are recorded as ADRs under [`adr/`](adr/) using the MADR
format. Start with [ADR-0001](adr/0001-record-architecture-decisions.md). When
you make an architectural decision, add a new ADR — do not silently change
direction.

## Conventions for agents

- Public API changes need an ADR and a human sign-off (see AGENTS.md).
- The placeholder name `mylib` is the single token to rename when starting a real
  project from this template.
