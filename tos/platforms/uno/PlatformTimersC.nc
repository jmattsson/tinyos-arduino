#include "Atm328pTimerClockSource.h"
module PlatformTimersC
{
    provides interface Atm328pTimerClockSource;
}
implementation
{
    async command atm328p_timer_clock_t Atm328pTimerClockSource.get64khzSource()
    {
        // Prescale 16MHz down to 64kHz for the timer on a standard Uno
        return TIMER_CLOCK_INTERNAL_PRESCALE_256;
    }
}
