# Guide

## Installing the C++ library

**vcpkg** (manifest mode) or **CMake FetchContent**:

```cmake
include(FetchContent)
FetchContent_Declare(mylib
  GIT_REPOSITORY https://github.com/your-org/mylib.git
  GIT_TAG v0.1.0)
FetchContent_MakeAvailable(mylib)
target_link_libraries(your_app PRIVATE mylib::mylib)
```

After `cmake --install`, consumers use `find_package`:

```cmake
find_package(mylib CONFIG REQUIRED)
target_link_libraries(your_app PRIVATE mylib::mylib)
```

## Installing the Python bindings

The bindings build as a standard wheel (nanobind + scikit-build-core):

```bash
uv pip install mylib       # from a registry, once published
# or, from a checkout:
uv build --wheel && uv pip install dist/*.whl
```

```python
import mylib
print(mylib.sum(2, 3))      # 5
```

The package ships type stubs (`mylib_ext.pyi`, `py.typed`), so it is fully typed
for editors and `mypy`.

## Building from source

```bash
make test          # C++ build + Catch2 tests (the TDD loop)
make python-test   # build + test the Python bindings (via uv)
make check         # run BOTH pipelines
make docs          # build this documentation site
```

See the repository's `AGENTS.md` and `docs/design/` for the contributor workflow,
coding standards, and architecture decisions.
