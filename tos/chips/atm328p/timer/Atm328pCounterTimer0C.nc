#include <Atm328pTimerConfig.h>
configuration Atm328pCounterTimer0C
{
    provides interface Counter<ATM328P_TIMER_0_PRECISION_TYPE, uint8_t>;
}
implementation
{
    components
        new Atm328pTimerToCounter(ATM328P_TIMER_0_PRECISION_TYPE, uint8_t),
        HplAtm328pTimer0C as HplTimer;

    Atm328pTimerToCounter.Timer -> HplTimer;

    Counter = Atm328pTimerToCounter;
}
