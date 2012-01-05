generic module HplAtm328pAlarmC(typedef precision_tag, typedef size_type @integer(), uint8_t OCREG, uint8_t CNTREG, uint8_t TIMSKREG, uint8_t TIMSK_BIT, uint8_t TIFREG, uint8_t TIFREG_BIT)
{
  provides interface HplAtm328pAlarm<precision_tag, size_type>;
}
implementation
{
  async command void HplAtm328pAlarm.start (size_type t)
  {
    atomic {
      *(size_type *)OCREG = t;
      *(uint8_t *)TIFREG |= TIFREG_BIT; /* clear compare interrupt flag */
      *(uint8_t *)TIMSKREG |= TIMSK_BIT; /* enable compare interrupt */
    }
  }

  async command void HplAtm328pAlarm.stop ()
  {
    *(uint8_t *)TIMSKREG &= ~TIMSK_BIT; /* disable compare interrupt */
  }

  async command bool HplAtm328pAlarm.isRunning ()
  {
    return *(uint8_t *)TIMSKREG & TIMSK_BIT;
  }

  async command size_type HplAtm328pAlarm.now ()
  {
    atomic return *(size_type *)CNTREG;
  }
}
