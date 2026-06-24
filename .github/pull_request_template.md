<!-- Thanks for contributing! Keep this project TDD-first. -->

## What changed?
<!-- Concise summary of the diff. -->

## Why?
<!-- Context: the problem this solves. Link issues: Closes #NNN -->

## How was it tested?
1. `make test`  <!-- and any sanitizer/coverage runs relevant to the change -->

## Checklist
- [ ] **A failing test was written first** (TDD), then the implementation made it pass
- [ ] `make test` is green locally
- [ ] New/changed public API has Doxygen comments (`@brief` / `@param` / `@returns`)
- [ ] `make lint` passes (clang-format + clang-tidy)
- [ ] Follows `docs/design/coding-standards.md`
- [ ] Commits use Conventional Commits (`feat:` / `fix:` / `docs:` …)
- [ ] No secrets committed
