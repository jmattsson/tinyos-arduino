configuration Counter64khz16C
{
    provides interface Counter<T64khz, uint16_t>;
}
implementation
{
    components Counter64khz16P, HplAtm328pTimer1C as Timer64khzC;
    Counter64khz16P.Timer -> Timer64khzC;

    Counter = Counter64khz16P;
}
