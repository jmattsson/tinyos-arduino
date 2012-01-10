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

configuration Atm328pAlarms0C
{
  provides interface Alarm<ATM328P_TIMER_0_PRECISION_TYPE, uint8_t>[uint8_t id]
    @atmostonce();
}
implementation
{
  components new HplAtm328pAlarmC (
    ATM328P_TIMER_0_PRECISION_TYPE,
    uint8_t,
    (uint8_t)&OCR0A, (uint8_t)&TCNT0,
    (uint8_t)&TIMSK0, (1 << OCIE0A),
    (uint8_t)&TIFR0, (1 << OCF0A)
  ) as HplAlarm0A;

  components new HplAtm328pAlarmC (
    ATM328P_TIMER_0_PRECISION_TYPE,
    uint8_t,
    (uint8_t)&OCR0B, (uint8_t)&TCNT0,
    (uint8_t)&TIMSK0, (1 << OCIE0B),
    (uint8_t)&TIFR0, (1 << OCF0B)
  ) as HplAlarm0B;

  components HplAtm328pAlarmIsr0P as Interrupts;

  components
    new Atm328pAlarmC (ATM328P_TIMER_0_PRECISION_TYPE, uint8_t, 1) as Alarm0A,
    new Atm328pAlarmC (ATM328P_TIMER_0_PRECISION_TYPE, uint8_t, 1) as Alarm0B;

  Alarm0A.HplAlarm -> HplAlarm0A;
  Alarm0B.HplAlarm -> HplAlarm0B;
  Alarm0A.Isr -> Interrupts.InterruptA;
  Alarm0B.Isr -> Interrupts.InterruptB;

  Alarm[0] = Alarm0A;
  Alarm[1] = Alarm0B;
}
