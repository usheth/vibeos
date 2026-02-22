# Default shell for recipes.
SHELL := /bin/bash

# Default target builds the kernel.
all: kernel

# Kernel target builds the kernel ELF.
kernel: build/kernel.elf

# Build directory creation target.
# Build directory creation target.
build:
# Create the build directory if it does not exist.
	mkdir -p build

# Assemble the entry object file.
# Assemble the entry object file.
build/entry.o: kernel/entry.S | build
# Assemble 32-bit entry code into an object file.
	x86_64-elf-as --32 kernel/entry.S -o build/entry.o

# Link the kernel ELF.
# Link the kernel ELF.
build/kernel.elf: build/entry.o kernel/linker.ld
# Link a 32-bit ELF kernel image.
	x86_64-elf-ld -m elf_i386 -T kernel/linker.ld -o build/kernel.elf build/entry.o

# ISO target builds a bootable GRUB ISO.
iso: build/kernel.elf
# Create ISO directories.
	mkdir -p build/iso/boot/grub
# Copy the kernel into the ISO tree.
	cp build/kernel.elf build/iso/boot/kernel.elf
# Copy the GRUB configuration.
	cp boot/grub.cfg build/iso/boot/grub/grub.cfg
# Build the ISO image.
	grub-mkrescue -o build/vibeos.iso build/iso

# Run target boots the ISO in QEMU.
run: iso
# Launch QEMU headless with serial output on stdio.
	qemu-system-x86_64 -cdrom build/vibeos.iso -display none -serial stdio -no-reboot -no-shutdown

# Clean target removes build artifacts.
clean:
# Delete the build directory.
	rm -rf build
