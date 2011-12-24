#include <Atm328pTimerconfig.h>
configuration HplAtm328pAlarm1AC
{
  provides interface Alarm<ATM328P_TIMER_1_PRECISION_TYPE, uint16_t> as AlarmA;
  provides interface Alarm<ATM328P_TIMER_1_PRECISION_TYPE, uint16_t> as AlarmB;
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

  components new HplAtm328pAlarmC (
    ATM328P_TIMER_1_PRECISION_TYPE,
    uint16_t,
    (uint8_t)&OCR1B, (uint8_t)&TCNT1,
    (uint8_t)&TIMSK1, (1 << OCIE1B),
    (uint8_t)&TIFR1, (1 << OCF1B),
    2) as Alarm1B;

  components HplAtm328pAlarmIsr1AP as Interrupts;
  Alarm1A.Isr -> Interrupts.InterruptA;
  Alarm1B.Isr -> Interrupts.InterruptB;

  AlarmA = Alarm1A;
  AlarmB = Alarm1B;
}
