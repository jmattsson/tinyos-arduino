module BusyWaitMicroC
{
  provides interface BusyWait<TMicro,uint16_t>;
}
implementation
{
  async command void BusyWait.wait (uint16_t us)
  {
    if (!us)
      return;

    asm volatile (
      "again:"
      " sbiw %0,1\n\t"        /* 2 cycles */

      /* Assuming we're running on 16Mhz, we need to add 16-(2+2) NOPs */

      " nop\n\t"              /* 1 cycle  */
      " nop\n\t"              /* 1 cycle  */
      " nop\n\t"              /* 1 cycle  */
      " nop\n\t"              /* 1 cycle  */

      " nop\n\t"              /* 1 cycle  */
      " nop\n\t"              /* 1 cycle  */
      " nop\n\t"              /* 1 cycle  */
      " nop\n\t"              /* 1 cycle  */

      " nop\n\t"              /* 1 cycle  */
      " nop\n\t"              /* 1 cycle  */
      " nop\n\t"              /* 1 cycle  */
      " nop\n\t"              /* 1 cycle  */

      " brbc 1,again\n\t"     /* 2 cycles if not zero, else 1 cycle */
      :
      : "w" (us)
    );
  }
}
