interface HplAtm328pUsart
{
  async command void enableRxcInterrupt ();
  async command void disableRxcInterrupt ();

  async command void enableTxcInterrupt ();
  async command void disableTxcInterrupt ();

  async command void enableDreInterrupt ();
  async command void disableDreInterrupt ();

  async command bool rxComplete ();
  async command bool txComplete ();
  async command bool txEmpty ();
  async command bool frameError ();
  async command bool dataOverrun ();
  async command bool parityError ();

  async command bool rxBit8 ();
  async command uint8_t rx ();

  async command void txBit8 (bool bit);
  async command void tx (uint8_t data);

  async event void rxDone ();
  async event void txDone ();
  async event void txNowEmpty ();
}
