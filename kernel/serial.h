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
// Header guard start.
#ifndef VIBEOS_SERIAL_H
// Header guard define.
#define VIBEOS_SERIAL_H
// Initialize the serial port.
void serial_init(void);
// Write a single character to the serial port.
void serial_write_char(char c);
// Write a null-terminated string to the serial port.
void serial_write(const char *s);
// Header guard end.
#endif
