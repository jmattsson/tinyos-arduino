#include "Atm328pTimerClockSource.h"

interface Atm328pTimerClockSource
{
    async command atm328p_timer_clock_t get64khzSource ();
}
