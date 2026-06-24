"""Python-side tests for the mylib bindings.

These verify the *binding wiring* (overload resolution, keyword args, exception
mapping, exposed metadata) — the arithmetic itself is covered by the C++ Catch2
suite. Works both against an installed wheel (``import mylib``) and an in-tree
CMake build (``import mylib_ext`` via PYTHONPATH).
"""

import math

import pytest

try:
    import mylib as m
except ImportError:  # in-tree CMake build exposes the raw extension
    import mylib_ext as m


class TestIntegerSum:
    def test_basic(self):
        assert m.sum(2, 3) == 5

    def test_zero_and_negatives(self):
        assert m.sum(0, 0) == 0
        assert m.sum(-4, 4) == 0
        assert m.sum(-7, -8) == -15

    def test_large_int64(self):
        assert m.sum(9_000_000_000, 1_000_000_000) == 10_000_000_000

    def test_return_type_is_int(self):
        assert isinstance(m.sum(1, 2), int)


class TestFloatSum:
    def test_precision(self):
        assert math.isclose(m.sum(0.1, 0.2), 0.3, rel_tol=1e-12)

    def test_negatives(self):
        assert math.isclose(m.sum(-1.5, 2.5), 1.0, rel_tol=1e-12)

    def test_return_type_is_float(self):
        assert isinstance(m.sum(1.0, 2.0), float)


class TestCallingConventions:
    def test_keyword_arguments(self):
        assert m.sum(a=20, b=22) == 42

    def test_mixed_positional_keyword(self):
        assert m.sum(20, b=22) == 42

    def test_wrong_type_raises_type_error(self):
        # nanobind raises TypeError when no overload matches.
        with pytest.raises(TypeError):
            m.sum("a", "b")

    def test_missing_argument_raises_type_error(self):
        with pytest.raises(TypeError):
            m.sum(1)


class TestModuleMetadata:
    def test_version_is_semver_string(self):
        assert isinstance(m.__version__, str)
        assert m.__version__.count(".") == 2

    def test_sum_has_docstring(self):
        assert m.sum.__doc__ is not None
        assert "sum" in m.sum.__doc__.lower()
