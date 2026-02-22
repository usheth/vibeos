# Decisions

Record key decisions and why they were made.

- 2026-02-22: Bootloader will be Multiboot2 with GRUB2 for the classic, well-documented path and compatibility with OSDev resources.
- 2026-02-22: Use an `x86_64-elf` cross-compiler to avoid host-OS assumptions and ensure a clean, freestanding toolchain.
