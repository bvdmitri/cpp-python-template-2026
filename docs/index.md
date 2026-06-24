# mylib

A **2026-grade modern C++ library template** with first-class, optional Python
bindings. This site documents **both** the C++ API and the Python API in one place.

`mylib` is a placeholder name and the shipped feature (`sum`) is intentionally
trivial — the value of the template is its engineering infrastructure (TDD,
cross-platform CI, sanitizers, coverage, packaging, and these docs). See the
[GitHub repository](https://github.com/bvdmitri/cpp-python-template-2026) for the full project.

```{toctree}
:maxdepth: 2
:caption: Contents

guide
cpp_api
python_api
```

## At a glance

C++:

```cpp
#include <mylib/mylib.hpp>
#include <print>

int main() {
    std::println("{}", mylib::sum(2, 3)); // 5
}
```

Python:

```python
import mylib

mylib.sum(2, 3)    # 5
mylib.__version__  # "0.1.0"
```

## Indices

- {ref}`genindex`
- {ref}`search`
