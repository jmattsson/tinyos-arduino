#include "Atm328pAdc.h"
configuration AdcC
{
  provides
  {
    interface StdControl;

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

  components new SimpleRoundRobinArbiterC(UQ_ATM328P_ADC_CLIENT) as Arbiter;
  AdcP.Resource -> Arbiter;

  components HplAtm328pAdcP;
  AdcP.Adc -> HplAtm328pAdcP;

  components Atm328pAlarms1C;
  AdcP.Alarm -> Atm328pAlarms1C.Alarm[1]; // Note: has to be COMP B (Alarm[1])

  ArbitratedReadC.Service -> AdcP;
  ArbitratedReadC.Resource -> Arbiter;

  ArbitratedReadStreamC.Service -> AdcP;
  ArbitratedReadStreamC.Resource -> Arbiter;

  StdControl = HplAtm328pAdcP;
  ReadNow = AdcP;
  Resource = Arbiter;
  Read = ArbitratedReadC;
  ReadStream = ArbitratedReadStreamC;

  AdcP.AdcConfigure = AdcConfigure;
}
