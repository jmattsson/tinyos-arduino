#include <Atm328pTimerConfig.h>
module HplAtm328pAlarmIsr0AP
{
  provides interface HplAtm328pAlarmIsr;
}
implementation
{
  AVR_NONATOMIC_HANDLER(TIMER0_COMPA_vect)
  {
    signal HplAtm328pAlarmIsr.fired ();
  }
}
