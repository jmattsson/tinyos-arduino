module AdcInitP
{
  provides interface Init as PlatformInit;
  uses interface StdControl as AdcControl;
}
implementation
{
  command error_t PlatformInit.init ()
  {
    call AdcControl.start ();
    return SUCCESS;
  }
}
