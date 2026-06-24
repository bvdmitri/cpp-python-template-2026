"""Sphinx configuration for the unified mylib documentation.

One site documents both languages:
  * C++ API  -> Breathe, reading Doxygen XML (generated into _build/doxygen/xml)
  * Python API -> autodoc, importing the installed `mylib` package

Build with `make docs` (which runs Doxygen, then sphinx-build via uv).
"""

from __future__ import annotations

import os

project = "mylib"
author = "mylib authors"
copyright = "2026, mylib authors"
release = "0.1.0"

extensions = [
    "myst_parser",  # Markdown support
    "breathe",  # C++ API from Doxygen XML
    "sphinx.ext.autodoc",  # Python API from docstrings/stubs
    "sphinx.ext.autosummary",
    "sphinx.ext.napoleon",  # Google/NumPy-style docstrings
    "sphinx.ext.intersphinx",
    "sphinx_copybutton",
]

# Markdown + reStructuredText.
source_suffix = {".rst": "restructuredtext", ".md": "markdown"}
myst_enable_extensions = ["colon_fence", "deflist"]

templates_path = ["_templates"]
exclude_patterns = ["_build", "design", "Thumbs.db", ".DS_Store"]

# --- Theme ------------------------------------------------------------------
html_theme = "furo"
html_title = "mylib"

# --- Breathe (C++) ----------------------------------------------------------
_doxygen_xml = os.path.join(os.path.dirname(__file__), "_build", "doxygen", "xml")
breathe_projects = {"mylib": _doxygen_xml}
breathe_default_project = "mylib"
breathe_default_members = ("members",)

# --- autodoc (Python) -------------------------------------------------------
autosummary_generate = True
autodoc_default_options = {"members": True, "undoc-members": False}
# If the extension cannot be imported (e.g. docs built without the bindings),
# mock it so the build still succeeds.
autodoc_mock_imports = []

intersphinx_mapping = {"python": ("https://docs.python.org/3", None)}

# Teach the C++ domain parser about our visibility macro so it doesn't choke on
# `MYLIB_EXPORT` in declarations pulled from the headers.
cpp_id_attributes = ["MYLIB_EXPORT"]

# Don't fail the whole build if the C++ XML is missing; warn instead.
nitpicky = False
