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

generic configuration HplAtm328pGeneralIOPortP (uint8_t port, uint8_t pin, uint8_t dir)
{
  provides
  {
    interface GeneralIO as Pin0;
    interface GeneralIO as Pin1;
    interface GeneralIO as Pin2;
    interface GeneralIO as Pin3;
    interface GeneralIO as Pin4;
    interface GeneralIO as Pin5;
    interface GeneralIO as Pin6;
    interface GeneralIO as Pin7;
  }
}
implementation
{
  components
    new HplAtm328pGeneralIOPinP (port, pin, dir, 0) as IOPin0,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 1) as IOPin1,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 2) as IOPin2,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 3) as IOPin3,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 4) as IOPin4,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 5) as IOPin5,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 6) as IOPin6,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 7) as IOPin7;

  Pin0 = IOPin0;
  Pin1 = IOPin1;
  Pin2 = IOPin2;
  Pin3 = IOPin3;
  Pin4 = IOPin4;
  Pin5 = IOPin5;
  Pin6 = IOPin6;
  Pin7 = IOPin7;
}
