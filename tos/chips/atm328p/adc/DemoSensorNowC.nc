generic configuration DemoSensorNowC()
{
  provides interface ReadNow<uint16_t>;
  provides interface Resource;
}
implementation
{
  components new AdcReadNowClientC() as ClientC, DemoSensorConfigP;
  ClientC.AdcConfigure -> DemoSensorConfigP;

  ReadNow  = ClientC;
  Resource = ClientC;
}
