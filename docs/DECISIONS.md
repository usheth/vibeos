# Decisions

Record key decisions and why they were made.

- 2026-02-22: Bootloader will be Multiboot2 with GRUB2 for the classic, well-documented path and compatibility with OSDev resources.
- 2026-02-22: Use an `x86_64-elf` cross-compiler to avoid host-OS assumptions and ensure a clean, freestanding toolchain.
- 2026-02-22: Early output will use serial first because it is easier to test automatically in QEMU.
- 2026-02-22: M0 scope is build/run/test skeleton only; visible output is deferred to M1 to keep milestones clean.
- 2026-02-22: QEMU runs headless with `-display none` and serial on stdio for remote-friendly output.
- 2026-02-22: Chose to keep M1 in 32-bit protected mode for now and add serial printing before switching to long mode later.
