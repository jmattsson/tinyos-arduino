configuration Atm328pUsartC
{
  provides
  {
    interface StdControl;
    interface UartStream;
    interface UartByte;
    interface SerialFlush;
  }

  uses interface BusyWait<TMicro, uint16_t>;
  uses interface Atm328pUsartConfig;
}
implementation
{
  components Atm328pUsartP, HplAtm328pUsartP;

  StdControl = Atm328pUsartP;
  UartStream = Atm328pUsartP;
  UartByte = Atm328pUsartP;
  SerialFlush = Atm328pUsartP;

  BusyWait = Atm328pUsartP;
  Atm328pUsartConfig = Atm328pUsartP;
  Atm328pUsartConfig = HplAtm328pUsartP;

  Atm328pUsartP.HplUsartInit -> HplAtm328pUsartP;
  Atm328pUsartP.HplRxControl -> HplAtm328pUsartP.RxControl;
  Atm328pUsartP.HplTxControl -> HplAtm328pUsartP.TxControl;
  Atm328pUsartP.HplUsart -> HplAtm328pUsartP;
}
