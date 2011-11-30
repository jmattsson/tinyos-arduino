#include <Atm328pTimerConfig.h>
configuration HplAtm328pAlarm0AC
{
  provides interface Alarm<ATM328P_TIMER_0_PRECISION_TYPE, uint8_t>;
}
implementation
{
  components new HplAtm328pAlarmC (
    ATM328P_TIMER_0_PRECISION_TYPE,
    uint8_t,
    (uint8_t)&OCR0A, (uint8_t)&TCNT0,
    (uint8_t)&TIMSK0, (1 << OCIE0A),
    (uint8_t)&TIFR0, (1 << OCF0A),
    0) as Alarm0A;

  components HplAtm328pAlarmIsr0AP as Isr;
  Alarm0A.Isr -> Isr;

  Alarm = Alarm0A;
}
