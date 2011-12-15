configuration HplAtm328pUsartC
{
  provides
  {
    interface Init;
    interface StdControl as RxControl;
    interface StdControl as TxControl;
    interface HplAtm328pUsart as Usart;
  }
  uses interface Atm328pConfig as Config;
}
implementation
{
  components HplAtm328pUsartP as UsartP;

  RxControl = UsartP.RxControl;
  TxControl = UsartP.RxControl;
  Usart     = UsartP.Usart;
  Config    = UsartP.Config;
  Init      = UsartP.Init;
}
