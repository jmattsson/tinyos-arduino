#include <Atm328pTimerConfig.h>
configuration HplAtm328pTimer0C
{
  provides
  {
    interface HplAtm328pTimer<uint8_t>;
    interface Alarm<ATM328P_TIMER_0_PRECISION_TYPE, uint8_t>[uint8_t id];
  }
}
implementation
{
  components HplAtm328pTimer0P, RealMainP;
  HplAtm328pTimer0P.PlatformInit <- RealMainP.PlatformInit;
  HplAtm328pTimer = HplAtm328pTimer0P;

  components HplAtm328pAlarms0C as Alarms;
  Alarm[0] = Alarms.AlarmA;
  Alarm[1] = Alarms.AlarmB;
}
