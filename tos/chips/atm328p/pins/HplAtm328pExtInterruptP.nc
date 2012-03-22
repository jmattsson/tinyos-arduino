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
generic module HplAtm328pExtInterruptP (uint8_t pin)
{
  provides interface HplAtm328pIoInterrupt;
  uses interface HplAtm328pIsr;
}
implementation
{
  async command void HplAtm328pIoInterrupt.enable ()
  {
    SFR_SET_BIT(EIMSK, pin);
  }

  async command void HplAtm328pIoInterrupt.disable ()
  {
    SFR_CLR_BIT(EIMSK, pin);
  }

  async command void HplAtm328pIoInterrupt.clear ()
  {
    SFR_SET_BIT(EIFR, pin);
  }

  async command void HplAtm328pIoInterrupt.configure (IoInterruptMode m)
  {
    atomic {
      uint8_t offs = 2 * pin;
      uint8_t msk = ~(0x03 << offs);
      uint8_t cfg = EICRA & msk;
      EICRA = cfg | (m << offs);
    }
  }


  async event void HplAtm328pIsr.fired ()
  {
    signal HplAtm328pIoInterrupt.fired ();
  }

  default async event void HplAtm328pIoInterrupt.fired () {}
}
