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

#include "Atm328pAdc.h"

generic configuration AdcReadStreamClientC()
{
  /**
   * The ATmega328P seems to have Serious Issues(tm) with running the ADC
   * tied to the compare interrupt, which is what the ReadStream interface
   * uses. Rather than trigger a single conversion whenever the compare
   * fires, it seems to trigger more willy-nilly, almost as if it was in
   * free-running mode. Maybe it's related to not using the counter/compare
   * in clear-on-compare mode, but as we're sharing the counter with the
   * micro timer, that mode is not an option. To work around this annoyance
   * we run with ADC interrupts disabled most of the time, and only briefly
   * enable them in response to the compare interrupt. This isn't ideal, but
   * all attempts at getting the chip to perform to documentation has failed.
   *
   * The maximum supported ReadStream period is 32766. The effective minimum
   * depends on the prescaler configuration used. With a core frequency of
   * 16MHz and the prescaler at 128, a stable period of ~120us can be achieved.
   * With the prescaler at 2, it's possible to go as low as ~18us. Using
   * a lower period will result in drift/skips in the samples.
   */
  provides interface ReadStream<uint16_t>;

  uses interface AdcConfigure<const Atm328pAdcConfig_t *>;
}
implementation
{
  enum {
    STREAM_ID = unique(UQ_ATM328P_ADC_STREAM),
    HAL_ID = unique(UQ_ATM328P_ADC_HAL)
  };

  components Atm328pAdcC as AdcC, AdcReadStreamP;

  AdcC.ReadStream[HAL_ID] <- AdcReadStreamP.Service[HAL_ID];
  ReadStream               = AdcReadStreamP.ReadStream[HAL_ID];

  AdcConfigure = AdcC.AdcConfigure[HAL_ID];
}
