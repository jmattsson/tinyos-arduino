#include "Atm328pAdc.h"
configuration AdcReadStreamP
{
  provides interface ReadStream<uint16_t>[uint8_t id];

  uses interface ReadStream<uint16_t> as Service[uint8_t id];
}
implementation
{
  components Atm328pAdcC as AdcC, AdcInitStreamP, RealMainP, HplAtm328pTimer1C;
  AdcInitStreamP.AdcControl -> AdcC;
  AdcInitStreamP.PlatformInit <- RealMainP.PlatformInit;
  AdcInitStreamP.StreamTimer -> HplAtm328pTimer1C;

  components
    new ArbitratedReadStreamC (uniqueCount(UQ_ATM328P_ADC_STREAM), uint16_t);
  ArbitratedReadStreamC.Resource -> AdcC;

  Service = ArbitratedReadStreamC.Service;
  ReadStream = ArbitratedReadStreamC.ReadStream;
}
