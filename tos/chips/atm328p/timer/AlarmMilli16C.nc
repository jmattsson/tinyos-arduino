#include <Atm328pTimerConfig.h>
generic configuration AlarmMilli16C()
{
  provides interface Alarm<TMilli, uint16_t>;
}
implementation
{
  components HplAtm328pTimer0C as Timer;
  components CounterMilli16C as Counter;

  components new TransformAlarmC (
    TMilli, uint16_t,
    ATM328P_TIMER_0_PRECISION_TYPE, uint8_t,
    ATM328P_TIMER_0_MILLI_DOWNSCALE) as Transform;
  Transform.AlarmFrom -> Timer.Alarm[unique(UQ_TIMER_0_ALARM)];
  Transform.Counter -> Counter;

  Alarm = Transform.Alarm;
}
