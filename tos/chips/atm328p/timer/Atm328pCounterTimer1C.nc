#include <Atm328pTimerConfig.h>
configuration Atm328pCounterTimer1C
{
    provides interface Counter<ATM328P_TIMER_1_PRECISION_TYPE, uint16_t>;
}
implementation
{
    components Atm328pCounterTimer1P, HplAtm328pTimer1C as HplTimer;
    Atm328pCounterTimer1P.Timer -> HplTimer;

    Counter = Atm328pCounterTimer1P;
}
