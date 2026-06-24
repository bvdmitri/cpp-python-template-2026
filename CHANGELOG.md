# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Releases are automated from [Conventional Commits](https://www.conventionalcommits.org/)
via release-please, so prefer letting automation update this file.

## [0.2.0](https://github.com/bvdmitri/cpp-python-template-2026/compare/mylib-v0.1.0...mylib-v0.2.0) (2026-06-24)


### Features

* add optional Python bindings, design docs, and consumer/install tooling ([ec796c5](https://github.com/bvdmitri/cpp-python-template-2026/commit/ec796c530ccb96a701f2cd1d77c73ead74f16f56))
* make Python bindings a first-class, fully-tooled part of the template ([811b41c](https://github.com/bvdmitri/cpp-python-template-2026/commit/811b41c5bbadb6bf2154100d79550542f1230ee9))
* scaffold 2026-grade modern C++ library template ([f875f00](https://github.com/bvdmitri/cpp-python-template-2026/commit/f875f009931d3f2c473ebd449df714ea8cb5206e))


### Bug Fixes

* green up CI (lint, Python tests, docs site) ([a0152a5](https://github.com/bvdmitri/cpp-python-template-2026/commit/a0152a515f5d6664bb46bf3880c4135a8ed2ec62))

## [Unreleased]

### Added
- Initial template scaffold: C++26 library with `mylib::sum`.
- Target-based CMake with presets, install/export, and a generated export header.
- vcpkg manifest (with FetchContent fallback) and Catch2 v3 test suite.
- Self-documenting `Makefile` task runner.
- Quality tooling: clang-format, clang-tidy, pre-commit, sanitizers, coverage.
- CI: cross-platform/cross-arch matrix, CodeQL, Doxygen→Pages, release-please.
- Docs: Doxygen + doxygen-awesome-css; `AGENTS.md`/`CLAUDE.md`, coding standards,
  architecture overview, and ADRs.
- First-class Python bindings (`bindings/python/`, nanobind, ON by default for a
  top-level build) with their own full quality pipeline: pytest, `ruff`,
  `mypy --strict` against generated type stubs (`.pyi` + `py.typed`), coverage,
  a dedicated `python.yml` CI, and `cibuildwheel` wheels. `uv`-driven throughout
  (`make python-test`/`py-lint`/`py-typecheck`/`py-coverage`/`py-check`/`wheel`).
- Combined coverage for C++ and Python in one repo via Codecov flags
  (`cpp` / `python`, configured in `codecov.yml`).
- Unified documentation: a single Sphinx site documenting both the C++ API
  (Breathe + Doxygen XML) and the Python API (autodoc), replacing the standalone
  Doxygen HTML; `make docs`, deployed by `docs.yml`.
- `make check` runs both the C++ and Python pipelines.
- `standalone/` example consumer + `install.yml` CI validating the install/export path.
- Design docs: `python-compatibility.md`, `test-driven-development.md`,
  `dependency-management.md`.
- `make format-check` target and an in-source-build guard.

[Unreleased]: https://github.com/bvdmitri/cpp-python-template-2026/commits/main
