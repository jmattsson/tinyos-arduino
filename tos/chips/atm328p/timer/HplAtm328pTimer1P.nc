#include "Atm328pTimerClockSource.h"
module HplAtm328pTimer1P
{
    provides interface HplAtm328pTimer<uint16_t> as Timer;
    provides interface Init as PlatformInit;
    uses interface Atm328pTimerClockSource as Config;
}
implementation
{
    #define CLOCK_SOURCE_gm (0x07 << CS10)

    AVR_NONATOMIC_HANDLER(TIMER1_OVF_vect)
    {
        signal Timer.overflow ();
    }


    async command uint16_t Timer.get ()
    {
        return TCNT1;
    }


    async command void Timer.set (uint16_t val)
    {
        TCNT1 = val;
    }


    default async event void Timer.overflow () {}


    async command bool Timer.test ()
    {
        return TIFR1 & (1 << TOV1);
    }


    async command void Timer.clear ()
    {
        TIFR1 |= (1 << TOV1);
    }


    async command void Timer.start ()
    {
        // clear clock source
        TCCR1B &= ~CLOCK_SOURCE_gm;

        // reset value
        call Timer.set (0);

        // enable overflow interrupts
        TIMSK1 |= (1 << TOIE1);

        // enable the chosen clock source
        TCCR1B |= (call Config.get64khzSource () << CS10);
    }


    async command void Timer.stop ()
    {
        // clear clock source
        TCCR1B &= ~CLOCK_SOURCE_gm;
    }

    command error_t PlatformInit.init ()
    {
        call Timer.start ();
        return SUCCESS;
    }
}
