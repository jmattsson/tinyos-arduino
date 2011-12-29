#include "Atm328pAdc.h"
generic configuration AdcReadNowClientC()
{
  provides {
    interface Resource;
    interface ReadNow<uint16_t>;
  }
  uses interface AdcConfigure<const Atm328pAdcConfig_t *>;
}
implementation
{
  enum { ID = unique(UQ_ATM328P_ADC_CLIENT) };

  components AdcC;
  AdcC.AdcConfigure[ID] = AdcConfigure;

  Resource = AdcC.Resource[ID];
  ReadNow = AdcC.ReadNow[ID];
}
