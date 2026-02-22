# Glossary

Plain-language explanations for OS development terms used in this repo.

## Compiler
Turns human-readable source code (like C) into machine code (instructions the CPU runs).

## Cross-Compiler
A compiler that runs on one system but produces code for a *different* system.
Example: `x86_64-elf-gcc` runs on Linux but produces code for a bare‑metal x86_64 OS.
We use a cross-compiler so the output does *not* depend on the host OS libraries.

## Linker
Takes one or more compiled object files and combines them into a single binary (like `kernel.elf`).
It also decides *where in memory* the code and data will live. For kernels, this is very important.

## Linker Script
A small script that tells the linker how to arrange the kernel in memory.
Think of it as a “map” for where code/data should go.

## Bootloader
A tiny program that starts *before* your OS. It loads your kernel into memory and jumps to it.
Examples: GRUB, Limine.

## Binutils
GNU Binary Utilities: assembler, linker, and binary inspection tools (`as`, `ld`, `objdump`, `readelf`, `nm`).
GCC uses these tools to assemble and link code for the target.

## Multiboot
A standard “contract” between a bootloader and a kernel.
If your kernel follows the contract, the bootloader knows how to load it and pass info to it.

## Multiboot2
The newer version of the Multiboot contract used by GRUB2 and other bootloaders.
It defines the exact data structures and rules for how a kernel must present itself.

## Multiboot2 Header
A small data block embedded near the start of your kernel file.
The bootloader scans the file for this header to confirm it is bootable and to learn how to load it.

## ELF (Executable and Linkable Format)
A standard file format used for executables and object files on Unix-like systems.
ELF files contain sections (code, data, BSS) plus metadata that tells tools how to load them.
We produce a `kernel.elf` so the linker can lay out memory correctly and GRUB can load the kernel.

## BSS (Block Started by Symbol)
A section for uninitialized global data that should start as zero at runtime.
BSS does not take space in the kernel file; the loader just reserves memory and zeros it.
We use BSS for things like the early stack so the file stays small.

## Freestanding (C environment)
Compilation mode for code that runs without a host OS or standard C library.
In freestanding mode the compiler does not assume `main()` or startup files exist,
and you typically avoid linking against libc.

## Kernel
The core program of an operating system. It runs in full control of the machine and manages memory,
processes, devices, and system calls.

## ISO (Bootable Image)
A file that represents a bootable CD/DVD. We use it to bundle GRUB + the kernel so QEMU can boot it.

## QEMU
An emulator that lets us run our OS in a virtual machine instead of real hardware.
