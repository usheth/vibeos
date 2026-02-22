#!/usr/bin/env bash
# Exit on error, on unset vars, and on pipeline failures.
set -euo pipefail

# Build an x86_64-elf cross toolchain (binutils + gcc).
# Installs to $PREFIX (default: $HOME/opt/cross).
# Set AUTO_INSTALL_DEPS=1 to install Ubuntu build deps via apt-get.

# Installation prefix for the toolchain.
PREFIX="${PREFIX:-$HOME/opt/cross}"
# Target triple for the cross toolchain.
TARGET="${TARGET:-x86_64-elf}"
# Parallel build jobs based on CPU count (fallback to 1).
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)}"

# Binutils version to download and build.
BINUTILS_VER="${BINUTILS_VER:-2.42}"
# GCC version to download and build.
GCC_VER="${GCC_VER:-13.2.0}"

# Working directory for downloads/builds.
WORKDIR="${WORKDIR:-$HOME/src/cross}"

# Ensure the work directory exists.
mkdir -p "$WORKDIR"
# Enter the work directory.
cd "$WORKDIR"

# Helper to verify required commands exist.
# Optionally install dependencies if requested.
auto_install_deps() {
  # Only run if AUTO_INSTALL_DEPS is set to 1.
  if [ "${AUTO_INSTALL_DEPS:-0}" != "1" ]; then
    return 0
  fi
  # Install build dependencies on Ubuntu.
  if command -v apt-get >/dev/null 2>&1; then
    # Update package lists in noninteractive mode.
    DEBIAN_FRONTEND=noninteractive sudo apt-get update
    # Install required packages in noninteractive mode (suppress restart prompts).
    NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive sudo apt-get install -y build-essential bison flex libgmp-dev libgmp3-dev libmpc-dev libmpfr-dev libisl-dev texinfo
  fi
}

# Check required commands and print install guidance if missing.
need() {
  # Check for the command; if missing, print guidance and exit.
  command -v "$1" >/dev/null 2>&1 || {
    # Report the missing dependency.
    echo "Missing dependency: $1" >&2
    # Suggest how to install dependencies on Ubuntu.
    echo "Install build deps (Ubuntu):" >&2
    # Provide the apt update command.
    echo "  sudo apt-get update" >&2
    # Provide the apt install command.
    echo "  sudo apt-get install -y build-essential bison flex gmp libgmp3-dev libmpc-dev libmpfr-dev texinfo" >&2
    # Exit with failure.
    exit 1
  }
}

# Attempt auto-install of dependencies if requested.
auto_install_deps
# Require wget for downloads.
need wget
# Require make for builds.
need make
# Require gcc to build GCC itself.
need gcc

# Download binutils tarball if missing.
if [ ! -f "binutils-$BINUTILS_VER.tar.xz" ]; then
  # Fetch binutils from GNU mirrors.
  wget "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VER.tar.xz"
# End binutils download check.
fi
# Download gcc tarball if missing.
if [ ! -f "gcc-$GCC_VER.tar.xz" ]; then
  # Fetch gcc from GNU mirrors.
  wget "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.xz"
# End gcc download check.
fi

# Extract binutils if source directory is missing.
if [ ! -d "binutils-$BINUTILS_VER" ]; then
  # Unpack the binutils source.
  tar -xf "binutils-$BINUTILS_VER.tar.xz"
# End binutils extract check.
fi
# Extract gcc if source directory is missing.
if [ ! -d "gcc-$GCC_VER" ]; then
  # Unpack the gcc source.
  tar -xf "gcc-$GCC_VER.tar.xz"
# End gcc extract check.
fi

# Create binutils build directory.
mkdir -p build-binutils
# Enter binutils build directory.
cd build-binutils
# Configure binutils for the target (single line to avoid broken continuations).
../binutils-$BINUTILS_VER/configure --target="$TARGET" --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror

# Build binutils.
make -j"$JOBS"
# Install binutils.
make install

# Return to the work directory.
cd "$WORKDIR"
# Create gcc build directory.
mkdir -p build-gcc
# Enter gcc build directory.
cd build-gcc
# Configure gcc for a freestanding C-only target (single line to avoid broken continuations).
../gcc-$GCC_VER/configure --target="$TARGET" --prefix="$PREFIX" --disable-nls --enable-languages=c --without-headers

# Build the gcc compiler components.
make -j"$JOBS" all-gcc
# Build target libgcc (compiler runtime).
make -j"$JOBS" all-target-libgcc
# Install gcc.
make install-gcc
# Install target libgcc.
make install-target-libgcc

# Print post-install guidance.
cat <<MSG

Toolchain installed to: $PREFIX
Add to PATH:
  export PATH="$PREFIX/bin:$PATH"

Verify:
  $TARGET-gcc --version

MSG
