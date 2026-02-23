# vibeos

Minimal x86_64 Unix-like OS for learning OS development, systems programming, and agent workflows.

## Goals
- Build a tiny, understandable boot-to-kernel path.
- Implement a minimal Unix-like kernel (processes, files, syscalls).
- Learn toolchains, low-level debugging, and systems design.

## Status
M0 complete (toolchain + build skeleton). M1 complete (32-bit serial hello). Next: plan long mode.

## Next
See `docs/ROADMAP.md` and `docs/DECISIONS.md`.

## Build/Run
- `make kernel` builds the minimal Multiboot2 kernel ELF into `build/kernel.elf`.
- `make iso` builds a bootable GRUB2 ISO at `build/vibeos.iso` (requires `grub-mkrescue`).
- `make run` runs the ISO in QEMU headless with serial output on stdio.

## Inspect/Debug
- Inspect the ELF with `x86_64-elf-objdump -h build/kernel.elf`.
- Run QEMU with a GDB stub using `qemu-system-x86_64 -cdrom build/vibeos.iso -display none -serial stdio -s -S`, then connect with `x86_64-elf-gdb`.

## Kernel Design (Current)
This is the *exact* state of the kernel today, with pointers to glossary terms.

**Boot protocol**
- **Multiboot2**: a standard contract that tells GRUB how to recognize and load our kernel (see `docs/GLOSSARY.md`: Multiboot2, Multiboot2 Header)
- **Bootloader**: GRUB2, which reads `grub.cfg`, loads the ELF, and jumps to our entry point (see `docs/GLOSSARY.md`: Bootloader)
- **Boot config**: `boot/grub.cfg` uses `multiboot2 /boot/kernel.elf`
**Boot flow (step‑by‑step)**
1. **GRUB starts** and reads `boot/grub.cfg`.
2. The `multiboot2 /boot/kernel.elf` line tells GRUB to treat the file as a Multiboot2 kernel.
3. **GRUB scans the kernel file** for a Multiboot2 header (the magic value + checksum must validate).
4. If valid, **GRUB reads the ELF program headers** to learn which segments to load and where.
5. **GRUB loads the segments into memory** at the specified addresses (currently starting at 1 MiB).
6. **GRUB jumps to the entry point** (`start` in `kernel/entry.S`) and transfers control to our code.

**CPU mode and entry**
- **CPU mode on entry**: 32-bit protected mode (GRUB hands off in 32-bit)
- **Entry point**: `kernel/entry.S` symbol `start` (assembly source processed by the preprocessor; see `docs/GLOSSARY.md`: .S)
- **Execution flow**:
  - `cli` disables interrupts
  - stack pointer set to `stack_top` in `.bss`
  - call `kmain` (C) to initialize serial and print
  - `hlt` loop to halt safely
**Why these steps exist**
- We disable interrupts to avoid unexpected CPU state changes before we set up handlers.
- We set a stack because almost every useful operation (calls, pushes, interrupts) depends on it.
- We halt in a loop because we have no scheduler or idle task yet; halting is safe and deterministic.

**Binary format and layout**
- **ELF format**: `elf32-i386`, which stores sections and metadata so loaders know what to load and where (see `docs/GLOSSARY.md`: ELF)
- **Linker script**: `kernel/linker.ld`, which decides where each section lives in memory (see `docs/GLOSSARY.md`: Linker Script, .ld)
- **Load address**: 1 MiB (`0x0010_0000`) via `. = 1M;` in the linker script
- **Sections present**:
  - `.multiboot2` (header required by GRUB to recognize the kernel)
  - `.text` (executable code; includes `start`)
  - `.rodata` (read-only data; holds string literals like the hello message)
  - `.bss` (zero-initialized data; holds the early 4 KiB stack)
- **Addressing**:
  - Section VMAs/LMAs currently match, so “where it runs” equals “where it is loaded” (see `docs/GLOSSARY.md`: VMA, LMA)
  - Addresses come from ELF program headers emitted by the linker based on the linker script
**How `.S` + `.ld` become `kernel.elf` (step‑by‑step)**
1. `kernel/entry.S` is assembled into `build/entry.o` (machine code + section metadata).
2. The linker reads `kernel/linker.ld` to set the base address and section order.
3. The linker merges sections from `entry.o` into a single ELF file.
4. The linker emits **program headers** that describe how GRUB should load the kernel into memory.
5. The result is `build/kernel.elf`, which GRUB can load.

**Memory map snapshot**
- The memory map diagram below is derived from:
  - `x86_64-elf-objdump -h build/kernel.elf`
- Current key addresses:
  - `.multiboot2` VMA `0x0010_0000`
  - `.text` VMA `0x0010_0000`
  - `.rodata` VMA `0x0010_0142` (size `0x1b`)
  - `.bss`  VMA `0x0010_0160` (size `0x1000`)
**Why 1 MiB**
- The region below 1 MiB contains legacy BIOS data and is traditionally avoided.
- 1 MiB is a conventional, well‑understood starting point for early kernels.

**I/O and output**
- **Output**: serial (COM1) from 32-bit C code
- **Reason**: `kmain` calls `serial_init()` from `kernel/serial.c` and prints a hello string

## Build Pipeline (Detailed)
This describes what each Makefile target does and why.

- **`make kernel`**
  - Assembles `kernel/entry.S` into `build/entry.o`.
  - Compiles `kernel/serial.c` and `kernel/kmain.c` into `build/serial.o` and `build/kmain.o`.
  - Links all three objects with `kernel/linker.ld` to produce `build/kernel.elf`.
  - Result: a Multiboot2‑compatible 32‑bit ELF kernel that prints to serial.

- **`make iso`**
  - Creates a staging directory at `build/iso/boot/grub`.
  - Copies `build/kernel.elf` to `build/iso/boot/kernel.elf`.
  - Copies `boot/grub.cfg` to `build/iso/boot/grub/grub.cfg`.
  - Runs `grub-mkrescue` to produce `build/vibeos.iso`.
  - Result: a bootable ISO GRUB can start in QEMU.

- **`make run`**
  - Runs QEMU headless with `-display none`.
  - Routes serial output to the terminal with `-serial stdio`.
  - Uses `-no-reboot -no-shutdown` to keep the session visible on exit.
  - Result: an emulated boot of the ISO (serial prints the hello message).

- **`make clean`**
  - Deletes the `build/` directory so the next build starts fresh.

## Serial Output (COM1 Details)
We use COM1 for early output because it is simple, reliable, and works in headless QEMU.

**COM1 base address**
- Base I/O port: `0x3F8`
- Registers are accessed by adding offsets to this base.

**Registers we use (offsets from `0x3F8`)**
- `+0` **Data Register**: write a byte to transmit; read a byte to receive.
- `+1` **Interrupt Enable Register (IER)**: we set this to 0 to use polling.
- `+2` **FIFO Control Register (FCR)**: we enable FIFO and clear buffers.
- `+3` **Line Control Register (LCR)**: sets 8‑N‑1 and toggles DLAB for baud rate.
- `+4` **Modem Control Register (MCR)**: enables RTS/DSR lines (basic modem control).
- `+5` **Line Status Register (LSR)**: status flags; bit 5 (**THRE**) means TX buffer is empty.

**Baud rate setup (DLAB + divisor)**
- To set the baud rate, LCR bit 7 (**DLAB**) is set to 1.
- With DLAB=1, the Data and IER registers become the **Divisor Latch**:
  - `+0` = Divisor Latch Low (DLL)
  - `+1` = Divisor Latch High (DLM)
- We set DLL to `0x03` and DLM to `0x00`, which gives **38400 baud** (given a 115200 base clock).
- After setting the divisor, DLAB is cleared and LCR is set to `0x03` for **8‑N‑1**.

**Protocol (how a character is sent)**
1. Read LSR until TX‑empty is set.
2. Write the character to the Data Register.

**Why this is safe early**
- No interrupts required (pure polling).
- Minimal hardware setup.
- QEMU exposes COM1 output directly to the host terminal.

## Memory Map (Early Boot)
Below is a simplified, not-to-scale view of where the kernel is loaded right now.
This is based on our linker script, which places the kernel at 1 MiB.

```text
High memory
┌──────────────────────────────────────────────┐
│                                              │
│              Free/unused (for now)          │
│                                              │
├──────────────────────────────────────────────┤
│ Kernel image (ELF sections) @ 0x0010_0000    │
│ - .text       VMA 0x0010_0000  (size 0x142)   │
│ - .multiboot2 VMA 0x0010_0000  (size 0x18)    │
│ - .rodata     VMA 0x0010_0142  (size 0x1b)    │
│ - .bss        VMA 0x0010_0160  (size 0x1000)  │
│   - early stack (4 KiB)                       │
├──────────────────────────────────────────────┤
│ Conventional memory below 1 MiB              │
│ (BIOS area, reserved, legacy)                │
└──────────────────────────────────────────────┘
Low memory
```

Why this matters:
- It shows **where** the CPU starts executing your kernel (the 1 MiB region).
- It explains **why** we need a linker script: without it, the kernel could be placed unpredictably.
- The addresses above come from `x86_64-elf-objdump -h build/kernel.elf`.

Note:
- `.text` and `.multiboot2` both show VMA `0x0010_0000` because the linker script anchors the location counter at 1 MiB and then places sections in order. The actual bytes are laid out sequentially; the section table just shows the start address for each section. If you want this to be clearer, we can force `.multiboot2` to start at 1 MiB and then explicitly advance the location counter before `.text`.
