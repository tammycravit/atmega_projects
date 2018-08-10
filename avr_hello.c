#include <avr/io.h>

#define F_CPU 16000000UL
#define TIMER_CLOCK 2

int main()
{
  DDRD = _BV(PD5);
  TCCR1A = _BV(COM1A0);
  TCCR1B = _BV(CS10) | _BV(CS11) | _BV(WGM12);
  OCR1A = ((F_CPU / 64) / (2 * TIMER_CLOCK)) - 1;

  while(1)
  {
  }
  return 0;
}
