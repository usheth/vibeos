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

## Multiboot
A standard “contract” between a bootloader and a kernel.
If your kernel follows the contract, the bootloader knows how to load it and pass info to it.

## Multiboot2 Header
A small data block embedded in your kernel file that tells the bootloader:
“I am a Multiboot2 kernel, here is how to load me.”

## ELF (Executable and Linkable Format)
A common file format for executables and object files on Unix-like systems.
Your kernel will be an ELF file so the bootloader/linker know how to load it.

## Kernel
The core program of an operating system. It runs in full control of the machine and manages memory,
processes, devices, and system calls.

## ISO (Bootable Image)
A file that represents a bootable CD/DVD. We use it to bundle GRUB + the kernel so QEMU can boot it.

## QEMU
An emulator that lets us run our OS in a virtual machine instead of real hardware.

