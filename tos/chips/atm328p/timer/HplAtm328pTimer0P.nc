#include <Atm328pTimerConfig.h>
module HplAtm328pTimer0P
{
    provides interface HplAtm328pTimer<uint8_t> as Timer;
    provides interface Init as PlatformInit;
}
implementation
{
    #define CLOCK_SOURCE_TIMER_0_gm (0x07 << CS00)

    AVR_ATOMIC_HANDLER(TIMER0_OVF_vect)
    {
        signal Timer.overflow ();
    }


    async command uint8_t Timer.get ()
    {
        return TCNT0;
    }


    async command void Timer.set (uint8_t val)
    {
        TCNT0 = val;
    }


    default async event void Timer.overflow () {}


    async command bool Timer.test ()
    {
        return TIFR0 & (1 << TOV0);
    }


    async command void Timer.clear ()
    {
        TIFR0 |= (1 << TOV0);
    }


    async command void Timer.start ()
    {
        // TODO: check if need to clear PRTIM0 bit to enable the timer

        // clear clock source
        TCCR0B &= ~CLOCK_SOURCE_TIMER_0_gm;

        // reset value
        call Timer.set (0);

        // enable overflow interrupts
        TIMSK0 |= (1 << TOIE1);

        // enable the chosen clock source
        TCCR0B |= (ATM328P_TIMER_0_CLOCK << CS00);
    }


    async command void Timer.stop ()
    {
        // clear clock source
        TCCR0B &= ~CLOCK_SOURCE_TIMER_0_gm;
    }

    command error_t PlatformInit.init ()
    {
        call Timer.start ();
        return SUCCESS;
    }
}
