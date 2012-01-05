configuration AdcReadP
{
  provides interface Read<uint16_t>[uint8_t id];

  uses interface Read<uint16_t> as Service[uint8_t id];
}
implementation
{
  components AdcC, AdcInitP, RealMainP;
  AdcInitP.AdcControl -> AdcC;
  AdcInitP.PlatformInit <- RealMainP.PlatformInit;

  components new ArbitratedReadC (uint16_t);
  ArbitratedReadC.Resource -> AdcC;

  Service = ArbitratedReadC.Service;
  Read = ArbitratedReadC.Read;
}
