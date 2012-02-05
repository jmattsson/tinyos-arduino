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

module HplAtm328pPowerP
{
  provides interface HplAtm328pPower;
  uses interface McuPowerState;
}
implementation
{

#define MAKE_POWER_ACCESSORS(name, bit) \
  async command void HplAtm328pPower.powerOn ## name () \
  { \
    SFR_CLR_BIT(PRR, bit); \
    call McuPowerState.update (); \
  } \
  \
  async command void HplAtm328pPower.powerOff ## name () \
  { \
    SFR_SET_BIT(PRR, bit); \
    call McuPowerState.update (); \
  } \
  \
  async command bool HplAtm328pPower.is ## name ## Powered () \
  { \
    return SFR_BIT_CLR(PRR, bit); \
  } \
  \

  MAKE_POWER_ACCESSORS(Adc, PRADC)
  MAKE_POWER_ACCESSORS(Usart, PRUSART0)
  MAKE_POWER_ACCESSORS(Spi, PRSPI)
  MAKE_POWER_ACCESSORS(Twi, PRTWI)
  MAKE_POWER_ACCESSORS(Timer0, PRTIM0)
  MAKE_POWER_ACCESSORS(Timer1, PRTIM1)
  MAKE_POWER_ACCESSORS(Timer2, PRTIM2)

#undef MAKE_POWER_ACCESSORS
}
