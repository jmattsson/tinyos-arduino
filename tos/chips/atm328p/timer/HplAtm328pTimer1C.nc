configuration HplAtm328pTimer1C
{
  provides interface HplAtm328pTimer<uint16_t> as Timer1;
}
implementation
{
  components HplAtm328pTimer1P, PlatformTimersC, RealMainP;

  HplAtm328pTimer1P.Config -> PlatformTimersC;
  HplAtm328pTimer1P.PlatformInit <- RealMainP.PlatformInit;

  Timer1 = HplAtm328pTimer1P;
}
