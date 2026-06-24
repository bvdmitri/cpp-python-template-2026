"""Python bindings for the mylib C++ library.

The native extension module (``mylib_ext``) is built by nanobind from the C++
library. This package re-exports its public surface so users write ``import
mylib`` rather than importing the raw extension.
"""

from __future__ import annotations

from .mylib_ext import __version__, sum  # noqa: A004 (intentionally shadow builtin)

__all__ = ["__version__", "sum"]
