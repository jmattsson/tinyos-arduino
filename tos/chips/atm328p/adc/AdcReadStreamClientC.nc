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
