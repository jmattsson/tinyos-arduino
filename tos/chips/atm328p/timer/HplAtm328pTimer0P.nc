/*
 * Copyright (c) 2012 Johny Mattsson
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <Atm328pTimerConfig.h>
#include <avr/power.h>

module HplAtm328pTimer0P
{
    provides interface HplAtm328pTimer<uint8_t> as Timer;
    provides interface Init as PlatformInit;
    uses interface McuPowerState;
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
        power_timer0_enable ();

        // clear clock source
        TCCR0B &= ~CLOCK_SOURCE_TIMER_0_gm;

        // reset value
        call Timer.set (0);

        // enable overflow interrupts
        TIMSK0 |= (1 << TOIE1);

        // enable the chosen clock source
        TCCR0B |= (ATM328P_TIMER_0_CLOCK << CS00);

        call McuPowerState.update ();
    }


    async command void Timer.stop ()
    {
        // clear clock source
        TCCR0B &= ~CLOCK_SOURCE_TIMER_0_gm;

        power_timer0_disable ();
        call McuPowerState.update ();
    }

    command error_t PlatformInit.init ()
    {
        call Timer.start ();
        return SUCCESS;
    }
}
