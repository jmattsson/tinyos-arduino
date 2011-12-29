generic configuration DemoSensorC()
{
  provides interface Read<uint16_t>;
}
implementation
{
  components new AdcReadClientC() as ClientC, DemoSensorConfigP;
  ClientC.AdcConfigure -> DemoSensorConfigP;

  Read = ClientC;
}
