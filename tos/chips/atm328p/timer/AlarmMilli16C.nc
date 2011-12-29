#include <Atm328pTimerConfig.h>
generic configuration AlarmMilli16C()
{
  provides interface Alarm<TMilli, uint16_t>;
}
implementation
{
  components Atm328pAlarms0C as Alarms;
  components CounterMilli16C as Counter;

  components new TransformAlarmC (
    TMilli, uint16_t,
    ATM328P_TIMER_0_PRECISION_TYPE, uint8_t,
    ATM328P_TIMER_0_MILLI_DOWNSCALE) as Transform;
  Transform.AlarmFrom -> Alarms.Alarm[unique(UQ_TIMER_0_ALARM)];
  Transform.Counter -> Counter;

  Alarm = Transform.Alarm;
}
