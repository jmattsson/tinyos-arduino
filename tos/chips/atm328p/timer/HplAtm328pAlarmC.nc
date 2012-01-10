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

generic module HplAtm328pAlarmC(typedef precision_tag, typedef size_type @integer(), uint8_t OCREG, uint8_t CNTREG, uint8_t TIMSKREG, uint8_t TIMSK_BIT, uint8_t TIFREG, uint8_t TIFREG_BIT)
{
  provides interface HplAtm328pAlarm<precision_tag, size_type>;
}
implementation
{
  async command void HplAtm328pAlarm.start (size_type t)
  {
    atomic {
      *(size_type *)OCREG = t;
      *(uint8_t *)TIFREG |= TIFREG_BIT; /* clear compare interrupt flag */
      *(uint8_t *)TIMSKREG |= TIMSK_BIT; /* enable compare interrupt */
    }
  }

  async command void HplAtm328pAlarm.stop ()
  {
    *(uint8_t *)TIMSKREG &= ~TIMSK_BIT; /* disable compare interrupt */
  }

  async command bool HplAtm328pAlarm.isRunning ()
  {
    return *(uint8_t *)TIMSKREG & TIMSK_BIT;
  }

  async command size_type HplAtm328pAlarm.now ()
  {
    atomic return *(size_type *)CNTREG;
  }
}
