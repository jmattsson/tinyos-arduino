#include <Atm328pTimerConfig.h>
configuration HplAtm328pTimer1C
{
  provides
  {
    interface HplAtm328pTimer<uint16_t>;
    interface Alarm<ATM328P_TIMER_1_PRECISION_TYPE, uint16_t>[uint8_t id];
  }
}
implementation
{
  components HplAtm328pTimer1P, RealMainP;
  HplAtm328pTimer1P.PlatformInit <- RealMainP.PlatformInit;
  HplAtm328pTimer = HplAtm328pTimer1P;

  components HplAtm328pAlarms1C as Alarms;
  Alarm[0] = Alarms.AlarmA;
  Alarm[1] = Alarms.AlarmB;
}
