#ifndef __ATM328PTIMERCONFIG__
#define __ATM328PTIMERCONFIG__

#include "Atm328pTimerClockSource.h"

/* The Uno runs the internal clock at 16MHz, so prescale down to 2MHz,
 * and then do a further shift-right-by-1 transform.
 */
#define ATM328P_TIMER_1_CLOCK       TIMER_CLOCK_INTERNAL_PRESCALE_8
#define ATM328P_TIMER_1_DOWNSCALE   1
typedef struct {} T2Mhz;
#define ATM328P_TIMER_1_PRECISION_TYPE T2Mhz

#endif
