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

# ---- Docs ------------------------------------------------------------------

.PHONY: docs
docs: ## Build the Doxygen documentation
	cmake --preset docs
	cmake --build --preset docs

# ---- Install / clean -------------------------------------------------------

.PHONY: install
install: build ## Install into PREFIX (default: out/install/dev)
	cmake --install out/build/dev --prefix $(PREFIX)

.PHONY: clean
clean: ## Remove all build/coverage output
	rm -rf out $(COV_DIR)
