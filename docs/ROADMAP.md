# Roadmap (Living Document)

This roadmap is a working plan. It will change as we explore and learn.

## Current Focus (next 1–3 items)
- Decide bootloader path: Multiboot2 + GRUB2 vs Limine
- Choose toolchain approach: cross-compiler vs host toolchain
- Establish a build/run/test skeleton

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
- (none yet)

## Notes
- Any milestone can be split, merged, or removed.
- Decisions should be recorded in `docs/DECISIONS.md`.
