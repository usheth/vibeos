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

## .S (Assembly Source)
An assembly source file that is run through the C preprocessor before assembling.
We use `.S` for early boot code that the CPU runs first.

## .ld (Linker Script File)
The file extension commonly used for linker scripts.
Our `.ld` file tells the linker where to place kernel sections in memory.

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

## Phony Target (Make)
A Makefile target that is not a real file.
Marking a target as `.PHONY` forces the commands to run even if a file with that name exists.

## Kernel
The core program of an operating system. It runs in full control of the machine and manages memory,
processes, devices, and system calls.

## ISO (Bootable Image)
A file that represents a bootable CD/DVD. We use it to bundle GRUB + the kernel so QEMU can boot it.

## QEMU
An emulator that lets us run our OS in a virtual machine instead of real hardware.

## VMA (Virtual Memory Address)
The address a section is intended to have when the program is running.
In our early boot, the VMA is still used even before we set up paging.

## LMA (Load Memory Address)
The address where a section is loaded into memory by the bootloader.
For our kernel, VMA and LMA are the same because we are not relocating sections yet.

## Long Mode
The 64-bit CPU mode on x86-64 processors.
Entering long mode requires enabling PAE, setting up page tables, enabling the long mode bit in EFER, and turning on paging.

## PAE (Physical Address Extension)
A paging mode that expands page table entries and allows the CPU to access more physical memory.
On x86-64, PAE must be enabled before entering long mode.
Enabling PAE is done by setting the PAE bit in CR4.
With PAE, page tables use 64-bit entries and add an extra level (PDPT → Page Directory → Page Table),
which is why the CPU can address more than 4 GiB of physical memory.

## EFER (Extended Feature Enable Register)
An x86 Model-Specific Register (MSR) that controls extended CPU features.
The Long Mode Enable (LME) bit inside EFER must be set before the CPU can enter long mode.
EFER is accessed via the `rdmsr` and `wrmsr` instructions.

## CR4 (Control Register 4)
An x86 control register used to enable or disable processor features.
The PAE bit in CR4 must be set before entering long mode.

## COM1 (Serial Port)
The first legacy serial port on x86 PCs, mapped to I/O port base `0x3F8`.
Early kernels often write to COM1 so QEMU can display output on the host terminal.
Common COM1 registers (offsets from base `0x3F8`):
- Data Register (`+0`): transmit or receive a byte.
- Interrupt Enable Register (`+1`): enables serial interrupts (we keep it off for polling).
- FIFO Control Register (`+2`): enables and configures FIFOs.
- Line Control Register (`+3`): sets data bits/parity/stop bits and the DLAB flag.
- Modem Control Register (`+4`): controls modem lines; often set to enable RTS/DSR.
- Line Status Register (`+5`): reports TX/RX status; bit 5 (THRE) indicates TX empty.
Protocol summary:
- We use **8-N-1**: 8 data bits, no parity, 1 stop bit.
- We poll the Line Status Register until the transmitter is ready, then write to the Data Register.
Baud rate summary:
- Set DLAB=1 in LCR, write the divisor to DLL/DLM, then clear DLAB and set 8‑N‑1.
