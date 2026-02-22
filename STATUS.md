# Status

## Current Milestone
- M1: Boot into 64-bit kernel and print a message

## Done
- Repo scaffolded
- Initial roadmap/logging structure added
- Bootloader decided: Multiboot2 + GRUB2
- Toolchain decided: `x86_64-elf` cross-compiler
- Toolchain built: binutils + gcc installed at `/home/ubuntu/opt/cross`
- Build/run/test skeleton added (Makefile, linker script, GRUB config, QEMU run target)

## Next
- Add long-mode bring-up code and a simple serial print
- Update boot path to 64-bit and print a message

## Blockers / Questions
- None yet

## Verification (2026-02-22)
- Command: `ls /home/ubuntu/opt/cross/bin`
  Output:
  - `x86_64-elf-addr2line`
  - `x86_64-elf-ar`
  - `x86_64-elf-as`
  - `x86_64-elf-c++filt`
  - `x86_64-elf-cpp`
  - `x86_64-elf-elfedit`
  - `x86_64-elf-gcc`
  - `x86_64-elf-gcc-13.2.0`
  - `x86_64-elf-gcc-ar`
  - `x86_64-elf-gcc-nm`
  - `x86_64-elf-gcc-ranlib`
  - `x86_64-elf-gcov`
  - `x86_64-elf-gcov-dump`
  - `x86_64-elf-gcov-tool`
  - `x86_64-elf-gprof`
  - `x86_64-elf-ld`
  - `x86_64-elf-ld.bfd`
  - `x86_64-elf-lto-dump`
  - `x86_64-elf-nm`
  - `x86_64-elf-objcopy`
  - `x86_64-elf-objdump`
  - `x86_64-elf-ranlib`
  - `x86_64-elf-readelf`
  - `x86_64-elf-size`
  - `x86_64-elf-strings`
  - `x86_64-elf-strip`
- Command: `PATH="/home/ubuntu/opt/cross/bin:$PATH" x86_64-elf-gcc --version`
  Output:
  - `x86_64-elf-gcc (GCC) 13.2.0`
  - `Copyright (C) 2023 Free Software Foundation, Inc.`
  - `This is free software; see the source for copying conditions.  There is NO`
  - `warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.`
- Command: `cd /home/ubuntu/code/vibeos && PATH="/home/ubuntu/opt/cross/bin:$PATH" tests/test_toolchain.sh`
  Output:
  - `OK: x86_64-elf-gcc is available`
- Command: `cd /home/ubuntu/code/vibeos && PATH="/home/ubuntu/opt/cross/bin:$PATH" tests/test_build.sh`
  Output:
  - `make: Entering directory '/home/ubuntu/code/vibeos'`
  - `rm -rf build`
  - `make: Leaving directory '/home/ubuntu/code/vibeos'`
  - `make: Entering directory '/home/ubuntu/code/vibeos'`
  - `mkdir -p build`
  - `x86_64-elf-as --32 kernel/entry.S -o build/entry.o`
  - `x86_64-elf-ld -m elf_i386 -T kernel/linker.ld -o build/kernel.elf build/entry.o`
  - `x86_64-elf-ld: warning: build/kernel.elf has a LOAD segment with RWX permissions`
  - `make: Leaving directory '/home/ubuntu/code/vibeos'`
  - `OK: build/kernel.elf built`
- Command: `cd /home/ubuntu/code/vibeos && make iso`
  Output:
  - `grub-mkrescue -o build/vibeos.iso build/iso`
  - `xorriso 1.5.6 : RockRidge filesystem manipulator, libburnia project.`
  - `ISO image produced: 5801 sectors`
  - `Writing to 'stdio:build/vibeos.iso' completed successfully.`
- Command: `cd /home/ubuntu/code/vibeos && make run`
  Output:
  - `qemu-system-x86_64 -cdrom build/vibeos.iso -display none -serial stdio -no-reboot -no-shutdown`
  - `No serial output (kernel currently halts immediately).`
