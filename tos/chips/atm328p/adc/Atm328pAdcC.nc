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

configuration Atm328pAdcC
{
  provides
  {
    interface StdControl;

    interface ReadNow<uint16_t>[uint8_t id];
    interface Resource[uint8_t];

    interface Read<uint16_t>[uint8_t id];
    interface ReadStream<uint16_t>[uint8_t id];

    interface ArbiterInfo;
    interface ResourceDefaultOwner;
  }
  uses interface AdcConfigure<const Atm328pAdcConfig_t *>[uint8_t id];
}
implementation
{
  components Atm328pAdcP as AdcP;
  components new RoundRobinArbiterC(UQ_ATM328P_ADC_HAL) as Arbiter;
  AdcP.Resource -> Arbiter;

  components HplAtm328pAdcP;
  AdcP.Adc -> HplAtm328pAdcP;
  AdcP.AdcControl -> HplAtm328pAdcP;

  components Atm328pAlarms1C;
  AdcP.Alarm -> Atm328pAlarms1C.Alarm[1]; // Note: has to be COMP B (Alarm[1])

  components HplAtm328pPowerC;
  AdcP.HplPower -> HplAtm328pPowerC;

  StdControl = AdcP;
  ReadNow = AdcP;
  Resource = Arbiter;
  Read = AdcP;
  ReadStream = AdcP;
  ArbiterInfo = Arbiter;
  ResourceDefaultOwner = Arbiter;

  AdcP.AdcConfigure = AdcConfigure;
}
