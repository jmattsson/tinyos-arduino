module HplAtm328pAlarmIsr0P
{
  provides interface HplAtm328pAlarmIsr as InterruptA;
  provides interface HplAtm328pAlarmIsr as InterruptB;
}
implementation
{
  AVR_ATOMIC_HANDLER(TIMER0_COMPA_vect)
  {
    signal InterruptA.fired ();
  }

  AVR_ATOMIC_HANDLER(TIMER0_COMPB_vect)
  {
    signal InterruptB.fired ();
  }

  default async event void InterruptA.fired () {}
  default async event void InterruptB.fired () {}
}
