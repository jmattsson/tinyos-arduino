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
module HwW5100SpiC
{
  provides
  {
    interface Init;
    interface HwW5100;
  }
  uses
  {
//    interface Resource as SpiBus; // FIXME - push this up for performance!
    interface GeneralIO as SS;
    interface FastSpiByte;
    interface GpioInterrupt;
  }
}
implementation
{
  command error_t Init.init ()
  {
    call SS.makeOutput ();
    call SS.set ();
    call GpioInterrupt.enableFallingEdge ();
    return SUCCESS;
  }

  async command void HwW5100.out (uint16_t addr, uint8_t val)
  {
    // FIXME - ensure SpiBus is acquired
    call SS.clr ();
    call FastSpiByte.splitWrite (0xf0);
    call FastSpiByte.splitReadWrite (addr >> 8);
    call FastSpiByte.splitReadWrite (addr & 0xff);
    call FastSpiByte.splitReadWrite (val);
    call FastSpiByte.splitRead ();
    call SS.set ();
  }

  async command uint8_t HwW5100.in (uint16_t addr)
  {
    uint8_t val;
    // FIXME - ensure SpiBus is acquired
    call SS.clr ();
    call FastSpiByte.splitWrite (0x0f);
    call FastSpiByte.splitReadWrite (addr >> 8);
    call FastSpiByte.splitReadWrite (addr & 0xff);
    val = call FastSpiByte.splitReadWrite (0);
    call SS.set ();
    return val;
  }

  async event void GpioInterrupt.fired ()
  {
    signal HwW5100.interrupt ();
  }
}
