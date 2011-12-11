#include <Atm328pTimerconfig.h>
configuration HplAtm328pAlarm1AC
{
  provides interface Alarm<ATM328P_TIMER_1_PRECISION_TYPE, uint16_t>;
}
implementation
{
  components new HplAtm328pAlarmC (
    ATM328P_TIMER_1_PRECISION_TYPE,
    uint16_t,
    (uint8_t)&OCR1A, (uint8_t)&TCNT1,
    (uint8_t)&TIMSK1, (1 << OCIE1A),
    (uint8_t)&TIFR1, (1 << OCF1A),
    2) as Alarm1A;

  components HplAtm328pAlarmIsr1AP as Isr;
  Alarm1A.Isr -> Isr;

  Alarm = Alarm1A;
}
