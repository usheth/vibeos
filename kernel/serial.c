// COM1 (communications port 1) protocol overview (16550-compatible UART,
// Universal Asynchronous Receiver/Transmitter):
// Base I/O port is 0x3F8, and registers are at fixed offsets:
// +0 Data, +1 IER (Interrupt Enable Register), +2 FCR (FIFO Control Register),
// +3 LCR (Line Control Register), +4 MCR (Modem Control Register),
// +5 LSR (Line Status Register).
// Initialization sequence matters:
// 1) Disable interrupts (IER=0) because we use polling, not IRQs
//    (Interrupt Requests).
// 2) Set DLAB (Divisor Latch Access Bit) (LCR bit 7) so +0/+1 become
//    divisor latch bytes.
//    Effect: the port map switches from Data/IER to DLL/DLM, letting us
//    program the baud-rate divisor without racing a live data stream.
//    Plain-English: the UART reuses the same I/O addresses for different
//    registers; DLAB is the mode switch that decides what 0x3F8/0x3F9 mean.
//    With DLAB=0, 0x3F8/0x3F9 are Data/IER. With DLAB=1, they are DLL/DLM
//    (Divisor Latch Low / Divisor Latch High) (together a 16-bit divisor).
//    Expanded: the UART has more internal registers than I/O addresses, so it
//    multiplexes them. The DLAB bit tells the UART which set you want to see.
//    Analogy: DLAB is a mode switch. Same address, different register.
// 3) Program baud divisor: DLL=0x03, DLM=0x00 for 38400 (115200/3).
//    Expanded: DLL/DLM store a 16-bit number called the divisor. The UART
//    uses it to divide its base clock (commonly 115200) down to the bit rate.
//    Divisor = 115200 / desired_baud, so 115200/38400 = 3 = 0x0003.
//    That is why DLL=0x03 and DLM=0x00.
//    Effect: the UART clock is divided by 3, so each bit lasts longer and
//    the wire speed becomes 38400 bits/second (must match the receiver).
// 4) Clear DLAB and set line format: LCR=0x03 (8 data bits, no parity, 1 stop).
//    Effect: restores normal Data/IER access and defines the frame format
//    (8-N-1) so both ends agree on byte boundaries.
//    Expanded: once the divisor is set, DLAB must be cleared so that writing
//    to 0x3F8 sends data again instead of overwriting DLL.
// 5) Enable FIFO (First-In, First-Out) and clear buffers (FCR=0xC7).
//    Effect: turns on the transmit/receive FIFOs, flushes stale bytes, and
//    sets a 14-byte RX (receive) threshold to reduce overrun risk.
// 6) Set MCR=0x0B to enable basic modem control lines.
//    Effect: asserts DTR (Data Terminal Ready) / RTS (Request To Send) and
//    sets OUT2 (output 2) so the UART can signal an IRQ line if interrupts
//    were later enabled (safe default in QEMU (Quick Emulator) / PC (personal
//    computer) UARTs).
// Transmit protocol (polling):
// Read LSR until THRE (Transmit Holding Register Empty) (bit 5, 0x20) is 1,
// then write the byte to Data.
// Include the serial interface.
#include "serial.h"
// Define an 8-bit unsigned type.
typedef unsigned char u8;
// Define a 16-bit unsigned type.
typedef unsigned short u16;
// Base I/O port for COM1 (communications port 1).
#define COM1_BASE 0x3F8
// Data register offset.
#define COM1_DATA (COM1_BASE + 0)
// Interrupt Enable Register (IER) offset.
#define COM1_IER (COM1_BASE + 1)
// FIFO Control Register (FCR) offset.
#define COM1_FCR (COM1_BASE + 2)
// Line Control Register (LCR) offset.
#define COM1_LCR (COM1_BASE + 3)
// Modem Control Register (MCR) offset.
#define COM1_MCR (COM1_BASE + 4)
// Line Status Register (LSR) offset.
#define COM1_LSR (COM1_BASE + 5)
// Disable all UART (Universal Asynchronous Receiver/Transmitter) interrupts.
#define COM1_IER_DISABLE 0x00
// Enable Divisor Latch Access Bit (DLAB) in Line Control Register (LCR).
#define COM1_LCR_DLAB 0x80
// 8 data bits, no parity, 1 stop bit format in Line Control Register (LCR).
#define COM1_LCR_8N1 0x03
// Enable FIFO (First-In, First-Out) in FIFO Control Register (FCR).
#define COM1_FCR_ENABLE 0x01
// Clear receive FIFO (First-In, First-Out) in FIFO Control Register (FCR).
#define COM1_FCR_CLEAR_RX 0x02
// Clear transmit FIFO (First-In, First-Out) in FIFO Control Register (FCR).
#define COM1_FCR_CLEAR_TX 0x04
// Set 14-byte receive (RX) threshold in FIFO Control Register (FCR).
#define COM1_FCR_RX_14 0xC0
// Set DTR (Data Terminal Ready) in Modem Control Register (MCR).
#define COM1_MCR_DTR 0x01
// Set RTS (Request To Send) in Modem Control Register (MCR).
#define COM1_MCR_RTS 0x02
// Set OUT2 (output 2) in Modem Control Register (MCR).
#define COM1_MCR_OUT2 0x08
// Line Status Register (LSR) bit for THRE (Transmit Holding Register Empty).
#define COM1_LSR_THRE 0x20
// Baud rate divisor for 38400 (115200/3).
#define COM1_BAUD_DIVISOR 3
// Low byte of the baud rate divisor.
#define COM1_BAUD_DIVISOR_LOW ((u8)(COM1_BAUD_DIVISOR & 0xFF))
// High byte of the baud rate divisor.
#define COM1_BAUD_DIVISOR_HIGH ((u8)((COM1_BAUD_DIVISOR >> 8) & 0xFF))
// Write one byte to an I/O port.
static inline void outb(u16 port, u8 value) {
// Inline assembly to write AL (accumulator low byte) to port.
  __asm__ __volatile__("outb %0, %1" : : "a"(value), "Nd"(port));
// End outb.
}
// Read one byte from an I/O port.
static inline u8 inb(u16 port) {
// Value to return.
  u8 value;
// Inline assembly to read AL (accumulator low byte) from port.
  __asm__ __volatile__("inb %1, %0" : "=a"(value) : "Nd"(port));
// Return the read value.
  return value;
// End inb.
}
// Initialize COM1 (communications port 1) for 38400 baud, 8-N-1, FIFO enabled.
void serial_init(void) {
// Disable all UART (Universal Asynchronous Receiver/Transmitter) interrupts.
  outb(COM1_IER, COM1_IER_DISABLE);
// Enable DLAB (Divisor Latch Access Bit) to set the baud divisor.
  outb(COM1_LCR, COM1_LCR_DLAB);
// Set divisor low byte for the baud rate.
  outb(COM1_DATA, COM1_BAUD_DIVISOR_LOW);
// Set divisor high byte for the baud rate.
  outb(COM1_IER, COM1_BAUD_DIVISOR_HIGH);
// 8 data bits, no parity, one stop bit.
  outb(COM1_LCR, COM1_LCR_8N1);
// Enable FIFO (First-In, First-Out), clear buffers, set RX threshold.
  outb(COM1_FCR, COM1_FCR_ENABLE | COM1_FCR_CLEAR_RX | COM1_FCR_CLEAR_TX | COM1_FCR_RX_14);
// Set DTR (Data Terminal Ready), RTS (Request To Send), OUT2 (output 2).
  outb(COM1_MCR, COM1_MCR_DTR | COM1_MCR_RTS | COM1_MCR_OUT2);
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
