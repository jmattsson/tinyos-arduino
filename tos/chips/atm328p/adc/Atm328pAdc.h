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

#define UQ_ATM328P_ADC_CLIENT "atm328p.adc"
#endif
