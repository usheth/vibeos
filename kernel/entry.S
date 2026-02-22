# Multiboot2 header section label comment.
#
# Section directive to place the multiboot2 header.
.section .multiboot2
# Alignment directive for 8-byte alignment.
.align 8
# Label marking the start of the multiboot2 header.
mb2_header:
# Multiboot2 magic number.
.long 0xE85250D6
# Architecture field set to i386 (0).
.long 0
# Header length field in bytes.
.long mb2_header_end - mb2_header
# Checksum field so the header sums to zero.
.long -(0xE85250D6 + 0 + (mb2_header_end - mb2_header))
# End tag type field.
.short 0
# End tag flags field.
.short 0
# End tag size field.
.long 8
# Label marking the end of the multiboot2 header.
mb2_header_end:

# Code section label comment.
#
# Section directive for executable code.
.section .text
# Assemble following instructions as 32-bit code.
.code32
# Export the entry symbol for the linker.
.global start
# Import the C entry point.
.extern kmain
# Entry point label used by the linker.
start:
# Disable interrupts.
cli
# Initialize the stack pointer to the top of our stack.
mov $stack_top, %esp
# Call the C entry point.
call kmain
# Label for the halt loop.
halt_loop:
# Halt the CPU until the next interrupt.
hlt
# Jump back to the halt loop label.
jmp halt_loop

# BSS section label comment.
#
# Section directive for uninitialized data (BSS).
.section .bss
# Align the stack to a 16-byte boundary.
.align 16
# Label for the bottom of the stack.
stack_bottom:
# Reserve 4096 bytes for the stack.
.skip 4096
# Label for the top of the stack.
stack_top:
