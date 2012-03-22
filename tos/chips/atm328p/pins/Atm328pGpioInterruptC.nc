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
generic module Atm328pGpioInterruptC()
{
  provides interface GpioInterrupt;
  uses interface HplAtm328pIoInterrupt;
}
implementation
{
  void enable_as_rising (bool rising)
  {
    atomic
    {
      call HplAtm328pIoInterrupt.disable ();
      call HplAtm328pIoInterrupt.configure (
        rising ? INTR_RISING_EDGE : INTR_FALLING_EDGE);
      call HplAtm328pIoInterrupt.clear ();
      call HplAtm328pIoInterrupt.enable ();
    }
  }

  async command error_t GpioInterrupt.enableRisingEdge ()
  {
    enable_as_rising (TRUE);
  }

  async command error_t GpioInterrupt.enableFallingEdge ()
  {
    enable_as_rising (FALSE);
  }

  async command error_t GpioInterrupt.disable ()
  {
    call HplAtm328pIoInterrupt.disable ();
    return SUCCESS;
  }

  async event void HplAtm328pIoInterrupt.fired ()
  {
    signal GpioInterrupt.fired ();
  }

  default async event void GpioInterrupt.fired () {}
}
