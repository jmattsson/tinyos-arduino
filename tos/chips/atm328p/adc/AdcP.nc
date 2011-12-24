module AdcP
{
  provides
  {
    interface Read[uint8_t id];
    interface ReadNow[uint8_t id];
    interface ReadStream[uint8_t id];
  }

  uses
    interface AdcConfigure<const Atm328pAdcConfig_t *>[uint8_t id];
}
implementation
{
  // TODO
}
