#include <Atm328pTimerConfig.h>
configuration Atm328pAlarms0C
{
  provides interface Alarm<ATM328P_TIMER_0_PRECISION_TYPE, uint8_t>[uint8_t id]
    @atmostonce();
}
implementation
{
  components new HplAtm328pAlarmC (
    ATM328P_TIMER_0_PRECISION_TYPE,
    uint8_t,
    (uint8_t)&OCR0A, (uint8_t)&TCNT0,
    (uint8_t)&TIMSK0, (1 << OCIE0A),
    (uint8_t)&TIFR0, (1 << OCF0A)
  ) as HplAlarm0A;

  components new HplAtm328pAlarmC (
    ATM328P_TIMER_0_PRECISION_TYPE,
    uint8_t,
    (uint8_t)&OCR0B, (uint8_t)&TCNT0,
    (uint8_t)&TIMSK0, (1 << OCIE0B),
    (uint8_t)&TIFR0, (1 << OCF0B)
  ) as HplAlarm0B;

  components HplAtm328pAlarmIsr0P as Interrupts;

  components
    new Atm328pAlarmC (ATM328P_TIMER_0_PRECISION_TYPE, uint8_t, 1) as Alarm0A,
    new Atm328pAlarmC (ATM328P_TIMER_0_PRECISION_TYPE, uint8_t, 1) as Alarm0B;

  Alarm0A.HplAlarm -> HplAlarm0A;
  Alarm0B.HplAlarm -> HplAlarm0B;
  Alarm0A.Isr -> Interrupts.InterruptA;
  Alarm0B.Isr -> Interrupts.InterruptB;

  Alarm[0] = Alarm0A;
  Alarm[1] = Alarm0B;
}
