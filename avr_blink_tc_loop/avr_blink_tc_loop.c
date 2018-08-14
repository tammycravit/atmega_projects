#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
  DDRB |= 0b11111111;               /* Use all of PORTB for LEDs */

  uint8_t  direction = 0;           /* Keep track of which direction we're moving. */
                                    /* 1 = down, 0 = up                            */
  uint8_t  pattern = 0b00000001;    /* The bit pattern for the output.             */

  while (1)
  {
    /* Display the current output pattern on the LEDs */
    PORTB = pattern;

    /* Set the direction flag so the chase pattern reverses at the top */
    if (pattern & (1<<7))
    {
      direction = 1;
    }
    else
    {
      direction = 0;
    }

    /* Shift the bit pattern in the appropriate direction */
    if (direction == 1)
    {
      pattern = pattern >> 1;
    }
    else
    {
      pattern = pattern << 1;
    }

    /* And wait a bit. */
    _delay_ms(500);
  }
}
