configuration PlatformSerialC
{
  provides interface StdControl;
  provides interface UartStream;
  provides interface UartByte;
}
implementation
{
  components Atm328pUsart0C as Usart0;
  
  StdControl = Usart0;
  UartStream = Usart0;
  UartByte = Usart0;

  components BusyWaitMicroC, PlatformUsartConfigC;
  Usart0.BusyWait -> BusyWaitMicroC;
  Usart0.Atm328pUsartConfig -> PlatformUsartConfigC;
}
