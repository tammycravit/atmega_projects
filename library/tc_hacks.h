/* Helpers from https://electronics.stackexchange.com/questions/80613/bit-type-for-avr-microcontroller-programming */

#define BIT_GET(p,m) ((p)&(m))
#define BIT_SET(p,m) ((p)|=(m))
#define BIT_CLEAR(p,m) ((p)&=~(m))
#define BIT(x) (0x01<<(x))
