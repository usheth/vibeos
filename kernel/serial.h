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
