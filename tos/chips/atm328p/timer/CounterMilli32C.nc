#include <Atm328pTimerConfig.h>
configuration CounterMilli32C
{
  provides interface Counter<TMilli, uint32_t>;
}
implementation
{
  components Atm328pCounterTimer0C;

#if ATM328P_TIMER_0_MILLI_DOWNSCALE == 0

  /* The prescaler can get us right onto millisecond precision. */
  Counter = Atm328pCounterTimer0C;

#else

  /* The prescaler does not have the correct divisor. Apply a transform. */
  components new TransformCounterC (
    TMilli, uint32_t,
    ATM328P_TIMER_0_PRECISION_TYPE, uint8_t, ATM328P_TIMER_0_MILLI_DOWNSCALE,
    uint32_t) as Transform;
  Transform.CounterFrom -> Atm328pCounterTimer0C;

  Counter = Transform.Counter;

#endif

}
