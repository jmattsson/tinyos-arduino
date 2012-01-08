#include "Atm328pAdc.h"
generic configuration AdcReadClientC()
{
  provides interface Read<uint16_t>;

  uses interface AdcConfigure<const Atm328pAdcConfig_t *>;
}
implementation
{
  enum { HAL_ID = unique(UQ_ATM328P_ADC_HAL) };

  components AdcC, AdcReadP;

  AdcC.Read[HAL_ID] <- AdcReadP.Service[HAL_ID];
  Read               = AdcReadP.Read[HAL_ID];

  AdcConfigure = AdcC.AdcConfigure[HAL_ID];
}
