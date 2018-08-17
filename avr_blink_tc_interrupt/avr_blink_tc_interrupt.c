////////////////////////////////////////////////////////////////////////////////
// File Name    : avr_blink_tc_interrupt.c
// Description  : Chase a series of 8 LEDs.
// Architecture : AVR
// Author       : Tammy Cravit <tammycravit@me.com>
// Last Modified: Tue Aug 14 17:01:28 UTC 2018
//////////////////////////////////////////////////////////////////////////////

/////////////////////////
// Include files
/////////////////////////

#include <avr/io.h>
#include <avr/interrupt.h>
#include "../library/simulavr_info.h"

/////////////////////////
// SimulAVR definitions for targeting
/////////////////////////

SIMINFO_DEVICE("attiny2313");
SIMINFO_CPUFREQUENCY(F_CPU);
SIMINFO_SERIAL_IN("D0", "-", 19200);
SIMINFO_SERIAL_OUT("D1", "-", 19200);

/////////////////////////
// Global variables and constants
/////////////////////////

volatile uint8_t  direction = 0;            // Keep track of which direction we're
                                            // moving. 1 = down, 0 = up
volatile uint8_t  pattern = 0b00000001;     // The bit pattern for the output.
const uint16_t timer_delay = 8000;          // About 500ms at 1MHz, adjust as needed.

/////////////////////////
// Interrupt service routine: TIMER1 overflow.
//
// We count the number of overflows (with 10x prescaling) to generate the right
// delay between activations. At 1 MHz, 8,000 overflows will result in a delay of
// about 500ms. At 16MHz, set the timer_delay constant to 128,000 and change it to
// a uint16_t.
/////////////////////////

ISR (TIMER1_OVF_vect) {
  PORTB = pattern;

  // Set the direction flag so the chase pattern reverses at the top
  direction = (pattern & (1<<7) ? 1 : 0);

  // Shift the bit pattern in the appropriate direction
  if (direction == 1) {
    pattern = pattern >> 1;
  }
  else {
    pattern = pattern << 1;
  }

  TCNT1 = timer_delay;
}

/////////////////////////
// Main entrypoint. Sets up the IO port and TIMER1 configuration, sets thbe initial
// LED state, and then enters an infinite loop. The actual process of updating the
// LEDs is handled by the TIMER1_OVF ISR.
/////////////////////////

int main(void) {

  DDRB |= 0b11111111;               // Use all of PORTB for LEDs

  PORTB = pattern;                  // Set the initial state of the LEDs

  TCNT1 = timer_delay;              // Number of timer overflows until LED change
  TCCR1A = 0x00;
  TCCR1B = (1<<CS10) | (1<<CS12);   // Timer mode with 1024 prescler
  TIMSK = (1 << TOIE1) ;            // Enable timer1 overflow interrupt(TOIE1)

  sei();                            // Enable global interrupts by setting global
                                    // interrupt enable bit in SREG

  while (1) {
    // Just let the loop run; the ISR takes care of doing stuff.
  }
}
