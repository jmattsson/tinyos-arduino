module AdcInitStreamP
{
  provides interface Init as PlatformInit;
  uses interface StdControl as AdcControl;
  uses interface HplAtm328pTimer<uint16_t> as StreamTimer;
}
implementation
{
  command error_t PlatformInit.init ()
  {
    call AdcControl.start ();
    call StreamTimer.start ();
    return SUCCESS;
  }

  async event void StreamTimer.overflow () {}
}
