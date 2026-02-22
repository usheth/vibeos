// Include the serial interface.
#include "serial.h"
// Kernel C entry point.
void kmain(void) {
// Initialize the serial port.
  serial_init();
// Print a hello message.
  serial_write("vibeos: hello from 32-bit\n");
// Halt forever.
  for (;;) {
// Halt the CPU until the next interrupt.
    __asm__ __volatile__("hlt");
// End halt loop body.
  }
// End kmain.
}
