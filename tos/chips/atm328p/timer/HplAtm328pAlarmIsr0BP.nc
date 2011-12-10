#include <Atm328pTimerConfig.h>
module HplAtm328pAlarmIsr0BP
{
  provides interface HplAtm328pAlarmIsr;
}
implementation
{
  AVR_NONATOMIC_HANDLER(TIMER0_COMPB_vect)
  {
    signal HplAtm328pAlarmIsr.fired ();
  }

  default async event void HplAtm328pAlarmIsr.fired () {}
}
