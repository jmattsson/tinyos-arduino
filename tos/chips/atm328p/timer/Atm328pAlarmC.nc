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

generic module Atm328pAlarmC(typedef precision_tag, typedef size_type @integer(), uint16_t MIN_DELTA_T)
{
  provides interface Alarm<precision_tag, size_type>;
  uses interface HplAtm328pAlarm<precision_tag, size_type> as HplAlarm;
  uses interface HplAtm328pAlarmIsr as Isr;
}
implementation
{
  size_type m_alarmAt;

  async event void Isr.fired ()
  {
    call HplAlarm.stop ();
    signal Alarm.fired ();
  }

  async command void Alarm.start (size_type dt)
  {
    atomic call Alarm.startAt (call Alarm.getNow (), dt);
  }

  async command void Alarm.stop ()
  {
    call HplAlarm.stop ();
  }

  async command bool Alarm.isRunning ()
  {
    return call HplAlarm.isRunning ();
  }

  async command void Alarm.startAt (size_type t0, size_type dt)
  {
    atomic {
      size_type now;
      size_type next = t0 + dt;

      now = call Alarm.getNow ();

      /* t0 is always assumed to be in the past */
      if (t0 > now)
      {
        if ((next >= t0) || (next <= now))
        {
          dt = 0;
          goto doit; /* wanted alarm some time in the past */
        }
      }
      else
      {
        if ((next >= t0) && (next <= now))
        {
          dt = 0;
          goto doit; /* wanted alarm some time in the past */
        }
      }

      /* make the delta-t relative to current counter time */
      dt = next - now;

    doit:
      /* It's not possible to match on the very next counter value, so need
       * to bump by at least one. For high-frequency counters, we might also
       * need to add a few extra cycles to avoid missing the match while doing
       * these calculations. Check the assembler output to work out what the
       * appropriate value for MIN_DELTA_T should be for the particular
       * instance.
       */
      m_alarmAt = call Alarm.getNow () + dt + 1 + MIN_DELTA_T;

      call HplAlarm.start (m_alarmAt);
    }
  }

  async command size_type Alarm.getNow ()
  {
    atomic return call HplAlarm.now ();
  }

  async command size_type Alarm.getAlarm ()
  {
    atomic return m_alarmAt;
  }

  default async event void Alarm.fired () {}
}
