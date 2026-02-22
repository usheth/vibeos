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
│ Kernel image (ELF sections) @ 0x0010_0000    │
│ - .text       VMA 0x0010_0000  (size 0x9)     │
│ - .multiboot2 VMA 0x0010_0000  (size 0x18)    │
│ - .bss        VMA 0x0010_0010  (size 0x1000)  │
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
