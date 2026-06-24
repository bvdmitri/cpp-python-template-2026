# mylib API documentation {#mainpage}

**mylib** is a 2026-grade modern C++ library template. This site is the generated
API reference; for the project overview, installation, and contribution guide see
the [GitHub repository](https://github.com/your-org/mylib).

## Getting started

```cpp
#include <mylib/mylib.hpp>
#include <print>

int main()
{
    std::println("{}", mylib::sum(2, 3)); // 5
}
```

## Where to look

- The public API lives in the `mylib` namespace (`mylib::sum`).
- The @ref mylib::Number concept constrains the generic `sum` overload.
- Design rationale and decision records live under `docs/design/` in the source tree.
