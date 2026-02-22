# Roadmap (Living Document)

This roadmap is a working plan. It will change as we explore and learn.

## Current Focus (next 1–3 items)
- Plan the long-mode bring-up steps
- Move to 64-bit long mode with basic paging (M2)

## Exploration / Options
- Bootloader: Multiboot2 (GRUB2), Limine, UEFI
- Output: VGA text, serial first, framebuffer
- Debugging: QEMU + GDB vs QEMU-only

## Milestones (tentative)
- M0: Toolchain + build skeleton
- M1: 32-bit serial print
- M2: Long mode + basic paging
- M3: Interrupts + timer
- M4: Keyboard input + simple shell
- M5: Minimal Unix-like syscall interface

## Completed
- `x86_64-elf` cross-compiler toolchain built
- Build/run/test skeleton in place (Makefile, linker script, GRUB config, QEMU run target)
- M1: 32-bit serial output from kernel

## Notes
- Any milestone can be split, merged, or removed.
- Decisions should be recorded in `docs/DECISIONS.md`.
