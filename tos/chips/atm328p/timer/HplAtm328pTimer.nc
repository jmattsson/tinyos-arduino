interface HplAtm328pTimer<size_type>
{
    async command size_type get ();
    async command void set (size_type val);

    async event void overflow ();

    // manual overflow control
    async command bool test ();
    async command void clear ();

    // clocking control
    async command void start ();
    async command void stop ();
}
