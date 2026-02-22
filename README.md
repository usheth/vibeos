# vibeos

Minimal x86_64 Unix-like OS for learning OS development, systems programming, and agent workflows.

## Goals
- Build a tiny, understandable boot-to-kernel path.
- Implement a minimal Unix-like kernel (processes, files, syscalls).
- Learn toolchains, low-level debugging, and systems design.

## Status
Empty scaffold. First milestone: boot a 64-bit kernel that prints a message.

## Next
See `docs/ROADMAP.md` and `docs/LEARNING.md`.

## Build/Run
- `make kernel` builds the minimal Multiboot2 kernel ELF into `build/kernel.elf`.
- `make iso` builds a bootable GRUB2 ISO at `build/vibeos.iso` (requires `grub-mkrescue`).
- `make run` runs the ISO in QEMU with serial output on stdio.

## Inspect/Debug
- Inspect the ELF with `x86_64-elf-objdump -h build/kernel.elf`.
- Run QEMU with a GDB stub using `qemu-system-x86_64 -cdrom build/vibeos.iso -serial stdio -s -S`, then connect with `x86_64-elf-gdb`.

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
│ Kernel image (ELF sections) @ 1 MiB          │
│ - .multiboot2 header                          │
│ - .text (code)                                │
│ - .rodata (read-only data)                    │
│ - .data (read/write data)                     │
│ - .bss (zeroed, includes early stack)         │
├──────────────────────────────────────────────┤
│ Conventional memory below 1 MiB              │
│ (BIOS area, reserved, legacy)                │
└──────────────────────────────────────────────┘
Low memory
```

Why this matters:
- It shows **where** the CPU starts executing your kernel (the 1 MiB region).
- It explains **why** we need a linker script: without it, the kernel could be placed unpredictably.
