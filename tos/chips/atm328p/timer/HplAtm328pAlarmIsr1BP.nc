#include <Atm328pTimerConfig.h>
module HplAtm328pAlarmIsr1AP
{
  provides interface HplAtm328pAlarmIsr;
}
implementation
{
  AVR_NONATOMIC_HANDLER(TIMER1_COMPB_vect)
  {
    signal HplAtm328pAlarmIsr.fired ();
  }
}
