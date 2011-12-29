generic configuration DemoSensorStreamC()
{
  provides interface ReadStream<uint16_t>;
}
implementation
{
  components new AdcReadStreamClientC() as ClientC, DemoSensorConfigP;
  ClientC.AdcConfigure -> DemoSensorConfigP;

  ReadStream = ClientC;
}
