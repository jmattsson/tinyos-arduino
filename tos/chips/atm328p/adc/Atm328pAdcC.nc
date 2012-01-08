#include "Atm328pAdc.h"
configuration Atm328pAdcC
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
  components Atm328pAdcP as AdcP;
  components new SimpleRoundRobinArbiterC(UQ_ATM328P_ADC_HAL) as Arbiter;
  AdcP.Resource -> Arbiter;

  components HplAtm328pAdcP;
  AdcP.Adc -> HplAtm328pAdcP;

  components Atm328pAlarms1C;
  AdcP.Alarm -> Atm328pAlarms1C.Alarm[1]; // Note: has to be COMP B (Alarm[1])

  StdControl = HplAtm328pAdcP;
  ReadNow = AdcP;
  Resource = Arbiter;
  Read = AdcP;
  ReadStream = AdcP;

  AdcP.AdcConfigure = AdcConfigure;
}
