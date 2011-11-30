configuration HplAtm328pTimer0C
{
  provides interface HplAtm328pTimer<uint8_t> as Timer0;
}
implementation
{
  components HplAtm328pTimer0P, RealMainP;
  HplAtm328pTimer0P.PlatformInit <- RealMainP.PlatformInit;

  Timer0 = HplAtm328pTimer0P;
}
