# Roadmap (Living Document)

This roadmap is a working plan. It will change as we explore and learn.

## Current Focus (next 1–3 items)
- Boot a 32-bit kernel and print a message (M1)
- Plan the long-mode bring-up steps

## Exploration / Options
- Bootloader: Multiboot2 (GRUB2), Limine, UEFI
- Output: VGA text, serial first, framebuffer
- Debugging: QEMU + GDB vs QEMU-only

## Milestones (tentative)
- M0: Toolchain + build skeleton
- M1: Boot into 64-bit kernel and print
- M2: Memory map + paging
- M3: Interrupts + timer
- M4: Keyboard input + simple shell
- M5: Minimal Unix-like syscall interface

## Completed
- `x86_64-elf` cross-compiler toolchain built
- Build/run/test skeleton in place (Makefile, linker script, GRUB config, QEMU run target)

## Notes
- Any milestone can be split, merged, or removed.
- Decisions should be recorded in `docs/DECISIONS.md`.
