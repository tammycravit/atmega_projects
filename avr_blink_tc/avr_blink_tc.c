#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
  DDRB |= 0b11111111;
  int direction = 0;
  int pattern = 0b00000001;

  while (1)
  {
    PORTB = pattern;
    _delay_ms(500);

    if (pattern & (1<<7))
    {
      direction = 1;
    }
    else
    {
      direction = 0;
    }

    if (direction == 1)
    {
      pattern = pattern >> 1;
    }
    else
    {
      pattern = pattern << 1;
    }
  }
}
