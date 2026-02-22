#!/usr/bin/env bash
# Exit on error, on unset vars, and on pipeline failures.
set -euo pipefail
# Resolve repo root directory.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Cross toolchain directory path.
CROSS_DIR="/home/ubuntu/opt/cross/bin"
# Ensure cross toolchain is on PATH.
PATH="${CROSS_DIR}:${PATH}"
# Clean previous build artifacts.
make -C "${ROOT_DIR}" clean
# Build the kernel ELF.
make -C "${ROOT_DIR}" kernel
# Check for the kernel ELF output.
if [ ! -f "${ROOT_DIR}/build/kernel.elf" ]; then
# Report missing kernel.
  echo "FAIL: build/kernel.elf not found" >&2
# Exit with failure.
  exit 1
# End existence check.
fi
# Report success.
echo "OK: build/kernel.elf built"
