#include <Atm328pTimerConfig.h>
module HplAtm328pAlarmIsr1AP
{
  provides interface HplAtm328pAlarmIsr;
}
implementation
{
  AVR_ATOMIC_HANDLER(TIMER1_COMPA_vect)
  {
    signal HplAtm328pAlarmIsr.fired ();
  }

  default async event void HplAtm328pAlarmIsr.fired () {}
}
