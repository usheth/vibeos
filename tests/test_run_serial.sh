#!/usr/bin/env bash
# Exit on error, on unset vars, and on pipeline failures.
set -euo pipefail
# Resolve repo root directory.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Temporary log file for serial output.
LOG_FILE="/tmp/vibeos-serial.log"
# Ensure cross toolchain is on PATH.
PATH="/home/ubuntu/opt/cross/bin:${PATH}"
# Build the ISO image.
make -C "${ROOT_DIR}" iso
# Remove any old log file.
rm -f "${LOG_FILE}"
# Run QEMU headless and capture serial output.
timeout 5s qemu-system-x86_64 -cdrom "${ROOT_DIR}/build/vibeos.iso" -display none -serial "file:${LOG_FILE}" -no-reboot -no-shutdown || true
# Ensure the log file exists.
if [ ! -f "${LOG_FILE}" ]; then
# Report missing log file.
  echo "FAIL: serial log not created" >&2
# Exit with failure.
  exit 1
# End log existence check.
fi
# Check for the hello string.
if ! grep -q "vibeos: hello from 32-bit" "${LOG_FILE}"; then
# Report missing message.
  echo "FAIL: hello message not found in serial log" >&2
# Exit with failure.
  exit 1
# End grep check.
fi
# Report success.
echo "OK: serial hello message found"
