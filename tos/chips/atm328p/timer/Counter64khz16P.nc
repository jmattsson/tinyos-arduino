module Counter64khz16P
{
    provides interface Counter<T64khz, uint16_t> as Counter;
    uses interface HplAtm328pTimer<uint16_t> as Timer;
}
implementation
{
    async command uint16_t Counter.get ()
    {
        return call Timer.get ();
    }

    async command bool Counter.isOverflowPending ()
    {
        return call Timer.test ();
    }

    async command void Counter.clearOverflow ()
    {
        call Timer.clear ();
    }

    async event void Timer.overflow ()
    {
        signal Counter.overflow ();
    }
}
