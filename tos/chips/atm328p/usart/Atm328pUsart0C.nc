configuration Atm328pUsart0C
{
  provides interface StdControl;
  provides interface UartStream;
  provides interface UartByte;

  uses interface Counter<TMicro, uint32_t>;
  uses interface Atm328pUsartConfig;
}
implementation
{
  components new Atm328pUsartP (), HplAtm328pUsart0P;

  StdControl = Atm328pUsartP;
  UartStream = Atm328pUsartP;
  UartByte = Atm328pUsartP;

  Counter = HplAtm328pUsartP;
  Atm328pUsartConfig = HplAtm328UsartP;

  Atm328pUsartP.HplUsartInit -> HplAtm328pUsart0P;
  Atm328pUsartP.HplRxControl -> HplAtm328pUsart0P;
  Atm328pUsartP.HplTxControl -> HplAtm328pUsart0P;
  Atm328pUsartP.HplUsart -> HplAtm328pUsart0P;
}
