#include "Atm328pAdc.h"
generic configuration AdcReadStreamClientC()
{
  provides interface ReadStream<uint16_t>;

  uses interface AdcConfigure<const Atm328pAdcConfig_t *>;
}
implementation
{
  enum {
    STREAM_ID = unique(UQ_ATM328P_ADC_STREAM),
    HAL_ID = unique(UQ_ATM328P_ADC_HAL)
  };

  components AdcC, AdcReadStreamP;

  AdcC.ReadStream[HAL_ID] <- AdcReadStreamP.Service[STREAM_ID];
  ReadStream               = AdcReadStreamP.ReadStream[STREAM_ID];

  AdcConfigure = AdcC.AdcConfigure[HAL_ID];
}
