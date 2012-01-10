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

#ifndef _ATM328PADC_H_
#define _ATM328PADC_H_

/* See the ATmega328p datasheet for acceptable uses and constraints
 * of the various voltage reference options.
 */
typedef enum {
  ATM328P_ADC_REF_AREF = 0x00,
  ATM328P_ADC_REF_AVCC = 0x01,
  ATM328P_ADC_REF_INTERNAL = 0x03,
} Atm328pAdcRef_t;


/* For maximum resolution sampling the ADC clock should be in the
 * 50-200kHz range. The prescale is relative to the system clock (as
 * defined by F_CPU).
 */
typedef enum {
  ATM328P_ADC_PRESCALE_2   = 0x01,
  ATM328P_ADC_PRESCALE_4   = 0x02,
  ATM328P_ADC_PRESCALE_8   = 0x03,
  ATM328P_ADC_PRESCALE_16  = 0x04,
  ATM328P_ADC_PRESCALE_32  = 0x05,
  ATM328P_ADC_PRESCALE_64  = 0x06,
  ATM328P_ADC_PRESCALE_128 = 0x07,
} Atm328pAdcPrescale_t;


/* Valid ADC channels.
 */
typedef enum {
  ATM328P_ADC_CHANNEL_0    = 0x00,
  ATM328P_ADC_CHANNEL_1    = 0x01,
  ATM328P_ADC_CHANNEL_2    = 0x02,
  ATM328P_ADC_CHANNEL_3    = 0x03,
  ATM328P_ADC_CHANNEL_4    = 0x04,
  ATM328P_ADC_CHANNEL_5    = 0x05,
  ATM328P_ADC_CHANNEL_6    = 0x06,
  ATM328P_ADC_CHANNEL_7    = 0x07,
  ATM328P_ADC_CHANNEL_TEMP = 0x08,
  ATM328P_ADC_CHANNEL_VREF = 0x0e,
  ATM328P_ADC_CHANNEL_GND  = 0x0f,
} Atm328pAdcChannel_t;


/* Note: The ReadStream interface uses TIMER1_COMP_B as trigger source.
 */
typedef enum {
  ATM328P_ADC_TRIGGER_FREE_RUNNING    = 0x00,
  ATM328P_ADC_TRIGGER_ANALOG_COMP     = 0x01,
  ATM328P_ADC_TRIGGER_EXT_INTR0       = 0x02,
  ATM328P_ADC_TRIGGER_TIMER0_COMP_A   = 0x03,
  ATM328P_ADC_TRIGGER_TIMER0_OVERFLOW = 0x04,
  ATM328P_ADC_TRIGGER_TIMER1_COMP_B   = 0x05,
  ATM328P_ADC_TRIGGER_TIMER1_OVERFLOW = 0x06,
  ATM328P_ADC_TRIGGER_TIMER1_CAPTURE  = 0x07,
} Atm328pAdcTriggerSource_t;


/* ADC client configuration, including reference source, clocking and
 * channel selection. The @c digital_input flag determines whether the
 * digital input buffer for the pin/channel is enabled.
 */
typedef struct {
  Atm328pAdcRef_t      reference;
  Atm328pAdcPrescale_t prescale;
  Atm328pAdcChannel_t  channel;
  bool                 digital_input;
} Atm328pAdcConfig_t;


#define UQ_ATM328P_ADC_HAL    "atm328p.adc"
#define UQ_ATM328P_ADC_STREAM "atm328p.adc.stream"
#endif
