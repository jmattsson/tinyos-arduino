#include "Atm328pAdc.h"
generic configuration AdcReadClientC()
{
  provides interface Read<uint16_t>;

  uses interface AdcConfigure<const Atm328pAdcConfig_t *>;
}
implementation
{
  enum {
    READ_ID = unique(UQ_ATM328P_ADC_READ),
    HAL_ID = unique(UQ_ATM328P_ADC_HAL)
  };

  components AdcC, AdcReadP;

  AdcC.Read[HAL_ID] <- AdcReadP.Service[READ_ID];
  Read               = AdcReadP.Read[READ_ID];

  AdcConfigure = AdcC.AdcConfigure[HAL_ID];
}
