# Test-Driven Development

TDD is the cornerstone of this project. This document is the full treatment;
[AGENTS.md](../../AGENTS.md) has the short version every contributor and agent
must follow. **No behavioral change lands without a failing test written first.**

## Why TDD here

- The shipped feature is trivial; the point of the template is *discipline*. TDD
  is the habit that keeps a real library correct as it grows.
- Tests written first are tests that actually exercise the new behavior (a test
  written after the code tends to assert what the code already does).
- A always-green suite + CI gate means every commit is a known-good state.

## The loop (Red → Green → Refactor)

1. **Red** — Write or extend a Catch2 `TEST_CASE` / `SCENARIO` in `test/`
   describing the desired behavior. Run `make test` and **watch it fail**. A test
   that passes immediately proves nothing — make sure it fails for the right
   reason (assertion failure, not a compile error in the test itself once the API
   exists).
2. **Green** — Write the *minimal* code in `include/mylib/` + `src/` to make that
   test pass. Resist adding anything the test doesn't require.
3. **Refactor** — With the suite green, improve names, structure, and performance.
   Add Doxygen to new public symbols. Run `make lint`. The tests are your safety
   net.
4. Repeat in small increments. Commit at green using Conventional Commits.

## Writing good tests with Catch2 v3

### Plain assertions

```cpp
TEST_CASE("sum adds two integers", "[sum]") {
    REQUIRE(mylib::sum(2, 3) == 5);   // REQUIRE: abort this test on failure
    CHECK(mylib::sum(-1, 1) == 0);    // CHECK: report but keep going
}
```

- `REQUIRE` stops the test case on failure (use when later lines depend on it).
- `CHECK` keeps going (use to collect several independent assertions).
- `REQUIRE_THROWS_AS(expr, Type)` / `REQUIRE_NOTHROW(expr)` for exceptions.
- `STATIC_REQUIRE(...)` asserts a `constexpr` condition at compile time.

### Sections (shared setup, independent branches)

```cpp
TEST_CASE("vector grows", "[vector]") {
    std::vector<int> v;          // re-run fresh for EACH section
    SECTION("push_back increases size") { v.push_back(1); REQUIRE(v.size() == 1); }
    SECTION("reserve doesn't change size") { v.reserve(10); REQUIRE(v.empty()); }
}
```

### BDD style

```cpp
SCENARIO("summing balances", "[sum][bdd]") {
    GIVEN("a starting balance") {
        int balance = 100;
        WHEN("a deposit is added") {
            int updated = mylib::sum(balance, 50);
            THEN("it increases by the deposit") { REQUIRE(updated == 150); }
        }
    }
}
```

### Matchers & floating point

```cpp
using Catch::Matchers::WithinRel;
REQUIRE_THAT(mylib::sum(0.1, 0.2), WithinRel(0.3, 1e-12)); // never == on floats
```

### Tags & naming

- Name the *behavior*, not the function: `"sum returns zero for opposite values"`.
- Tag with `[component]` (and `[slow]`, `[bdd]`, etc.) so you can filter:
  `ctest`/the test binary can select by tag.

## What and how much to test

- **Public behavior, not implementation.** Test the API contract so you can
  refactor internals freely.
- **Edge cases**: empty/zero, negatives, boundaries, overflow, error paths.
- **Error handling**: assert the right exception type / `std::expected` error.
- Follow **Arrange–Act–Assert**: set up inputs, perform the action, assert the
  outcome — one logical behavior per test case.
- Prefer **pure functions** and dependency injection; they're trivial to test. If
  something is hard to test, that's a design smell — fix the design.
- Use fakes/mocks sparingly (Catch2 has no built-in mocking; hand-write small
  fakes or inject interfaces). Don't mock what you don't own.

## Coverage

Coverage is a *guide*, not a target to game. Run `make coverage` for an
inspectable HTML + lcov report (`out/coverage/html/index.html`); CI uploads it to
Codecov. Aim high on core logic; don't chase 100% by testing trivial getters.
Uncovered lines are a prompt: "is this behavior specified by a test?"

## How CI enforces it

`make test` runs the full Catch2 suite (each `TEST_CASE`/`SCENARIO` is a CTest
case via `catch_discover_tests`). CI runs it on every push/PR across the
Linux/macOS/Windows × x86_64/arm64 matrix, plus sanitizer and coverage lanes. A
red test fails the job; with branch protection, that blocks the merge. The PR
template has a checkbox affirming a test was written first.

## Python bindings — same discipline, Python tools

The Python bindings are a first-class part of the project and follow the same
TDD/quality discipline with the Python ecosystem's tools (all `uv`-driven):

- **Tests**: pytest under `bindings/python/tests/` (`make python-test`). Write the
  failing test first, same loop. These cover the *binding wiring* (overloads,
  keyword args, exception mapping); the arithmetic itself is already covered by
  the C++ suite — don't duplicate logic tests in Python.
- **Lint/format**: `ruff` (`make py-lint`) — the analogue of clang-format +
  clang-tidy.
- **Types**: `mypy --strict` (`make py-typecheck`) against the generated `.pyi`
  stubs — annotate tests too (`-> None`), and mark intentionally ill-typed calls
  with `# type: ignore[...]`.
- **Coverage**: `coverage.py` via `pytest-cov` (`make py-coverage`), uploaded to
  Codecov under the `python` flag (C++ under `cpp`).

`make py-check` runs lint + types + tests; `make check` runs the C++ and Python
pipelines together. CI enforces them in `python.yml`. See
[python-compatibility.md](python-compatibility.md) for the toolchain details.
