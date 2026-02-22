/* Output format directive for 32-bit i386 ELF. */
OUTPUT_FORMAT(elf32-i386)
/* Entry point symbol directive. */
ENTRY(start)
/* Begin section layout. */
SECTIONS
/* Open section layout block. */
{
/* Set the initial location counter to 1 MiB. */
  . = 1M;
/* Define the multiboot2 header section. */
  .multiboot2 :
/* Open multiboot2 section block. */
  {
/* Keep the multiboot2 header in the output. */
    *(.multiboot2)
/* Close multiboot2 section block. */
  }
/* Define the text section. */
  .text :
/* Open text section block. */
  {
/* Include all text input sections. */
    *(.text*)
/* Close text section block. */
  }
/* Define the read-only data section. */
  .rodata :
/* Open rodata section block. */
  {
/* Include all rodata input sections. */
    *(.rodata*)
/* Close rodata section block. */
  }
/* Define the data section. */
  .data :
/* Open data section block. */
  {
/* Include all data input sections. */
    *(.data*)
/* Close data section block. */
  }
/* Define the BSS section. */
  .bss :
/* Open BSS section block. */
  {
/* Include all BSS input sections. */
    *(.bss*)
/* Include common symbols. */
    *(COMMON)
/* Close BSS section block. */
  }
/* Close section layout block. */
}
