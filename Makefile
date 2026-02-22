# Default shell for recipes.
SHELL := /bin/bash
# Cross-compiler prefix.
CROSS_PREFIX ?= x86_64-elf-
# Assembler executable.
AS := $(CROSS_PREFIX)as
# Linker executable.
LD := $(CROSS_PREFIX)ld
# Build output directory.
BUILD_DIR := build
# Kernel entry source.
KERNEL_ENTRY := kernel/entry.S
# Kernel linker script.
KERNEL_LINKER := kernel/linker.ld
# Kernel object file.
KERNEL_OBJ := $(BUILD_DIR)/entry.o
# Kernel ELF output.
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
# ISO output path.
ISO_PATH := $(BUILD_DIR)/vibeos.iso
# ISO staging directory.
ISO_DIR := $(BUILD_DIR)/iso
# ISO boot directory.
ISO_BOOT := $(ISO_DIR)/boot
# ISO GRUB directory.
ISO_GRUB := $(ISO_BOOT)/grub
# GRUB configuration path.
GRUB_CFG := boot/grub.cfg

# Default target builds the kernel.
all: kernel

# Kernel target builds the kernel ELF.
kernel: $(KERNEL_ELF)

# Build directory creation target.
$(BUILD_DIR):
# Create the build directory if it does not exist.
	mkdir -p $(BUILD_DIR)

# Assemble the entry object file.
$(KERNEL_OBJ): $(KERNEL_ENTRY) | $(BUILD_DIR)
# Assemble 32-bit entry code into an object file.
	$(AS) --32 $(KERNEL_ENTRY) -o $(KERNEL_OBJ)

# Link the kernel ELF.
$(KERNEL_ELF): $(KERNEL_OBJ) $(KERNEL_LINKER)
# Link a 32-bit ELF kernel image.
	$(LD) -m elf_i386 -T $(KERNEL_LINKER) -o $(KERNEL_ELF) $(KERNEL_OBJ)

# ISO target builds a bootable GRUB ISO.
iso: $(KERNEL_ELF)
# Create ISO directories.
	mkdir -p $(ISO_GRUB)
# Copy the kernel into the ISO tree.
	cp $(KERNEL_ELF) $(ISO_BOOT)/kernel.elf
# Copy the GRUB configuration.
	cp $(GRUB_CFG) $(ISO_GRUB)/grub.cfg
# Build the ISO image.
	grub-mkrescue -o $(ISO_PATH) $(ISO_DIR)

# Run target boots the ISO in QEMU.
run: iso
# Launch QEMU headless with serial output on stdio.
	qemu-system-x86_64 -cdrom $(ISO_PATH) -display none -serial stdio -no-reboot -no-shutdown

# Clean target removes build artifacts.
clean:
# Delete the build directory.
	rm -rf $(BUILD_DIR)
