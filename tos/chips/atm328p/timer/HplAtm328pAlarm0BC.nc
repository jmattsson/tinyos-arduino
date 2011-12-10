#include <Atm328pTimerConfig.h>
configuration HplAtm328pAlarm0BC
{
  provides interface Alarm<ATM328P_TIMER_0_PRECISION_TYPE, uint8_t>;
}
implementation
{
  components new HplAtm328pAlarmC (
    ATM328P_TIMER_0_PRECISION_TYPE,
    uint8_t,
    (uint8_t)&OCR0A, (uint8_t)&TCNT0,
    (uint8_t)&TIMSK0, (1 << OCIE0B),
    (uint8_t)&TIFR0, (1 << OCF0B),
    1) as Alarm0B;

  components HplAtm328pAlarmIsr0BP as Isr;
  Alarm0B.Isr -> Isr;

  Alarm = Alarm0B;
}
