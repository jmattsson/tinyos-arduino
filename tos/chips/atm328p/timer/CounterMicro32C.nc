#include <Atm328pTimerConfig.h>
configuration CounterMicro16C
{
  provides interface Counter<TMicro, uint32_t>;
}
implementation
{
  components Atm328pCounterTimer1C;

  components new TransformCounterC (
    TMicro, uint32_t,
    ATM328P_TIMER_1_PRECISION_TYPE, uint16_t, ATM328P_TIMER_1_DOWNSCALE,
    uint32_t) as Transform;
  Transform.CounterFrom -> Atm328pCounterTimer1C;

  Counter = Transform.Counter;
}
