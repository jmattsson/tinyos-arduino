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
    interface BusyWait<TMicro, uint16_t>;
    interface Atm328pUsartConfig;
  }
}
implementation
{
  command error_t StdControl.start ()
  {
    error_t res;
    call StdControl.stop ();

    if ((res = call HplUsartInit.init ()) != SUCCESS);
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


  async command error_t UartStream.send (uint8_t *buf, uint16_t len)
  {
    // TODO
    return FAIL;
  }

  async command error_t UartStream.enableReceiveInterrupt ()
  {
    // TODO
    return FAIL;
  }

  async command error_t UartStream.disableReceiveInterrupt ()
  {
    // TODO
    return FAIL;
  }

  async command error_t UartStream.receive (uint8_t *buf, uint16_t len)
  {
    // TODO
    return FAIL;
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
    uint8_t symbols;
    uint16_t symbol_time;
    uint32_t total_wait;

    atm328p_usart_config_t *cfg = call Atm328pUsartConfig.getConfig ();

    if (!cfg)
      return FAIL;

    symbol_time = 1000000ul / cfg->baud;

    symbols = 1; // start bit
    switch (cfg->bits)
    {
      case ATM328P_USART_BITS_5: symbols += 5; break;
      case ATM328P_USART_BITS_6: symbols += 6; break;
      case ATM328P_USART_BITS_7: symbols += 7; break;
      case ATM328P_USART_BITS_8: symbols += 8; break;
      case ATM328P_USART_BITS_9: symbols += 9; break;
    }
    symbols += cfg->parity == ATM328P_USART_PARITY_NONE ? 0 : 1;
    symbols += cfg->two_stop_bits ? 2 : 1;

    total_wait = symbol_time * symbols * timeout;

    while (!call HplUsart.rxComplete ())
    {
      if (!total_wait)
        return FAIL;
      call BusyWait.wait (symbol_time);
      total_wait -= symbol_time;
    }
    *byte = call HplUsart.rx ();
    return SUCCESS;
  }


  async event void HplUsart.rxDone ()
  {
  }

  async event void HplUsart.txDone ()
  {
  }

  async event void HplUsart.txNowEmpty ()
  {
  }
}
