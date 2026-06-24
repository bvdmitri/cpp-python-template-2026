# Coding Standards — stable, fast, safe, modern C++

This is the binding style and engineering guide for this repository. It is
**required reading before writing code** and is linked from
[AGENTS.md](../../AGENTS.md). The goal: code that is **stable, ultra
high-performance, memory-safe, maintainable, and explainable**, using modern C++
(C++23/26) features *correctly*.

Rules use ✅ (do) / ❌ (avoid). Many are mechanically enforced by `.clang-tidy`
and `.clang-format` — when a rule here and a tool disagree, fix the code, not the
tool. Where this guide is silent, defer (in order) to the
[C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/) and the
[Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html).

## 0. Authoritative sources

- **[C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/)** (Stroustrup/Sutter) — the backbone for safety, lifetime, and resource rules.
- **[Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)** — naming/formatting conventions (we encode ours in `.clang-format` / `.clang-tidy`).
- **GSL** (Guidelines Support Library) — `gsl::span`-style helpers when the standard lacks one (the standard `std::span`/`std::expected` are preferred now).
- **MISRA C++ / AUTOSAR** — only relevant if this project ever targets safety-critical/automotive; not enforced here, but cited if that need arises.

## 1. Memory safety without sacrificing performance

Memory safety in modern C++ comes from **ownership discipline and value
semantics**, not from a GC and not at the cost of speed. (Context: 2024-2026
regulatory pressure — CISA/EU — pushed C++ toward the **Safety Profiles**
direction; WG21 chose Profiles (Stroustrup [P3081]/[P3651]) over "Safe C++".)

- ✅ **RAII for every resource.** Acquisition is initialization; release is the
  destructor. No manual cleanup paths.
- ✅ **Rule of zero.** Design types so the compiler-generated special members are
  correct; you then write none of them. Only when a type *directly manages a
  resource* do you write all five (rule of five) — and prefer wrapping the
  resource in an existing RAII type so you can go back to rule of zero.
- ✅ **Value semantics by default.** Pass and return values; let move semantics
  and copy elision make it cheap. Reach for indirection only when measured.
- ✅ **Ownership is explicit:**
  - `std::unique_ptr<T>` — sole ownership (the default smart pointer).
  - `std::shared_ptr<T>` — *only* for genuine shared ownership (it has atomic
    refcount cost; don't use it as "a pointer that's safe").
  - **Raw pointers / references are non-owning observers only.** A raw pointer
    never owns; never `delete` one.
- ✅ **Non-owning views:** `std::span<T>` for contiguous ranges, `std::string_view`
  for strings. ❌ Never return a view (or store one) that outlives the data it
  refers to — beware binding a `string_view`/`span` to a temporary.
- ✅ Prefer standard containers (`std::vector`, `std::array`) over hand-rolled
  buffers; index with bounds-checked access in debug builds.
- ❌ No naked `new`/`delete`, no `malloc`/`free`, no owning raw pointers.
- ✅ **Adopt Safety Profiles** as compiler/analyzer support matures
  (`Pro.Type`, `Pro.Bounds`, `Pro.Lifetime`) and keep the static-analysis gate
  (`make tidy`, CodeQL) green.

## 2. Performance — measure, never guess

- ✅ **Parameter passing:** cheap-to-copy types by value; large read-only inputs
  by `const&`; "sink" parameters by value then `std::move` into place; forwarding
  references (`T&&` + `std::forward`) only in genuinely generic code.
- ✅ **Let the compiler elide.** Return local values directly; rely on NRVO/copy
  elision. ❌ Do **not** `return std::move(local)` — it *disables* NRVO.
- ✅ **Avoid reallocation:** `reserve()` when the size is known; reuse buffers in
  hot loops.
- ✅ **Data-oriented design:** prefer contiguous, cache-friendly layouts; consider
  struct-of-arrays over array-of-structs in hot paths; `std::vector` over
  node-based containers (`list`/`map`) unless you need their semantics.
- ✅ **Compile-time work:** `constexpr`/`consteval` to move computation off the hot
  path; `[[nodiscard]]`; `[[likely]]`/`[[unlikely]]` on measured-hot branches.
- ✅ **`noexcept`** on move constructors/assignment and on functions that truly
  can't throw — it enables container optimizations and better codegen.
- ✅ Avoid virtual dispatch and hidden allocations in inner loops; consider
  `std::pmr` polymorphic allocators when allocation dominates a profile.
- ✅ **No performance claim without a benchmark.** Add micro-benchmarks (Catch2
  `BENCHMARK` or google-benchmark in a `bench/` target) and profile before and
  after. ❌ No premature optimization that hurts readability without data.

## 3. Modern features — used correctly

### Error handling
- ✅ `std::expected<T, E>` for *expected/recoverable* failures (parsing, lookups,
  I/O you handle locally). Mark such functions `[[nodiscard]]`.
- ✅ Exceptions for *exceptional*, non-local error conditions (invariants broken,
  OOM). ❌ Don't use exceptions for ordinary control flow.
- ❌ **Never let exceptions propagate across an ABI / C boundary.** Translate at
  the boundary.

### Contracts (C++26)
- ✅ Express preconditions/postconditions/invariants with **contracts**
  (`pre`, `post`, `contract_assert`) where the toolchain supports them
  (GCC 16.1+ ships experimental support) — they belong in the function
  declaration, where callers can see them.
- ✅ **Contract predicates must be side-effect-free** (no observable state
  changes; they may be evaluated zero or many times).
- ✅ Understand the evaluation modes (ignore / observe / enforce / quick-enforce):
  enforce in dev & CI, relax in release as appropriate. Until contracts are
  broadly available, use `assert` / a project assertion macro with the same
  "side-effect-free predicate" discipline.

### Concurrency / async
- ✅ When async is genuinely needed, prefer the C++26 **`std::execution`
  (senders/receivers, [P2300])** model (reference implementation: NVIDIA
  `stdexec`) over ad-hoc threads/futures.
- ✅ Coroutines are fine for clearly asynchronous or lazy-generator code, but:
  mind the **lifetime of captured state** (a coroutine frame outlives the call;
  don't capture dangling references) and the **per-coroutine heap allocation**
  (measure; use custom allocators if it matters).
- ❌ Don't reach for coroutines/threads where a plain function or algorithm
  suffices.

### General modern usage
- ✅ **Concepts** to constrain templates (clear errors) instead of SFINAE.
- ✅ **Ranges** where they improve clarity over raw loops.
- ✅ `std::optional` for "maybe a value"; structured bindings; designated
  initializers; `std::format`/`std::print` for formatting.
- ✅ Correct `const`-ness and `noexcept`-ness everywhere.

## 4. Maintainability & explainability

- ✅ **const-correctness** by default; make everything `const` that can be.
- ✅ Small, single-responsibility functions with intention-revealing names.
- ✅ Stable public API: don't leak implementation details across headers; use the
  pimpl idiom or careful header design where ABI stability matters.
- ✅ **Header hygiene:** include what you use, nothing more (IWYU-friendly);
  forward-declare where possible; `#pragma once`.
- ✅ **Comment the *why*, not the *what*.** Self-documenting code shows the what.
  Every public symbol carries a Doxygen block (`@brief`/`@param`/`@returns`).
- ✅ Keep functions testable; prefer pure functions and dependency injection over
  hidden global state.
- ✅ **Design the public API to be Python-binding-friendly** — value semantics, no
  owning raw pointers, bindable STL types, and templates kept out of the public
  signature. These rules overlap with the above; see
  [python-compatibility.md](python-compatibility.md) for the full checklist.

## 5. Anti-patterns — reject in review

- ❌ Undefined behavior (signed overflow, OOB access, use-after-free, data races,
  uninitialized reads, strict-aliasing violations).
- ❌ C-style casts — use `static_cast` / `gsl::narrow_cast` / `reinterpret_cast`
  (rare, justified) / `const_cast` (rarer).
- ❌ Function-like macros — use `constexpr`, `inline`, templates, `enum class`.
- ❌ Owning raw pointers; manual memory management.
- ❌ `using namespace` at file/namespace scope in headers.
- ❌ Swallowing errors / empty `catch`; returning error codes silently ignored.
- ❌ Over-templating ("God templates") and premature abstraction.
- ❌ Premature optimization that sacrifices clarity without benchmark evidence.

---

*This document is enforced where possible by `.clang-tidy`, `.clang-format`,
sanitizers, and CodeQL. When you find a rule that should be machine-checked but
isn't, add the check rather than relying on review.*

[P3081]: https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2025/p3081r1.pdf
[P3651]: https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2025/p3651r0.pdf
[P2300]: https://wg21.link/P2300
