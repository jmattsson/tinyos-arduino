module DemoSensorConfigP
{
  provides interface AdcConfigure<const Atm328pAdcConfig_t *>;
}
implementation
{
  Atm328pAdcConfig_t cfg = {
    .reference = ATM328P_ADC_REF_INTERNAL,
    .prescale  = ATM328P_ADC_PRESCALE_128,
    .channel   = ATM328P_ADC_CHANNEL_TEMP,
    .digital_input = FALSE,
  };

  async command const Atm328pAdcConfig_t *AdcConfigure.getConfiguration ()
  {
    return &cfg;
  }
}
