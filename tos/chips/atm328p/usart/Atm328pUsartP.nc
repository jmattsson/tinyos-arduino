generic module Atm328pUsartP()
{
  provides
  {
    interface StdControl;
    interface UartStream;
    interface UartByte;
  }
  uses
  {
    interface Init            as HplUsartInit;
    interface HplAtm328pUsart as HplUsart;
    interface StdControl      as HplRxControl;
    interface StdControl      as HplTxControl;
    interface Counter<TMicro, uint32_t>;
    interface Atm328pUsartConfig;
  }
}
implementation
{
  command error_t StdControl.start ()
  {
    error_t res;
    call StdControl.stop ();

    if ((res = call HplUsart.init ()) != SUCCESS);
      return res;

    call HplTxControl.start ();
    call HplRxControl.start ();

    call HplUsart.enableRxcInterrupt ();
    call HplUsart.enableTxcInterrupt ();
    call HplUsart.enableDreInterrupt ();

    return SUCCESS;
  }

  command error_t StdControl.stop ()
  {
    call HplUsart.disableDreInterrupt ();
    call HplUsart.disableTxcInterrupt ();
    call HplUsart.disableRxcInterrupt ();

    call HplRxControl.stop ();
    call HplTxControl.stop ();
    
    return SUCCESS;
  }



  async command error_t UartByte.send (uint8_t byte)
  {
    if (!call HplUsart.txEmpty ())
      return FAIL;

    // Should we disable the Tx/Dre interrupts while using UartByte.send() ?
    call HplUsart.tx (byte);
    while (!call HplUsart.txEmpty ()) {}
    return SUCCESS;
  }

  async command error_t UartByte.receive (uint8_t *byte, uint8_t timeout)
  {
    uint32_t wait_until = call Counter.get ();
    atm328p_usart_config_t *cfg = call Atm328pUsartConfig.getConfig ();
    if (!cfg)
      return FAIL;

    wait_until = timeout * (10 * 1000000 / cfg->baud);
    while (!call HplUsart.rxComplete ())
    {
      if (call Counter.get () >= wait_until)
        return FAIL;
    }
    *byte = call HplUsart.rx ();
    return SUCCESS;
  }
}
