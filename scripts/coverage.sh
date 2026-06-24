#!/usr/bin/env bash
# Generate an inspectable coverage report (HTML + lcov) from a coverage build.
#
#   scripts/coverage.sh <build-dir> <output-dir>
#
# Auto-detects LLVM (clang, source-based) vs GCC (gcov) instrumentation.
set -euo pipefail

BUILD_DIR="${1:?usage: coverage.sh <build-dir> <output-dir>}"
OUT_DIR="${2:?usage: coverage.sh <build-dir> <output-dir>}"
BIN="${BUILD_DIR}/test/mylib_tests"

mkdir -p "${OUT_DIR}/html"

# Prefer Apple's toolchain wrappers on macOS, otherwise plain binaries.
llvm_tool() {
  if command -v "llvm-$1" >/dev/null 2>&1; then echo "llvm-$1";
  elif xcrun --find "llvm-$1" >/dev/null 2>&1; then echo "xcrun llvm-$1";
  else echo ""; fi
}

PROFRAW_COUNT=$(find "${OUT_DIR}" -name '*.profraw' 2>/dev/null | wc -l | tr -d ' ')

if [ "${PROFRAW_COUNT}" != "0" ]; then
  # ---- LLVM source-based coverage ----
  PROFDATA_TOOL=$(llvm_tool profdata)
  COV_TOOL=$(llvm_tool cov)
  if [ -z "${PROFDATA_TOOL}" ] || [ -z "${COV_TOOL}" ]; then
    echo "error: llvm-profdata / llvm-cov not found" >&2; exit 1
  fi
  ${PROFDATA_TOOL} merge -sparse "${OUT_DIR}"/*.profraw -o "${OUT_DIR}/merged.profdata"
  ${COV_TOOL} show "${BIN}" -instr-profile="${OUT_DIR}/merged.profdata" \
      -format=html -output-dir="${OUT_DIR}/html" \
      -ignore-filename-regex='(_deps|/test/|out/build)'
  ${COV_TOOL} export "${BIN}" -instr-profile="${OUT_DIR}/merged.profdata" \
      -format=lcov -ignore-filename-regex='(_deps|/test/|out/build)' \
      > "${OUT_DIR}/coverage.lcov"
  echo "--- coverage summary ---"
  ${COV_TOOL} report "${BIN}" -instr-profile="${OUT_DIR}/merged.profdata" \
      -ignore-filename-regex='(_deps|/test/|out/build)'
else
  # ---- GCC gcov coverage ----
  if ! command -v gcovr >/dev/null 2>&1; then
    echo "error: no .profraw files and gcovr not installed" >&2; exit 1
  fi
  gcovr --root . --filter 'include/' --filter 'src/' \
        --html-details "${OUT_DIR}/html/index.html" \
        --lcov "${OUT_DIR}/coverage.lcov" \
        --print-summary "${BUILD_DIR}"
fi
