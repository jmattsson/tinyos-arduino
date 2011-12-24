#include "Atm328pAdc.h"
configuration AdcC
{
  provides
  {
    interface ReadNow<uint16_t>[uint8_t id];
    interface Resource[uint8_t];

    interface Read<uint16_t>[uint8_t id];
    interface ReadStream<uint16_t>[uint8_t id];
  }
  uses interface AdcConfigure<const Atm328pAdcConfig_t *>[uint8_t id];
}
implementation
{
  components AdcP,
    new ArbitratedReadC(uint16_t),
    new ArbitratedReadStreamC(uniqueCount(UQ_ATM328P_ADC_CLIENT), uint16_t);

  components SimpleFcfsArbiterC as Arbiter;

  ArbitratedReadC.Service = AdcP;
  ArbitratedReadC.Resource = Arbiter;

  ArbitratedReadStreamC.Service = AdcP;
  ArbitratedReadStreamC.Resource = Arbiter;

  ReadNow = AdcP;
  Resource = Arbiter;

  Read = ArbitratedReadC;
  ReadStream = ArbitratedReadStreamC;
}
