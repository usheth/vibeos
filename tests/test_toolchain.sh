#!/usr/bin/env bash
# Exit on error, on unset vars, and on pipeline failures.
set -euo pipefail

# Target triple for the cross-compiler.
TARGET="${TARGET:-x86_64-elf}"

# Check whether the cross-compiler is on PATH.
if ! command -v "$TARGET-gcc" >/dev/null 2>&1; then
  # Report failure to stderr.
  echo "FAIL: $TARGET-gcc not found in PATH" >&2
  # Exit with failure.
  exit 1
# End PATH check.
fi

# Ensure the compiler runs.
"$TARGET-gcc" --version >/dev/null 2>&1

# Report success.
echo "OK: $TARGET-gcc is available"
