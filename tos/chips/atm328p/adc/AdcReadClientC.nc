#include "Atm328pAdc.h"
generic configuration AdcReadClientC()
{
  provides interface Read<uint16_t>;

  uses interface AdcConfigure<const Atm328pAdcConfig_t *>;
}
implementation
{
  enum { ID = unique(UQ_ATM328P_ADC_CLIENT) };

  components AdcC;

  Read = AdcC.Read[ID];
  AdcConfigure = AdcC.AdcConfigure[ID];
}
