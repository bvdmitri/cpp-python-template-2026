# Contributing

Thanks for contributing! This project is **test-driven** and tooling-heavy on
purpose. Please read [AGENTS.md](AGENTS.md) and
[docs/design/coding-standards.md](docs/design/coding-standards.md) first.

## Prerequisites

- A C++26 compiler (GCC 16+, Clang 18+, or MSVC 19.4x+)
- CMake ≥ 3.28 and Ninja
- GNU Make (Windows: WSL or Git-Bash; or use the `cmake --preset` commands)
- Optional: [vcpkg](https://vcpkg.io) (set `VCPKG_ROOT`), `pre-commit`, Doxygen

## The TDD workflow (required)

Every behavioral change starts with a failing test:

1. Add/extend a test in `test/` (Catch2).
2. `make test` → confirm it **fails**.
3. Implement the minimal code under `include/mylib/` + `src/`.
4. `make test` → green.
5. `make lint` → clean; add Doxygen comments to new public API.
6. Commit using [Conventional Commits](https://www.conventionalcommits.org/)
   (`feat:`, `fix:`, `docs:`, …).

```bash
make help        # list all tasks
make test        # the everyday loop
make asan        # check under sanitizers
make coverage    # open out/coverage/html/index.html
make lint        # clang-format + clang-tidy + hooks
```

Install the git hooks once: `pre-commit install`.

## Set up your IDE

The project is **editor-agnostic**: every editor uses the same
`compile_commands.json` (generated on configure and symlinked to the repo root)
through **clangd**, so completion, diagnostics, and go-to-definition are identical
everywhere. Run `make configure` (or `make build`) once first to generate it.

### Neovim
- Install **clangd** via your LSP manager (`mason.nvim` → `clangd`, wired with
  `nvim-lspconfig`). It auto-discovers `compile_commands.json` at the repo root
  (see `.clangd`). clang-tidy diagnostics are on by default via that config.
- Drive presets from the CLI (`make build` / `make test`) or a plugin like
  `Civitasv/cmake-tools.nvim`.
- Run/debug tests with `nvim-neotest/neotest` + a Catch2 adapter, or
  `mfussenegger/nvim-dap` against `out/build/dev/test/mylib_tests`.

### VS Code
- Accept the recommended extensions (`.vscode/extensions.json`): **clangd** and
  **CMake Tools**. The shared `.vscode/settings.json` disables the built-in
  C/C++ IntelliSense in favor of clangd and enables presets.
- Pick the `dev` preset in the CMake Tools status bar; build/test from there.
  The Catch2 Test Explorer adapter lists individual test cases.

### CLion
- Open the folder; CLion auto-detects `CMakePresets.json` — enable the `dev`
  preset. Enable **"Use .clang-tidy file"** and **"ClangFormat"** in Settings so
  the IDE matches CI exactly. CTest integration runs the Catch2 suite.

Whatever the editor: configure once, then **write a failing test first**.

## Pull requests

- Fill out the PR template checklist (TDD, green suite, lint, Doxygen, standards).
- Keep PRs focused. Link issues (`Closes #NNN`).
- CI must pass: build/test matrix, sanitizers, coverage, lint, CodeQL.
- Architectural changes need an ADR under `docs/design/adr/` (see the template).

## Reporting issues

Use the issue templates (bug report / feature request). For security issues, see
[SECURITY.md](SECURITY.md) — do **not** open a public issue.
