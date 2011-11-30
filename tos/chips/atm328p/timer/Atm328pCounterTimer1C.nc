#include <Atm328pTimerConfig.h>
configuration Atm328pCounterTimer1C
{
    provides interface Counter<ATM328P_TIMER_1_PRECISION_TYPE, uint16_t>;
}
implementation
{
    components
        new Atm328pTimerToCounter(ATM328P_TIMER_1_PRECISION_TYPE, uint16_t),
        HplAtm328pTimer1C as HplTimer;

    Atm328pTimerToCounter.Timer -> HplTimer;

    Counter = Atm328pTimerToCounter;
}
