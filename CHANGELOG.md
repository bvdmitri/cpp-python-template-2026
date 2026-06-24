# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Releases are automated from [Conventional Commits](https://www.conventionalcommits.org/)
via release-please, so prefer letting automation update this file.

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

[Unreleased]: https://github.com/your-org/mylib/commits/main
