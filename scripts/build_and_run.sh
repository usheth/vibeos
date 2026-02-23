# Run with: bash scripts/build_and_run.sh
# Exit on error, unset vars, or failed pipes.
set -euo pipefail
# Ensure the cross-compiler tools are on PATH.
export PATH="/home/ubuntu/opt/cross/bin:$PATH"
# Build the kernel and ISO using the Makefile.
make kernel iso
# Run the ISO in QEMU with serial output.
make run
