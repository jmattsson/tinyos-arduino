configuration PlatformLedsC
{
  provides
  {
    interface GeneralIO as Led0;
    interface GeneralIO as Led1;
    interface GeneralIO as Led2;
  }
  uses interface Init;
}
implementation
{
  components HplAtm328pGeneralIOC as Gpio,
    new InvertedIOC () as Inv0, new NoPinC();
  Inv0.SubIO -> Gpio.PortB5;

  Led0 = Inv0;
  Led1 = NoPinC;
  Led2 = NoPinC;

  components PlatformP;
  Init = PlatformP.LedsInit;
}
