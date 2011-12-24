configuration PlatformSerialC
{
  provides
  {
    interface StdControl;
    interface UartStream;
    interface UartByte;
    interface SerialFlush;
  }
}
implementation
{
  components Atm328pUsartC as Usart;
  
  StdControl  = Usart;
  UartStream  = Usart;
  UartByte    = Usart;
  SerialFlush = Usart;

  components BusyWaitMicroC, PlatformUsartConfigC;
  Usart.BusyWait -> BusyWaitMicroC;
  Usart.Atm328pUsartConfig -> PlatformUsartConfigC;
}
