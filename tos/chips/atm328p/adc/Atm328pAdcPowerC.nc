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

/**
 * This component implements a deferred power policy for the ADC.
 * When included, it automatically powers off the ADC when usused for
 * a certain time period (determined by ATM328P_ADC_POWER_OFF_DELAY, by
 * default two seconds). See TEP115 for details on power policies.
 *
 * Note: Due to interplay between the power manager and platform initialization
 * the power policy does not take effect until after the ADC has been used
 * once. This should not present an issue however, since if the ADC components
 * aren't included the ADC is powered off anyway.
 */
configuration Atm328pAdcPowerC
{
}
implementation
{

#ifndef ATM328P_ADC_POWER_OFF_DELAY
#define ATM328P_ADC_POWER_OFF_DELAY 2048
#endif

  components Atm328pAdcC as AdcC;
  components new StdControlDeferredPowerManagerC(ATM328P_ADC_POWER_OFF_DELAY) as PowerMgrC;

  PowerMgrC.StdControl -> AdcC;
  PowerMgrC.ResourceDefaultOwner -> AdcC;
  PowerMgrC.ArbiterInfo -> AdcC;
}
