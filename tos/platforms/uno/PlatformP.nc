module PlatformP
{
  provides interface Init;
  uses interface Init as LedsInit;
}
implementation
{
  command error_t Init.init ()
  {
    return call LedsInit.init ();
  }

  default command error_t LedsInit.init () { return SUCCESS; }
}
