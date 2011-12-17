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
  components Atm328pUsart0C as Usart0;
  
  StdControl  = Usart0;
  UartStream  = Usart0;
  UartByte    = Usart0;
  SerialFlush = Usart0;

  components BusyWaitMicroC, PlatformUsartConfigC;
  Usart0.BusyWait -> BusyWaitMicroC;
  Usart0.Atm328pUsartConfig -> PlatformUsartConfigC;
}
