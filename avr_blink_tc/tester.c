#include <stdio.h>
#include "print_binary_macros.h"

void main(void)
{
  __uint16_t the_val = 1;
  printf("At start: "
      PRINTF_BINARY_PATTERN_INT16,
      PRINTF_BYTE_TO_BINARY_INT16(the_val));
  printf("\n");

  __uint8_t direction = 0;

  for (int i=0; i < 256; i++)
  {
    if (the_val & (1<<15))
    {
      direction = 1;
    }
    else if (the_val & (1<<0))
    {
      direction = 0;
    }

    if (direction == 1)
    {
      the_val = the_val >> 1;
    }
    else
    {
      the_val = the_val << 1;
    }
    printf("Next step: "
      PRINTF_BINARY_PATTERN_INT16,
      PRINTF_BYTE_TO_BINARY_INT16(the_val));
    printf("\n");
  }
}
