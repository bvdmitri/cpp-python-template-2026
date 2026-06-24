# AGENTS.md

Guidance for AI coding agents (and humans) working in this repository. This is
the canonical context file; `CLAUDE.md` is a symlink to it. Read it fully before
making changes. It follows the [agents.md](https://agents.md) convention.

> ⚠️ **`mylib` is a placeholder name.** If this is still a fresh template, the
> first real task is usually to rename it — see "Using this template" in the
> [README](README.md).

## Mission

`mylib` is a modern **C++26** library. The shipped feature (`mylib::sum`) is
intentionally trivial — the substance is the engineering infrastructure:
TDD-first workflow, cross-platform/cross-arch CI, vcpkg dependencies, sanitizers,
coverage, linting, docs, and packaging. Keep that bar. Quality and correctness
beat cleverness.

## Toolchain Registry — prefer `make`

Use these for all normal work. `make help` lists everything.

| Task | Primary command | Verbose fallback |
|------|-----------------|------------------|
| Build (Debug) | `make build` | `cmake --preset dev && cmake --build --preset dev` |
| **Run tests** | `make test` | `ctest --preset dev --output-on-failure` |
| Release build | `make release` | `cmake --preset release && cmake --build --preset release` |
| ASan + UBSan | `make asan` | `cmake --preset asan && cmake --build --preset asan && ctest --preset asan` |
| ThreadSanitizer | `make tsan` | `cmake --preset tsan && …` |
| Coverage (HTML+lcov) | `make coverage` | see `Makefile` / `scripts/coverage.sh` |
| Format | `make format` | `clang-format -i <files>` |
| Lint (format+tidy+hooks) | `make lint` | `pre-commit run --all-files` |
| Static analysis | `make tidy` | `clang-tidy -p out/build/dev <files>` |
| Docs | `make docs` | `cmake --preset docs && cmake --build --preset docs` |
| Install | `make install` | `cmake --install out/build/dev --prefix <p>` |
| Standalone example | `make standalone` | install, then `cmake -S standalone …` |
| Format check (CI) | `make format-check` | `clang-format --dry-run -Werror <files>` |
| **Python** ext + tests | `make python-test` | see `Makefile` (uv-driven) |
| Python wheel | `make wheel` | `uv build --wheel` |

Reach for the verbose `cmake --preset …` form only when you need something the
Makefile doesn't expose (a custom cache variable, a one-off preset, IDE-driven
configure). Otherwise use `make`.

## How to extend this library — TDD is mandatory

**Every behavioral change starts with a failing test.** This is not optional and
is the single most important rule in this repo. The loop:

1. **Red.** Add or extend a Catch2 `TEST_CASE` / `SCENARIO` in `test/` that
   describes the new behavior.
2. **Confirm red.** Run `make test` and verify the new test **fails** (proves it
   actually exercises unwritten behavior).
3. **Green.** Write the *minimal* code in `include/mylib/` + `src/` to make that
   test pass — nothing more.
4. **Confirm green.** Run `make test` until the whole suite passes.
5. **Refactor.** Improve the code with the suite green. Add Doxygen comments to
   any new public API. Run `make lint`.
6. **Commit.** Use [Conventional Commits](https://www.conventionalcommits.org/)
   (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `build:`, `ci:`, `chore:`) so
   release automation can version the change. Use `feat!:` / `BREAKING CHANGE:`
   for incompatible API changes.

New code MUST follow **[docs/design/coding-standards.md](docs/design/coding-standards.md)**
(stable, ultra-performant, memory-safe modern C++). Read it before writing code.

## Judgment Boundaries

**NEVER**
- Write or modify implementation code before a failing test exists for it.
- Leave the test suite red, or commit with `make test` failing.
- Introduce undefined behavior, owning raw pointers, C-style casts, or naked
  `new`/`delete` (see coding-standards.md).
- Commit secrets, credentials, or large binaries.
- Push to a remote / create the GitHub repo unless the human explicitly asks —
  while this is still a template, all work stays local.

**ALWAYS**
- Keep the suite green and `make lint` clean before finishing.
- Add Doxygen comments (`@brief` / `@param` / `@returns`) to new public symbols.
- Prefer reusing existing utilities and the established patterns in this repo.
- Keep changes minimal and focused; match the surrounding style.

**ASK** (pause and confirm with the human) before
- Changing or removing public API / ABI.
- Adding a new third-party dependency (it goes in `vcpkg.json`).
- Making architectural decisions — and record them as an ADR under
  `docs/design/adr/` (see the template there).

## Context Map

| Path | What it is |
|------|------------|
| `include/mylib/` | Public headers (the API surface). `version.hpp`/`mylib_export.h` are generated. |
| `src/` | Library implementation (compiled translation units). |
| `test/` | Catch2 test suite — **write tests here first**. |
| `cmake/` | CMake helpers: warnings, sanitizers, package config template. |
| `bindings/python/` | Optional nanobind Python bindings (OFF by default; `MYLIB_BUILD_PYTHON`). |
| `standalone/` | Example consumer built against the *installed* library (validates install/export). |
| `docs/` | Doxygen config + `design/` (architecture, ADRs, coding standards, TDD, deps, Python). |
| `scripts/` | Helper scripts (e.g. coverage report generation). |
| `.github/` | CI workflows, issue/PR templates, dependabot. |
| `CMakeLists.txt`, `CMakePresets.json`, `vcpkg.json` | Build + dependency definition. |
| `pyproject.toml` | Python wheel build (scikit-build-core); used only for bindings. |
| `Makefile` | Primary task runner (wraps the presets). |

### Design docs (read before working in the relevant area)

- **[coding-standards.md](docs/design/coding-standards.md)** — stable/fast/safe modern C++ (required before writing code).
- **[test-driven-development.md](docs/design/test-driven-development.md)** — the full TDD treatment.
- **[dependency-management.md](docs/design/dependency-management.md)** — how to add/remove dependencies.
- **[python-compatibility.md](docs/design/python-compatibility.md)** — keep new public API binding-friendly.
- **[architecture-overview.md](docs/design/architecture-overview.md)** + **[adr/](docs/design/adr/)** — structure & decisions.

## Conventions

- **C++26**, classic headers (no modules). Namespace `mylib`, target `mylib::mylib`.
- Naming: `lower_case` for functions/variables/namespaces, `CamelCase` for types
  and concepts (enforced by `.clang-tidy`).
- Errors: `std::expected` for recoverable failures; exceptions for the truly
  exceptional; never let exceptions cross an ABI boundary.
- Formatting/linting are enforced (`.clang-format`, `.clang-tidy`); run
  `make lint` — do not hand-format against the style.
- **Design new public API to be Python-binding-friendly** (value semantics, no
  owning raw pointers, bindable types, templates out of the public surface) — see
  [python-compatibility.md](docs/design/python-compatibility.md).
- Python tooling uses **`uv`** (e.g. `make python-test`, `make wheel`). The C++
  core never depends on Python.
