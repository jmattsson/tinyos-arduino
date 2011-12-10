#include <Atm328pTimerConfig.h>
configuration HplAtm328pTimer0C
{
  provides interface HplAtm328pTimer<uint8_t> as Timer0;
  provides interface Alarm<ATM328P_TIMER_0_PRECISION_TYPE, uint8_t>[uint8_t id];
}
implementation
{
  components HplAtm328pTimer0P, RealMainP;
  HplAtm328pTimer0P.PlatformInit <- RealMainP.PlatformInit;
  Timer0 = HplAtm328pTimer0P;

  // FIXME: don't pull in the ISR unless alarm(s) are wired
  components HplAtm328pAlarm0AC as Alarm0A, HplAtm328pAlarm0BC as Alarm0B;
  Alarm[0] = Alarm0A;
  Alarm[1] = Alarm0B;
}
