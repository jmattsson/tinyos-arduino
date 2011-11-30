#ifndef __ATM328PTIMERCONFIG__
#define __ATM328PTIMERCONFIG__

#include "Atm328pTimerClockSource.h"

/* The Uno runs the internal clock at 16MHz, so prescale down to 16kHz,
 * and then do a further shift-right-by-4 transform for the milli timer. */
#define ATM328P_TIMER_0_CLOCK           TIMER_CLOCK_INTERNAL_PRESCALE_1024
#define ATM328P_TIMER_0_MILLI_DOWNSCALE 4
typedef struct {} T16khz;
#define ATM328P_TIMER_0_PRECISION_TYPE T16khz

/* The Uno runs the internal clock at 16MHz, so prescale down to 2MHz,
 * and then do a further shift-right-by-1 transform for the micro timer. */
#define ATM328P_TIMER_1_CLOCK           TIMER_CLOCK_INTERNAL_PRESCALE_8
#define ATM328P_TIMER_1_MICRO_DOWNSCALE 1
#define ATM328P_TIMER_1_32KHZ_DOWNSCALE 6
typedef struct {} T2Mhz;
#define ATM328P_TIMER_1_PRECISION_TYPE T2Mhz

#endif
