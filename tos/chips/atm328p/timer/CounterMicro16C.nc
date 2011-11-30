#include <Atm328pTimerConfig.h>
configuration CounterMicro16C
{
  provides interface Counter<TMicro, uint16_t>;
}
implementation
{
  components Atm328pCounterTimer1C;

#if ATM328P_TIMER_1_MICRO_DOWNSCALE == 0

  /* The prescaler can get us right onto micro second precision. */
  Counter = Atm328pCounterTimer1C;

#else

  /* The prescaler does not have the correct divisor. Apply a transform. */
  components new TransformCounterC (
    TMicro, uint16_t,
    ATM328P_TIMER_1_PRECISION_TYPE, uint16_t, ATM328P_TIMER_1_MICRO_DOWNSCALE,
    uint8_t) as Transform;
  Transform.CounterFrom -> Atm328pCounterTimer1C;

  Counter = Transform.Counter;

#endif

}
