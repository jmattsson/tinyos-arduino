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
configuration ArduinoPinsC
{
  provides interface GeneralIO as Digital[uint8_t idx];
  provides interface GeneralIO as Analog[uint8_t idx];
}
implementation
{
  components HplAtm328pGeneralIOC as IO;

  Digital[0] = IO.PortD0;
  Digital[1] = IO.PortD1;
  Digital[2] = IO.PortD2;
  Digital[3] = IO.PortD3;
  Digital[4] = IO.PortD4;
  Digital[5] = IO.PortD5;
  Digital[6] = IO.PortD6;
  Digital[7] = IO.PortD7;

  Digital[ 8] = IO.PortB0;
  Digital[ 9] = IO.PortB1;
  Digital[10] = IO.PortB2;
  Digital[11] = IO.PortB3;
  Digital[12] = IO.PortB4;
  Digital[13] = IO.PortB5;

  Analog[0] = IO.PortC0;
  Analog[1] = IO.PortC1;
  Analog[2] = IO.PortC2;
  Analog[3] = IO.PortC3;
  Analog[4] = IO.PortC4;
  Analog[5] = IO.PortC5;
}
