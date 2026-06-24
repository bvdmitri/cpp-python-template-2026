# ============================================================================
# mylib — primary task runner.
#
# This Makefile is the friendly front door over CMake presets + ctest. Humans
# and agents should prefer `make <target>` for everyday work; the underlying
# `cmake --preset ...` commands (shown in AGENTS.md) remain available for the
# rare case that needs something not exposed here.
#
# Run `make help` (the default) to list every target.
# ============================================================================

# Override on the command line, e.g. `make install PREFIX=/usr/local`.
PREFIX     ?= out/install/dev
COV_DIR    ?= out/coverage
PY         ?= 3.12       # Python version for uv-driven targets

.DEFAULT_GOAL := help

# ---- Meta ------------------------------------------------------------------

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "; print "mylib — make targets:\n"} \
	     /^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}' \
	     $(MAKEFILE_LIST)

# ---- Build / test (everyday TDD loop) --------------------------------------

.PHONY: configure
configure: ## Configure the dev preset
	cmake --preset dev

.PHONY: build
build: ## Configure + build (Debug)
	cmake --preset dev
	cmake --build --preset dev

.PHONY: test
test: build ## Build then run the full test suite (the everyday TDD command)
	ctest --preset dev

.PHONY: release
release: ## Configure + build the Release preset
	cmake --preset release
	cmake --build --preset release

.PHONY: check
check: test py-check ## Run BOTH pipelines: C++ tests + Python lint/types/tests
	@echo "All C++ and Python checks passed."

# ---- Sanitizers ------------------------------------------------------------

.PHONY: asan
asan: ## Build + test under AddressSanitizer + UBSan
	cmake --preset asan
	cmake --build --preset asan
	ctest --preset asan

.PHONY: tsan
tsan: ## Build + test under ThreadSanitizer
	cmake --preset tsan
	cmake --build --preset tsan
	ctest --preset tsan

# ---- Coverage --------------------------------------------------------------

.PHONY: coverage
coverage: ## Build + test with coverage, then emit an inspectable HTML + lcov report
	cmake --preset coverage
	cmake --build --preset coverage
	@rm -rf $(COV_DIR) && mkdir -p $(COV_DIR)
	LLVM_PROFILE_FILE="$(CURDIR)/$(COV_DIR)/mylib-%p.profraw" ctest --preset coverage
	@bash scripts/coverage.sh "$(CURDIR)/out/build/coverage" "$(CURDIR)/$(COV_DIR)"
	@echo "Open $(COV_DIR)/html/index.html"

# ---- Quality ---------------------------------------------------------------

.PHONY: lint
lint: ## Run all pre-commit hooks (clang-format + clang-tidy + misc) on all files
	pre-commit run --all-files

.PHONY: format
format: ## Format all C++ sources in place with clang-format
	@find include src test -name '*.hpp' -o -name '*.cpp' -o -name '*.h' | xargs clang-format -i
	@echo "Formatted."

.PHONY: tidy
tidy: configure ## Run clang-tidy over the compile database
	clang-tidy -p out/build/dev $$(find include src test -name '*.cpp')

.PHONY: format-check
format-check: ## Check formatting without modifying files (CI-friendly)
	@find include src test standalone bindings -name '*.hpp' -o -name '*.cpp' -o -name '*.h' \
	  | xargs clang-format --dry-run -Werror
	@echo "Formatting OK."

# ---- Standalone consumer example ------------------------------------------

.PHONY: standalone
standalone: install ## Build the standalone example against the installed library
	cmake -S standalone -B out/build/standalone -G Ninja -DCMAKE_PREFIX_PATH="$(CURDIR)/$(PREFIX)"
	cmake --build out/build/standalone
	@echo "Run: ./out/build/standalone/mylib_standalone"

# ---- Python bindings (uv-driven; `uv run` builds + installs the project) ----
# These mirror the C++ quality gates for the Python side. `uv run` builds the
# nanobind extension via scikit-build-core and installs the typed `mylib` package
# into a managed env, so `import mylib` resolves with stubs.

UVRUN = uv run --python $(PY) --group dev

.PHONY: python-test
python-test: ## Run the Python binding tests (pytest via uv)
	$(UVRUN) pytest

.PHONY: py-lint
py-lint: ## Lint + format-check Python (ruff)
	$(UVRUN) ruff check .
	$(UVRUN) ruff format --check .

.PHONY: py-format
py-format: ## Auto-format Python sources (ruff)
	$(UVRUN) ruff format .
	$(UVRUN) ruff check --fix .

.PHONY: py-typecheck
py-typecheck: ## Strict static type-check the bindings (mypy)
	$(UVRUN) mypy

.PHONY: py-coverage
py-coverage: ## Python tests with coverage (HTML + xml), via uv
	$(UVRUN) pytest --cov=mylib --cov-branch \
	  --cov-report=term --cov-report=xml:out/coverage/python/coverage.xml \
	  --cov-report=html:out/coverage/python/html
	@echo "Open out/coverage/python/html/index.html"

.PHONY: py-check
py-check: py-lint py-typecheck python-test ## All Python gates: lint + types + tests

.PHONY: wheel
wheel: ## Build a wheel with scikit-build-core (uv)
	uv build --wheel --python $(PY)

.PHONY: wheel-test
wheel-test: wheel ## Build the wheel and run pytest against the installed wheel
	uv run --python $(PY) --with "$$(ls -t dist/*.whl | head -1)" --group dev \
	  pytest bindings/python/tests -q

# ---- Docs (unified C++ + Python site: Doxygen XML -> Breathe -> Sphinx) -----

.PHONY: docs
docs: ## Build the unified documentation site (C++ + Python) via uv
	@mkdir -p docs/_build/doxygen
	cd docs && doxygen Doxyfile
	$(UVRUN) --group docs sphinx-build -b html docs docs/_build/html
	@echo "Open docs/_build/html/index.html"

.PHONY: docs-serve
docs-serve: docs ## Build docs and serve them locally
	$(UVRUN) --group docs python -m http.server -d docs/_build/html 8000

# ---- Install / clean -------------------------------------------------------

.PHONY: install
install: build ## Install into PREFIX (default: out/install/dev)
	cmake --install out/build/dev --prefix $(PREFIX)

.PHONY: clean
clean: ## Remove all build/coverage output
	rm -rf out $(COV_DIR)
