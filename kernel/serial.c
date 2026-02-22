// Include the serial interface.
#include "serial.h"
// Define an 8-bit unsigned type.
typedef unsigned char u8;
// Define a 16-bit unsigned type.
typedef unsigned short u16;
// Base I/O port for COM1.
#define COM1_BASE 0x3F8
// Data register offset.
#define COM1_DATA (COM1_BASE + 0)
// Interrupt enable register offset.
#define COM1_IER (COM1_BASE + 1)
// FIFO control register offset.
#define COM1_FCR (COM1_BASE + 2)
// Line control register offset.
#define COM1_LCR (COM1_BASE + 3)
// Modem control register offset.
#define COM1_MCR (COM1_BASE + 4)
// Line status register offset.
#define COM1_LSR (COM1_BASE + 5)
// Line status bit for transmit-hold-register empty.
#define COM1_LSR_THRE 0x20
// Write one byte to an I/O port.
static inline void outb(u16 port, u8 value) {
// Inline assembly to write AL to port.
  __asm__ __volatile__("outb %0, %1" : : "a"(value), "Nd"(port));
// End outb.
}
// Read one byte from an I/O port.
static inline u8 inb(u16 port) {
// Value to return.
  u8 value;
// Inline assembly to read AL from port.
  __asm__ __volatile__("inb %1, %0" : "=a"(value) : "Nd"(port));
// Return the read value.
  return value;
// End inb.
}
// Initialize COM1 for 38400 baud, 8-N-1, FIFO enabled.
void serial_init(void) {
// Disable all interrupts.
  outb(COM1_IER, 0x00);
// Enable DLAB to set baud divisor.
  outb(COM1_LCR, 0x80);
// Set divisor low byte (0x03 for 38400 baud).
  outb(COM1_DATA, 0x03);
// Set divisor high byte.
  outb(COM1_IER, 0x00);
// 8 data bits, no parity, one stop bit.
  outb(COM1_LCR, 0x03);
// Enable FIFO, clear them, 14-byte threshold.
  outb(COM1_FCR, 0xC7);
// IRQs enabled, RTS/DSR set.
  outb(COM1_MCR, 0x0B);
// End serial_init.
}
// Write a single character when the transmitter is ready.
void serial_write_char(char c) {
// Wait for transmitter holding register to be empty.
  while ((inb(COM1_LSR) & COM1_LSR_THRE) == 0) {
// Busy wait.
  }
// Write the character to the data register.
  outb(COM1_DATA, (u8)c);
// End serial_write_char.
}
// Write a null-terminated string to the serial port.
void serial_write(const char *s) {
// Loop over each character.
  while (*s != 0) {
// Write the current character.
    serial_write_char(*s);
// Advance to the next character.
    s++;
// End loop body.
  }
// End serial_write.
}
