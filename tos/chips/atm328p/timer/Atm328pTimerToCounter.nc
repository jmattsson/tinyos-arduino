generic module Atm328pTimerToCounter (typedef precision_type, typedef size_type)
{
    provides interface Counter<precision_type, size_type> as Counter;
    uses interface HplAtm328pTimer<size_type> as Timer;
}
implementation
{
    async command size_type Counter.get ()
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
