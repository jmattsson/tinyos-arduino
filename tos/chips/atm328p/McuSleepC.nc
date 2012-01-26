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
#include <avr/sleep.h>
#include <avr/power.h>

module McuSleepC
{
  provides
  {
    interface Init @exactlyonce();
    interface McuSleep;
    interface McuPowerState;
  }
  uses interface McuPowerOverride;
}
implementation
{

  bool dirty = TRUE;
  mcu_power_t mode;

#define POWERED_ON(module) (!(PRR & _BV(module)))

  void update_power_mode ()
  {
    mcu_power_t mp = ATM328P_POWER_DOWN;

    // If timer 0 or 1 is active, can only IDLE
    if (POWERED_ON(PRTIM0) || POWERED_ON(PRTIM1))
      mp = ATM328P_POWER_IDLE;
    // ...same with usart, two-wire and spi
    else if (POWERED_ON(PRUSART0) || POWERED_ON(PRTWI) || POWERED_ON(PRSPI))
      mp = ATM328P_POWER_IDLE;
    // ...but the adc can be used in noise reduction mode
    else if (POWERED_ON(PRADC))
      mp = ATM328P_POWER_ADC_NOISERED;
    // ... and timer 2 is functional all the way down in power-save
    else if (POWERED_ON(PRTIM2))
      mp = ATM328P_POWER_SAVE;

    mode = combine_mcu_power_t (mp, call McuPowerOverride.lowestState ());
  }

  command error_t Init.init ()
  {
    // Switch off power to all I/O modules. Any modules actually used will
    // re-enable power to themselves at init/start time.

    // The ADC must be disabled before powered off
    ADCSRA &= ~_BV(ADEN);

    power_all_disable ();

    return SUCCESS;
  }

  async command void McuSleep.sleep ()
  {
    uint8_t sreg;
    uint8_t sm;

    if (dirty)
      update_power_mode ();

    switch (mode)
    {
      case ATM328P_POWER_IDLE:         sm = SLEEP_MODE_IDLE; break;
      case ATM328P_POWER_ADC_NOISERED: sm = SLEEP_MODE_ADC; break;
      case ATM328P_POWER_EXT_STANDBY:  sm = SLEEP_MODE_EXT_STANDBY; break;
      case ATM328P_POWER_SAVE:         sm = SLEEP_MODE_PWR_SAVE; break;
      case ATM328P_POWER_STANDBY:      sm = SLEEP_MODE_STANDBY; break;
      default:
      case ATM328P_POWER_DOWN:         sm = SLEEP_MODE_PWR_DOWN; break;
    }

    set_sleep_mode (sm);
    sleep_enable ();

    sreg = SREG;

    sleep_bod_disable(); // TODO: make this optional
    sei ();
    asm ("sleep" ::: "memory"); // sleep_cpu() lacks needed "memory" clobber
    sleep_disable ();

    SREG = sreg;
  }

  async command void McuPowerState.update ()
  {
    dirty = TRUE;
  }

  default async command mcu_power_t McuPowerOverride.lowestState ()
  {
    return ATM328P_POWER_DOWN;
  }
}
